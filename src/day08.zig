const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day08.txt");

const Operation = enum(u8) {
    Acc,
    Jmp,
    Nop,
};

const Instruction = struct {
    operation: Operation,
    argument: i32,
    execution_counter: usize = 0,

    fn initFromString(string: []const u8) !Instruction {
        var tokens = std.mem.tokenize(string, " ");
        const op = tokens.next() orelse return error.MissingOperation;
        const arg = tokens.next() orelse return error.MissingArgument;

        var self = Instruction{
            .operation = undefined,
            .argument = try std.fmt.parseInt(i32, arg, 10),
        };
        if (std.mem.eql(u8, op, "acc")) {
            self.operation = .Acc;
        } else if (std.mem.eql(u8, op, "jmp")) {
            self.operation = .Jmp;
        } else if (std.mem.eql(u8, op, "nop")) {
            self.operation = .Nop;
        } else {
            return error.UnknownOperation;
        }

        return self;
    }
};

const Program = struct {
    instructions: ArrayList(Instruction),
    program_counter: usize = 0,
    accumulator: i32 = 0,

    fn initFromString(allocator: *Allocator, string: []const u8) !Program {
        var self = Program{
            .instructions = ArrayList(Instruction).init(allocator),
        };

        var lines = std.mem.split(string, "\n");
        while (lines.next()) |line| {
            try self.instructions.append(try Instruction.initFromString(line));
        }

        return self;
    }

    fn deinit(self: *Program) void {
        self.instructions.deinit();
    }

    fn execute(self: *Program) bool { // true if terminated
        while (self.program_counter < self.instructions.items.len) {
            var instruction = &self.instructions.items[self.program_counter];
            if (instruction.execution_counter >= 1) return false;
            instruction.execution_counter += 1;
            switch (instruction.operation) {
                .Acc => self.accumulator += instruction.argument,
                .Jmp => {
                    const address = @intCast(i32, self.program_counter) + instruction.argument;
                    self.program_counter = @intCast(usize, address);
                    continue;
                },
                .Nop => {},
            }
            self.program_counter += 1;
        }
        return true;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    var program = try Program.initFromString(allocator, input);
    _ = program.execute();
    print("part1: {}\n", .{program.accumulator});
    program.deinit();

    var i: usize = 0;
    while (true) : (i += 1) {
        program = try Program.initFromString(allocator, input);
        defer program.deinit();

        // manipulate an instruction
        while (program.instructions.items[i].operation == .Acc) i += 1;
        var instruction = &program.instructions.items[i];
        instruction.operation = if (instruction.operation == .Jmp) .Nop else .Jmp;

        if (program.execute()) {
            print("part2: {}\n", .{program.accumulator});
            break;
        }
    }
}

const example =
\\nop +0
\\acc +1
\\jmp +4
\\acc +3
\\jmp -3
\\acc -99
\\acc +1
\\jmp -4
\\acc +6
;
