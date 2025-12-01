const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input11.txt");
const example =
    \\...#......
    \\.......#..
    \\#.........
    \\..........
    \\......#...
    \\.#........
    \\.........#
    \\..........
    \\.......#..
    \\#...#.....
;

const Map = std.ArrayList(Row);
const Row = std.ArrayListUnmanaged(bool);

pub fn solution1() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var map = Map.init(allocator);
    defer map.deinit();
    var lines = mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const row = try allocator.alloc(bool, line.len);
        for (line, row) |char, *cell| {
            cell.* = (char == '#');
        }
        try map.append(Row.fromOwnedSlice(row));
    }
    defer for (map.items) |*row| row.deinit(map.allocator);

    try expand(&map);

    var galaxies = std.ArrayList(@Vector(2, isize)).init(allocator);
    defer galaxies.deinit();

    for (map.items, 0..) |row, y| {
        for (row.items, 0..) |cell, x| {
            if (cell) {
                try galaxies.append(.{ @intCast(x), @intCast(y) });
            }
        }
    }

    var sum: usize = 0;
    for (galaxies.items, 1..) |g1, i| {
        for (galaxies.items[i..]) |g2| {
            sum += @reduce(.Add, @abs(g1 - g2));
        }
    }

    return sum;
}

pub fn solution2() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var map = Map.init(allocator);
    defer map.deinit();
    var lines = mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const row = try allocator.alloc(bool, line.len);
        for (line, row) |char, *cell| {
            cell.* = (char == '#');
        }
        try map.append(Row.fromOwnedSlice(row));
    }
    defer for (map.items) |*row| row.deinit(map.allocator);

    const is_empty_cols = try allocator.alloc(bool, map.items.len);
    defer allocator.free(is_empty_cols);
    @memset(is_empty_cols, true);
    const is_empty_rows = try allocator.alloc(bool, map.items[0].items.len);
    defer allocator.free(is_empty_rows);
    @memset(is_empty_rows, true);

    var galaxies = std.ArrayList(@Vector(2, usize)).init(allocator);
    defer galaxies.deinit();

    for (map.items, 0..) |row, y| {
        for (row.items, 0..) |cell, x| {
            if (cell) {
                try galaxies.append(.{ x, y });
                is_empty_cols[x] = false;
                is_empty_rows[y] = false;
            }
        }
    }

    var sum: usize = 0;
    for (galaxies.items, 1..) |g1, i| {
        const x1, const y1 = g1;
        for (galaxies.items[i..]) |g2| {
            const x2, const y2 = g2;
            for (@min(x1, x2)..@max(x1, x2)) |x| {
                sum += if (is_empty_cols[x]) 1_000_000 else 1;
            }
            for (@min(y1, y2)..@max(y1, y2)) |y| {
                sum += if (is_empty_rows[y]) 1_000_000 else 1;
            }
        }
    }

    return sum;
}

fn expand(map: *Map) !void {
    var i: usize = 0;
    while (i < map.items.len) : (i += 1) {
        if (mem.indexOfScalar(bool, map.items[i].items, true) == null) {
            const ext = try map.allocator.alloc(bool, map.items[i].items.len);
            @memset(ext, false);
            try map.insert(i, Row.fromOwnedSlice(ext));
            i += 1;
        }
    }

    var col: usize = 0;
    next: while (col < map.items[0].items.len) : (col += 1) {
        var row: usize = 0;
        while (row < map.items.len) : (row += 1) {
            if (map.items[row].items[col]) {
                continue :next;
            }
        }

        for (map.items) |*items| {
            try items.insert(map.allocator, col, false);
        }
        col += 1;
    }
}

test {
    try std.testing.expectEqual(@as(usize, 9799681), try solution1());
    try std.testing.expectEqual(@as(usize, 513171773355), try solution2());
}
