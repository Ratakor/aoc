const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input13.txt");
const example =
    \\#.##..##.
    \\..#.##.#.
    \\##......#
    \\##......#
    \\..#.##.#.
    \\..##..##.
    \\#.#.##.#.
    \\
    \\#...##..#
    \\#....#..#
    \\..##..###
    \\#####.##.
    \\#####.##.
    \\..##..###
    \\#....#..#
;

pub fn solution1() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var result: usize = 0;
    var patterns = mem.tokenizeSequence(u8, data, "\n\n");
    while (patterns.next()) |pattern| {
        if (try verticalCheck(allocator, pattern, false)) |value| {
            result += value;
        } else if (try horizontalCheck(allocator, pattern, false)) |value| {
            result += value * 100;
        }
    }

    return result;
}

pub fn solution2() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var result: usize = 0;
    var patterns = mem.tokenizeSequence(u8, data, "\n\n");
    while (patterns.next()) |pattern| {
        if (try verticalCheck(allocator, pattern, true)) |value| {
            result += value;
        } else if (try horizontalCheck(allocator, pattern, true)) |value| {
            result += value * 100;
        }
    }

    return result;
}

fn verticalCheck(allocator: mem.Allocator, pattern: []const u8, comptime has_smudge: bool) !?usize {
    var lines = mem.tokenizeScalar(u8, pattern, '\n');
    const columns_arrays = try allocator.alloc(std.ArrayListUnmanaged(u8), lines.peek().?.len);
    for (columns_arrays) |*array| array.* = .{};
    defer {
        for (columns_arrays) |*array| array.deinit(allocator);
        allocator.free(columns_arrays);
    }

    while (lines.next()) |line| {
        for (columns_arrays, line) |*array, char| {
            try array.append(allocator, char);
        }
    }

    const columns = try allocator.alloc([]const u8, columns_arrays.len);
    defer allocator.free(columns);
    for (columns, columns_arrays) |*column, array| {
        column.* = array.items;
    }

    return check(columns, has_smudge);
}

fn horizontalCheck(allocator: mem.Allocator, pattern: []const u8, comptime has_smudge: bool) !?usize {
    var list: std.ArrayListUnmanaged([]const u8) = .{};
    defer list.deinit(allocator);

    var lines = mem.tokenizeScalar(u8, pattern, '\n');
    var i: usize = 1;
    while (lines.next()) |line| : (i += 1) {
        try list.append(allocator, line);
    }

    return check(list.items, has_smudge);
}

fn check(pattern: []const []const u8, comptime has_smudge: bool) !?usize {
    next: for (1..pattern.len) |i| {
        var j: usize = i;
        var k: usize = i + 1;
        var smudge: usize = 0;
        while (j > 0 and k <= pattern.len) : ({
            j -= 1;
            k += 1;
        }) {
            if (has_smudge) {
                smudge += countDiff(pattern[j - 1], pattern[k - 1]);
                if (smudge > 1) {
                    continue :next;
                }
            } else {
                if (!mem.eql(u8, pattern[j - 1], pattern[k - 1])) {
                    continue :next;
                }
            }
        }

        if (!has_smudge or smudge == 1) {
            return i;
        }
    }

    return null;
}

fn countDiff(s1: []const u8, s2: []const u8) usize {
    var count: usize = 0;
    for (s1, s2) |c1, c2| {
        if (c1 != c2) {
            count += 1;
        }
    }
    return count;
}

test {
    try std.testing.expectEqual(@as(usize, 35521), try solution1());
    try std.testing.expectEqual(@as(usize, 34795), try solution2());
}
