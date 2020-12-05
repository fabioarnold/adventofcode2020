const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day05.txt");

fn seatId(boarding_pass: []const u8) usize {
    var min: usize = 0;
    var max: usize = 127;
    for (boarding_pass[0..7]) |c| {
        const mid = (min + max) / 2;
        switch (c) {
            'F' => max = mid,
            'B' => min = mid + 1,
            else => unreachable
        }
    }
    const row = min;
    min = 0;
    max = 7;
    for (boarding_pass[7..10]) |c| {
        const mid = (min + max) / 2;
        switch (c) {
            'L' => max = mid,
            'R' => min = mid + 1,
            else => unreachable
        }
    }
    const col = min;
    return row * 8 + col;
}

fn maxSeat() usize {
    var max: usize = 0;
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line| {
        const seat_id = seatId(line);
        if (seat_id > max) max = seat_id;
    }
    return max;
}

fn missingSeat() usize {
    var map = [_]bool{false} ** (128 * 8);
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line| {
        const seat_id = seatId(line);
        map[seat_id] = true;
    }
    var i: usize = 0;
    while (!map[i]) : (i += 1) {}
    while (map[i]) : (i += 1) {}
    return i;
}

pub fn main() !void {
    print("part1: {}\n", .{maxSeat()});
    print("part2: {}\n", .{missingSeat()});
}

test "part1 example" {
    std.testing.expect(seatId("BFFFBBFRRR") == 567);
    std.testing.expect(seatId("FFFBBBFRRR") == 119);
    std.testing.expect(seatId("BBFFBBFRLL") == 820);
}
