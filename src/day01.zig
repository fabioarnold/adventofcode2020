const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;

const EOL = '\n';

pub fn readInput(allocator: *Allocator) !ArrayList(u32) {
    var entries = ArrayList(u32).init(allocator);

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const reader = file.reader();
    var line_buf: [20]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&line_buf, EOL)) |line| {
        try entries.append(try std.fmt.parseInt(u32, std.mem.trim(u8, line[0..], std.ascii.spaces[0..]), 10));
    }

    return entries;
}

pub fn findPair(entries: []const u32, sum: u32) ![2]u32 {
    var i: usize = 0;
    while (i < entries.len) : (i += 1) {
        var j: usize = i + 1;
        while (j < entries.len) : (j += 1) {
            if (entries[i] + entries[j] == sum) {
                return [2]u32{ entries[i], entries[j] };
            }
        }
    }
    return error.PairNotFound;
}

pub fn part1(allocator: *Allocator) !void {
    const entries = try readInput(allocator);
    const pair = try findPair(entries.items, 2020);

    std.log.info("part1 {}", .{pair[0] * pair[1]});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    try part1(allocator);
}

test "part1 example" {
    const entries = [_]u32{
        1721,
        979,
        366,
        299,
        675,
        1456,
    };
    const pair = try findPair(entries[0..], 2020);
    std.testing.expect((pair[0] == 1721 and pair[1] == 299) or (pair[1] == 1721 and pair[0] == 299));
    std.testing.expect(pair[0] * pair[1] == 514579);
}
