const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day17.txt");

const Cube = struct {
    dim_x: usize,
    dim_y: usize,
    dim_z: usize,
    data: []bool,
    allocator: *Allocator,

    const Self = @This();

    pub fn init(allocator: *Allocator, string: []const u8) !*Self {
        var dim: usize = 0;
        while (string[dim] != '\n') : (dim += 1) {}
        var cube = try create(allocator, dim, dim, 1);
        var lines = std.mem.tokenize(string, "\n");
        var y: usize = 0;
        while (lines.next()) |line| : (y += 1) {
            for (line) |c, x| {
                if (c == '#') cube.setActive(x, y, 0, true);
            }
        }
        return cube;
    }

    pub fn create(allocator: *Allocator, dim_x: usize, dim_y: usize, dim_z: usize) !*Self {
        var data = try allocator.alloc(bool, dim_x * dim_y * dim_z);
        std.mem.set(bool, data, false);
        var cube = try allocator.create(Self);
        cube.* = Self{
            .dim_x = dim_x,
            .dim_y = dim_y,
            .dim_z = dim_z,
            .data = data,
            .allocator = allocator,
        };
        return cube;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.data);
        self.allocator.destroy(self);
    }

    pub fn step(self: Self) !*Self {
        var src = try self.expand(2);
        defer src.deinit();
        var next = try create(self.allocator, self.dim_x + 2, self.dim_y + 2, self.dim_z + 2);
        defer next.deinit();

        var min_x: usize = next.dim_x;
        var min_y: usize = next.dim_y;
        var min_z: usize = next.dim_z;
        var max_x: usize = 0;
        var max_y: usize = 0;
        var max_z: usize = 0;

        var z: usize = 0;
        while (z < next.dim_z) : (z += 1) {
            var y: usize = 0;
            while (y < next.dim_y) : (y += 1) {
                var x: usize = 0;
                while (x < next.dim_x) : (x += 1) {
                    var n: usize = 0;
                    var dz: usize = 0;
                    while (dz < 3) : (dz += 1) {
                        var dy: usize = 0;
                        while (dy < 3) : (dy += 1) {
                            var dx: usize = 0;
                            while (dx < 3) : (dx += 1) {
                                if (dx == 1 and dy == 1 and dz == 1) continue;
                                if (src.isActive(x + dx, y + dy, z + dz)) n += 1;
                            }
                        }
                    }
                    if (src.isActive(x + 1, y + 1, z + 1)) {
                        next.setActive(x, y, z, n == 2 or n == 3);
                    } else {
                        next.setActive(x, y, z, n == 3);
                    }

                    if (next.isActive(x, y, z)) {
                        min_x = std.math.min(x, min_x);
                        min_y = std.math.min(y, min_y);
                        min_z = std.math.min(z, min_z);
                        max_x = std.math.max(x, max_x);
                        max_y = std.math.max(y, max_y);
                        max_z = std.math.max(z, max_z);
                    }
                }
            }
        }
        return try next.shrink(min_x, max_x, min_y, max_y, min_z, max_z);
    }

    fn expand(self: Self, e: usize) !*Self {
        var result = try Self.create(self.allocator, self.dim_x + 2 * e, self.dim_y + 2 * e, self.dim_z + 2 * e);
        var z: usize = 0;
        while (z < self.dim_z) : (z += 1) {
            var y: usize = 0;
            while (y < self.dim_y) : (y += 1) {
                var x: usize = 0;
                while (x < self.dim_x) : (x += 1) {
                    result.setActive(e + x, e + y, e + z, self.isActive(x, y, z));
                }
            }
        }
        return result;
    }

    fn shrink(self: Self, min_x: usize, max_x: usize, min_y: usize, max_y: usize, min_z: usize, max_z: usize) !*Self {
        assert(min_x < max_x);
        assert(min_y < max_y);
        assert(min_z < max_z);
        var result = try Self.create(self.allocator, max_x + 1 - min_x, max_y + 1 - min_y, max_z + 1 - min_z);
        var z: usize = 0;
        while (z < result.dim_z) : (z += 1) {
            var y: usize = 0;
            while (y < result.dim_y) : (y += 1) {
                var x: usize = 0;
                while (x < result.dim_x) : (x += 1) {
                    result.setActive(x, y, z, self.isActive(min_x + x, min_y + y, min_z + z));
                }
            }
        }
        return result;
    }

    fn index(self: Self, x: usize, y: usize, z: usize) usize {
        return z * self.dim_y * self.dim_x + y * self.dim_x + x;
    }

    fn isActive(self: Self, x: usize, y: usize, z: usize) bool {
        return self.data[self.index(x, y, z)];
    }

    fn setActive(self: *Self, x: usize, y: usize, z: usize, active: bool) void {
        self.data[self.index(x, y, z)] = active;
    }

    fn numActive(self: Self) usize {
        var num: usize = 0;
        for (self.data) |b| {
            if (b) num += 1;
        }
        return num;
    }

    fn print(self: Self) void {
        var z: usize = 0;
        while (z < self.dim_z) : (z += 1) {
            print("\nz={}\n", .{z});
            var y: usize = 0;
            while (y < self.dim_y) : (y += 1) {
                var x: usize = 0;
                while (x < self.dim_x) : (x += 1) {
                    if (self.isActive(x, y, z)) {
                        print("#", .{});
                    } else {
                        print(".", .{});
                    }
                }
                print("\n", .{});
            }
        }
    }
};

