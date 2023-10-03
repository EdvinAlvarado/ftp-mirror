use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Config {
    pub dir: PathBuf,
    pub ftps: Vec<Ftp>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Ftp {
    pub name: String,
    pub ip: String,
    pub path: String,
    pub user: String,
    pub password: String,
}
