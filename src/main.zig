const std = @import("std");

pub fn main() !void {
    if (std.os.argv.len > 2) {
        std.debug.print("Usage: jlox [script]\n", .{});
        std.process.exit(64);
    } else if (std.os.argv.len == 2) {
        const path = std.mem.span(std.os.argv[1]);
        try runFile(path);
    } else {
        try runPrompt();
    }
}

fn runFile(path: []const u8) !void {
    // Get allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    // Open source code file.
    const source_file = try std.fs.cwd().openFile(path, .{});
    defer source_file.close();

    // Read the file into a buffer.
    const stat = try source_file.stat();
    const buffer = try source_file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    // Run the code.
    run(buffer);
}

fn runPrompt() !void {
    // TODO: Write the interactive shell.
}

fn run(source: []const u8) void {
    var lines = std.mem.splitAny(u8, source, "\r\n");
    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
