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
        consumed: i32,
    },
};

pub fn scan(source: []const u8) Report {
    return scanForToken(source);
}

pub fn scanForToken(source: []const u8) Report {
    const char = source[0];
    const token = switch (char) {
        '(' => Token.LEFT_PAREN,
        else => {
            return Report{ .Error = .{ .line = 0, .message = "unknown character" } };
        },
    };
    const tokens = [1]Token{token};

    return Report{ .OK = .{ .tokens = &tokens, .consumed = 1 } };
}
