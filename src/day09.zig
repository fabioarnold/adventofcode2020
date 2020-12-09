const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day09.txt");
const input_preamble_len = 25;

fn loadNumbers(allocator: *Allocator, string: []const u8) !ArrayList(u64) {
    var numbers = ArrayList(u64).init(allocator);
    var tokens = std.mem.tokenize(string, "\r\n");
    while (tokens.next()) |token| {
        try numbers.append(try std.fmt.parseUnsigned(u64, token, 10));
    }
    return numbers;
}

fn checkPreamble(preamble: []u64, sum: u64) bool {
    var i: usize = 0;
    while (i < preamble.len - 1) : (i += 1) {
        var j: usize = i + 1;
        while (j < preamble.len) : (j += 1) {
            if (preamble[i] + preamble[j] == sum) {
                return true;
            }
        }
    }
    return false;
}

fn findInvalid(numbers: []u64, preamble_len: usize) usize {
    for (numbers[preamble_len..]) |num, i| {
        if (!checkPreamble(numbers[i..i + preamble_len], num)) {
            return preamble_len + i;
        }
    }
    return 0;
}

fn findRange(numbers: []u64, invalid: u64) u64 {
    var i: usize = 0;
    while (i < numbers.len - 1) : (i += 1) {
        var sum = numbers[i];
        var smallest = numbers[i];
        var largest = numbers[i];
        var j: usize = i + 1;
        while (sum < invalid) : (j += 1) {
            sum += numbers[j];
            smallest = std.math.min(smallest, numbers[j]);
            largest = std.math.max(largest, numbers[j]);
        }
        if (sum == invalid) {
            return smallest + largest;
        }
    }
    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;

    var numbers = try loadNumbers(allocator, input);
    defer numbers.deinit();
    const i = findInvalid(numbers.items, input_preamble_len);
    print("part1: {}\n", .{numbers.items[i]});
    print("part2: {}\n", .{findRange(numbers.items[0..i], numbers.items[i])});
}

const example_preamble_len = 5;
const example =
\\35
\\20
\\15
\\25
\\47
\\40
\\62
\\55
\\65
\\95
\\102
\\117
\\150
\\182
\\127
\\219
\\299
\\277
\\309
\\576
;