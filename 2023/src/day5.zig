const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const data = @embedFile("./data/input5.txt");
const example =
    \\seeds: 79 14 55 13
    \\
    \\seed-to-soil map:
    \\50 98 2
    \\52 50 48
    \\
    \\soil-to-fertilizer map:
    \\0 15 37
    \\37 52 2
    \\39 0 15
    \\
    \\fertilizer-to-water map:
    \\49 53 8
    \\0 11 42
    \\42 0 7
    \\57 7 4
    \\
    \\water-to-light map:
    \\88 18 7
    \\18 25 70
    \\
    \\light-to-temperature map:
    \\45 77 23
    \\81 45 19
    \\68 64 13
    \\
    \\temperature-to-humidity map:
    \\0 69 1
    \\1 0 69
    \\
    \\humidity-to-location map:
    \\60 56 37
    \\56 93 4
;

const Range = struct {
    start: usize,
    length: usize,

    inline fn end(self: Range) usize {
        return self.start + self.length;
    }
};

// a lot of bytes wasted but idc
const Map = struct {
    destinations: []Range,
    sources: []Range,

    const names = [_][]const u8{
        "seed-to-soil",
        "soil-to-fertilizer",
        "fertilizer-to-water",
        "water-to-light",
        "light-to-temperature",
        "temperature-to-humidity",
        "humidity-to-location",
    };

    fn init(allocator: mem.Allocator, input: []const u8, map_name: []const u8) !Map {
        var destinations: std.ArrayListUnmanaged(Range) = .{};
        var sources: std.ArrayListUnmanaged(Range) = .{};

        const map_name_start = mem.indexOf(u8, input, map_name).?;
        const start = mem.indexOfScalarPos(u8, input, map_name_start, '\n').? + 1;
        const end = mem.indexOfPos(u8, input, start, "\n\n") orelse input.len;
        var iter = mem.tokenizeScalar(u8, input[start..end], '\n');
        while (iter.next()) |line| {
            const end_first = mem.indexOfScalar(u8, line, ' ').?;
            const end_second = mem.lastIndexOfScalar(u8, line, ' ').?;

            const dst_range_start = try std.fmt.parseUnsigned(usize, line[0..end_first], 10);
            const src_range_start = try std.fmt.parseUnsigned(usize, line[end_first + 1 .. end_second], 10);
            const range_len = try std.fmt.parseUnsigned(usize, line[end_second + 1 ..], 10);

            try destinations.append(allocator, .{ .start = dst_range_start, .length = range_len });
            try sources.append(allocator, .{ .start = src_range_start, .length = range_len });
        }

        return .{
            .destinations = try destinations.toOwnedSlice(allocator),
            .sources = try sources.toOwnedSlice(allocator),
        };
    }
};

pub fn solution1() !usize {
    const input = data;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const seeds = blk: {
        var list: std.ArrayListUnmanaged(usize) = .{};
        const start = mem.indexOfScalar(u8, input, ':').? + 2;
        const end = mem.indexOfScalar(u8, input, '\n').?;
        var iter = mem.tokenizeScalar(u8, input[start..end], ' ');
        while (iter.next()) |seed| {
            try list.append(allocator, try std.fmt.parseUnsigned(usize, seed, 10));
        }
        break :blk try list.toOwnedSlice(allocator);
    };

    for (Map.names) |name| {
        const map = try Map.init(allocator, input, name);
        for (seeds) |*seed| {
            for (map.destinations, map.sources) |dst, src| {
                if (seed.* >= src.start and seed.* < src.end()) {
                    seed.* = seed.* + dst.start - src.start;
                    break;
                }
            }
        }
    }

    return mem.min(usize, seeds);
}

pub fn solution2() !usize {
    const input = data;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var seed_ranges = blk: {
        var list: std.ArrayListUnmanaged(Range) = .{};
        const start = mem.indexOfScalar(u8, input, ':').? + 2;
        const end = mem.indexOfScalar(u8, input, '\n').?;
        var iter = mem.tokenizeScalar(u8, input[start..end], ' ');
        while (iter.next()) |seed_start| {
            const seed_len = iter.next().?;
            try list.append(allocator, .{
                .start = try std.fmt.parseUnsigned(usize, seed_start, 10),
                .length = try std.fmt.parseUnsigned(usize, seed_len, 10),
            });
        }
        break :blk list;
    };

    // this is terrible
    for (Map.names) |name| {
        const map = try Map.init(allocator, input, name);
        var new: std.ArrayListUnmanaged(Range) = .{};

        while (seed_ranges.items.len > 0) {
            const range = seed_ranges.pop();
            for (map.destinations, map.sources) |dst, src| {
                const overlap_start = @max(range.start, src.start);
                const overlap_end = @min(range.end(), src.end());
                if (overlap_start < overlap_end) {
                    try new.append(allocator, .{
                        .start = overlap_start + dst.start - src.start,
                        .length = overlap_end - overlap_start,
                    });

                    if (overlap_start > range.start) {
                        try seed_ranges.append(allocator, .{
                            .start = range.start,
                            .length = overlap_start - range.start,
                        });
                    }

                    if (range.end() > overlap_end) {
                        try seed_ranges.append(allocator, .{
                            .start = overlap_end,
                            .length = range.end() - overlap_end,
                        });
                    }

                    break;
                }
            } else {
                try new.append(allocator, range);
            }
        }

        seed_ranges = new;
    }

    var lowest: usize = seed_ranges.items[0].start;
    for (seed_ranges.items[1..]) |range| {
        lowest = @min(lowest, range.start);
    }
    return lowest;
}

test {
    try std.testing.expectEqual(@as(usize, 382895070), try solution1());
    try std.testing.expectEqual(@as(usize, 17729182), try solution2());
}
