# Rust AI Coding Conventions

## 1. Architecture & Workflow (Type-First)
- Implement in strict order: (1) Data Structures (`struct`, `enum`) & Error Types -> (2) Trait Signatures -> (3) Unit Test Skeletons -> (4) Business Logic.
- Use `todo!()` for unimplemented function bodies when scaffolding types.

## 2. Ownership & Lifetimes (Borrow Checker Mitigation)
- Prefer **owned types** (`String`, `Vec<T>`) inside `struct` definitions over explicit lifetimes (`'a`), unless zero-copy parsing is strictly requested.
- For shared state across threads or async tasks, default to `Arc<T>` (or `Arc<RwLock<T>>` / `Arc<Mutex<T>>`).
- Prefer borrowing slices (`&str`, `&[T]`) in function parameters rather than `&String` or `&Vec<T>`.
- Clone judiciously (`Clone`) during initial implementation to satisfy the borrow checker; optimize allocations only after tests pass.

## 3. Error Handling
- **STRICT BAN**: Never use `.unwrap()` or `.expect()` in production code (allowed only inside `#[cfg(test)]`).
- Use `thiserror` for library/domain errors (`enum DomainError`) and `anyhow::Result<T>` for application-level handlers.
- Always propagate errors with `?` and attach context via `.context("...")` where appropriate.

## 4. Safety & Concurrency
- **STRICT BAN**: Do not use `unsafe` blocks unless explicitly instructed.
- Never hold a `std::sync::MutexGuard` across an `.await` point. Use `tokio::sync::Mutex` if the lock must span `.await`, or scope the synchronous lock inside a block `{ ... }` before awaiting.

## 5. Modern Crate Idioms (Anti-Hallucination)
- **Rust Edition**: 2024 (or 2021+). Use inline format args (`format!("{var}")`) and `let-else` statements (`let Some(x) = opt else { return Err(...); };`).
- **Axum (0.7 / 0.8+)**: Use `tokio::net::TcpListener::bind()` + `axum::serve(listener, app).await`. Never use `axum::Server::bind` (deprecated 0.6 syntax).
- **Clap (4.x)**: Always use the `#[derive(Parser)]` macro pattern, not the builder pattern.
