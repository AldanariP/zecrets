const std = @import("std");
const httpz = @import("httpz");
const App = @import("main.zig").App;
const datastar = @import("datastar");

pub fn index(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = .HTML;
    res.body = std.fmt.comptimePrint(
        @embedFile("html/base.html"),
        .{ @embedFile("html/index/index.html") }
    );
}

pub fn indexStyle(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = .CSS;
    res.body = @embedFile("css/style.css")
        ++ @embedFile("css/index.css")
        ++ @embedFile("css/secrets.css");
}

pub fn favicon(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = .ICO;
    res.body = @embedFile("public/favicon.ico");
}

pub fn form(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = .HTML;
    res.body = std.fmt.comptimePrint(
        @embedFile("html/index/form.html"),
        .{ @embedFile("html/index/tabs/duration_tab.html")}
    );
}

pub fn tabDuration(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = .HTML;
    res.body = @embedFile("html/index/tabs/duration_tab.html");
}

pub fn tabDate(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = .HTML;
    res.body = @embedFile("html/index/tabs/date_tab.html");
}
