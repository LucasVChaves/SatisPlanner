package main;

import ray "vendor:raylib";
import "model";
import "view";
import "controller";

BACKGROUND_COLOR := ray.Color{24, 24, 24, 255};

main :: proc() {
    ray.InitWindow(1280, 720, "SatisPlanner");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    factory := model.Factory{}
    append(&factory.machines, model.factory_make_machine(.Miner, 100, 100));
    append(&factory.machines, model.factory_make_machine(.Smelter, 300, 300));

    camera := ray.Camera2D{zoom = 1.0}

    for !ray.WindowShouldClose() {
        controller.update_input(&factory, camera);

        update_camera_controls(&camera);

        ray.BeginDrawing();
        ray.ClearBackground(BACKGROUND_COLOR);

        ray.BeginMode2D(camera);
        view.draw_factory(&factory);
        ray.EndMode2D();
        
        ray.EndDrawing();
    }
}

update_camera_controls :: proc(camera: ^ray.Camera2D) {
    wheel := ray.GetMouseWheelMove();
    if wheel != 0 {
        camera.zoom += wheel * 0.1;
        if camera.zoom < 0.1 do camera.zoom = 0.1;
    }

    if ray.IsMouseButtonDown(ray.MouseButton.RIGHT) {
        delta := ray.GetMouseDelta();
        delta = delta * (-1.0 / camera.zoom);
        camera.target = camera.target + delta;
    }
}