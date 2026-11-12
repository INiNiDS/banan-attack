use axum::{Json, Router};
use axum::extract::State;
use axum::http::StatusCode;
use serde::{Deserialize, Serialize};
use serde_repr::{Deserialize_repr, Serialize_repr};
use std::sync::Arc;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize_repr, Deserialize_repr)]
#[repr(u8)]
enum Size {
    Small = 1,
    Medium = 2,
    Large = 3,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
struct Scene {
    size: Size,
    id: u32,
    tscn: String,
}

#[derive(Clone)]
struct AppState {
    s3_client: aws_sdk_s3::Client,
    bucket_name: String,
}

async fn create_scene_handler(
    State(state): State<Arc<AppState>>,
    Json(payload): Json<Scene>,
) -> Result<StatusCode, (StatusCode, String)> {
    let tscn = payload.tscn;
    let client = &state.s3_client;
    client
        .put_object()
        .bucket(&state.bucket_name)
        .key(format!("scenes/chunk_{}.tscn", payload.id))
        .body(tscn.into_bytes().into())
        .send()
        .await
        .map_err(|e| {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Failed to upload scene: {}", e),
            )
        })?;

    Ok(StatusCode::CREATED)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenvy::dotenv().ok();

    let s3_endpoint = std::env::var("S3_ENDPOINT").unwrap_or_else(|_| "http://localhost:9000".to_string());
    let bucket_name = std::env::var("S3_BUCKET").unwrap_or_else(|_| "scenes".to_string());

    let base_config = aws_config::defaults(aws_config::BehaviorVersion::latest())
        .endpoint_url(&s3_endpoint)
        .load()
        .await;
    let config = aws_sdk_s3::config::Builder::from(&base_config)
        .force_path_style(true)
        .build();
    let client = aws_sdk_s3::Client::from_conf(config);
    let state = AppState {
        s3_client: client,
        bucket_name,
    };
    let router = Router::new()
        .route("/scenes", axum::routing::post(create_scene_handler))
        .with_state(Arc::from(state));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await?;
    axum::serve(listener, router).await?;
    Ok(())
}