const HyperCube = struct {
    dim_x: usize,
    dim_y: usize,
    dim_z: usize,
    dim_w: usize,
    data: []bool,
    allocator: *Allocator,

    const Self = @This();

    pub fn init(allocator: *Allocator, string: []const u8) !*Self {
        var dim: usize = 0;
        while (string[dim] != '\n') : (dim += 1) {}
        var cube = try create(allocator, dim, dim, 1, 1);
        var lines = std.mem.tokenize(string, "\n");
        var y: usize = 0;
        while (lines.next()) |line| : (y += 1) {
            for (line) |c, x| {
                if (c == '#') cube.setActive(x, y, 0, 0, true);
            }
        }
        return cube;
    }

    pub fn create(allocator: *Allocator, dim_x: usize, dim_y: usize, dim_z: usize, dim_w: usize) !*Self {
        var data = try allocator.alloc(bool, dim_x * dim_y * dim_z * dim_w);
        std.mem.set(bool, data, false);
        var cube = try allocator.create(Self);
        cube.* = Self{
            .dim_x = dim_x,
            .dim_y = dim_y,
            .dim_z = dim_z,
            .dim_w = dim_w,
            .data = data,
            .allocator = allocator,
        };
        return cube;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.data);
        self.allocator.destroy(self);
    }

    pub fn step(self: Self) !*Self {
        var src = try self.expand(2);
        defer src.deinit();
        var next = try create(self.allocator, self.dim_x + 2, self.dim_y + 2, self.dim_z + 2, self.dim_w + 2);
        defer next.deinit();

        var min_x: usize = next.dim_x;
        var min_y: usize = next.dim_y;
        var min_z: usize = next.dim_z;
        var min_w: usize = next.dim_w;
        var max_x: usize = 0;
        var max_y: usize = 0;
        var max_z: usize = 0;
        var max_w: usize = 0;

        var w: usize = 0;
        while (w < next.dim_w) : (w += 1) {
            var z: usize = 0;
            while (z < next.dim_z) : (z += 1) {
                var y: usize = 0;
                while (y < next.dim_y) : (y += 1) {
                    var x: usize = 0;
                    while (x < next.dim_x) : (x += 1) {
                        var n: usize = 0;
                        var dw: usize = 0;
                        while (dw < 3) : (dw += 1) {
                            var dz: usize = 0;
                            while (dz < 3) : (dz += 1) {
                                var dy: usize = 0;
                                while (dy < 3) : (dy += 1) {
                                    var dx: usize = 0;
                                    while (dx < 3) : (dx += 1) {
                                        if (dx == 1 and dy == 1 and dz == 1 and dw == 1) continue;
                                        if (src.isActive(x + dx, y + dy, z + dz, w + dw)) n += 1;
                                    }
                                }
                            }
                        }
                        if (src.isActive(x + 1, y + 1, z + 1, w + 1)) {
                            next.setActive(x, y, z, w, n == 2 or n == 3);
                        } else {
                            next.setActive(x, y, z, w, n == 3);
                        }

                        if (next.isActive(x, y, z, w)) {
                            min_x = std.math.min(x, min_x);
                            min_y = std.math.min(y, min_y);
                            min_z = std.math.min(z, min_z);
                            min_w = std.math.min(w, min_w);
                            max_x = std.math.max(x, max_x);
                            max_y = std.math.max(y, max_y);
                            max_z = std.math.max(z, max_z);
                            max_w = std.math.max(w, max_w);
                        }
                    }
                }
            }
        }
        return try next.shrink(min_x, max_x, min_y, max_y, min_z, max_z, min_w, max_w);
    }

    fn expand(self: Self, e: usize) !*Self {
        var result = try Self.create(self.allocator, self.dim_x + 2 * e, self.dim_y + 2 * e, self.dim_z + 2 * e, self.dim_w + 2 * e);
        var w: usize = 0;
        while (w < self.dim_w) : (w += 1) {
            var z: usize = 0;
            while (z < self.dim_z) : (z += 1) {
                var y: usize = 0;
                while (y < self.dim_y) : (y += 1) {
                    var x: usize = 0;
                    while (x < self.dim_x) : (x += 1) {
                        result.setActive(e + x, e + y, e + z, e + w, self.isActive(x, y, z, w));
                    }
                }
            }
        }
        return result;
    }

    fn shrink(self: Self, min_x: usize, max_x: usize, min_y: usize, max_y: usize, min_z: usize, max_z: usize, min_w: usize, max_w: usize) !*Self {
        assert(min_x < max_x);
        assert(min_y < max_y);
        assert(min_z < max_z);
        var result = try Self.create(self.allocator, max_x + 1 - min_x, max_y + 1 - min_y, max_z + 1 - min_z, max_w + 1 - min_w);
        var w: usize = 0;
        while (w < result.dim_w) : (w += 1) {
            var z: usize = 0;
            while (z < result.dim_z) : (z += 1) {
                var y: usize = 0;
                while (y < result.dim_y) : (y += 1) {
                    var x: usize = 0;
                    while (x < result.dim_x) : (x += 1) {
                        result.setActive(x, y, z, w, self.isActive(min_x + x, min_y + y, min_z + z, min_w + w));
                    }
                }
            }
        }
        return result;
    }

    fn index(self: Self, x: usize, y: usize, z: usize, w: usize) usize {
        return w * self.dim_z * self.dim_y * self.dim_x + z * self.dim_y * self.dim_x + y * self.dim_x + x;
    }

    fn isActive(self: Self, x: usize, y: usize, z: usize, w: usize) bool {
        return self.data[self.index(x, y, z, w)];
    }

    fn setActive(self: *Self, x: usize, y: usize, z: usize, w: usize, active: bool) void {
        self.data[self.index(x, y, z, w)] = active;
    }

    fn numActive(self: Self) usize {
        var num: usize = 0;
        for (self.data) |b| {
            if (b) num += 1;
        }
        return num;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;

    var cube = try Cube.init(allocator, input);
    defer cube.deinit();
    var i: usize = 0;
    while (i < 6) : (i += 1) {
        //cube.print();
        var next = try cube.step();
        cube.deinit();
        cube = next;
    }
    print("part1: {}\n", .{cube.numActive()});

    var hyper_cube = try HyperCube.init(allocator, input);
    defer hyper_cube.deinit();
    i = 0;
    while (i < 6) : (i += 1) {
        var next = try hyper_cube.step();
        hyper_cube.deinit();
        hyper_cube = next;
    }
    print("part2: {}\n", .{hyper_cube.numActive()});
}

const example =
    \\.#.
    \\..#
    \\###
;
