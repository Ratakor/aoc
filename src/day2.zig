const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

const Color = struct {
    name: []const u8,
    max: usize,
};

const data = @embedFile("data/input2.txt");
const example =
    \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
;

pub fn solution1() !usize {
    const colors = [_]Color{
        .{ .name = "red", .max = 12 },
        .{ .name = "green", .max = 13 },
        .{ .name = "blue", .max = 14 },
    };

    var sum: usize = 0;
    var id: usize = 1;
    var readline = std.mem.tokenizeScalar(u8, data, '\n');
    next_line: while (readline.next()) |line| : (id += 1) {
        const offset = "Game : ".len + countDigits(id);
        var iter = std.mem.tokenizeSequence(u8, line[offset..], "; ");
        while (iter.next()) |subset| {
            var it = std.mem.tokenizeSequence(u8, subset, ", ");
            while (it.next()) |cube| {
                const idx = std.mem.indexOfScalar(u8, cube, ' ').?;
                const n = try std.fmt.parseUnsigned(usize, cube[0..idx], 10);
                const digits = countDigits(n);

                for (colors) |color| {
                    if (std.mem.eql(u8, cube[digits + 1 ..], color.name)) {
                        if (n > color.max) {
                            continue :next_line;
                        }
                        break;
                    }
                }
            }
        }
        sum += id;
    }

    return sum;
}

pub fn solution2() !usize {
    var sum: usize = 0;
    var id: usize = 1;
    var readline = std.mem.tokenizeScalar(u8, data, '\n');
    while (readline.next()) |line| : (id += 1) {
        var colors = [_]Color{
            .{ .name = "red", .max = 0 },
            .{ .name = "green", .max = 0 },
            .{ .name = "blue", .max = 0 },
        };

        const offset = "Game : ".len + countDigits(id);
        var iter = std.mem.tokenizeSequence(u8, line[offset..], "; ");
        while (iter.next()) |subset| {
            var it = std.mem.tokenizeSequence(u8, subset, ", ");
            while (it.next()) |cube| {
                const idx = std.mem.indexOfScalar(u8, cube, ' ').?;
                const n = try std.fmt.parseUnsigned(usize, cube[0..idx], 10);
                const digits = countDigits(n);

                for (&colors) |*color| {
                    if (std.mem.eql(u8, cube[digits + 1 ..], color.name)) {
                        color.max = @max(color.max, n);
                        break;
                    }
                }
            }
        }

        var power: usize = 1;
        inline for (colors) |color| {
            power *= color.max;
        }
        sum += power;
    }

    return sum;
}

fn countDigits(number: usize) usize {
    var count: usize = 1;
    var n = number / 10;
    while (n != 0) {
        count += 1;
        n /= 10;
    }
    return count;
}
