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

fn seesOccupied(grid: []u8, sx: usize, sy: usize, dx: i32, dy: i32, blocking_floor: bool) bool {
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
            else => { if (blocking_floor) return false; },
        }
    }
}

fn applyRules(in: []u8, out: []u8, blocking_floor: bool, tolerance: usize) void {
    var y: usize = 0;
    while (y < h) : (y += 1) {
        var x: usize = 0;
        while (x < w) : (x += 1) {
            var occupied: usize = 0;
            var dx: i32 = -1;
            while (dx <= 1) : (dx += 1) {
                var dy: i32 = -1;
                while (dy <= 1) : (dy += 1) {
                    if (dx == 0 and dy == 0) continue;
                    if (seesOccupied(in, x, y, dx, dy, blocking_floor)) occupied += 1;
                }
            }

            const i = y * w + x;
            switch (in[i]) {
                'L' => {if (occupied == 0) out[i] = '#';},
                '#' => {if (occupied >= tolerance) out[i] = 'L';},
                else => {}
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

    var part: usize = 1;
    while (part <= 2) : (part += 1) {
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
            if (part == 1) applyRules(buf0, buf1, true, 4) else  applyRules(buf0, buf1, false, 5);
            const occupied = std.mem.count(u8, buf1, "#");
            if (occupied == prev_occupied) {
                print("part{}: {}\n", .{part, occupied});
                break;
            }
            prev_occupied = occupied;
        }
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