const std = @import("std");

const Result = @import("error.zig").Result;
const Error = @import("error.zig").Error;

const TokenKind = enum {
    // Single Character Tokens
    LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA, PERIOD, DASH,
    PLUS, SEMICOLON, SLASH, STAR, BANG, EQUAL, GREATER, LESS,
    // Double Character Tokens
    BANG_EQUAL, EQUAL_EQUAL, GREATER_EQUAL, LESS_EQUAL,
    // Literals
    IDENTIFIER, STRING, NUMBER,
    // Keywords
    AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER,
    THIS, TRUE, VAR, WHILE,
    // Utilities
    EOF,
};

const Token = struct {
    kind: TokenKind,
    value: []const u8,
};

pub const Report = union(Result) {
    Error: Error,
    OK: std.ArrayList(Token),
};

pub fn scan(allocator: std.mem.Allocator, source: []const u8) !Report {
    var tokens = std.ArrayList(Token).init(allocator);
    var next_source = source;
    var line: i32 = 0;
    while (next_source.len > 0) {
        if (source[0] == '\n') {
            next_source = next_source[1..];
            line += 1;
        } else if (next(next_source)) |token| {
            next_source = next_source[token.value.len..];
            try tokens.append(token);
        } else {
            tokens.deinit();
            return Report{
                .Error = Error{
                    .line = line,
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
        '(' => Token{ .kind = .LEFT_PAREN, .value = "(" },
        ')' => Token{ .kind = .RIGHT_PAREN, .value = ")" },
        '{' => Token{ .kind = .LEFT_BRACE, .value = "{" },
        '}' => Token{ .kind = .RIGHT_BRACE, .value = "}" },
        ',' => Token{ .kind = .COMMA, .value = "," },
        '.' => Token{ .kind = .PERIOD, .value = "." },
        '-' => Token{ .kind = .DASH, .value = "-" },
        '+' => Token{ .kind = .PLUS, .value = "+" },
        ';' => Token{ .kind = .SEMICOLON, .value = ";" },
        '/' => Token{ .kind = .SLASH, .value = "/" },
        '*' => Token{ .kind = .STAR, .value = "*" },
        '!' =>
            if (checkChars(source, "!="))
                Token{ .kind = .BANG_EQUAL, .value = "!=" }
            else
                Token{ .kind = .BANG, .value = "!" },
        '=' =>
            if (checkChars(source, "=="))
                Token{ .kind = .EQUAL_EQUAL, .value = "==" }
            else
                Token{ .kind = .EQUAL, .value = "=" },
        '>' =>
            if (checkChars(source, ">="))
                Token{ .kind = .GREATER_EQUAL, .value = ">=" }
            else
                Token{ .kind = .GREATER, .value = ">" },
        '<' =>
            if (checkChars(source, "<="))
                Token{ .kind = .LESS_EQUAL, .value = "<=" }
            else
                Token{ .kind = .LESS, .value = "<" },
        else => null,
    };
}

fn checkChars(source: []const u8, chars: []const u8) bool {
    return chars.len <= source.len and std.mem.eql(u8, source[0..chars.len], chars);
}
