pub const Ftp = struct {
    name: []u8,
    ip: []u8,
    path: []u8,
    user: []u8,
    password: []u8,
};

pub const Config = struct {
    dir: []u8,
    ftps: []Ftp,
};
