# Dependencies is python v3, systemd, go, lftp, and zsh
# New FTP servers can be added in the config.yaml file. 
# Remember to rerun setup.sh when changing config.yaml.

INSTALL_DIR=/opt/bioquell-ftp-copier
SYSTEMD_DIR=/etc/systemd/system

dependencies: debian vsftpd

install: build enable clean

uninstall: disable remove


debian:
	apt install vsftpd zsh golang python3 python3-is-python git lftp ftp neovim

vsftpd:
	#TODO add all ftp configs
	echo "vsftpd: ALL" >> /etc/hosts.allow 
	echo "#Change IP address range!" >> /etc/hosts.allow
	echo "#vsftpd: 10.0.0.0/255.255.255.0" >> /etc/hosts.allow
	nvim /etc/hosts.allow
	systemctl enable --now vsftpd.service

build:
	mkdir $(INSTALL_DIR)
	cp opt/* $(INSTALL_DIR)
	cd bioquell-go; go run gopkg.in/yaml.v3; go build -ldflags '-s -w'
	cp bioquell-go/bioquell-ftp $(INSTALL_DIR)
	$(INSTALL_DIR)/setup.sh
	chmod 600 ~/.netrc

clean:
	rm bioquell-go/bioquell-ftp

enable:
	ln -s $(INSTALL_DIR)/bioquell-ftp-copier.service $(SYSTEMD_DIR)/bioquell-ftp-copier.service
	ln -s $(INSTALL_DIR)/bioquell-ftp-copier.timer $(SYSTEMD_DIR)/bioquell-ftp-copier.timer
	systemctl enable --now bioquell-ftp-copier.timer

disable:
	systemctl stop bioquell-ftp-copier.timer
	systemctl disable bioquell-ftp-copier.timer
	rm $(SYSTEMD_DIR)/bioquell-ftp-copier.service

remove:
	rm -r $(INSTALL_DIR)
	rm ~/.netrc
