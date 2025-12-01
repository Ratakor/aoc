const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input15.txt");
const example = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";
const Box = std.StringArrayHashMapUnmanaged(u8);

pub fn solution1() !usize {
    var sum: usize = 0;
    var init_seq = mem.tokenizeScalar(u8, data[0 .. data.len - 1], ',');
    while (init_seq.next()) |step| {
        sum += HASH(step);
    }
    return sum;
}

pub fn solution2() !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var boxes = [_]Box{.{}} ** 256;
    var init_seq = mem.tokenizeScalar(u8, data[0 .. data.len - 1], ',');
    while (init_seq.next()) |step| {
        const i = mem.indexOfAny(u8, step, "=-").?;
        const label = step[0..i];
        const id = HASH(label);

        if (step[i] == '=') {
            const focal_length = try parseUnsigned(u8, step[i + 1 ..], 10);
            try boxes[id].put(allocator, label, focal_length);
        } else {
            _ = boxes[id].orderedRemove(label);
        }
    }

    var focusing_power: usize = 0;
    for (boxes, 1..) |box, id| {
        var slot: usize = 1;
        var iter = box.iterator();
        while (iter.next()) |entry| : (slot += 1) {
            focusing_power += id * slot * entry.value_ptr.*;
        }
    }

    return focusing_power;
}

fn HASH(str: []const u8) u8 {
    var n: u64 = 0;
    for (str) |char| {
        n += char;
        n *= 17;
        n %= 256;
    }
    return @intCast(n);
}

test {
    try std.testing.expectEqual(@as(usize, 511416), try solution1());
    try std.testing.expectEqual(@as(usize, 290779), try solution2());
}
