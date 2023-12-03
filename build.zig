const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day = try findTargetDay(b);
    try createDaySources(b, day);

    const day_path = b.fmt("src/day{}.zig", .{day});
    const day_module = b.addModule("aoc-day", .{ .source_file = .{ .path = day_path } });

    const exe = b.addExecutable(.{
        .name = b.fmt("aoc-day{}", .{day}),
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("aoc-day", day_module);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the target day");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Check if the answers are valid");
    var buffer: ["src/dayXX.zig".len]u8 = undefined;
    for (1..25 + 1) |i| {
        const path = try std.fmt.bufPrint(buffer[0..], "src/day{}.zig", .{i});
        b.build_root.handle.access(path, .{}) catch continue;
        const day_test = b.addTest(.{
            .root_source_file = .{ .path = path },
            .target = target,
            .optimize = optimize,
        });
        test_step.dependOn(&b.addRunArtifact(day_test).step);
    }

    const fmt_step = b.step("fmt", "Format all source files");
    fmt_step.dependOn(&b.addFmt(.{ .paths = &.{ "build.zig", "src" } }).step);

    const clean_step = b.step("clean", "Delete all artifacts created by zig build");
    clean_step.dependOn(&b.addRemoveDirTree("zig-cache").step);
    clean_step.dependOn(&b.addRemoveDirTree("zig-out").step);
}

fn findTargetDay(b: *std.Build) !u32 {
    const day = b.option(u32, "day", "Advent of code target day") orelse blk: {
        var buffer: ["src/dayXX.zig".len]u8 = undefined;
        var i: u32 = 25;
        while (i > 0) : (i -= 1) {
            const path = try std.fmt.bufPrint(buffer[0..], "src/day{}.zig", .{i});
            b.build_root.handle.access(path, .{}) catch continue;
            break :blk i;
        }
        break :blk 1;
    };

    if (day == 0 or day > 25) {
        return error.InvalidDay;
    }

    return day;
}

fn createDaySources(b: *std.Build, day: u32) !void {
    const root = b.build_root.handle;
    try root.makePath("src/data");

    const src_path = b.fmt("src/day{}.zig", .{day});
    const input_path = b.fmt("src/data/input{}.txt", .{day});

    root.access(src_path, .{}) catch {
        const src_file = try root.createFile(src_path, .{});
        defer src_file.close();

        const template = @embedFile("src/template.zig");
        const idx = std.mem.indexOfScalar(u8, template, '$') orelse return error.InvalidTemplate;
        const day_code = try std.mem.concat(b.allocator, u8, &[_][]const u8{
            template[0..idx],
            b.fmt("{}", .{day}),
            template[idx + 1 ..],
        });

        try src_file.writeAll(day_code);
    };

    root.access(input_path, .{}) catch {
        const input_file = try root.createFile(input_path, .{});
        input_file.close();
    };
}
