#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOCS_DIR="$ROOT_DIR/Docs"

HIGH_MMD="$DOCS_DIR/组件依赖关系图-高层.mmd"
DETAIL_MMD="$DOCS_DIR/组件依赖关系图-详细.mmd"

HIGH_SVG="$DOCS_DIR/组件依赖关系图-高层.svg"
DETAIL_SVG="$DOCS_DIR/组件依赖关系图-详细.svg"

HIGH_PDF="$DOCS_DIR/组件依赖关系图-高层.pdf"
DETAIL_PDF="$DOCS_DIR/组件依赖关系图-详细.pdf"

if ! command -v mmdc >/dev/null 2>&1; then
    echo "error: mermaid-cli not found."
    echo "install with: npm install -g @mermaid-js/mermaid-cli"
    exit 1
fi

render_diagram() {
    local input_file="$1"
    local svg_output="$2"
    local pdf_output="$3"

    echo "rendering: $(basename "$input_file")"
    mmdc -i "$input_file" -o "$svg_output" -t neutral -b white -w 2200
    mmdc -i "$input_file" -o "$pdf_output" -t neutral -b white -w 2200 -f
}

render_diagram "$HIGH_MMD" "$HIGH_SVG" "$HIGH_PDF"
render_diagram "$DETAIL_MMD" "$DETAIL_SVG" "$DETAIL_PDF"

echo "done:"
echo "  $HIGH_SVG"
echo "  $HIGH_PDF"
echo "  $DETAIL_SVG"
echo "  $DETAIL_PDF"
