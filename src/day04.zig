const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const input = @embedFile("../input/day04.txt");

fn validPassport(passport: []const u8) bool {
    const has_byr = std.mem.indexOf(u8, passport, "byr:") != null;
    const has_iyr = std.mem.indexOf(u8, passport, "iyr:") != null;
    const has_eyr = std.mem.indexOf(u8, passport, "eyr:") != null;
    const has_hgt = std.mem.indexOf(u8, passport, "hgt:") != null;
    const has_hcl = std.mem.indexOf(u8, passport, "hcl:") != null;
    const has_ecl = std.mem.indexOf(u8, passport, "ecl:") != null;
    const has_pid = std.mem.indexOf(u8, passport, "pid:") != null;
    const has_cid = std.mem.indexOf(u8, passport, "cid:") != null;
    return has_byr and has_iyr and has_eyr and has_hgt and has_hcl and has_ecl and has_pid;
}

fn validPassport2(passport: []const u8) bool {
    if (!validPassport(passport)) return false;
    var iter = std.mem.tokenize(passport, " \n");
    while (iter.next()) |token| {
        if (token.len < 4) return false;
        const identifier = token[0..3];
        if (std.mem.eql(u8, identifier, "byr")) {
            if (token.len != 8) return false;
            const byr = std.fmt.parseUnsigned(usize, token[4..8], 10) catch |_| return false;
            if (byr < 1920 or byr > 2002) return false;
        } else if (std.mem.eql(u8, identifier, "iyr")) {
            if (token.len != 8) return false;
            const iyr = std.fmt.parseUnsigned(usize, token[4..8], 10) catch |_| return false;
            if (iyr < 2010 or iyr > 2020) return false;
        } else if (std.mem.eql(u8, identifier, "eyr")) {
            if (token.len != 8) return false;
            const eyr = std.fmt.parseUnsigned(usize, token[4..8], 10) catch |_| return false;
            if (eyr < 2020 or eyr > 2030) return false;
        } else if (std.mem.eql(u8, identifier, "hgt")) {
            if (token.len < 8) return false;
            const hgt_unit = token[token.len - 2..token.len];
            const hgt_value = std.fmt.parseUnsigned(usize, token[4..token.len - 2], 10) catch |_| return false;
            if (std.mem.eql(u8, hgt_unit, "cm")) {
                if (hgt_value < 150 or hgt_value > 193) return false;
            } else if (std.mem.eql(u8, hgt_unit, "in")) {
                if (hgt_value < 59 or hgt_value > 76) return false;
            } else {
                return false;
            }
        } else if (std.mem.eql(u8, identifier, "hcl")) {
            if (token.len != 4 + 7) return false;
            if (token[4] != '#') return false;
            const color = token[5..11];
            for (color) |c| {
                if (!(('0' <= c and c <= '9') or ('a' <= c and c <= 'f'))) return false;
            }
        } else if (std.mem.eql(u8, identifier, "ecl")) {
            if (token.len != 7) return false;
            const valid_ecls = [_][]const u8{"amb", "blu", "brn", "gry", "grn", "hzl", "oth"};
            const ecl = token[4..7];
            var ecl_found = false;
            for (valid_ecls) |valid_ecl| {
                if (std.mem.eql(u8, ecl, valid_ecl)) {
                    ecl_found = true;
                    break;
                }
            }
            if (!ecl_found) return false;
        } else if (std.mem.eql(u8, identifier, "pid")) {
            if (token.len != 13) return false;
            const pid = token[4..13];
            for (pid) |c| {
                if (!('0' <= c and c <= '9')) return false;
            }
        }
    }

    return true;
}

fn validPassports(string: []const u8) usize {
    var count: usize = 0;

    const sep = "\n\n";
    var i: usize = 0;
    while (std.mem.indexOf(u8, string[i..], sep)) |found| : (i += found + sep.len) {
        const passport = string[i..i + found];
        if (validPassport(passport)) count += 1;
    }
    const passport = string[i..];
    if (validPassport(passport)) count += 1;

    return count;
}

fn validPassports2(string: []const u8) usize {
    var count: usize = 0;

    const sep = "\n\n";
    var i: usize = 0;
    while (std.mem.indexOf(u8, string[i..], sep)) |found| : (i += found + sep.len) {
        const passport = string[i..i + found];
        if (validPassport2(passport)) count += 1;
    }
    const passport = string[i..];
    if (validPassport2(passport)) count += 1;

    return count;
}

pub fn main() !void {
    print("part1 {}\n", .{validPassports(input)});
    print("part2 {}\n", .{validPassports2(input)});
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
    std.testing.expect(validPassports(example) == 2);
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
    std.testing.expect(validPassports2(example_invalid) == 0);
    std.testing.expect(validPassports2(example_valid) == 4);
}