package main

import (
	"fmt"
	"ftp-mirror/libs/config"
	"ftp-mirror/libs/errhandl"
	"os"
	"os/exec"
	"sync"

	"gopkg.in/yaml.v3"
)

func ftpMirror(ftp_des string, ftp config.Ftp) error {
	cmd := fmt.Sprintf("lftp -c \"open %s; cd %s; lcd %s/%s; mirror -c\"", ftp.Ip, ftp.Path, ftp_des, ftp.Name)
	output, err := exec.Command("zsh", "-c", cmd).Output()

	if err != nil {
		fmt.Println(output)
		return err
	}
	res := fmt.Sprintf("Completed copy: %s\t->\t%s/%s", ftp.Ip, ftp_des, ftp.Name)
	fmt.Println(res)

	return nil
}

func main() {
	var conf config.Config
	yf, err := os.ReadFile(os.Args[1])
	errhandl.Expect(err)
	err = yaml.Unmarshal(yf, &conf)
	errhandl.Expect(err)

	var wg sync.WaitGroup
	for _, ftp := range conf.Ftps {
		wg.Add(1)
		go func(ftp_des string, ftp config.Ftp) {
			defer wg.Done()
			ftpMirror(ftp_des, ftp)
		}(conf.Dir, ftp)
	}
	wg.Wait()
}
