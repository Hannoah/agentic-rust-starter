# agentic-rust-starter

Rust 프로젝트 루트에 복사해서 바로 쓰는 **AI 코딩 최적화 템플릿**입니다.
[Aider](https://aider.chat)를 기준으로 만들었고, 규칙 파일(`CONVENTIONS.md`)과 치트시트는 다른 AI 코딩 도구에서도 그대로 쓸 수 있습니다.

목표는 두 가지입니다: **대여 검사기(Borrow Checker) 에러 줄이기**, **구버전 문법 환각(Hallucination) 막기**.

## 구성

| 파일 | 역할 |
|---|---|
| `CONVENTIONS.md` | AI 코딩 규칙: Type-First 작업 순서, 소유권 전략, 에러 처리, 최신 crate 관용구 |
| `.aider.conf.yml` | 세션 시작 시 규칙 파일을 읽기 전용으로 주입, 코드 수정마다 자동 린트 |
| `ai-verify.sh` | `cargo check` + `clippy`를 짧은 출력(`short`)으로 실행해 컨텍스트 낭비를 줄임 |
| `Cargo.toml` | `[lints]`로 `unsafe`, `unwrap`/`expect`, `dbg!`, 락 보유 중 `.await`를 컴파일 단계에서 차단 |
| `clippy.toml` | 테스트 코드(`#[cfg(test)]`)에서는 `unwrap`/`expect` 허용 |
| `docs/ai_context/crate_cheatsheet.md` | thiserror, Axum 0.8, Clap 4 최신 패턴 모음 |

## 사용법

1. 위 파일들을 Rust 프로젝트 루트에 복사합니다. 이미 `Cargo.toml`이 있다면 `[lints.*]` 블록과 필요한 의존성만 병합하세요.
2. `chmod +x ai-verify.sh`
3. 프로젝트 루트에서 `aider`를 실행합니다. 설정이 자동으로 적용됩니다.
4. 작업은 타입부터 시작합니다.
   > 먼저 `src/types.rs`와 `src/error.rs`의 구조체 및 시그니처만 설계해 줘

   컴파일이 통과한 뒤에 구현을 지시합니다.

## 알아둘 점

- `ai-verify.sh`는 `-D clippy::todo`를 켜 둡니다. `CONVENTIONS.md`의 1단계(`todo!()`로 뼈대 작성) 중에는 이 줄을 주석 처리하세요.
- `edition = "2024"`는 Rust 1.85 이상이 필요합니다. 구버전이면 `"2021"`로 바꾸세요.
- Aider 외 도구(Claude Code, Cursor 등)를 쓴다면 `CONVENTIONS.md` 내용을 해당 도구의 지침 파일(`CLAUDE.md`, `.cursor/rules` 등)에 옮겨 쓰면 됩니다.

## 라이선스

[MIT](LICENSE)
