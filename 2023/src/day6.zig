const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const data = @embedFile("./data/input6.txt");
const use_example = false;

pub fn solution1() !usize {
    const times, const distances = if (use_example)
        .{ [_]usize{ 7, 15, 30 }, [_]usize{ 9, 40, 200 } }
    else
        .{ [_]usize{ 44, 80, 65, 72 }, [_]usize{ 208, 1581, 1050, 1102 } };

    var product: usize = 1;
    for (times, distances) |time, distance| {
        var ways: usize = 0;
        for (1..time - 1) |speed| {
            const traveled = speed * (time - speed);
            if (traveled > distance) {
                ways += 1;
            }
        }
        product *= ways;
    }
    return product;
}

pub fn solution2() !usize {
    const time = if (use_example) 71530 else 44806572;
    const distance = if (use_example) 940200 else 208158110501102;

    // x * (time - x) > distance => x^2 - (time * x) + distance > 0
    const a: f64 = 1;
    const b: f64 = -time;
    const c: f64 = distance;

    const delta = b * b - 4 * a * c;
    const x1 = (-b - @sqrt(delta)) / (2 * a);
    const x2 = (-b + @sqrt(delta)) / (2 * a);

    return @intFromFloat(@floor(x2) - @ceil(x1) + 1);
}

test {
    try std.testing.expectEqual(@as(usize, 32076), try solution1());
    try std.testing.expectEqual(@as(usize, 34278221), try solution2());
}
