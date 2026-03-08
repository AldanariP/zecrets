const std = @import("std");
const jetzig = @import("jetzig");

const StoreValue = struct {
    cipher: []const u8,
    iv: []const u8,
};

pub const layout = "default";

pub fn get(id: []const u8, request: *jetzig.Request) !jetzig.View {
    const val = try request.store.get(id);
    if (val) |value| {
        const response = try request.data(.object);
        try response.put("data", value);
        return request.render(.ok);
    }
    return request.fail(.not_found);
}

pub fn post(request: *jetzig.Request) !jetzig.View {
    const params = try request.params();

    const cypher: []const u8 = params.getT(.string, "ciphertext") orelse return request.fail(.unprocessable_entity);
    const iv: []const u8 = params.getT(.string, "iv") orelse return request.fail(.unprocessable_entity);
    const once: bool = params.getT(.boolean, "once") orelse return request.fail(.unprocessable_entity);
    const maybe_expires: ?i128 = params.getT(.integer, "expires");
    const maybe_expires_at: ?i128 = params.getT(.integer, "expires_at");

    var expire_time: i32 = undefined;

    if (maybe_expires) |expires| {
        expire_time = @truncate(expires);
    } else if (maybe_expires_at) |expires_at| {
        const now = std.time.timestamp();
        const then: i64 = @truncate(@divTrunc(expires_at, std.time.ms_per_s));
        if (then < now) return request.fail(.unprocessable_entity);
        expire_time = @truncate(then - now);

    } else return request.fail(.unprocessable_entity);

    const id = std.crypto.random.int(u31);

    var key_buf: [10]u8 = undefined;
    const store_key = try std.fmt.bufPrint(&key_buf, "{d}", .{id});

    const store_val = .{
        .cipher = cypher,
        .iv = iv,
        .once = once
    };
    try request.store.putExpire(store_key, store_val, expire_time);

    var response = try request.data(.object);
    try response.put("id", id);

    return request.render(.created);
}

pub fn delete(id: []const u8, request: *jetzig.Request) !jetzig.View {
    try request.store.remove(id);
    return request.render(.no_content);
}