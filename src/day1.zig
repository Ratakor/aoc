const std = @import("std");
const data = @embedFile("./data/input1.txt");
const numbers = "123456789";
const numbers_str = [_][]const u8{
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
};

pub fn solution1() !usize {
    var sum: usize = 0;
    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        const idx1 = std.mem.indexOfAny(u8, line, numbers).?;
        const idx2 = std.mem.lastIndexOfAny(u8, line[idx1..], numbers).? + idx1;
        const n1 = line[idx1] - '0';
        const n2 = line[idx2] - '0';
        sum += n1 * 10 + n2;
    }

    return sum;
}

pub fn solution2() !usize {
    var sum: usize = 0;
    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        var idx1 = std.mem.indexOfAny(u8, line, numbers) orelse line.len;
        for (numbers_str) |number| {
            if (std.mem.indexOf(u8, line, number)) |idx| {
                idx1 = @min(idx1, idx);
            }
        }

        var idx2 = std.mem.lastIndexOfAny(u8, line[idx1..], numbers) orelse 0;
        for (numbers_str) |number| {
            if (std.mem.lastIndexOf(u8, line[idx1..], number)) |idx| {
                idx2 = @max(idx2, idx);
            }
        }
        idx2 += idx1;

        const n1 = if (std.ascii.isDigit(line[idx1]))
            line[idx1] - '0'
        else for (numbers_str, 0..) |number, i| {
            if (line[idx1..].len < number.len) continue;
            if (std.mem.eql(u8, line[idx1 .. idx1 + number.len], number)) {
                break i + 1;
            }
        } else unreachable;

        const n2 = if (std.ascii.isDigit(line[idx2]))
            line[idx2] - '0'
        else for (numbers_str, 0..) |number, i| {
            if (line[idx2..].len < number.len) continue;
            if (std.mem.eql(u8, line[idx2 .. idx2 + number.len], number)) {
                break i + 1;
            }
        } else unreachable;

        sum += n1 * 10 + n2;
    }

    return sum;
}

test {
    try std.testing.expectEqual(@as(usize, 55607), try solution1());
    try std.testing.expectEqual(@as(usize, 55291), try solution2());
}
