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

// Application callbacks
init :: ()
{
    load_all_resources();
}

shutdown :: ()
{
    unload_all_resources();
}

update :: (dt: float)
{

}

draw :: ()
{
    clear_background(resources.settings.background_color);
    draw_circle(.{0.2,0.2, 0}, resources.settings.circle_radius, resources.settings.circle_color);
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
