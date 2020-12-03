const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day03.txt");

fn trees(string: []const u8, right: usize, down: usize) usize {
    var lines = std.mem.tokenize(string, "\n");
    var count: usize = 0;
    var y: usize = 0;
    while (lines.next()) |line| : (y += 1) {
        if ((y % down) == 0) {
            const x = (y * right / down) % line.len;
            if (line[x] == '#') count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    const r1d1 = trees(input, 1, 1);
    const r3d1 = trees(input, 3, 1);
    const r5d1 = trees(input, 5, 1);
    const r7d1 = trees(input, 7, 1);
    const r1d2 = trees(input, 1, 2);
    print("part1: {}\n", .{r3d1});
    print("part2: {}\n", .{r1d1 * r3d1 * r5d1 * r7d1 * r1d2});
}

const example = 
\\..##.......
\\#...#...#..
\\.#....#..#.
\\..#.#...#.#
\\.#...##..#.
\\..#.##.....
\\.#.#.#....#
\\.#........#
\\#.##...#...
\\#...##....#
\\.#..#...#.#
;

test "part1 example" {
    std.testing.expect(trees(example, 3, 1) == 7);
}

test "part2 example" {
    std.testing.expect(trees(example, 1, 1) == 2);
    std.testing.expect(trees(example, 3, 1) == 7);
    std.testing.expect(trees(example, 5, 1) == 3);
    std.testing.expect(trees(example, 7, 1) == 4);
    std.testing.expect(trees(example, 1, 2) == 2);
}