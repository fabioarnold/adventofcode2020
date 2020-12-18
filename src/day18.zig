const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day18.txt");

const Operation = enum(u2) {
    None,
    Add,
    Multiply,
};

const Calculator = struct {
    const Frame = struct {
        accum: u64 = 0,
        op: Operation = .None,

        fn num(self: *Frame, n: u64) void {
            switch (self.op) {
                .None => self.accum = n,
                .Multiply => self.accum *= n,
                .Add => self.accum += n,
            }
            self.op = .None;
        }
    };
    stack: [10]Frame = undefined,
    sp: usize = 0,

    const Self = @This();

    fn push(self: *Self) void {
        self.sp += 1;
        self.stack[self.sp] = Frame{};
    }
    fn pop(self: *Self) void {
        var n = self.stack[self.sp].accum;
        self.sp -= 1;
        self.num(n);
    }
    fn op(self: *Self, o: Operation) void {
        self.stack[self.sp].op = o;
    }
    fn num(self: *Self, n: u64) void {
        self.stack[self.sp].num(n);
    }
    fn result(self: Self) u64 {
        return self.stack[self.sp].accum;
    }
};

fn eval(string: []const u8) u64 {
    var calc = Calculator{};
    for (string) |c| {
        switch (c) {
            '(' => calc.push(),
            ')' => calc.pop(),
            '+' => calc.op(.Add),
            '*' => calc.op(.Multiply),
            '0'...'9' => calc.num(c - '0'),
            else => {},
        }
    }
    return calc.result();
}

// https://www.paulgriffiths.net/program/c/calc1.php

fn precedence(c: u8) u32 {
    return switch (c) {
        '*' => 1,
        '+' => 2,
        ')' => 3,
        '(' => 4,
        else => unreachable,
    };
}

fn eval2(string: []const u8) u64 {
    // convert to postfix
    const STACK_SIZE = 10;
    var buffer: [100]u8 = undefined;
    var pos: usize = 0;
    var op_stack: [STACK_SIZE]u8 = undefined;
    var top: usize = 0;
    for (string) |c| {
        switch (c) {
            ' ' => {},
            '0'...'9' => {
                buffer[pos] = c;
                pos += 1;
            },
            else => { // op
                if (top == 0 or precedence(c) > precedence(op_stack[top]) or op_stack[top] == '(') {
                    top += 1;
                    op_stack[top] = c;
                } else { // remove all operators from the op_stack which have higher precendence
                    var balparen: i32 = 0;
                    while (top > 0 
                        and (precedence(op_stack[top]) >= precedence(c) or balparen != 0)
                        and !(balparen == 0 and op_stack[top] == '(')) {
                        if (op_stack[top] == ')') {
                            balparen += 1;
                        } else if (op_stack[top] == '(') {
                            balparen -= 1;
                        } else {
                            buffer[pos] = op_stack[top];
                            pos += 1;
                        }
                        top -= 1;
                    }
                    top += 1;
                    op_stack[top] = c;
                }
            },
        }
    }
    // append remaining ops
    while (top > 0) : (top -= 1) {
        if (op_stack[top] != '(' and op_stack[top] != ')') {
            buffer[pos] = op_stack[top];
            pos += 1;
        }
    }
    var postfix = buffer[0..pos];

    // eval postfix
    var stack: [STACK_SIZE]u64 = undefined;
    top = 0;
    for (postfix) |c| {
        switch (c) {
            '0'...'9' => {
                top += 1;
                stack[top] = c - '0';
            },
            else => {
                const op0 = stack[top];
                top -= 1;
                const op1 = stack[top];
                top -= 1;
                top += 1;
                stack[top] = switch (c) {
                    '+' => op0 + op1,
                    '*' => op0 * op1,
                    else => unreachable,
                };
            }
        }
    }
    return stack[top];
}

pub fn main() !void {
    assert(eval("1 + (2 * 3) + (4 * (5 + 6))") == 51);
    assert(eval("2 * 3 + (4 * 5)") == 26);
    assert(eval("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437);
    assert(eval("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240);
    assert(eval("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632);

    var lines = std.mem.tokenize(input, "\r\n");
    var sum: u64 = 0;
    while (lines.next()) |line| {
        sum += eval(line);
    }
    print("part1: {}\n", .{sum});

    assert(eval2("1 + (2 * 3) + (4 * (5 + 6))") == 51);
    assert(eval2("2 * 3 + (4 * 5)") == 46);
    assert(eval2("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 1445);
    assert(eval2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 669060);
    assert(eval2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340);

    lines.index = 0;
    sum = 0;
    while (lines.next()) |line| {
        sum += eval2(line);
    }
    print("part2: {}\n", .{sum});
}
