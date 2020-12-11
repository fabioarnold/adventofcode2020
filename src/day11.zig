const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day11.txt");

fn loadLines(allocator: *Allocator, string: []const u8) !ArrayList([]const u8) {
    var lines = ArrayList([]const u8).init(allocator);
    var tokens = std.mem.tokenize(string, "\r\n");
    while (tokens.next()) |token| {
        try lines.append(token);
    }
    return lines;
}

fn printGrid(buf: []u8) void {
    var y: usize = 0;
    while (y < h) : (y += 1) {
        print("{}\n", .{buf[y * w .. y * w + w]});
    }
}

fn isOccupied(grid: []u8, x: i32, y: i32) bool {
    if (x < 0 or y < 0 or x >= w or y >= h) return false;
    const safe_x = @intCast(usize, x);
    const safe_y = @intCast(usize, y);
    return grid[safe_y * w + safe_x] == '#';
}

fn applyRules(in: []u8, out: []u8) void {
    var y: i32 = 0;
    while (y < h) : (y += 1) {
        var x: i32 = 0;
        while (x < w) : (x += 1) {
            var occupied: usize = 0;
            if (isOccupied(in, x - 1, y - 1)) occupied += 1;
            if (isOccupied(in, x - 1, y)) occupied += 1;
            if (isOccupied(in, x - 1, y + 1)) occupied += 1;
            if (isOccupied(in, x, y + 1)) occupied += 1;
            if (isOccupied(in, x + 1, y + 1)) occupied += 1;
            if (isOccupied(in, x + 1, y)) occupied += 1;
            if (isOccupied(in, x + 1, y - 1)) occupied += 1;
            if (isOccupied(in, x, y - 1)) occupied += 1;

            const i = @intCast(usize, y) * w + @intCast(usize, x);
            if (in[i] == 'L' and occupied == 0) {
                out[i] = '#';
            }
            if (in[i] == '#') {
                if (occupied >= 4) out[i] = 'L';
            }
        }
    }
}

fn seesOccupied(grid: []u8, sx: usize, sy: usize, dx: i32, dy: i32) bool {
    var x = @intCast(i32, sx);
    var y = @intCast(i32, sy);
    while (true) {
        x += dx;
        y += dy;
        if (x < 0 or y < 0 or x >= w or y >= h) return false;
        const safe_x = @intCast(usize, x);
        const safe_y = @intCast(usize, y);
        switch (grid[safe_y * w + safe_x]) {
            '#' => return true,
            'L' => return false,
            else => {},
        }
    }
}

fn applyRules2(in: []u8, out: []u8) void {
    var y: usize = 0;
    while (y < h) : (y += 1) {
        var x: usize = 0;
        while (x < w) : (x += 1) {
            var occupied: usize = 0;
            if (seesOccupied(in, x, y, -1, -1)) occupied += 1;
            if (seesOccupied(in, x, y, -1, 0)) occupied += 1;
            if (seesOccupied(in, x, y, -1, 1)) occupied += 1;
            if (seesOccupied(in, x, y, 0, 1)) occupied += 1;
            if (seesOccupied(in, x, y, 1, 1)) occupied += 1;
            if (seesOccupied(in, x, y, 1, 0)) occupied += 1;
            if (seesOccupied(in, x, y, 1, -1)) occupied += 1;
            if (seesOccupied(in, x, y, 0, -1)) occupied += 1;

            const i = y * w + x;
            if (in[i] == 'L' and occupied == 0) {
                out[i] = '#';
            }
            if (in[i] == '#') {
                if (occupied >= 5) out[i] = 'L';
            }
        }
    }
}

var w: usize = undefined;
var h: usize = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    var lines = try loadLines(allocator, input);
    defer lines.deinit();

    w = lines.items[0].len;
    h = lines.items.len;

    var buf0 = try allocator.alloc(u8, w * h);
    defer allocator.free(buf0);
    for (lines.items) |line, i| {
        std.mem.copy(u8, buf0[w * i..], line[0..w]);
    }
    var buf1 = try allocator.dupe(u8, buf0);
    defer allocator.free(buf1);

    var prev_occupied = std.mem.count(u8, buf0, "#");
    while (true) {
        std.mem.copy(u8, buf0, buf1);
        applyRules(buf0, buf1);
        const occupied = std.mem.count(u8, buf1, "#");
        if (occupied == prev_occupied) {
            print("part1: {}\n", .{occupied});
            break;
        }
        prev_occupied = occupied;
    }

    for (lines.items) |line, i| {
        std.mem.copy(u8, buf0[w * i..], line[0..w]);
    }
    std.mem.copy(u8, buf1, buf0);
    prev_occupied = std.mem.count(u8, buf0, "#");
    while (true) {
        std.mem.copy(u8, buf0, buf1);
        applyRules2(buf0, buf1);
        const occupied = std.mem.count(u8, buf1, "#");
        if (occupied == prev_occupied) {
            print("part2: {}\n", .{occupied});
            break;
        }
        prev_occupied = occupied;
    }
}

const example =
\\L.LL.LL.LL
\\LLLLLLL.LL
\\L.L.L..L..
\\LLLL.LL.LL
\\L.LL.LL.LL
\\L.LLLLL.LL
\\..L.L.....
\\LLLLLLLLLL
\\L.LLLLLL.L
\\L.LLLLL.LL
;