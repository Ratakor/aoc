const std = @import("std");
const print = std.debug.print;
const data = @embedFile("./data/input3.txt");
const example =
    \\467..114..
    \\...*......
    \\..35..633.
    \\......#...
    \\617*......
    \\.....+.58.
    \\..592.....
    \\......755.
    \\...$.*....
    \\.664.598..
;

pub fn solution1() !usize {
    var sum: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var prev_line: ?[]const u8 = null;
    while (lines.next()) |line| {
        const next_line = lines.peek();
        var parser: std.fmt.Parser = .{ .buf = line };
        next_n: while (std.mem.indexOfAnyPos(u8, parser.buf, parser.pos, "123456789")) |idx| {
            parser.pos = idx;
            const n = parser.number().?; // parser.pos = idx + n_digits

            // left = line[idx - 1];
            if (idx > 0 and line[idx - 1] != '.') {
                sum += n;
                continue :next_n;
            }

            // right = line[parser.pos];
            if (parser.pos < line.len and line[parser.pos] != '.') {
                sum += n;
                continue :next_n;
            }

            const start = idx -| 1;
            const end = @min(parser.pos + 1, line.len); // every lines have the same length

            // top = prev_line[idx - 1 .. parser.pos + 1]
            if (prev_line) |prev| {
                for (prev[start..end]) |chr| {
                    if (chr != '.') {
                        sum += n;
                        continue :next_n;
                    }
                }
            }

            // bottom = next_line[idx - 1 .. parser.pos + 1]
            if (next_line) |next| {
                for (next[start..end]) |chr| {
                    if (chr != '.') {
                        sum += n;
                        continue :next_n;
                    }
                }
            }
        }

        prev_line = line;
    }

    return sum;
}

pub fn solution2() !usize {
    var sum: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var prev_line: ?[]const u8 = null;
    while (lines.next()) |line| {
        const next_line = lines.peek();
        var offset: usize = 0;
        while (std.mem.indexOfScalarPos(u8, line, offset, '*')) |idx| {
            offset = idx + 1;
            var parts: std.BoundedArray(usize, 6) = .{};

            // left = line[idx - X .. idx];
            if (idx > 0 and line[idx - 1] != '.') {
                parts.appendAssumeCapacity(parseIntReverse(line, idx - 1));
            }

            // right = line[idx + 1 ..];
            if (idx + 1 < line.len and line[idx + 1] != '.') {
                parts.appendAssumeCapacity(parseInt(line[idx + 1 ..]));
            }

            const start = idx -| 1;

            // top = prev_line[idx - 1 .. idx + 2]
            if (prev_line) |prev| {
                helper(prev, start, &parts);
            }

            // bottom = next_line[idx - 1 .. idx + 2]
            if (next_line) |next| {
                helper(next, start, &parts);
            }

            if (parts.len == 2) {
                sum += parts.get(0) * parts.get(1);
            }
        }

        prev_line = line;
    }

    return sum;
}

fn parseInt(buf: []const u8) usize {
    var n: usize = 0;
    for (buf) |chr| switch (chr) {
        '0'...'9' => n = (n * 10) + (chr - '0'),
        else => break,
    };
    return n;
}

fn parseIntReverse(buf: []const u8, num_end_i: usize) usize {
    var i: isize = @intCast(num_end_i);
    while (i >= 0) : (i -= 1) {
        switch (buf[@bitCast(i)]) {
            '0'...'9' => {},
            else => break,
        }
    }
    return parseInt(buf[@bitCast(i + 1)..]);
}

/// "..." // 0 part
/// "..x" // 1 part forward
/// ".x." // 1 part
/// ".xx" // 1 part forward
/// "x.." // 1 part backward
/// "x.x" // 1 part backward and 1 part forward
/// "xx." // 1 part backward
/// "xxx" // 1 part backward
fn helper(line: []const u8, start: usize, parts: *std.BoundedArray(usize, 6)) void {
    switch (line[start]) {
        '.' => switch (line[start + 1]) {
            '.' => switch (line[start + 2]) {
                '.' => {}, // "..."
                else => parts.appendAssumeCapacity(parseInt(line[start + 2 ..])), // "..x"
            },
            else => switch (line[start + 2]) {
                '.' => parts.appendAssumeCapacity(line[start + 1] - '0'), // ".x."
                else => parts.appendAssumeCapacity(parseInt(line[start + 1 ..])), // ".xx"
            },
        },
        else => switch (line[start + 1]) {
            '.' => switch (line[start + 2]) {
                '.' => parts.appendAssumeCapacity(parseIntReverse(line, start)), // "x.."
                else => {
                    parts.appendAssumeCapacity(parseIntReverse(line, start));
                    parts.appendAssumeCapacity(parseInt(line[start + 2 ..]));
                }, // "x.x"
            },
            else => switch (line[start + 2]) {
                '.' => parts.appendAssumeCapacity(parseIntReverse(line, start + 1)), // "xx."
                else => parts.appendAssumeCapacity(parseIntReverse(line, start + 2)), // "xxx"
            },
        },
    }
}

test {
    try std.testing.expectEqual(@as(usize, 531561), try solution1());
    try std.testing.expectEqual(@as(usize, 83279367), try solution2());
}
