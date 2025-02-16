const std = @import("std");

const Result = @import("error.zig").Result;
const Error = @import("error.zig").Error;
const scanner = @import("scanner.zig");

const Report = union {
    scan_report: scanner.Report
};

pub fn main() !void {
    if (std.os.argv.len != 2) {
        try std.io.getStdOut().writeAll("Usage: jlox [script]\n");
        std.process.exit(64);
    }

    const err = try runFile(std.mem.span(std.os.argv[1]));

    if (err) |e| {
        try std.io.getStdErr().writer().print("[line {d}] Error: {s}\n", .{ e.line, e.message });
    } else {
        try std.io.getStdOut().writeAll("Success.\n");
    }
}

fn runFile(path: []const u8) !?Error {
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

    // Scan the buffer
    const report = try scanner.scan(allocator, buffer);
    switch (report) {
        .Error => |err| {
            return err;
        },
        .OK => |tokens| {
            for (tokens.items) |token| {
                try std.io.getStdErr().writer().print("Token: {s}\n", .{token.value});
            }
            tokens.deinit();
            return null;
        }
    }

    // Run the code.
    // return try run(buffer);
}

// fn runPrompt() !Report {
//     var buffer: [1024]u8 = undefined;
//     while (true) {
//         try std.io.getStdOut().writeAll("> ");
//         const line = (try std.io.getStdIn().reader().readUntilDelimiterOrEof(&buffer, '\n')).?;
//         const result = try run(line);
//         if (result == .Error) return result;
//     }
//     return Report{ .OK = .{} };
// }

// fn run(source: []const u8) !Report {
//     var lines = std.mem.splitAny(u8, source, "\r\n");
//     while (lines.next()) |line| {
//         try std.io.getStdOut().writer().print("{s}\n", .{line});
//     }
//     return Report{ .OK = .{} };
// }
