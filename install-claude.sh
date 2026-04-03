#!/bin/bash
# code-server 컨테이너 내부에서 실행하는 Claude Code CLI 설치 스크립트
# 사용법: docker exec -it code-server bash /home/coder/projects/install-claude.sh

set -e

echo "=== Node.js 설치 확인 ==="
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi
node -v
npm -v

echo "=== Claude Code CLI 설치 ==="
npm install -g @anthropic-ai/claude-code

echo "=== 설치 완료 ==="
echo "터미널에서 'claude' 명령어로 실행하세요"
echo "첫 실행 시 Anthropic API 키 또는 claude.ai 로그인이 필요합니다"
