#!/usr/bin/env bash
# Integrity check for llm-rag-knowledge-graph.
# Runs Gates 0, 4, 5 from the bulletproof publishing contract.
#
# Gate 0: every claim in docs/claim-evidence.md must be marked verified.
# Gate 4: zero occurrences of private identifiers.
# Gate 5: zero secret-like tokens outside whitelisted files.
# Artifact-specific: wiki-node count, chronicle count, retrieval example runs.

set -euo pipefail

cd "$(dirname "$0")/.."

fail=0
green() { printf '\033[32m%s\033[0m\n' "$1"; }
red()   { printf '\033[31m%s\033[0m\n' "$1"; }

echo "[Gate 0] claim-evidence mapping..."
if grep -Eq '^\| .* \| .* \| ☐ \|$' docs/claim-evidence.md; then
  red "FAIL: unverified claims in docs/claim-evidence.md (look for | ☐ | rows)"
  fail=1
else
  green "OK: all claim-table rows marked verified"
fi

echo "[Gate 4] identifier grep (private names / clients / domains)..."
# Narrow, unique tokens only. Generic English words ('replacement', 'laid off')
# are excluded because they recur pedagogically in any engineering writing.
if grep -riE \
  'sirrista|saacash|aman0101|ATATT3|xoxe|xoxp|Olga|Arun|Thinh|Hudson|Anida|Vladimir|Sirish|Om Prakash|dev\.querylah|bhandari\.aman0101|taksha|daxa|querylah' \
  --exclude-dir=.git \
  --exclude=integrity-check.sh \
  --exclude=claim-evidence.md \
  . ; then
  red "FAIL: identifier leak"
  fail=1
else
  green "OK: no private identifiers"
fi

echo "[Gate 5] secret grep..."
# Narrow to assignment-style and known secret prefixes. Prose discussion of
# 'token'/'secret'/'api key' in markdown is allowed.
hits=$(grep -riE \
  '(sk-[a-zA-Z0-9]{20,}|sk-ant-[a-zA-Z0-9_-]{20,}|ghp_[a-zA-Z0-9]{20,}|xoxb-[0-9a-zA-Z-]{20,}|xoxp-[0-9a-zA-Z-]{20,}|ATATT3[a-zA-Z0-9]{20,}|AKIA[A-Z0-9]{16}|[A-Z_]+_(KEY|TOKEN|SECRET|PASSWORD)=[^\s]+)' \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude='*.env.example' \
  --exclude=integrity-check.sh \
  . || true)
if [[ -n "$hits" ]]; then
  red "FAIL: possible secret(s) detected — review manually:"
  echo "$hits"
  fail=1
else
  green "OK: no secret patterns"
fi

echo "[Artifact-specific] wiki concept-page count..."
# Concept pages = all wiki/**/*.md EXCLUDING index.md, log.md, README.md
concept_count=$(find wiki -type f -name '*.md' \
  ! -name 'index.md' ! -name 'log.md' ! -name 'README.md' | wc -l)
if [[ "$concept_count" -ne 5 ]]; then
  red "FAIL: expected 5 wiki concept pages, found $concept_count"
  fail=1
else
  green "OK: 5 wiki concept pages"
fi

echo "[Artifact-specific] wiki category count..."
category_count=$(find wiki -mindepth 1 -maxdepth 1 -type d | wc -l)
if [[ "$category_count" -ne 2 ]]; then
  red "FAIL: expected 2 wiki categories, found $category_count"
  fail=1
else
  green "OK: 2 wiki categories"
fi

echo "[Artifact-specific] every category has index.md..."
missing_idx=0
for d in wiki/*/; do
  if [[ ! -f "$d/index.md" ]]; then
    red "FAIL: $d missing index.md"
    missing_idx=1
  fi
done
if [[ "$missing_idx" -eq 0 ]]; then
  green "OK: every category has index.md"
else
  fail=1
fi

echo "[Artifact-specific] sample chronicle count..."
chron_count=$(find chronicle/examples -type f -name '*.md' | wc -l)
if [[ "$chron_count" -lt 2 ]]; then
  red "FAIL: expected >=2 sample chronicles, found $chron_count"
  fail=1
else
  green "OK: $chron_count sample chronicles"
fi

echo "[Artifact-specific] chronicle frontmatter required fields..."
missing_field=0
for f in chronicle/examples/*.md; do
  for field in '^date:' '^session:' '^topic:' '^title:' '^summary:' '^status:' '^prev:' '^next:'; do
    if ! grep -q "$field" "$f"; then
      red "FAIL: $f missing required frontmatter field matching $field"
      missing_field=1
    fi
  done
done
if [[ "$missing_field" -eq 0 ]]; then
  green "OK: sample chronicles have required frontmatter fields"
else
  fail=1
fi

echo "[Artifact-specific] wiki-link resolution (every [[link]] must resolve)..."
# Extract every wiki-link from wiki/**/*.md and chronicle/**/*.md, check that
# a matching file exists somewhere under wiki/. Skips links inside fenced code
# blocks and inline backticks (those render as literal text in markdown, not
# as links — a `[[placeholder]]` in prose is documentation, not a broken link).
unresolved=$(python3 - <<'PY'
import re, pathlib
root = pathlib.Path('.')
wiki = root / 'wiki'
link_re = re.compile(r'\[\[([^\]|#]+)(?:\|[^\]]*)?(?:#[^\]]*)?\]\]')
sources = list(wiki.rglob('*.md')) + list((root / 'chronicle').rglob('*.md'))
missing = []

def strip_code_spans(text: str) -> str:
    # Remove fenced code blocks (```...```), then inline code spans (`...`).
    text = re.sub(r'```.*?```', '', text, flags=re.DOTALL)
    text = re.sub(r'`[^`\n]+`', '', text)
    return text

for src in sources:
    body = strip_code_spans(src.read_text(encoding='utf-8'))
    for m in link_re.finditer(body):
        target = m.group(1).strip()
        if '/' in target:
            candidate = wiki / f'{target}.md'
            ok = candidate.is_file()
        else:
            ok = bool(list(wiki.rglob(f'{target}.md')))
        if not ok:
            missing.append(f'{src}: [[{target}]]')
for line in missing:
    print(line)
PY
)
if [[ -n "$unresolved" ]]; then
  red "FAIL: unresolved wiki-links:"
  echo "$unresolved"
  fail=1
else
  green "OK: every [[wiki-link]] resolves"
fi

echo "[Artifact-specific] retrieval example runs..."
if ! python3 scripts/wiki_traverse.py python/decorators --depth 2 > /dev/null; then
  red "FAIL: wiki_traverse.py did not run cleanly"
  fail=1
else
  green "OK: wiki_traverse.py python/decorators --depth 2 runs"
fi

echo "[Artifact-specific] retrieval example emits valid JSON..."
if ! python3 scripts/wiki_traverse.py rag/chunking-strategies --depth 1 --format json | python3 -m json.tool > /dev/null; then
  red "FAIL: wiki_traverse.py --format json did not emit valid JSON"
  fail=1
else
  green "OK: wiki_traverse.py --format json valid"
fi

echo
if [[ "$fail" -ne 0 ]]; then
  red "INTEGRITY CHECK FAILED"
  exit 1
fi
green "ALL GATES GREEN"
