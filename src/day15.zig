const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
//const input = @embedFile("../input/day15.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;

    const input = [_]u64{ 16,1,0,18,12,14,19 };
    for ([_]usize{2020, 30000000}) |stop, part| {
        var map = std.AutoHashMap(u64, usize).init(allocator);
        defer map.deinit();

        for (input[0..input.len-1]) |num, j| {
            try map.put(num, j);
        }
        var i = input.len;
        var num = input[i - 1];
        while (i < stop) : (i += 1) {
            const age = if (map.get(num)) |j| i - j - 1 else 0;
            try map.put(num, i - 1);
            num = age;
        }

        print("part{} {}\n", .{part + 1, num});
    }
}
