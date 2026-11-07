# agentic-rust-starter

**AI 코딩 에이전트가 Rust를 짤 때 반복하는 실수를 막아주는 복사-붙여넣기 템플릿.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Rust](https://img.shields.io/badge/rust-1.85%2B-orange.svg)

## 왜 필요한가

AI에게 Rust를 시키면 같은 실수가 반복됩니다.

| 문제 | 증상 | 이 템플릿의 대응 |
|---|---|---|
| **대여 검사기 에러** | 라이프타임 `'a`를 덕지덕지 붙이다가 컴파일이 더 꼬임 | 구조체는 소유 타입 기본, 공유 상태는 `Arc`, 초기엔 `clone` 허용 |
| **구버전 문법 환각** | `axum::Server::bind`, 존재하지 않는 API, 옛날 Clap 빌더 | 규칙 파일 + 최신 패턴 치트시트를 매 세션 자동 주입 |
| **편법으로 컴파일 통과** | `.unwrap()`, `unsafe`, `dbg!`로 에러를 덮음 | `Cargo.toml` `[lints]`로 컴파일 단계에서 차단 |
| **긴 에러 로그** | 컴파일러 출력이 컨텍스트를 잡아먹음 | `--message-format=short`로 압축 |

규칙을 "부탁"하는 데서 끝나지 않고, **린트로 강제하고 자동 피드백 루프로 되돌려 보내는 것**이 핵심입니다.

## 동작 방식

```
 aider 시작
    │  .aider.conf.yml 이 읽기 전용 컨텍스트로 주입
    │  ├─ CONVENTIONS.md                  (규칙)
    │  ├─ Cargo.toml                      (의존성·린트)
    │  └─ docs/ai_context/crate_cheatsheet.md  (최신 API 패턴)
    ▼
 AI가 코드 수정
    ▼
 auto-lint → ./ai-verify.sh → cargo check + clippy (-D warnings)
    │  실패: 짧은 에러가 AI에게 돌아가 자동 수정
    ▼  통과
 /test → cargo test --quiet
```

## 빠른 시작

**방법 1 — 한 줄 설치.** 내 Rust 프로젝트 루트에서 실행합니다. 이미 있는 파일은 덮어쓰지 않습니다.

```bash
curl -fsSL https://raw.githubusercontent.com/Hannoah/agentic-rust-starter/main/install.sh | bash
aider
```

**방법 2 — 템플릿으로 새 프로젝트 만들기.** 이 페이지 위쪽의 **Use this template** 버튼을 누르세요.

**방법 3 — ZIP.** **Code → Download ZIP**으로 받아 파일을 프로젝트 루트에 복사하고 `chmod +x ai-verify.sh`를 실행하세요.

처음 작업은 **타입부터** 시킵니다.

> 먼저 `src/types.rs`와 `src/error.rs`의 구조체 및 시그니처만 설계해 줘

컴파일이 통과하면 그다음에 구현을 지시합니다(`CONVENTIONS.md` 1번의 Type-First 순서).

### 기존 프로젝트에 적용

`Cargo.toml`은 통째로 덮어쓰지 말고 아래 부분만 병합하세요.

```toml
[lints.rust]
unsafe_code = "forbid"
unused_must_use = "deny"

[lints.clippy]
unwrap_used = "deny"
expect_used = "deny"
dbg_macro = "deny"
await_holding_lock = "deny"
large_futures = "warn"
needless_pass_by_value = "warn"
```

규칙에서 권장하는 `thiserror`, `anyhow`가 없다면 `cargo add thiserror anyhow`.

## 구성 파일

| 파일 | 역할 |
|---|---|
| [`CONVENTIONS.md`](CONVENTIONS.md) | 작업 순서(Type-First), 소유권, 에러 처리, 안전·동시성, 최신 crate 관용구 |
| [`.aider.conf.yml`](.aider.conf.yml) | 규칙 파일 자동 주입, 수정마다 `ai-verify.sh` 실행, `/test` 연동 |
| [`ai-verify.sh`](ai-verify.sh) | `cargo check` + `clippy`를 압축 출력으로 실행. 프로젝트 전체를 검사 |
| [`install.sh`](install.sh) | 한 줄 설치 스크립트. 기존 파일은 덮어쓰지 않음 |
| [`Cargo.toml`](Cargo.toml) | 편법 차단 린트와 기본 의존성(tokio, serde, anyhow, thiserror, tracing) |
| [`clippy.toml`](clippy.toml) | 테스트 코드에서만 `unwrap`/`expect` 허용 |
| [`docs/ai_context/crate_cheatsheet.md`](docs/ai_context/crate_cheatsheet.md) | thiserror, Axum 0.8, Clap 4 최신 패턴 |

## 무엇이 차단되나

| 코드 | 결과 |
|---|---|
| 일반 코드의 `.unwrap()` / `.expect()` | 컴파일 에러 (`#[cfg(test)]`에서는 허용) |
| `unsafe { ... }` | 컴파일 에러 (`forbid`) |
| `dbg!()` 남김 | 컴파일 에러 |
| `std::sync::MutexGuard`를 쥔 채 `.await` | 컴파일 에러 |
| `fn f(s: &String)` 같은 파라미터 | `clippy::ptr_arg` 경고 → `-D warnings`로 에러 처리 |
| 값을 불필요하게 소유로 받는 파라미터 | `needless_pass_by_value` 경고 |

## 커스터마이즈

- **스캐폴딩 단계에서 `todo!()`를 쓰고 싶다면:** `ai-verify.sh`의 `-D clippy::todo` 줄을 주석 처리하세요. 규칙의 1단계(`todo!()`로 뼈대 작성)와 충돌합니다.
- **Windows:** aider는 `lint-cmd`를 cmd.exe로 실행하므로 `./ai-verify.sh`는 동작하지 않습니다. 그래서 `bash ai-verify.sh`로 지정했습니다. Git Bash 등 `bash`가 PATH에 있어야 합니다. 또 aider가 설정 파일을 cp949로 읽기 때문에 **`.aider.conf.yml`에는 한글 주석을 쓰지 마세요**(파싱 실패).
- **Edition:** `Cargo.toml`의 `edition = "2024"`는 Rust 1.85 이상이 필요합니다. 구버전이면 `"2021"`.
- **규칙 추가:** `CONVENTIONS.md`는 AI가 매 세션 읽는 파일입니다. 프로젝트 고유 규칙(사용 중인 DB 크레이트 등)을 여기에 추가하고, 자주 틀리는 API는 치트시트에 예제로 넣는 것이 효과적입니다.
- **다른 AI 도구:** 규칙의 본문은 도구에 종속적이지 않습니다. Claude Code는 `CLAUDE.md`, Cursor는 `.cursor/rules/*.mdc`, Copilot은 `.github/copilot-instructions.md`에 `CONVENTIONS.md` 내용을 옮겨 쓰면 됩니다. `ai-verify.sh`는 어떤 도구에서도 수동 검증 스크립트로 쓸 수 있습니다.

## 한계

- 린트는 위반을 막을 뿐, 설계 품질까지 보장하지는 않습니다.
- 치트시트는 작성 시점(Axum 0.8, Clap 4, thiserror 2)의 패턴입니다. 의존성 메이저 버전을 올리면 함께 갱신하세요.
- `.aider.conf.yml`은 Aider 설정 형식입니다. 다른 도구에서는 쓰이지 않습니다.

## 라이선스

[MIT](LICENSE)
