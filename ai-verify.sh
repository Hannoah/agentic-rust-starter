#!/usr/bin/env bash
set -e

echo "=== [1/2] Running cargo check ==="
cargo check --all-targets --message-format=short --quiet

echo "=== [2/2] Running cargo clippy ==="
# 초기 스캐폴딩(todo!() 사용) 단계에서는 마지막 -D clippy::todo 줄을 주석 처리
cargo clippy --all-targets --message-format=short --quiet -- \
    -D warnings \
    -D clippy::unwrap_used \
    -D clippy::expect_used \
    -D clippy::todo
