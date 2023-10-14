const std = @import("std");
const lib = @import("lib.zig");
const yaml = @import("yaml");

fn ftp_mirror(allocator: std.mem.Allocator, config: lib.Config) !void {
    const stdout = std.io.getStdOut().writer();

    var process_list = std.ArrayList(std.ChildProcess).init(allocator);
    defer process_list.deinit();

    for (config.ftps) |ftp| {
        const cmd = try std.fmt.allocPrint(allocator, "lftp -c \\\"open {s}; cd {}; lcd {}/{}; mirror -c \"", .{ ftp.ip, ftp.path, config.dir, ftp.name });
        const ret = std.ChildProcess.spawn(cmd);
        stdout.print("id: {} - Started mirroring: {}\t->\t{}/{}", .{ ret.id, ftp.ip, config.dir, ftp.name });
        try process_list.append(ret);
    }

    for (process_list.items) |proc| {
        const id = proc.id;
        try proc.wait();
        try stdout.print("id: {} - Completed mirroring", .{id});
    }
}

pub fn main() !void {
    //const stdin = std.io.getStdIn().reader();

    const arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = std.process.args();
    _ = args.skip();
    const conf_filepath = try args.next();

    const yf = try std.fs.cwd().openFile(conf_filepath, .{});
    var ys = try yf.readToEndAlloc(allocator, 2048);
    yf.close();

    for (std.mem.splitAny(u8, ys, "\n")) |line| {
        std.debug.print("{s}", line);
    }

    //var yf = try yaml.Yaml.load(allocator, file);
    //defer yf.deinit();

    //try ftp_mirror(allocator, config);

}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
