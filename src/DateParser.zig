const std = @import("std");
const Year = std.time.epoch.Year;
const Month = std.time.epoch.Month;


pub fn fromSlice(slice: []const u8) !std.Io.Timestamp {
    var it = std.mem.splitAny(u8, slice, "- :");

    const year = try std.fmt.parseUnsigned(Year, it.next() orelse return error.InvalidFormat, 10);
    const month = try std.fmt.parseUnsigned(u64, it.next() orelse return error.InvalidFormat, 10);
    const day = try std.fmt.parseUnsigned(u64, it.next() orelse return error.InvalidFormat, 10);
    const hour = try std.fmt.parseUnsigned(u64, it.next() orelse return error.InvalidFormat, 10);
    const minute = try std.fmt.parseUnsigned(u64, it.next() orelse return error.InvalidFormat, 10);

    var epoch_seconds: u64 = 0;
    var y: Year = std.time.epoch.epoch_year;
    while (y < year) : (y += 1) {
        epoch_seconds += @as(u64, std.time.epoch.getDaysInYear(y)) * std.time.epoch.secs_per_day;
    }

    var m: Month = .jan;
    while (m.numeric() < month) : (m = @enumFromInt(m.numeric() + 1)) {
        epoch_seconds += @as(u64, std.time.epoch.getDaysInMonth(year, m)) * std.time.epoch.secs_per_day;
    }

    epoch_seconds += (day - 1) * std.time.epoch.secs_per_day;
    epoch_seconds += hour * std.time.s_per_hour;
    epoch_seconds += minute * std.time.s_per_min;

    return std.Io.Timestamp{ .nanoseconds = epoch_seconds * std.time.ns_per_s };
}