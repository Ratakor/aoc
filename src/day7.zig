const std = @import("std");
const mem = std.mem;
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;
const data = @embedFile("./data/input7.txt");
const example =
    \\32T3K 765
    \\T55J5 684
    \\KK677 28
    \\KTJJT 220
    \\QQQJA 483
;

const Hand = struct {
    strength: u64,
    bid: u64,

    fn lessThan(_: void, lhs: Hand, rhs: Hand) bool {
        return lhs.strength < rhs.strength;
    }
};

pub fn solution1() !usize {
    return solve(data, false);
}

pub fn solution2() !usize {
    return solve(data, true);
}

fn solve(comptime input: []const u8, comptime has_joker: bool) !usize {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var hands = std.ArrayList(Hand).init(gpa.allocator());
    defer hands.deinit();

    var lines = mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const hand = line[0..5];
        try hands.append(.{
            .strength = computeStrength(hand, has_joker),
            .bid = try parseUnsigned(u64, line[hand.len + 1 ..], 10),
        });
    }

    mem.sort(Hand, hands.items, {}, Hand.lessThan);

    var winnings: usize = 0;
    for (hands.items, 1..) |hand, rank| {
        winnings += hand.bid * rank;
    }

    return winnings;
}

fn cardValue(card: u8, comptime has_joker: bool) u8 {
    return switch (card) {
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => if (has_joker) 1 else 11,
        'T' => 10,
        else => card - '0',
    };
}

fn computeStrength(hand: *const [5]u8, comptime has_joker: bool) u64 {
    var weights = [_]u8{0} ** 13;
    inline for (hand) |card| {
        const idx = cardValue(card, false) - 2;
        weights[idx] += 1;
    }

    if (has_joker) {
        const joker_count = weights[9];
        weights[9] = 0;
        const idx = mem.indexOfMax(u8, &weights);
        weights[idx] += joker_count;
    }

    var strength: u64 = blk: {
        var three = false;
        var pairs: usize = 0;
        for (weights) |weight| {
            switch (weight) {
                5 => break :blk 6, // Five of a kind
                4 => break :blk 5, // Four of a kind
                3 => three = true,
                2 => pairs += 1,
                else => {},
            }
        }
        if (three) {
            if (pairs == 1) break :blk 4; // Full house
            break :blk 3; // Three of a kind
        }
        if (pairs == 2) break :blk 2; // Tow pair
        if (pairs == 1) break :blk 1; // One pair
        break :blk 0; // High Card
    };

    inline for (hand) |card| {
        strength <<= 8;
        strength += cardValue(card, has_joker);
    }

    return strength;
}

test {
    try std.testing.expectEqual(@as(usize, 250347426), try solution1());
    try std.testing.expectEqual(@as(usize, 251224870), try solution2());
}
