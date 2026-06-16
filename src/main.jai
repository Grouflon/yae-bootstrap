// Example Resource
GameSettings :: struct
{
    #as using _resource: Resource;
    type = type_info(GameSettings);

    circle_radius: float = 0.2; @serialize @drag @step(0.01) @min(0)
    circle_color: Color = WHITE; @serialize
    background_color: Color = GOLD; @serialize
}

// Resource List
resources : struct
{
    settings: GameSettings = .{ path = "data://settings.res" };
};

TestStruct :: struct
{
    a: float = 10.0;
    b: float = 0.2;
    c: Color = WHITE;
    p: Vector2;
}

update :: (using ptr: *TestStruct, dt: float) 
{
    p = .{0.5 + sin(get_time_since_startup().(float) * a) * 0.3, 0.5};
} @default_update

draw :: (using ptr: *TestStruct)
{
    draw_circle(xyz(p, 0), b, c);
} @default_draw

ptr: *TestStruct;
id: ID(TestStruct);

// Application callbacks
init :: ()
{
    load_all_resources();

    _:, id = pool_add(TestStruct);
    ptr=, _: = pool_add(TestStruct);
    ptr.a = 5.0;
    ptr.c = PURPLE;
}

shutdown :: ()
{
    pool_remove(ptr);
    pool_remove(id);

    unload_all_resources();
}

update :: (dt: float)
{
    default_update(dt);

    if is_pressed(.ESCAPE)
    {
        yae_request_close();
    }
}

draw :: ()
{
    clear_background(resources.settings.background_color);
    draw_circle(.{0.2,0.2, 0}, resources.settings.circle_radius, resources.settings.circle_color);

    default_draw();
}

// Boilerplate
main :: ()
{
    register_resources(*resources);

    // Init
    yae_init(800, 600, "bootstrap");
    init();

    // Loop
    yae_loop(update, draw);
    if OS == .WASM return; // wasm needs to exit immediately. Everything will happen async later

    // Shutdown
    shutdown();
    yae_shutdown();
}

// === Loads ===
#if OS == .WASM
{
    // @NOTE(remi): We can remove this with functions that send callbacks as argument to wasm
    #load "../modules/yae/wasm_export.jai";
}

// === Imports ===
#scope_file
#import "Basic"()(MEMORY_DEBUGGER = YAE_DEBUG_MEMORY);
#import "yae";

#import "Math";