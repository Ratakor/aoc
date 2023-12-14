const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input14.txt");
const example =
    \\O....#....
    \\O.OO#....#
    \\.....##...
    \\OO.#O....O
    \\.O.....O#.
    \\O.#..O.#.#
    \\..O..#O..O
    \\.......O..
    \\#....###..
    \\#OO..#....
;

const Orientation = enum { north, west, south, east };

pub fn solution1() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const grid = try makeGrid(allocator, data);
    defer freeGrid(allocator, grid);

    tilt(.north, grid);

    var load: usize = 0;
    for (grid, 0..) |row, offset| {
        for (row) |case| {
            if (case == 'O') {
                load += grid.len - offset;
            }
        }
    }

    return load;
}

pub fn solution2() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const grid = try makeGrid(allocator, data);
    defer freeGrid(allocator, grid);

    // for (0..1000000000) |_| {
    for (0..1000) |_| {
        tilt(.north, grid);
        tilt(.west, grid);
        tilt(.south, grid);
        tilt(.east, grid);
    }

    var load: usize = 0;
    for (grid, 0..) |row, offset| {
        for (row) |case| {
            if (case == 'O') {
                load += grid.len - offset;
            }
        }
    }

    return load;
}

fn tilt(comptime orientation: Orientation, grid: [][]u8) void {
    switch (orientation) {
        .north => rotateLeft(grid),
        .west => {
            rotateRight(grid);
            rotateRight(grid);
        },
        .south => rotateRight(grid),
        .east => {},
    }

    var grid_changed = false;
    while (true) {
        for (grid) |row| {
            var i: usize = 0;
            while (i < row.len) : (i += 1) {
                if (row[i] != 'O') continue;

                const orig = i;
                i += 1;
                while (i < row.len and row[i] == '.') {
                    i += 1;
                }
                if (orig != i - 1) {
                    row[orig] = '.';
                    row[i - 1] = 'O';
                    grid_changed = true;
                }
                i -= 1;
            }
        }

        if (grid_changed) {
            grid_changed = false;
        } else {
            break;
        }
    }

    switch (orientation) {
        .north => rotateRight(grid),
        .west => {
            rotateLeft(grid);
            rotateLeft(grid);
        },
        .south => rotateLeft(grid),
        .east => {},
    }
}

fn rotateRight(grid: [][]u8) void {
    const n = grid.len;
    for (0..n / 2) |i| {
        for (i..n - i - 1) |j| {
            const tmp = grid[i][j];
            grid[i][j] = grid[j][n - i - 1];
            grid[j][n - i - 1] = grid[n - i - 1][n - j - 1];
            grid[n - i - 1][n - j - 1] = grid[n - j - 1][i];
            grid[n - j - 1][i] = tmp;
        }
    }
}

fn rotateLeft(grid: [][]u8) void {
    const n = grid.len;
    for (0..n / 2) |i| {
        for (i..n - i - 1) |j| {
            const tmp = grid[n - j - 1][i];
            grid[n - j - 1][i] = grid[n - i - 1][n - j - 1];
            grid[n - i - 1][n - j - 1] = grid[j][n - i - 1];
            grid[j][n - i - 1] = grid[i][j];
            grid[i][j] = tmp;
        }
    }
}

fn makeGrid(allocator: mem.Allocator, input: []const u8) ![][]u8 {
    var list = std.ArrayList([]u8).init(allocator);
    errdefer list.deinit();

    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try list.append(try allocator.dupe(u8, line));
    }
    return list.toOwnedSlice();
}

fn freeGrid(allocator: mem.Allocator, grid: [][]u8) void {
    for (grid) |row| {
        allocator.free(row);
    }
    allocator.free(grid);
}

test {
    try std.testing.expectEqual(@as(usize, 110128), try solution1());
    try std.testing.expectEqual(@as(usize, 103861), try solution2());
}
