const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day14.txt");

fn part1(allocator: *Allocator) !void {
    var and_mask: u36 = 0;
    var or_mask: u36 = 0;
    var mem = try allocator.alloc(u36, 1 << 16);
    defer allocator.free(mem);
    std.mem.set(u36, mem, 0);

    var lines = std.mem.tokenize(input, "\r\n");
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line[0..4], "mask")) {
            var mask = line[7 .. 7 + 36];
            and_mask = 0b111111111111111111111111111111111111;
            or_mask = 0b000000000000000000000000000000000000;
            for (mask) |c, i| {
                const bit: u6 = 35 - @intCast(u6, i);
                switch (c) {
                    '0' => and_mask &= ~(@as(u36, 1) << bit),
                    '1' => or_mask |= @as(u36, 1) << bit,
                    else => {},
                }
            }
        } else if (std.mem.eql(u8, line[0..3], "mem")) {
            var token = std.mem.tokenize(line[4..], "] =");
            const address = try std.fmt.parseUnsigned(u16, token.next().?, 10);
            var value = try std.fmt.parseUnsigned(u36, token.next().?, 10);
            // apply masks
            value &= and_mask;
            value |= or_mask;
            mem[address] = value;
        }
    }

    var sum: u64 = 0;
    for (mem) |value| {
        sum += @as(u64, value);
    }
    print("part1: {}\n", .{sum});
}

fn enumerateAddresses(mask: []const u8, address: u36, addresses: *std.ArrayList(u36)) void {
    if (mask.len == 0) {
        addresses.append(address) catch unreachable;
    } else {
        const bit = @intCast(u6, mask.len - 1);
        switch (mask[0]) {
            '0' => enumerateAddresses(mask[1..], address, addresses),
            '1' => enumerateAddresses(mask[1..], address | @as(u36, 1) << bit, addresses),
            'X' => {
                enumerateAddresses(mask[1..], address & ~(@as(u36, 1) << bit), addresses);
                enumerateAddresses(mask[1..], address | @as(u36, 1) << bit, addresses);
            },
            else => {},
        }
    }
}

fn part2(allocator: *Allocator) !void {
    var mem = std.AutoHashMap(u64, u36).init(allocator); // if I use u36 as key, garbage data will be hashed
    defer mem.deinit();

    var mask: []const u8 = undefined;

    var lines = std.mem.tokenize(input, "\r\n");
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line[0..4], "mask")) {
            mask = line[7 .. 7 + 36];
        } else if (std.mem.eql(u8, line[0..3], "mem")) {
            var token = std.mem.tokenize(line[4..], "] =");
            const address = try std.fmt.parseUnsigned(u16, token.next().?, 10);
            var value = try std.fmt.parseUnsigned(u36, token.next().?, 10);
            var addresses = std.ArrayList(u36).init(allocator);
            defer addresses.deinit();
            enumerateAddresses(mask, address, &addresses);
            for (addresses.items) |a| {
                try mem.put(@as(u64, a), value);
            }
        }
    }

    var sum: u64 = 0;
    var iter = mem.iterator();
    while (iter.next()) |entry| {
        sum += @as(u64, entry.value);
    }
    print("part2: {}\n", .{sum});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    try part1(allocator);
    try part2(allocator);
}

const example =
\\mask = 000000000000000000000000000000X1001X
\\mem[42] = 100
\\mask = 00000000000000000000000000000000X0XX
\\mem[26] = 1
;