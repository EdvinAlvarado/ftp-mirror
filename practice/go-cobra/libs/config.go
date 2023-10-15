package config

type Ftp struct {
	Name     string `yaml:"name"`
	Ip       string `yaml:"ip"`
	Path     string `yaml:"path"`
	User     string `yaml:"user"`
	Password string `yaml:"password"`
}

type Config struct {
	Dir  string `yaml:"dir"`
	Ftps []Ftp  `yaml:"ftps"`
}
