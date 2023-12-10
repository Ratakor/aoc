const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const data = @embedFile("./data/input9.txt");
const example =
    \\0 3 6 9 12 15
    \\1 3 6 10 15 21
    \\10 13 16 21 30 45
;

pub fn solution1() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var list = std.ArrayList(isize).init(gpa.allocator());
    defer list.deinit();

    var result: isize = 0;
    var lines = mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var numbers = mem.tokenizeScalar(u8, line, ' ');
        while (numbers.next()) |number| {
            try list.append(try parseInt(isize, number, 10));
        }

        while (mem.indexOfNone(isize, list.items, &[_]isize{0})) |_| {
            var i: usize = 0;
            while (i < list.items.len - 1) : (i += 1) {
                list.items[i] = list.items[i + 1] - list.items[i];
            }
            result += list.pop();
        }

        list.clearRetainingCapacity();
    }

    return @intCast(result);
}

pub fn solution2() !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var list = std.ArrayList(isize).init(gpa.allocator());
    defer list.deinit();

    var result: isize = 0;
    var lines = mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var numbers = mem.tokenizeScalar(u8, line, ' ');
        while (numbers.next()) |number| {
            try list.append(try parseInt(isize, number, 10));
        }

        mem.reverse(isize, list.items);

        while (mem.indexOfNone(isize, list.items, &[_]isize{0})) |_| {
            var i: usize = 0;
            while (i < list.items.len - 1) : (i += 1) {
                list.items[i] = list.items[i + 1] - list.items[i];
            }
            result += list.pop();
        }

        list.clearRetainingCapacity();
    }

    return @intCast(result);
}

test {
    try std.testing.expectEqual(@as(usize, 1980437560), try solution1());
    try std.testing.expectEqual(@as(usize, 977), try solution2());
}
