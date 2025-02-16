pub const Result = enum { Error, OK };

pub const Error = struct {
    line: i32,
    message: []const u8,
};
