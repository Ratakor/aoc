const std = @import("std");
const mem = std.mem;
const meta = std.meta;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input10.txt");

const Coord = @Vector(2, usize); // .{ x, y }
const Direction = @Vector(2, isize); // .{ x, y }

const north: Direction = .{ 0, -1 };
const south: Direction = .{ 0, 1 };
const west: Direction = .{ -1, 0 };
const east: Direction = .{ 1, 0 };
const directions = [_]Direction{ north, south, west, east };

const pipes = std.ComptimeStringMap([2]Direction, .{
    .{ "|", .{ north, south } },
    .{ "-", .{ east, west } },
    .{ "L", .{ north, east } },
    .{ "J", .{ north, west } },
    .{ "7", .{ south, west } },
    .{ "F", .{ south, east } },
});

pub fn solution1() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const grid = try makeGrid(allocator, data);
    defer allocator.free(grid);

    const start = findStart(grid);
    var direction = findFirstDirection(grid, start);
    var previous = start;
    var current = add(previous, direction);

    var loop_size: usize = 1;
    while (!meta.eql(current, start)) : (loop_size += 1) {
        const tile = [_]u8{grid[current[1]][current[0]]};
        const d1, const d2 = pipes.get(&tile) orelse unreachable;
        direction = if (meta.eql(d1, -direction)) d2 else d1;
        const next = add(current, direction);
        previous = current;
        current = next;
    }

    return loop_size / 2;
}

pub fn solution2() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const grid = try makeGrid(allocator, data);
    defer allocator.free(grid);

    const start = findStart(grid);
    var direction = findFirstDirection(grid, start);
    var previous = start;
    var current = add(previous, direction);

    const map = blk: {
        const map = try allocator.alloc([]bool, grid.len);
        for (grid, map) |row, *map_row| {
            map_row.* = try allocator.alloc(bool, row.len);
        }
        break :blk map;
    };
    defer {
        for (map) |row| allocator.free(row);
        allocator.free(map);
    }

    map[start[1]][start[0]] = true;
    while (!meta.eql(current, start)) {
        map[current[1]][current[0]] = true;
        const tile = [_]u8{grid[current[1]][current[0]]};
        const d1, const d2 = pipes.get(&tile) orelse unreachable;
        direction = if (meta.eql(d1, -direction)) d2 else d1;
        const next = add(current, direction);
        previous = current;
        current = next;
    }

    var count: usize = 0;
    for (grid, map) |row, map_row| {
        var inside = false;
        var last: u8 = 0;
        for (row, map_row) |tile, is_loop| {
            if (!is_loop) {
                if (inside) {
                    count += 1;
                }
            } else switch (tile) {
                '|' => inside = !inside,
                'L', 'F' => last = tile,
                'J' => {
                    if (last == 'F') {
                        inside = !inside;
                    }
                    last = 0;
                },
                '7' => {
                    if (last == 'L') {
                        inside = !inside;
                    }
                    last = 0;
                },
                else => {},
            }
        }
    }

    return count;
}

inline fn add(a: anytype, b: anytype) @TypeOf(a) {
    return a +% @as(@TypeOf(a), @bitCast(b));
}

fn makeGrid(allocator: mem.Allocator, input: []const u8) ![]const []const u8 {
    var list = std.ArrayList([]const u8).init(allocator);
    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try list.append(line);
    }
    return try list.toOwnedSlice();
}

fn findStart(grid: []const []const u8) Coord {
    for (grid, 0..) |row, y| {
        for (row, 0..) |tile, x| {
            if (tile == 'S') {
                return .{ x, y };
            }
        }
    }
    unreachable;
}

fn findFirstDirection(grid: []const []const u8, start: Coord) Direction {
    for (directions) |direction| {
        const next = add(start, direction);
        const tile = [_]u8{grid[next[1]][next[0]]};
        const d1, const d2 = pipes.get(&tile) orelse continue;
        if (meta.eql(d1, -direction) or meta.eql(d2, -direction)) {
            return direction;
        }
    }
    unreachable;
}

test {
    try std.testing.expectEqual(@as(usize, 6979), try solution1());
    try std.testing.expectEqual(@as(usize, 443), try solution2());
}
