const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input8.txt");
const example1 =
    \\RL
    \\
    \\AAA = (BBB, CCC)
    \\BBB = (DDD, EEE)
    \\CCC = (ZZZ, GGG)
    \\DDD = (DDD, DDD)
    \\EEE = (EEE, EEE)
    \\GGG = (GGG, GGG)
    \\ZZZ = (ZZZ, ZZZ)
;
const example2 =
    \\LLR
    \\
    \\AAA = (BBB, BBB)
    \\BBB = (AAA, ZZZ)
    \\ZZZ = (ZZZ, ZZZ)
;
const example3 =
    \\LR
    \\
    \\11A = (11B, XXX)
    \\11B = (XXX, 11Z)
    \\11Z = (11B, XXX)
    \\22A = (22B, XXX)
    \\22B = (22C, 22C)
    \\22C = (22Z, 22Z)
    \\22Z = (22B, 22B)
    \\XXX = (XXX, XXX)
;

const Node = struct {
    left: *const [3]u8,
    right: *const [3]u8,
};

pub fn solution1() !usize {
    const input = data;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var network = std.StringHashMap(Node).init(gpa.allocator());
    defer network.deinit();

    const delim_i = mem.indexOf(u8, input, "\n\n").?;
    const instructions = input[0..delim_i];
    var nodes = mem.tokenizeScalar(u8, input[delim_i + 2 ..], '\n');
    while (nodes.next()) |node| {
        try network.putNoClobber(node[0..3], .{
            .left = node[7..10],
            .right = node[12..15],
        });
    }

    var key: *const [3]u8 = "AAA";
    var steps: usize = 0;
    out: while (true) {
        for (instructions) |instruction| {
            if (mem.eql(u8, key, "ZZZ")) {
                break :out;
            }
            const node = network.get(key).?;
            switch (instruction) {
                'L' => key = node.left,
                'R' => key = node.right,
                else => unreachable,
            }
            steps += 1;
        }
    }

    return steps;
}

pub fn solution2() !usize {
    const input = data;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var network = std.StringHashMap(Node).init(gpa.allocator());
    defer network.deinit();
    var keys = std.ArrayList(*const [3]u8).init(gpa.allocator());
    defer keys.deinit();

    const delim_i = mem.indexOf(u8, input, "\n\n").?;
    const instructions = input[0..delim_i];
    var nodes = mem.tokenizeScalar(u8, input[delim_i + 2 ..], '\n');
    while (nodes.next()) |node| {
        const key = node[0..3];
        if (key[2] == 'A') {
            try keys.append(key);
        }
        try network.putNoClobber(key, .{
            .left = node[7..10],
            .right = node[12..15],
        });
    }

    var res: usize = 1;
    for (keys.items) |*key| {
        var steps: usize = 0;
        out: while (true) {
            for (instructions) |instruction| {
                if (key.*[2] == 'Z') {
                    break :out;
                }
                const node = network.get(key.*).?;
                switch (instruction) {
                    'L' => key.* = node.left,
                    'R' => key.* = node.right,
                    else => unreachable,
                }
                steps += 1;
            }
        }
        res = lcm(res, steps);
    }

    return res;
}

fn lcm(a: anytype, b: anytype) @TypeOf(a, b) {
    return @abs(a * b) / std.math.gcd(a, b);
}

test {
    try std.testing.expectEqual(@as(usize, 24253), try solution1());
    try std.testing.expectEqual(@as(usize, 12357789728873), try solution2());
}
