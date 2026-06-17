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
    c: Color = WHITE;
    p: Vector2;
}

update :: (using ptr: *TestStruct, dt: float) 
{
    p = .{200 + sin(get_time_since_startup().(float) * a) * 50, 200};
} @update_group()

draw :: (using ptr: *TestStruct)
{
    draw_circle(xyz(p, 0), resources.settings.circle_radius, c);
} @draw_group()

ptr: *TestStruct;
id: ID(TestStruct);

// Rendering
GAME_WIDTH :: 320;
GAME_HEIGHT :: 200;
game_render_texture: RenderTexture;

// Application callbacks
init :: ()
{
    load_all_resources();

    game_render_texture = load_render_texture(GAME_WIDTH, GAME_HEIGHT);
    set_texture_parameters(game_render_texture.texture, TextureParameters.{
        min_filter = .NEAREST,
        mag_filter = .NEAREST,
    });

    _:, id = pool_add(TestStruct);
    ptr=, _: = pool_add(TestStruct);
    ptr.a = 5.0;
    ptr.c = PURPLE;
}

shutdown :: ()
{
    pool_remove(ptr);
    pool_remove(id);

    unload_render_texture(game_render_texture);

    unload_all_resources();
}

update :: (dt: float)
{
    update_group(dt);

    if is_pressed(.ESCAPE)
    {
        yae_request_close();
    }
}

draw :: ()
{
    // GAME
    {
        begin_render_texture(game_render_texture);
        defer end_render_texture();

        begin_camera(.{
            type=.ORTHOGRAPHIC,
            orthographic = .{
                top = 0.0,
                left = 0.0,
                right = GAME_WIDTH,
                bottom = GAME_HEIGHT,
                near = -1.0,
                far = 1.0
            }
        });
        defer end_camera();

        clear_background(resources.settings.background_color);

        draw_circle(.{100,100, 0}, resources.settings.circle_radius, resources.settings.circle_color);

        draw_circle_outline(.{160,100, 0.1}, 50.0, 1.0);

        draw_group();
    }

    // COMPOSITING
    {
        clear_background(.{0,0,0,255});

        draw_sprite(.{}, game_render_texture.texture, draw_rect = .{.{0,0}, .{1,1}}, flip_y = true); // we flip y cause opengl naturally draws textures upside down
    }
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