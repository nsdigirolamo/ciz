const std = @import("std");

const Error = @import("error.zig").Error;
const Result = @import("main.zig").Result;

const Token = enum {
    // single character tokens
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,

    // One or two character tokens
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,

    // Literals
    IDENTIFIER,
    STRING,
    NUMBER,

    // Keywords
    AND,
    CLASS,
    ELSE,
    FALSE,
    FUN,
    FOR,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,

    // Misc
    EOF,
};

const Report = union(Result) {
    Error: Error,
    OK: struct {
        tokens: []const Token,
        source: []const u8,
    },
};

// TODO: Make scanner be responsible for the memory allocated to ArrayList

pub fn scan(allocator: std.mem.Allocator, source: []const u8) !Report {
    var tokens = std.ArrayList(Token).init(allocator);

    var current_source = source;
    while (current_source.len > 0) {
        const report = next(current_source);
        switch (report) {
            .Error => {
                tokens.deinit();
                return report;
            },
            .OK => |ok| {
                try tokens.appendSlice(ok.tokens);
                current_source = ok.source;
            },
        }
    }

    const sliced_tokens = try tokens.toOwnedSlice();
    return Report{ .OK = .{ .tokens = sliced_tokens, .source = current_source } };
}

fn next(source: []const u8) Report {
    const char = source[0];
    const token = switch (char) {
        '(' => Token.LEFT_PAREN,
        ')' => Token.RIGHT_PAREN,
        else => null,
    };

    if (token) |t| {
        return Report{ .OK = .{ .tokens = &[1]Token{t}, .source = source[1..] } };
    } else {
        return Report{ .Error = .{ .line = 0, .message = "Unknown character." } };
    }
}
