const std = @import("std");
const assert = std.debug.assert;

const Store = @This();

const U32Context = struct {
    pub fn hash(_: U32Context, key: u32) u32 {
        return key;
    }
    pub fn eql(_: U32Context, a: u32, b: u32, _: usize) bool {
        return a == b;
    }
};

const Payload = struct {
    ciphertext: []const u8,
    iv: []const u8,
    expires_at: i64,
    delete_on_first_view: bool
};


alloc: std.mem.Allocator,
map: std.array_hash_map.Custom(u32, Payload, U32Context, false),
mutex: std.Io.Mutex,

pub fn init(alloc: std.mem.Allocator) !Store {
    return .{
        .alloc = alloc,
        .map = .empty,
        .mutex = .init,
    };
}

pub fn deinit(self: *Store) void {
    self.map.deinit(self.alloc);
    self.* = undefined;
}

pub fn put(self: *Store, io: std.Io, id: u32, entry: Payload) !void {
    if (self.map.contains(id)) return error.SecretAlreadyExists;

    self.mutex.lockUncancelable(io);
    defer self.mutex.unlock(io);

    try self.map.putNoClobber(self.alloc, id, entry);
}

pub fn get(self: *Store, io: std.Io, id: u32) ?Payload {
    self.mutex.lockUncancelable(io);
    defer self.mutex.unlock(io);

    const entry = self.map.get(id) orelse return null;

    if (entry.expires_at <= std.Io.Timestamp.now(io, .real).toSeconds()) {
        std.log.debug("{d} < {d}", .{entry.expires_at, std.Io.Timestamp.now(io, .real).toSeconds()});
        const removed = self.map.swapRemove(id);
        assert(removed);
        return null;
    }

    return entry;
}

pub fn remove(self: *Store, io: std.Io, id: u32) bool {
    self.mutex.lockUncancelable(io);
    defer self.mutex.unlock(io);

    return self.map.swapRemove(id);
}
