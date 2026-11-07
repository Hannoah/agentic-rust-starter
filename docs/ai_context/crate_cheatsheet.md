# Modern Rust Crate Patterns Reference

## 1. Error Handling (`thiserror` + `anyhow`)
```rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum AppError {
    #[error("Database failure: {0}")]
    DbError(#[from] std::io::Error),
    #[error("Invalid input for field `{field}`: {reason}")]
    Validation { field: String, reason: String },
}

pub type AppResult<T> = Result<T, AppError>;
```

## 2. Axum 0.7+ / 0.8+ Server & State Pattern
```rust
use axum::{extract::{Path, State}, routing::get, Json, Router};
use std::sync::Arc;
use tokio::net::TcpListener;

#[derive(Clone)]
pub struct AppState {
    pub db_pool: Arc<String>,
}

pub async fn run_server(state: AppState) -> anyhow::Result<()> {
    let app = Router::new()
        .route("/items/{id}", get(get_item)) // Axum 0.8 path syntax (0.7 uses /:id)
        .with_state(state);

    let listener = TcpListener::bind("0.0.0.0:3000").await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn get_item(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<String>, String> {
    Ok(Json(format!("Item {id} from {}", state.db_pool)))
}
```

## 3. Clap 4.x Derive Pattern
```rust
use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(version, about)]
pub struct Cli {
    #[arg(short, long, env = "APP_CONFIG")]
    pub config: Option<String>,

    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    Serve {
        #[arg(short, long, default_value_t = 8080)]
        port: u16,
    },
}
```
