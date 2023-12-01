const std = @import("std");

var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
const allocator = gpa.allocator();

const data = @embedFile("data/input$.txt");

pub fn solution1() !usize {
    return error.TODO;
}

pub fn solution2() !usize {
    return error.TODO;
}
