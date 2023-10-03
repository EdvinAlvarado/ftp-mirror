use clap::{Parser, Subcommand};
use config;
use main_error::MainError;
use std::{
    error::Error,
    fs::File,
    io::{self, Write},
    path::PathBuf,
    process::Command, rc::Rc,
};

fn setup_dir(config: &config::Config) -> Result<(), io::Error> {
    for ftp in &config.ftps {
        let dir = format!("{}/{}", config.dir.display(), ftp.name);
        Command::new("mkdir").arg(dir).output()?;
    }
    Ok(())
}

fn write_netrc(ftps: &Vec<config::Ftp>) -> Result<(), Box<dyn Error>> {
	let netrc_path = "/root/.netrc";
    let mut netrc = File::create(netrc_path)?;
    for ftp in ftps {
        write!(netrc, "machine {}\n", ftp.ip)?;
        write!(netrc, "login {}\n", ftp.user)?;
        write!(netrc, "password {}\n", ftp.password)?;
    }
	Command::new("chmod").args(["600", netrc_path]).output()?;
    Ok(())
}

/// Configures and enable ftp-mirror service.
#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    /// Path to config file.
    #[arg(short, long, default_value = "/etc/ftp-mirror/ftp-mirror-config.yaml")]
    config: PathBuf,
    /// Enable and start service with the specified config.
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// setups the netrc, timer, and service.
    Setup,
}

fn main() -> Result<(), MainError> {
    let args = Args::parse();

    let config_rdr = File::open(args.config)?;
    let config: config::Config = serde_yaml::from_reader(config_rdr)?;

    match args.command {
        Some(Commands::Setup) => {
            setup_dir(&config)?;
            write_netrc(&config.ftps)?;
        }
        None => unreachable!(),
    }

    Ok(())
}
