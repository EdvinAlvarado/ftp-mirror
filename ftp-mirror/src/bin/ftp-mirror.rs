use config;
use main_error::MainError;
use std::fs::File;
use std::io;
use std::path::Path;
use std::process::Command;
use std::sync::Arc;
use std::thread;
use thiserror::Error;

#[derive(Error, Debug)]
enum MirrorError {
    #[error("lftp exit with an error. See ouput:\n{0}")]
    FtpError(String),
    #[error("IO error when getting lftp output.")]
    CommandError(#[from] io::Error),
}

fn ftp_mirror<P: AsRef<Path> + Send>(ftp_des: P, ftp: &config::Ftp) -> Result<(), MirrorError> {
    let args = [
        "-c",
        &format!("\"open {};", ftp.ip),
        &format!("cd {};", ftp.path),
        &format!("lcd {}/{};", ftp_des.as_ref().display(), ftp.name),
        "mirror -c\"",
    ];
    let output = Command::new("lftp").args(args).output()?;
    
    println!(
        "Completed copy: {}\t->\t{}/{}",
        ftp.ip,
        ftp_des.as_ref().display(),
        ftp.name
    );
    
    match output.status.code() {
        Some(0) => Ok(()),
        _ => Err(MirrorError::FtpError(
            String::from_utf8_lossy(&output.stdout).into_owned(),
        )),
    }
}

fn main() -> Result<(), MainError> {
    let config_rdr = File::open(std::env::args().next().unwrap())?;
    let config: config::Config = serde_yaml::from_reader(config_rdr)?;
    let ftp_dir: Arc<Path> = config.dir.as_path().into();

    let mut threads = vec![];
    for ftp in config.ftps {
        let dir = ftp_dir.clone();
        let thread = thread::spawn(move || ftp_mirror(dir.as_ref(), &ftp));
        threads.push(thread);
    }

    for thread in threads {
        thread.join().unwrap()?;
    }

    Ok(())
}
