const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input12.txt");
const example =
    \\???.### 1,1,3
    \\.??..??...?##. 1,1,3
    \\?#?#?#?#?#?#?#? 1,3,1,6
    \\????.#...#... 4,1,1
    \\????.######..#####. 1,6,5
    \\?###???????? 3,2,1
;

pub fn solution1() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var groups = std.ArrayList(usize).init(allocator);
    defer groups.deinit();

    var sum: usize = 0;
    var lines = mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const delim = mem.indexOfScalar(u8, line, ' ').?;
        // const springs = line[0..delim];
        var sizes = mem.tokenizeScalar(u8, line[delim + 1 ..], ',');

        const springs = try allocator.alloc(u8, line[0..delim].len + 2);
        defer allocator.free(springs);
        springs[0] = '.';
        @memcpy(springs[1 .. springs.len - 1], line[0..delim]);
        springs[springs.len - 1] = '.';

        while (sizes.next()) |size| {
            try groups.append(try parseUnsigned(usize, size, 10));
        }

        sum += try solve(allocator, springs, groups.items);

        groups.clearRetainingCapacity();
    }

    return sum;
}

pub fn solution2() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var groups = std.ArrayList(usize).init(allocator);
    defer groups.deinit();

    var sum: usize = 0;
    var lines = mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const delim = mem.indexOfScalar(u8, line, ' ').?;
        var sizes = mem.tokenizeScalar(u8, line[delim + 1 ..], ',');

        const springs = try allocator.alloc(u8, 5 * line[0..delim].len + 6);
        defer allocator.free(springs);

        springs[0] = '.';
        inline for (0..5) |i| {
            @memcpy(
                springs[i * line[0..delim].len + i + 1 .. (i + 1) * line[0..delim].len + i + 1],
                line[0..delim],
            );
            springs[(i + 1) * line[0..delim].len + i + 1] = '?';
        }
        springs[springs.len - 1] = '.';

        for (0..5) |_| {
            while (sizes.next()) |size| {
                try groups.append(try parseUnsigned(usize, size, 10));
            }
            sizes.reset();
        }

        sum += try solve(allocator, springs, groups.items);

        groups.clearRetainingCapacity();
    }

    return sum;
}

fn solve(allocator: mem.Allocator, springs: []const u8, groups: []const usize) !usize {
    var operationals_count = try allocator.alloc(usize, springs.len + 1);
    defer allocator.free(operationals_count);
    operationals_count[0] = 0;
    for (springs, 1..) |spring, i| {
        switch (spring) {
            '#', '?' => operationals_count[i] = operationals_count[i - 1] + 1,
            else => operationals_count[i] = operationals_count[i - 1],
        }
    }

    const dp = try allocator.alloc([]usize, springs.len + 1);
    defer allocator.free(dp);
    for (dp) |*row| {
        row.* = try allocator.alloc(usize, groups.len + 1);
        @memset(row.*, 0);
    }
    defer for (dp) |row| allocator.free(row);

    dp[springs.len][groups.len] = 1;
    var k = springs.len - 1;
    while (springs[k] != '#') : (k -= 1) {
        dp[k][groups.len] = 1;
        if (k == 0) break;
    }

    var j = groups.len - 1;
    while (true) : (j -= 1) {
        var i = springs.len - groups[j];
        while (i > 0) : (i -= 1) {
            if (springs[i - 1] != '#' and
                operationals_count[i + groups[j]] - operationals_count[i] == groups[j] and
                springs[i + groups[j]] != '#')
            {
                dp[i][j] += dp[i + groups[j] + 1][j + 1];
            }

            if (springs[i] != '#') {
                dp[i][j] += dp[i + 1][j];
            }
        }
        if (j == 0) break;
    }

    return dp[1][0];
}

test {
    try std.testing.expectEqual(@as(usize, 7922), try solution1());
    try std.testing.expectEqual(@as(usize, 18093821750095), try solution2());
}
