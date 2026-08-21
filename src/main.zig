const std = @import("std");
const builtin = @import("builtin");
const httpz = @import("httpz");

const Store = @import("Store.zig");
const LoggerMiddleware = @import("LoggerMiddleware.zig");

const router_static = @import("router-static.zig");
const router_secrets = @import("router-secrets.zig");


pub const App = struct {
    store: Store
};

pub fn main(init: std.process.Init) !void {
    const alloc = init.gpa;

    var app: App = .{ .store = try .init(alloc) };
    defer app.store.deinit();

    var port: u16 = 3000;

    const maybe_port_string = init.environ_map.get("port");
    if (maybe_port_string) |port_string| {
        port = std.fmt.parseUnsigned(u16, port_string, 10) catch blk: {
            std.log.warn("Invalid port: \"{s}\", defaulting to 3000", .{port_string});
            break :blk 3000;
        };
    }

    var server: httpz.Server(*App) = try .init(init.io, alloc, .{
        .address = .all(port)
    }, &app);
    defer { server.stop(); server.deinit(); }

    const logger = try server.middleware(LoggerMiddleware, .{ .io = init.io });

    var router = try server.router(.{});

    router.middlewares = &.{ logger };

    router.get("/", router_static.index, .{});
    router.get("/style.css", router_static.indexStyle, .{});
    router.get("/favicon.ico", router_static.favicon, .{});
    router.get("/form", router_static.form, .{});
    router.get("/tabs/duration", router_static.tabDuration, .{});
    router.get("/tabs/date", router_static.tabDate, .{});

    router.post("/secret/duration", router_secrets.secretByDuration, .{});
    router.post("/secret/date", router_secrets.secretByDate, .{});
    router.get("/secret/:id", router_secrets.getSecret, .{});
    router.delete("/secret/:id", router_secrets.burnSecret, .{});

    std.log.info("Listening on http://localhost:{}", .{port});
    try server.listen();
}
