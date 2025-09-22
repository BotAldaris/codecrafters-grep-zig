const std = @import("std");
var stdin = std.fs.File.stdin().readerStreaming(&.{});

fn matchPattern(input_line: []const u8, pattern: []const u8) bool {
    if (pattern.len == 1) {
        return std.mem.indexOf(u8, input_line, pattern) != null;
    }
    if (std.mem.eql(u8, pattern, "\\d")) {
        for (input_line) |value| {
            if (std.ascii.isDigit(value)) {
                return true;
            }
        }
    } else if (std.mem.eql(u8, pattern, "\\w")) {
        for (input_line) |value| {
            if (std.ascii.isAlphanumeric(value) or '_' == value) {
                return true;
            }
        }
    } else {
        @panic("Unhandled pattern");
    }
    return false;
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

    const pattern = args[2];
    if (matchPattern(input_slice, pattern)) {
        std.debug.print("matched", .{});
        std.process.exit(0);
    } else {
        std.debug.print("fail to match", .{});
        std.process.exit(1);
    }
}
