const std = @import("std");

const Report = @import("main.zig").Report;

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

const Scanned = struct {
    tokens: []const Token,
    next_source: []const u8,
};

pub const Scanner = struct {
    allocator: std.mem.Allocator,
    tokens: std.ArrayList(Token),

    pub fn init(allocator: std.mem.Allocator) Scanner {
        return Scanner{
            .allocator = allocator,
            .tokens = std.ArrayList(Token).init(allocator)
        };
    }

    pub fn deinit(self: *Scanner) void {
        self.tokens.deinit();
    }

    pub fn scan(self: *Scanner, source: []const u8) !Report {
        var next_source = source;
        while (next_source.len > 0) {
            if (next(next_source)) |scanned| {
                next_source = scanned.next_source;
                try self.tokens.appendSlice(scanned.tokens);
            } else {
                return Report{ .Error = .{ .line = 0, .message = "Unknown character" } };
            }
        }
        return Report{ .OK = .{} };
    }
};

fn next(source: []const u8) ?Scanned {
    const char = source[0];
    const scanned = switch (char) {
        '(' => Token.LEFT_PAREN,
        ')' => Token.RIGHT_PAREN,
        else => null,
    };

    if (scanned) |token| {
        return Scanned{ .tokens = &[1]Token{token}, .next_source = source[1..] };
    } else {
        return null;
    }
}

