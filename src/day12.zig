const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day12.txt");

const Facing = enum(u2) {
    East,
    South,
    West,
    North,
};

pub fn main() !void {
    var east: isize = 0;
    var north: isize = 0;
    var facing: Facing = .East;

    var lines = std.mem.tokenize(input, "\r\n");
    while (lines.next()) |line| {
        const num = try std.fmt.parseUnsigned(usize, line[1..], 10);
        const inum = @intCast(isize, num);
        switch (line[0]) {
            'N' => north += inum,
            'S' => north -= inum,
            'E' => east += inum,
            'W' => east -= inum,
            'L' => facing = @intToEnum(Facing, @enumToInt(facing) -% @intCast(u2, num / 90)),
            'R' => facing = @intToEnum(Facing, @enumToInt(facing) +% @intCast(u2, num / 90)),
            'F' => {
                switch (facing) {
                    .North => north += inum,
                    .South => north -= inum,
                    .East => east += inum,
                    .West => east -= inum,
                }
            },
            else => unreachable
        }
    }
    print("part1: {}\n", .{(try std.math.absInt(north)) + (try std.math.absInt(east))});

    east = 0;
    north = 0;
    var w_east: isize = 10;
    var w_north: isize = 1;

    lines.index = 0;
    while (lines.next()) |line| {
        const num = try std.fmt.parseUnsigned(usize, line[1..], 10);
        const inum = @intCast(isize, num);
        switch (line[0]) {
            'N' => w_north += inum,
            'S' => w_north -= inum,
            'E' => w_east += inum,
            'W' => w_east -= inum,
            'L' => {
                var i: usize = 0;
                while (i < num) : (i += 90) {
                    var tmp = w_east;
                    w_east = -w_north;
                    w_north = tmp;
                }
            },
            'R' => {
                var i: usize = 0;
                while (i < num) : (i += 90) {
                    var tmp = w_east;
                    w_east = w_north;
                    w_north = -tmp;
                }
            },
            'F' => {
                east += inum * w_east;
                north += inum * w_north;
            },
            else => unreachable
        }
    }
    print("part2: {}\n", .{(try std.math.absInt(north)) + (try std.math.absInt(east))});
}

const example =
\\F10
\\N3
\\F7
\\R90
\\F11
;
