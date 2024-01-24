# Dependencies is systemd, lftp, rust

INSTALL_DIR=/usr/local
SYSTEMD_DIR=/etc/systemd/system
BUILD_DIR=ftp-mirror/target

CONFIG=ftp-mirror-config.yaml
SERVICE=ftp-mirror.service
TIMER=ftp-mirror.timer
EXE=ftp-mirror
CLI=ftp-mirror-cli

# testing
deb: build
	mkdir -p debian/ftp-mirror$(INSTALL_DIR)/etc/ftp-mirror
	mkdir -p debian/ftp-mirror$(INSTALL_DIR)/bin/
	cp files/$(CONFIG) debian/ftp-mirror$(INSTALL_DIR)/etc/ftp-mirror/$(CONFIG)
	cp files/$(SERVICE) debian/ftp-mirror$(INSTALL_DIR)/etc/ftp-mirror/$(SERVICE)
	cp files/$(TIMER) debian/ftp-mirror$(INSTALL_DIR)/etc/ftp-mirror/$(TIMER)
	cp $(BUILD_DIR)/release/$(EXE) debian/ftp-mirror$(INSTALL_DIR)/bin/$(EXE)
	cp $(BUILD_DIR)/release/$(CLI) debian/ftp-mirror$(INSTALL_DIR)/bin/$(CLI)
	cd debian; dpkg-deb --build ftp-mirror

# testing
debinstall: deb
	cd debian; dpkg -i ftp-mirror.deb

vsftpd:
	#TODO add all ftp configs
	echo "vsftpd: ALL" >> /etc/hosts.allow 
	echo "#Change IP address range!" >> /etc/hosts.allow
	echo "#vsftpd: 10.0.0.0/255.255.255.0" >> /etc/hosts.allow
	nvim /etc/hosts.allow
	systemctl enable --now vsftpd.service

package: 
	tar cvfz ftp-mirror.tar.gz files/* ftp-mirror/src/* ftp-mirror/Cargo.toml makefile

build:
	cd ftp-mirror; cargo build -r

install: build
	mkdir $(INSTALL_DIR)/etc/ftp-mirror
	cp files/$(CONFIG) $(INSTALL_DIR)/etc/ftp-mirror/$(CONFIG)
	cp files/$(SERVICE) $(INSTALL_DIR)/etc/ftp-mirror/$(SERVICE)
	cp files/$(TIMER) $(INSTALL_DIR)/etc/ftp-mirror/$(TIMER)
	cp $(BUILD_DIR)/release/$(EXE) $(INSTALL_DIR)/bin/$(EXE)
	cp $(BUILD_DIR)/release/$(CLI) $(INSTALL_DIR)/bin/$(CLI)


clean:
	rm -r $(BUILD_DIR)/release/

enable:
	ln -s $(INSTALL_DIR)/etc/ftp-mirror/$(SERVICE) $(SYSTEMD_DIR)/$(SERVICE)
	ln -s $(INSTALL_DIR)/etc/ftp-mirror/$(TIMER) $(SYSTEMD_DIR)/$(TIMER)
	systemctl enable --now $(TIMER)

uninstall: disable remove

disable:
	systemctl stop $(TIMER) 
	systemctl disable $(TIMER) 
	rm $(SYSTEMD_DIR)/$(SERVICE)

remove:
	rm -r $(INSTALL_DIR)/etc/ftp-mirror
	rm -r $(INSTALL_DIR)/bin/ftp-mirror
	rm -r $(INSTALL_DIR)/bin/ftp-mirror-cli
	rm /root/.netrc
