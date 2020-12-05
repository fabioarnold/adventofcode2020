const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day04.txt");

const Passport = struct {
    byr: ?[]const u8 = null,
    iyr: ?[]const u8 = null,
    eyr: ?[]const u8 = null,
    hgt: ?[]const u8 = null,
    hcl: ?[]const u8 = null,
    ecl: ?[]const u8 = null,
    pid: ?[]const u8 = null,
    //cid: ?[]const u8 = null,

    pub fn initFromString(string: []const u8) !Passport {
        var self = Passport{};

        var iter = std.mem.tokenize(string, " \n");
        while (iter.next()) |token| {
            const i = std.mem.indexOfScalar(u8, token, ':') orelse return error.InvalidToken;
            const identifier = token[0..i];
            const value = token[i + 1..];
            inline for (std.meta.fields(Passport)) |field| {
                if (std.mem.eql(u8, identifier, field.name)) {
                    @field(self, field.name) = value;
                }
            }
        }

        return self;
    }

    pub fn isComplete(self: Passport) bool {
        inline for (std.meta.fields(Passport)) |field| {
            if (@field(self, field.name) == null) {
                return false;
            }
        }
        return true;
    }

    pub fn isValid(self: Passport) bool {
        if (!self.isComplete()) return false;

        const byr = std.fmt.parseUnsigned(usize, self.byr.?, 10) catch |_| return false;
        if (byr < 1920 or byr > 2002) return false;

        const iyr = std.fmt.parseUnsigned(usize, self.iyr.?, 10) catch |_| return false;
        if (iyr < 2010 or iyr > 2020) return false;

        const eyr = std.fmt.parseUnsigned(usize, self.eyr.?, 10) catch |_| return false;
        if (eyr < 2020 or eyr > 2030) return false;

        if (self.hgt.?.len < 3) return false;
        const hgt_unit = self.hgt.?[self.hgt.?.len - 2..self.hgt.?.len];
        const hgt_value = std.fmt.parseUnsigned(usize, self.hgt.?[0..self.hgt.?.len - 2], 10) catch |_| return false;
        if (std.mem.eql(u8, hgt_unit, "cm")) {
            if (hgt_value < 150 or hgt_value > 193) return false;
        } else if (std.mem.eql(u8, hgt_unit, "in")) {
            if (hgt_value < 59 or hgt_value > 76) return false;
        } else {
            return false;
        }

        if (self.hcl.?.len != 7) return false;
        if (self.hcl.?[0] != '#') return false;
        for (self.hcl.?[1..]) |c| {
            if (!(('0' <= c and c <= '9') or ('a' <= c and c <= 'f'))) return false;
        }

        if (self.ecl.?.len != 3) return false;
        const valid_ecls = [_][]const u8{"amb", "blu", "brn", "gry", "grn", "hzl", "oth"};
        var ecl_found = false;
        for (valid_ecls) |valid_ecl| {
            if (std.mem.eql(u8, self.ecl.?, valid_ecl)) {
                ecl_found = true;
                break;
            }
        }
        if (!ecl_found) return false;

        if (self.pid.?.len != 9) return false;
        for (self.pid.?) |c| {
            if (!('0' <= c and c <= '9')) return false;
        }

        return true;
    }
};

fn completePassports(string: []const u8) usize {
    var count: usize = 0;

    const sep = "\n\n";
    var iter = std.mem.split(string, sep);
    while (iter.next()) |token| {
        const passport = Passport.initFromString(token) catch |_| continue;
        if (passport.isComplete()) count += 1;
    }

    return count;
}

fn validPassports(string: []const u8) usize {
    var count: usize = 0;

    const sep = "\n\n";
    var iter = std.mem.split(string, sep);
    while (iter.next()) |token| {
        const passport = Passport.initFromString(token) catch |_| continue;
        if (passport.isValid()) count += 1;
    }

    return count;
}

pub fn main() !void {
    print("part1 {}\n", .{completePassports(input)});
    print("part2 {}\n", .{validPassports(input)});
}

const example =
\\ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
\\byr:1937 iyr:2017 cid:147 hgt:183cm
\\
\\iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
\\hcl:#cfa07d byr:1929
\\
\\hcl:#ae17e1 iyr:2013
\\eyr:2024
\\ecl:brn pid:760753108 byr:1931
\\hgt:179cm
\\
\\hcl:#cfa07d eyr:2025 pid:166559648
\\iyr:2011 ecl:brn hgt:59in
;

test "part1 example" {
    std.testing.expect(completePassports(example) == 2);
}

const example_invalid =
\\eyr:1972 cid:100
\\hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926
\\
\\iyr:2019
\\hcl:#602927 eyr:1967 hgt:170cm
\\ecl:grn pid:012533040 byr:1946
\\
\\hcl:dab227 iyr:2012
\\ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
\\
\\hgt:59cm ecl:zzz
\\eyr:2038 hcl:74454a iyr:2023
\\pid:3556412378 byr:2007
;

const example_valid =
\\pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
\\hcl:#623a2f
\\
\\eyr:2029 ecl:blu cid:129 byr:1989
\\iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
\\
\\hcl:#888785
\\hgt:164cm byr:2001 iyr:2015 cid:88
\\pid:545766238 ecl:hzl
\\eyr:2022
\\
\\iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
;

test "part2 examples" {
    std.testing.expect(validPassports(example_invalid) == 0);
    std.testing.expect(validPassports(example_valid) == 4);
}