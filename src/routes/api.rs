use std::sync::Arc;

use axum::Json;
use axum::extract::{OriginalUri, Query, State};

use crate::AppState;
use crate::db_client::{RepoFilter, RepoTotals};
use crate::types::JsonRes;

#[derive(Debug, serde::Serialize)]
pub struct ReposList {
  total_count: i32,
  total_stars: i32,
  total_forks: i32,
  total_views: i32,
  total_clones: i32,
  items: Vec<RepoTotals>,
}

pub async fn api_get_repos(
  State(state): State<Arc<AppState>>,
  OriginalUri(uri): OriginalUri,
) -> JsonRes<ReposList> {
  let qs: Query<RepoFilter> = Query::try_from_uri(&uri)?;
  let repos = state.get_repos_filtered(&qs).await?;

  let repos_list = ReposList {
    total_count: repos.len() as i32,
    total_stars: repos.iter().map(|r| r.stars).sum(),
    total_forks: repos.iter().map(|r| r.forks).sum(),
    total_views: repos.iter().map(|r| r.views_count).sum(),
    total_clones: repos.iter().map(|r| r.clones_count).sum(),
    items: repos,
  };

  Ok(Json(repos_list))
}
