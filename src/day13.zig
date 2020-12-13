const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day13.txt");

pub fn main() !void {
    var lines = std.mem.tokenize(input, "\r\n");
    const arrival = try std.fmt.parseUnsigned(usize, lines.next().?, 10);
    var buses = std.mem.tokenize(lines.next().?, ",");

    var part1: usize = undefined;
    var part2: usize = 0;
    var min_wait: usize = std.math.maxInt(usize);
    var period: usize = 1;
    var i: usize = 0;
    while (buses.next()) |bus| {
        if (bus[0] != 'x') {
            const id = try std.fmt.parseUnsigned(usize, bus, 10);
            const wait = id - (arrival % id);
            if (wait < min_wait) {
                min_wait = wait;
                part1 = id * wait;
            }
            while ((part2 + i) % id != 0) { part2 += period; }
            period *= id;
        }
        i += 1;
    }

    print("part1: {}\n", .{part1});
    print("part2: {}\n", .{part2});
}