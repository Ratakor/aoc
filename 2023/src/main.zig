const std = @import("std");
const day = @import("aoc-day");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Solution 1: {}\n", .{try day.solution1()});
    try stdout.print("Solution 2: {}\n", .{try day.solution2()});
}
