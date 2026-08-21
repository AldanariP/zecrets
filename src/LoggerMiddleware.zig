const std = @import("std");
const httpz = @import("httpz");

const Logger = @This();

io: std.Io,

pub fn init(config: Config) !Logger {
    return .{
        .io = config.io,
    };
}

const month_names = [_][]const u8{
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
};

pub fn execute(self: *const Logger, req: *httpz.Request, res: *httpz.Response, executor: anytype) !void {

    defer {
        const now = std.Io.Timestamp.now(self.io, .real);

        var ip_string_buf: [15]u8 = undefined;
        const ip = req.address.ip4;
        const ip_string = std.fmt.bufPrint(
            &ip_string_buf,
            "{d}.{d}.{d}.{d}",
            .{ip.bytes[0], ip.bytes[1], ip.bytes[2], ip.bytes[3]}
        ) catch unreachable;

        const epoch_seconds: std.time.epoch.EpochSeconds = .{ .secs = @intCast(now.toSeconds()) };
        const day_seconds = epoch_seconds.getDaySeconds();
        const epoch_day = epoch_seconds.getEpochDay();
        const year_day = epoch_day.calculateYearDay();
        const month_day = year_day.calculateMonthDay();
        const month_name = month_names[month_day.month.numeric() - 1];

        const protocol_string = switch (req.protocol) {
            .HTTP10 => "HTTP/1.0",
            .HTTP11 => "HTTP/1.1",
        };

        const method_string = switch (req.method) {
            .OTHER => req.method_string,
            else => @tagName(req.method)
        };

        std.log.info(
            "{s} - - [{d:0>2}/{s}/{d}:{d:0>2}:{d:0>2}:{d:0>2} +0000] \"{s} {s} {s}\" {d} {d} {s} {s}",
            .{
                ip_string,
                month_day.day_index + 1,
                month_name,
                year_day.year,
                day_seconds.getHoursIntoDay(),
                day_seconds.getSecondsIntoMinute(),
                day_seconds.getSecondsIntoMinute(),
                method_string,
                req.url.path,
                protocol_string,
                res.status,
                res.body.len,
                req.headers.get("referer") orelse "-",
                req.headers.get("user-agent") orelse "-"
            }
        );
    }

    return executor.next();
}

pub const Config = struct {
    io: std.Io
};