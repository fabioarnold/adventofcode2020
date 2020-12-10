const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day10.txt");

fn loadNumbers(allocator: *Allocator, string: []const u8) !ArrayList(u64) {
    var numbers = ArrayList(u64).init(allocator);
    var tokens = std.mem.tokenize(string, "\r\n");
    while (tokens.next()) |token| {
        try numbers.append(try std.fmt.parseUnsigned(u64, token, 10));
    }
    return numbers;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    var numbers = try loadNumbers(allocator, input);
    defer numbers.deinit();

    try numbers.append(0); // need this for part2
    const u64asc = comptime std.sort.asc(u64);
    std.sort.sort(u64, numbers.items, {}, u64asc);
    try numbers.append(numbers.items[numbers.items.len - 1] + 3);
    var jolts = numbers.items;

    var count1: usize = 0;
    var count2: usize = 0;
    var count3: usize = 0;
    var prev: u64 = 0;
    for (jolts) |jolt, i| {
        if (i == 0) continue;
        switch (jolt - prev) {
            1 => count1 += 1,
            2 => count2 += 1,
            3 => count3 += 1,
            else => unreachable,
        }
        prev = jolt;
    }

    print("part1: {}\n", .{count1 * count3});

    var part2: u64 = 0;
    var counts = try allocator.alloc(u64, jolts.len);
    defer allocator.free(counts);
    std.mem.set(u64, counts, 0);

    counts[0] = 1;
    var i: usize = 1;
    while (i < jolts.len) : (i += 1) {
        if (jolts[i] - jolts[i - 1] <= 3) {
            counts[i] += counts[i - 1];
        }
        if (i > 1 and jolts[i] - jolts[i - 2] <= 3) {
            counts[i] += counts[i - 2];
        }
        if (i > 2 and jolts[i] - jolts[i - 3] <= 3) {
            counts[i] += counts[i - 3];
        }
    }
    part2 = counts[jolts.len - 1];

    print("part2: {}\n", .{part2});
}

const example1 =
\\16
\\10
\\15
\\5
\\1
\\11
\\7
\\19
\\6
\\12
\\4
;

const example2 =
\\28
\\33
\\18
\\42
\\31
\\14
\\46
\\20
\\48
\\47
\\24
\\23
\\49
\\45
\\19
\\38
\\39
\\11
\\1
\\32
\\25
\\35
\\8
\\17
\\7
\\9
\\4
\\2
\\34
\\10
\\3
;
