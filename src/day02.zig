const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day02.txt");

fn readPolicies(allocator: *Allocator) !ArrayList(Policy) {
    var policies = ArrayList(Policy).init(allocator);
    var lines = std.mem.tokenize(input, "\n");
    while (lines.next()) |line| {
        try policies.append(try Policy.initFromString(line));
    }
    return policies;
}

const Policy = struct {
    min: u8,
    max: u8,
    char: u8,
    password: []const u8,

    pub fn initFromString(string: []const u8) !Policy {
        const min_end = std.mem.indexOfScalar(u8, string, '-').?;
        const min = try std.fmt.parseUnsigned(u8, string[0..min_end], 10);
        const max_start = min_end + 1;
        const max_end = max_start + std.mem.indexOfScalar(u8, string[max_start..], ' ').?;
        const max = try std.fmt.parseUnsigned(u8, string[max_start..max_end], 10);

        return Policy{
            .min = min,
            .max = max,
            .char = string[max_end + 1],
            .password = string[max_end + 4..],
        };
    }

    pub fn checkRule1(self: Policy) bool {
        var num_char: usize = 0;
        for (self.password) |c| {
            if (c == self.char) num_char += 1;
        }
        return self.min <= num_char and num_char <= self.max;
    }

    pub fn checkRule2(self: Policy) bool {
        return (self.password[self.min - 1] == self.char) != (self.password[self.max - 1] == self.char);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var policies = try readPolicies(&gpa.allocator);
    var part1: usize = 0;
    var part2: usize = 0;
    for (policies.items) |policy| {
        if (policy.checkRule1()) part1 += 1;
        if (policy.checkRule2()) part2 += 1;
    }
    print("part1: {}\n", .{part1});
    print("part2: {}\n", .{part2});
}

test "part1 example" {
    std.testing.expect((try Policy.initFromString("1-3 a: abcde")).checkRule1() == true);
    std.testing.expect((try Policy.initFromString("1-3 b: cdefg")).checkRule1() == false);
    std.testing.expect((try Policy.initFromString("2-9 c: ccccccccc")).checkRule1() == true);
}

test "part2 example" {
    std.testing.expect((try Policy.initFromString("1-3 a: abcde")).checkRule2() == true);
    std.testing.expect((try Policy.initFromString("1-3 b: cdefg")).checkRule2() == false);
    std.testing.expect((try Policy.initFromString("2-9 c: ccccccccc")).checkRule2() == false);
}
