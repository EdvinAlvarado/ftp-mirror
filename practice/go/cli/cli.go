package cli

import (
	"fmt"
	"ftp-mirror/libs/config"
	"ftp-mirror/libs/errhandl"
	"os"
	"os/exec"
	"path"

	"gopkg.in/yaml.v3"
)

func setupDir(conf config.Config) error {
	for _, ftp := range conf.Ftps {
		lcd := path.Join(conf.Dir, ftp.Name)
		output, err := exec.Command("mkdir", lcd).Output()
		if err != nil {
			fmt.Println(output)
		}
		fmt.Printf("Created directory: %s", lcd)
	}
	return nil
}

func writeNetrc(ftps []config.Ftp) error {
	content := ""
	for _, ftp := range ftps {
		content += fmt.Sprintf("machine %s\nlogin %s\npassword %s\n\n", ftp.Ip, ftp.User, ftp.Password)
	}
	return os.WriteFile("/root/.netrc", []byte(content), 0600)
}

func main() {
	yf, err := os.ReadFile(os.Args[1])
	errhandl.Expect(err)

	var conf config.Config
	err = yaml.Unmarshal(yf, &conf)
	errhandl.Expect(err)

	setupDir(conf)
	writeNetrc(conf.Ftps)
}
