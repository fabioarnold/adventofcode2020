const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day19.txt");

var rules: [133][]const u8 = undefined;

const Key = struct {
    start: usize,
    len: usize,
    rule: usize,
};
var cache: std.AutoHashMap(Key, bool) = undefined;

fn matchSeq(message: []const u8, start: usize, rule_seq: []const u8) bool {
    if (message.len == 0 and rule_seq.len == 0) return true;
    if (message.len == 0 or rule_seq.len == 0) return false;

    var t = std.mem.tokenize(rule_seq, " ");
    const rule_no = std.fmt.parseUnsigned(usize, t.next().?, 10) catch unreachable;
    const rule_rest = t.rest();
    var i: usize = 1;
    while (i <= message.len) : (i += 1) {
        const b = match(message[0..i], start, rule_no);
        if (b and matchSeq(message[i..], start + i, rule_rest)) {
            return true;
        }
    }
    return false;
}

fn match(message: []const u8, start: usize, rule_no: usize) bool {
    if (cache.get(Key{.start = start, .len = message.len, .rule = rule_no})) |ret|
        return ret;

    var ret = false;
    const rule = rules[rule_no];
    if (rule[0] == '"') {
        ret = message[0] == rule[1] and message.len == 1;
    } else {
        var options = std.mem.split(rule, " | ");
        while (options.next()) |rule_seq| {
            if (matchSeq(message, start, rule_seq)) {
                ret = true;
                break;
            }
        }
    }

    cache.put(Key{.start = start, .len = message.len, .rule = rule_no}, ret) catch unreachable;
    return ret;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    cache = std.AutoHashMap(Key, bool).init(allocator);
    defer cache.deinit();

    var s = std.mem.split(input, "\n\n");
    var rules_block = s.next().?;
    var message_block = s.next().?;

    var lines = std.mem.tokenize(rules_block, "\n");
    while (lines.next()) |line| {
        const colon_pos = std.mem.indexOfScalar(u8, line, ':').?;
        const rule_no = try std.fmt.parseUnsigned(usize, line[0..colon_pos], 10);
        rules[rule_no] = line[colon_pos+2..];
    }

    var part: usize = 1;
    while (part <= 2) : (part += 1) {
        if (part == 2) {
            rules[8] = "42 | 42 8";
            rules[11] = "42 31 | 42 11 31";
        }
        var matches: usize = 0;
        var messages = std.mem.tokenize(message_block, "\n");
        while (messages.next()) |message| {
            cache.clearRetainingCapacity();
            if (match(message, 0, 0)) matches += 1;
        }
        print("part{}: {}\n", .{part, matches});
    }
}