const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day_num = try findTargetDay(b);
    try createDaySources(b, day_num);

    const day_src_path = try std.fmt.allocPrint(b.allocator, "src/day{}.zig", .{day_num});
    const day_module = b.addModule("aoc-day", .{ .source_file = .{ .path = day_src_path } });

    const exe = b.addExecutable(.{
        .name = "aoc-zig",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("aoc-day", day_module);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const fmt_step = b.step("fmt", "Format all source files");
    fmt_step.dependOn(&b.addFmt(.{ .paths = &.{ "build.zig", "src" } }).step);

    const clean_step = b.step("clean", "Delete all artifacts created by zig build");
    clean_step.dependOn(&b.addRemoveDirTree("zig-cache").step);
    clean_step.dependOn(&b.addRemoveDirTree("zig-out").step);
}

fn findTargetDay(b: *std.Build) !u32 {
    const day_num = b.option(u32, "day", "Advent of code target day") orelse blk: {
        var buffer: ["src/dayXX.zig".len]u8 = undefined;
        var i: u32 = 25;
        while (i > 0) : (i -= 1) {
            const path = try std.fmt.bufPrint(buffer[0..], "src/day{}.zig", .{i});
            b.build_root.handle.access(path, .{}) catch continue;
            break :blk i;
        }
        break :blk 1;
    };

    if (day_num == 0 or day_num > 25) {
        return error.InvalidDay;
    }

    return day_num;
}

fn createDaySources(b: *std.Build, day_num: u32) !void {
    const root = b.build_root.handle;

    try root.makePath("src/data");

    const src_path = try std.fmt.allocPrint(b.allocator, "src/day{}.zig", .{day_num});
    const input_path = try std.fmt.allocPrint(b.allocator, "src/data/input{}.txt", .{day_num});

    root.access(src_path, .{}) catch {
        const src_file = try root.createFile(src_path, .{});
        defer src_file.close();

        const template = @embedFile("src/template.zig");
        const idx = std.mem.indexOfScalar(u8, template, '$') orelse return error.InvalidTemplate;
        const day_str = try std.fmt.allocPrint(b.allocator, "{}", .{day_num});
        const day_code = try std.mem.concat(b.allocator, u8, &[_][]const u8{
            template[0..idx],
            day_str,
            template[idx + 1 ..],
        });

        try src_file.writeAll(day_code);
    };

    root.access(input_path, .{}) catch {
        const input_file = try root.createFile(input_path, .{});
        input_file.close();
    };
}
