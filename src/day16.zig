const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day16.txt");

const Rule = struct {
    name: []const u8,
    min1: u32,
    max1: u32,
    min2: u32,
    max2: u32,
    pos: ?usize = null,

    pub fn init(string: []const u8) Rule {
        var s = std.mem.split(string, ":");
        const name = s.next().?;
        var t = std.mem.tokenize(s.next().?, " - or");
        return Rule{
            .name = name,
            .min1 = std.fmt.parseUnsigned(u32, t.next().?, 10) catch unreachable,
            .max1 = std.fmt.parseUnsigned(u32, t.next().?, 10) catch unreachable,
            .min2 = std.fmt.parseUnsigned(u32, t.next().?, 10) catch unreachable,
            .max2 = std.fmt.parseUnsigned(u32, t.next().?, 10) catch unreachable,
        };
    }

    pub fn inRange(self: Rule, value: u32) bool {
        return (self.min1 <= value and value <= self.max1) or (self.min2 <= value and value <= self.max2);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;

    var blocks = std.mem.split(input, "\n\n");
    const rule_block = blocks.next().?;
    const my_ticket_block = blocks.next().?;
    const tickets_block = blocks.next().?;

    var rules: [20]Rule = undefined;
    var lines = std.mem.tokenize(rule_block, "\n");
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        rules[i] = Rule.init(line);
    }

    var my_ticket: [20]u32 = undefined;
    lines = std.mem.tokenize(my_ticket_block, "\n");
    _ = lines.next();
    if (lines.next()) |line| {
        var token = std.mem.tokenize(line, ",");
        i = 0;
        while (token.next()) |t| : (i += 1) {
            my_ticket[i] = try std.fmt.parseUnsigned(u32, t, 10);
        }
        assert(i == my_ticket.len);
    }

    var error_rate: u32 = 0;
    var tickets = std.ArrayList([20]u32).init(allocator);
    defer tickets.deinit();
    lines = std.mem.tokenize(tickets_block, "\n");
    _ = lines.next();
    while (lines.next()) |line| {
        var other_ticket: [20]u32 = undefined;
        var token = std.mem.tokenize(line, ",");
        i = 0;
        const ticket_valid = while (token.next()) |t| : (i += 1) {
            other_ticket[i] = try std.fmt.parseUnsigned(u32, t, 10);

            var valid = false;
            for (rules) |rule| {
                if (rule.inRange(other_ticket[i])) {
                    valid = true;
                    break;
                }
            }
            if (!valid) {
                error_rate += other_ticket[i];
                break false;
            }
        } else true;
        if (ticket_valid) try tickets.append(other_ticket);
    }

    print("part1: {}\n", .{error_rate});

    var found = [_]bool{false}**20;
    var done: bool = false;
    while (!done) {
        done = true;
        for (rules) |*rule, rule_pos| {
            if (rule.pos != null) continue;

            var valid_count: usize = 0;
            var valid_pos: usize = 0;
            for (found) |f, pos| {
                if (f) continue;
                const all_valid = for (tickets.items) |ticket| {
                    if (!rule.inRange(ticket[pos])) break false;
                } else true;
                if (all_valid) {
                    valid_pos = pos;
                    valid_count += 1;
                }
            }
            if (valid_count == 1) { // just one candidate
                rule.pos = valid_pos;
                found[valid_pos] = true;
                print("found rule{} pos {}\n", .{rule_pos, valid_pos});
            } else {
                done = false;
            }
        }
        print("next\n", .{});
    }

    var part2: u64 = 1;
    for (rules[0..6]) |rule| {
        part2 *= my_ticket[rule.pos.?];
    }

    print("part2: {}\n", .{part2});
}
