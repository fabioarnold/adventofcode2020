const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;

const EOL = '\n';

fn readPolicies(allocator: *Allocator) !ArrayList([]const u8) {
    var entries = ArrayList([]const u8).init(allocator);

    const file = try std.fs.cwd().openFile("input/day02.txt", .{});
    defer file.close();
    const reader = file.reader();
    var line_buf: [100]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&line_buf, EOL)) |line| {
        const policy = try allocator.dupe(u8, std.mem.trim(u8, line[0..], std.ascii.spaces[0..]));
        try entries.append(policy);
    }

    return entries;
}

const Policy = struct {
    low: u8,
    high: u8,
    char: u8,
    password: []const u8,

    pub fn fromString(policy: []const u8) Policy {
        var i: usize = 0;
        var low = policy[i] - '0';
        i += 1;
        if (policy[i] != '-') {
            low *= 10;
            low += policy[i] - '0';
            i += 1;
        }
        i += 1;
        var high = policy[i] - '0';
        i += 1;
        if (policy[i] != ' ') {
            high *= 10;
            high += policy[i] - '0';
            i += 1;
        }
        i += 1;
        const char = policy[i];
        i += 3;
        const password = policy[i..];

        return .{
            .low = low,
            .high = high,
            .char = char,
            .password = password,
        };
    }
};

fn validPasswords(policies: []const []const u8) u32 {
    var num_valid: u32 = 0;

    for (policies) |policy| {
        const p = Policy.fromString(policy);

        var num_char: u32 = 0;
        for (p.password) |c| {
            if (c == p.char) num_char += 1;
        }

        if (p.low <= num_char and num_char <= p.high) {
            num_valid += 1;
        }
    }

    return num_valid;
}

fn validPasswords2(policies: []const []const u8) u32 {
    var num_valid: u32 = 0;

    for (policies) |policy| {
        const p = Policy.fromString(policy);

        if ((p.password[p.low - 1] == p.char) != (p.password[p.high - 1] == p.char)) {
            num_valid += 1;
        }
    }

    return num_valid;
}

fn part1(allocator: *Allocator) !void {
    var policies = try readPolicies(allocator);
    print("part1: {}\n", .{validPasswords(policies.items)});
}

fn part2(allocator: *Allocator) !void {
    var policies = try readPolicies(allocator);
    print("part2: {}\n", .{validPasswords2(policies.items)});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    try part1(allocator);
    try part2(allocator);
}

test "part1 example" {
    const policies = [_][]const u8 {
        "1-3 a: abcde",
        "1-3 b: cdefg",
        "2-9 c: ccccccccc",
    };
    std.testing.expect(validPasswords(policies[0..]) == 2);
}

test "part2 example" {
    const policies = [_][]const u8 {
        "1-3 a: abcde",
        "1-3 b: cdefg",
        "2-9 c: ccccccccc",
    };
    std.testing.expect(validPasswords2(policies[0..]) == 1);
}
