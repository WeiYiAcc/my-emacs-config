#!/usr/bin/env bash
# install.sh — 把 projects/ 下的 .dir-locals.el 软链接到实际项目目录
# 用法: bash install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHQ_BASE="$HOME/ghq/github.com/WeiYiAcc"

link_dir_locals() {
  local project="$1"
  local target_dir="$2"
  local src="$REPO_DIR/projects/$project/.dir-locals.el"
  local dst="$target_dir/.dir-locals.el"

  if [[ ! -d "$target_dir" ]]; then
    echo "⚠️  跳过 $project：目录不存在 ($target_dir)"
    return
  fi

  if [[ -L "$dst" ]]; then
    echo "✓  $project：已有软链接，跳过"
    return
  fi

  if [[ -f "$dst" ]]; then
    echo "⚠️  $project：已有 .dir-locals.el（非软链接），备份为 .dir-locals.el.bak"
    mv "$dst" "${dst}.bak"
  fi

  ln -s "$src" "$dst"
  echo "✓  $project：已链接 $dst → $src"
}

link_dir_locals "subsidy-2026"  "$GHQ_BASE/subsidy-2026"
link_dir_locals "my-tools"      "$GHQ_BASE/my-tools"
link_dir_locals "ariadne-fact"  "$GHQ_BASE/ariadne-fact"

echo ""
echo "完成。在 Emacs 中打开项目文件时，dir-locals 会自动生效。"
echo "首次加载时 Emacs 会询问是否信任，选 '!' 永久信任。"
