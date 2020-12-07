const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day07.txt");

const Content = struct {
    count: usize,
    color: []const u8,

    pub fn init(string: []const u8) !Content {
        var s = std.mem.tokenize(string, " ");
        const count = try std.fmt.parseUnsigned(usize, s.next().?, 10);
        var color = s.rest();
        const i = std.mem.indexOf(u8, color, " bag").?;
        var self = Content{
            .count = count,
            .color = color[0..i],
        };
        return self;
    }
};

const Bag = struct {
    color: []const u8,
    content: ArrayList(Content),

    pub fn init(allocator: *Allocator, string: []const u8) !Bag {
        var s = std.mem.split(string, " bags contain ");
        var self = Bag{
            .color = s.next().?,
            .content = ArrayList(Content).init(allocator),
        };
        var content = s.next().?;
        if (!std.mem.eql(u8, content, "no other bags.")) {
            s = std.mem.split(content, ", ");
            while (s.next()) |c| {
                try self.content.append(try Content.init(c));
            }
        }
        return self;
    }

    pub fn deinit(self: *Bag) void {
        self.content.deinit();
    }
};

var bags: ArrayList(Bag) = undefined;

fn initBags(allocator: *Allocator, string: []const u8) !void {
    var lines = std.mem.split(string, "\n");
    bags = ArrayList(Bag).init(allocator);
    while (lines.next()) |line| {
        try bags.append(try Bag.init(allocator, line));
    }
}

pub fn findBag(color: []const u8) ?usize {
    for (bags.items) |bag, i| {
        if (std.mem.eql(u8, bag.color, color)) {
            return i;
        }
    }
    return null;
}

pub fn canContainShinyGoldBag(i: usize) bool {
    for (bags.items[i].content.items) |item| {
        if (std.mem.eql(u8, item.color, "shiny gold")) {
            return true;
        }
        if (findBag(item.color)) |j| {
            if (canContainShinyGoldBag(j)) {
                return true;
            }
        }
    }
    return false;
}

pub fn countContainingBags(i: usize) usize {
    var sum: usize = 0;
    for (bags.items[i].content.items) |item| {
        if (findBag(item.color)) |j| {
            sum += item.count + item.count * countContainingBags(j);
        }
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    try initBags(allocator, input);

    var count: usize = 0;
    for (bags.items) |_, i| {
        if (canContainShinyGoldBag(i)) {
            count += 1;
        }
    }
    print("part1: {}\n", .{count});

    if (findBag("shiny gold")) |shiny_gold| {
        print("part2: {}\n", .{countContainingBags(shiny_gold)});
    }
}

const example_part1 =
\\light red bags contain 1 bright white bag, 2 muted yellow bags.
\\dark orange bags contain 3 bright white bags, 4 muted yellow bags.
\\bright white bags contain 1 shiny gold bag.
\\muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
\\shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
\\dark olive bags contain 3 faded blue bags, 4 dotted black bags.
\\vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
\\faded blue bags contain no other bags.
\\dotted black bags contain no other bags.
;

test "part1 example" {
    try initBags(std.testing.allocator, example_part1);
    defer {
        for (bags.items) |*bag| {
            bag.deinit();
        }
        bags.deinit();
    }
    var count: usize = 0;
    for (bags.items) |_, i| {
        if (canContainShinyGoldBag(i)) {
            count += 1;
        }
    }
    std.testing.expect(count == 4);
}

const example_part2 =
\\shiny gold bags contain 2 dark red bags.
\\dark red bags contain 2 dark orange bags.
\\dark orange bags contain 2 dark yellow bags.
\\dark yellow bags contain 2 dark green bags.
\\dark green bags contain 2 dark blue bags.
\\dark blue bags contain 2 dark violet bags.
\\dark violet bags contain no other bags.
;

test "part2 example" {
    try initBags(std.testing.allocator, example_part2);
    defer {
        for (bags.items) |*bag| {
            bag.deinit();
        }
        bags.deinit();
    }
    var shiny_gold = findBag("shiny gold").?;
    std.testing.expect(countContainingBags(shiny_gold) == 126);
}