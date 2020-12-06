const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day06.txt");

pub fn groupAnswersAnyone(string: []const u8) !usize {
    var sum: usize = 0;
    var iter = std.mem.split(string, "\n\n");
    while (iter.next()) |group| {
        var bitset: u26 = 0;
        var lines = std.mem.tokenize(group, "\n");
        while (lines.next()) |line| {
            for (line) |c| {
                if (c < 'a' or c > 'z') return error.InvalidChar;
                const bit = c - 'a';
                bitset |= @as(@TypeOf(bitset), 1) << @intCast(u5, bit);
            }
        }
        sum += @popCount(@TypeOf(bitset), bitset);
    }
    return sum;
}


pub fn groupAnswersEveryone(string: []const u8) !usize {
    var sum: usize = 0;
    var iter = std.mem.split(string, "\n\n");
    while (iter.next()) |group| {
        var bitset: u26 = 0b11111111111111111111111111;
        var lines = std.mem.tokenize(group, "\n");
        while (lines.next()) |line| {
            var bits: u26 = 0;
            for (line) |c| {
                if (c < 'a' or c > 'z') return error.InvalidChar;
                const bit = c - 'a';
                bits |= @as(@TypeOf(bitset), 1) << @intCast(u5, bit);
            }
            bitset &= bits;
        }
        sum += @popCount(@TypeOf(bitset), bitset);
    }
    return sum;
}

pub fn main() !void {
    print("part1: {}\n", .{try groupAnswersAnyone(input)});
    print("part1: {}\n", .{try groupAnswersEveryone(input)});
}

const example =
\\abc
\\
\\a
\\b
\\c
\\
\\ab
\\ac
\\
\\a
\\a
\\a
\\a
\\
\\b
;

test "part1 example" {
    std.testing.expect((try groupAnswersAnyone(example)) == 11);
}

test "part2 example" {
    std.testing.expect((try groupAnswersEveryone(example)) == 6);
}