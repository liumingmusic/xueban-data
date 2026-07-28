#!/bin/sh
# 一键推送内容数据到 GitHub（SSH）
# 前提：GitHub 已建空仓库 liumingmusic/xueban-data，且本机 SSH key 已配（ssh -T git@github.com 可认证）
set -e
REPO=liumingmusic/xueban-data
DIR=$(cd "$(dirname "$0")" && pwd)
cd "$DIR"

git init -q 2>/dev/null || true
git add -A
git commit -q -m "update content data $(date +%Y-%m-%dT%H:%M)" || echo "（无变更，跳过提交）"

git remote get-url origin >/dev/null 2>&1 || git remote add origin "git@github.com:$REPO.git"
git push -u origin main 2>&1 || git push -u origin HEAD:main

echo ""
echo "✅ 已推送至 https://github.com/$REPO"
echo "   小程序将从 https://raw.githubusercontent.com/$REPO/main/ 读取数据"
