const std = @import("std");
const print = std.debug.print;
const data = @embedFile("./data/input4.txt");
const example =
    \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
;

pub fn solution1() !usize {
    var sum: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const offset = std.mem.indexOfScalar(u8, line, ':').? + 2;
        const separator = std.mem.indexOfScalar(u8, line, '|').?;
        var winning_numbers = std.mem.tokenizeScalar(u8, line[offset..separator], ' ');
        var numbers = std.mem.tokenizeScalar(u8, line[separator + 1 ..], ' ');
        var total: u6 = 0;
        while (winning_numbers.next()) |winning| {
            const w = try std.fmt.parseUnsigned(usize, winning, 10);
            defer numbers.reset();
            while (numbers.next()) |number| {
                const n = try std.fmt.parseUnsigned(usize, number, 10);
                if (w == n) {
                    total += 1;
                }
            }
        }

        if (total > 0) {
            sum += @as(usize, 1) << (total - 1);
        }
    }

    return sum;
}

pub fn solution2() !usize {
    const input = data;
    const cards_count = comptime blk: {
        const start = std.mem.lastIndexOfScalar(u8, input[0 .. input.len - 1], '\n').? + "\nCard ".len;
        const end = std.mem.indexOfScalarPos(u8, input, start, ':').?;
        break :blk try std.fmt.parseUnsigned(usize, input[start..end], 10);
    };

    var cards: @Vector(cards_count, usize) = @splat(1); // we own 1 ticket of each by default
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        const offset = std.mem.indexOfScalar(u8, line, ':').? + 2;
        const separator = std.mem.indexOfScalar(u8, line, '|').?;
        var winning_numbers = std.mem.tokenizeScalar(u8, line[offset..separator], ' ');
        var numbers = std.mem.tokenizeScalar(u8, line[separator + 1 ..], ' ');
        var matching_numbers: usize = 0;
        while (winning_numbers.next()) |winning| {
            const w = try std.fmt.parseUnsigned(usize, winning, 10);
            defer numbers.reset();
            while (numbers.next()) |number| {
                const n = try std.fmt.parseUnsigned(usize, number, 10);
                if (w == n) {
                    matching_numbers += 1;
                }
            }
        }

        for (i + 1..i + 1 + matching_numbers) |j| {
            cards[j] += cards[i];
        }
    }

    return @reduce(.Add, cards);
}

test {
    try std.testing.expectEqual(@as(usize, 26426), try solution1());
    try std.testing.expectEqual(@as(usize, 6227972), try solution2());
}
