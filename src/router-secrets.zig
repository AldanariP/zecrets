const std = @import("std");

const httpz = @import("httpz");
const datastar = @import("datastar");

const App = @import("main.zig").App;
const Date = @import("DateParser.zig");

fn readSignals(comptime T: type, req: *httpz.Request) !T {
    const arena = req.arena;
    const json_text: []const u8 = switch (req.method) {
        .GET => blk: {
            const qs = try req.query();
            break :blk qs.get("datastar") orelse return error.MissingDatastarKey;
        },
        else => req.body() orelse return error.MissingBody,
    };
    std.log.debug("{s}", .{json_text});
    return std.json.parseFromSliceLeaky(
        T,
        arena,
        json_text,
        .{ .ignore_unknown_fields = true },
    );
}

pub fn secretByDuration(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const Signals = struct {
        ciphertext: []const u8,
        iv: []const u8,
        deleteOnFirstView: bool,
        hours: usize,
        minutes: usize,
    };
    const signals = readSignals(Signals, req) catch |err| {
        std.log.warn("{any}", .{err});
        res.setStatus(.bad_request);
        return;
    };
    std.log.debug("signals: {any}", .{signals});

    var id: u32 = undefined;
    try std.Io.randomSecure(req.conn.io, std.mem.asBytes(&id));

    const duration = blk: {
        const hours_s: i64 = @intCast(signals.hours * std.time.s_per_hour);
        const minutes_s: i64 = @intCast(signals.minutes * std.time.s_per_min);
        break :blk std.Io.Duration.fromSeconds(hours_s + minutes_s);
    };
    std.log.debug("duration: {f}", .{duration});

    const expire_at = std.Io.Timestamp.now(res.conn.io, .real).addDuration(duration).toSeconds();

    app.store.put(req.conn.io, id, .{
        .ciphertext = signals.ciphertext,
        .iv = signals.iv,
        .delete_on_first_view = signals.deleteOnFirstView,
        .expires_at = expire_at
    }) catch |err| switch (err) {
        error.SecretAlreadyExists => {
            std.log.warn("{any}", .{err});
            res.setStatus(.bad_request);
            return;
        },
        else => return err
    };

    res.body = try datastar.patchSignals(req.arena, .{ .secretId = id }, .{});
}

pub fn secretByDate(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const Signals = struct {
        ciphertext: []const u8,
        iv: []const u8,
        deleteOnFirstView: bool,
        date: []const u8,
        time: []const u8,
    };
    const signals = readSignals(Signals, req) catch |err| {
        std.log.warn("{any}", .{err});
        res.setStatus(.bad_request);
        return;
    };

    var datetime_buf: [16]u8 = undefined;
    const datetime = std.fmt.bufPrint(
        &datetime_buf,
        "{s} {s}",
        .{signals.date, signals.time}
    ) catch |err| switch (err) {
        error.NoSpaceLeft => {
            std.log.warn("{any}", .{err});
            res.setStatus(.bad_request);
            return;
        }
    };
    const expire_at = Date.fromSlice(datetime) catch |err| {
        std.log.warn("{any}", .{err});
        res.setStatus(.bad_request);
        return;
    };

    var id: u32 = undefined;
    try std.Io.randomSecure(req.conn.io, std.mem.asBytes(&id));
    app.store.put(req.conn.io, id, .{
        .ciphertext = signals.ciphertext,
        .iv = signals.iv,
        .delete_on_first_view = signals.deleteOnFirstView,
        .expires_at = expire_at.toSeconds()
    }) catch |err| switch (err) {
        error.SecretAlreadyExists => {
            std.log.warn("{any}", .{err});
            res.setStatus(.bad_request);
            return;
        },
        else => return err
    };

    res.body = try datastar.patchSignals(req.arena, .{ .secretId = id }, .{});
}


pub fn getSecret(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const id_param = req.param("id") orelse {
        res.setStatus(.bad_request);
        return;
    };
    const secret_id = std.fmt.parseUnsigned(u32, id_param, 10) catch {
        res.setStatus(.bad_request);
        return;
    };
    std.log.debug("get with id: {d}", .{secret_id});
    const secret = app.store.get(req.conn.io, secret_id) orelse {
        std.log.warn("404", .{});
        res.setStatus(.not_found);
        return;
    };

    res.body = try std.fmt.allocPrint(
        req.arena,
        std.fmt.comptimePrint(
            @embedFile("html/base.html"),
            .{ @embedFile("html/secret/get.html") }
        ),
        .{
            secret.ciphertext,
            secret.iv,
            secret.delete_on_first_view,
            secret_id,
            @embedFile("html/secret/script.js")
        }
    );
}

pub fn burnSecret(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const id_param = req.param("id") orelse {
        res.setStatus(.bad_request);
        return;
    };
    const secret_id = std.fmt.parseUnsigned(u32, id_param, 10) catch {
        res.setStatus(.bad_request);
        return;
    };

    const removed = app.store.remove(req.conn.io, secret_id);

    if (removed) {
        res.setStatus(.no_content);
    } else {
        res.setStatus(.not_found);
    }
}