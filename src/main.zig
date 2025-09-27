const std = @import("std");
const Allocator = std.mem.Allocator;
var stdin = std.fs.File.stdin().readerStreaming(&.{});

fn matchPattern(input_line: []const u8, pattern: []const u8) bool {
    if (pattern.len == 1) {
        return std.mem.indexOf(u8, input_line, pattern) != null;
    }
    const i: usize = 0;
    while (i < pattern.len) {
        switch (pattern[i]) {
            '\\' => return matchEscape(input_line, pattern, i + 1),
            '[' => return matchArray(input_line, pattern, i + 1),
            else => @panic("Unhandled pattern"),
        }
    }
    return false;
}

fn matchEscape(input_line: []const u8, pattern: []const u8, index: usize) bool {
    if (index >= pattern.len) return false;
    const esc = pattern[index];
    return switch (esc) {
        'd' => {
            for (input_line) |c| {
                if (std.ascii.isDigit(c)) return true;
            }
            return false;
        },
        'w' => {
            for (input_line) |c| {
                if (std.ascii.isAlphanumeric(c) or c == '_') return true;
            }
            return false;
        },
        else => false,
    };
}
fn matchArray(input_line: []const u8, pattern: []const u8, index: usize) bool {
    var end = index;
    for (pattern[index..]) |value| {
        switch (value) {
            ']' => break,
            else => {},
        }
        end += 1;
    }
    return std.mem.indexOfAny(u8, input_line, pattern[index..end]) != null;
}
pub fn main() !void {
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3 or !std.mem.eql(u8, args[1], "-E")) {
        std.debug.print("Expected first argument to be '-E'\n", .{});
        std.process.exit(1);
    }

    // You can use print statements as follows for debugging, they'll be visible when running tests.
    // std.debug.print("Logs from your program will appear here!\n", .{});

    var input_buffer: [1024]u8 = undefined;
    const input_len = try stdin.read(&input_buffer);
    const input_slice = input_buffer[0..input_len];
    // var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    // var gpa = debug_allocator.allocator();
    // defer debug_allocator.deinit();
    const pattern = args[2];
    if (matchPattern(input_slice, pattern)) {
        std.debug.print("matched", .{});
        std.process.exit(0);
    } else {
        std.debug.print("fail to match", .{});
        std.process.exit(1);
    }
}
