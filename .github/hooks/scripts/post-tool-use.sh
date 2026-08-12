#!/bin/bash
# PostToolUse Hook — Log significant tool results and run formatters

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")
TOOL_INPUT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin).get('tool_input',{})))" 2>/dev/null || echo "{}")
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

# After file edits, run formatter if applicable
case "$TOOL_NAME" in
  create_file|replace_string_in_file|edit_notebook_file)
    FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('filePath', d.get('path','')))" 2>/dev/null || echo "")
    
    if [ -n "$FILE_PATH" ]; then
      # Run ruff on Python files
      if [[ "$FILE_PATH" == *.py ]]; then
        if command -v ruff &> /dev/null; then
          ruff format "$FILE_PATH" 2>/dev/null || true
          ruff check --fix "$FILE_PATH" 2>/dev/null || true
        fi
      fi
      
      # Run prettier on JS/TS files
      if [[ "$FILE_PATH" == *.ts ]] || [[ "$FILE_PATH" == *.tsx ]] || [[ "$FILE_PATH" == *.js ]] || [[ "$FILE_PATH" == *.jsx ]]; then
        if command -v npx &> /dev/null; then
          npx prettier --write "$FILE_PATH" 2>/dev/null || true
        fi
      fi
    fi
    ;;
esac

echo '{"continue": true}'
