const std = @import("std");

const Result = @import("error.zig").Result;
const Error = @import("error.zig").Error;

const Token = struct {
    kind: enum {
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
        BANG,
        BANG_EQUAL,
        EQUAL,
        EQUAL_EQUAL,
        GREATER,
        GREATER_EQUAL,
        LESS,
        LESS_EQUAL,
        IDENTIFIER,
        STRING,
        NUMBER,
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
        EOF,
    },
    value: []const u8,
};

pub const Report = union(Result) {
    Error: Error,
    OK: std.ArrayList(Token),
};

pub fn scan(allocator: std.mem.Allocator, source: []const u8) !Report {
    var tokens = std.ArrayList(Token).init(allocator);
    var next_source = source;
    while (next_source.len > 0) {
        if (next(next_source)) |token| {
            next_source = next_source[token.value.len..];
            try tokens.append(token);
        } else {
            tokens.deinit();
            return Report{
                .Error = Error{
                    .line = 0,
                    .message = "unexpected character"
                }
            };
        }
    }
    return Report{ .OK = tokens };
}

fn next(source: []const u8) ?Token {
    const char = source[0];
    return switch (char) {
        '(' => Token{ .kind = .LEFT_PAREN, .value = "("},
        ')' => Token{ .kind = .RIGHT_PAREN, .value = ")"},
        '{' => Token{ .kind = .LEFT_BRACE, .value = "{"},
        '}' => Token{ .kind = .RIGHT_BRACE, .value = "}"},
        ',' => Token{ .kind = .COMMA, .value = ","},
        '.' => Token{ .kind = .DOT, .value = "."},
        '-' => Token{ .kind = .MINUS, .value = "-"},
        '+' => Token{ .kind = .PLUS, .value = "+"},
        ';' => Token{ .kind = .SEMICOLON, .value = ";"},
        '*' => Token{ .kind = .STAR, .value = "*"},
        else => null,
    };
}

