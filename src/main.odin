package main;

import ray "vendor:raylib";
import "model";
import "view";
import "controller";

BACKGROUND_COLOR := ray.Color{24, 24, 24, 255};

main :: proc() {
    ray.InitWindow(1280, 720, "SatisPlanner");
    defer ray.CloseWindow();
    ray.SetExitKey(.DELETE);
    ray.SetTargetFPS(60);

    factory := model.Factory{}
    factory.machine_registry = model.load_registry("assets/machines");
    factory.ore_node_registry = model.load_ore_node_registry("assets/ore_nodes");

    // BEGIN_TEMP
    if "smelter_mk1" in factory.machine_registry {
        new_machine := model.Machine{
            uuid = 1,
            def_id = "smelter_mk1",
            pos = {100, 100},
        };
        append(&factory.machines, new_machine);
    }

    if "miner_mk1" in factory.machine_registry {
        new_machine := model.Machine{
            uuid = 2,
            def_id = "miner_mk1",
            pos = {400, 200},
        };
        append(&factory.machines, new_machine);
    }

    if "manufacturer" in factory.machine_registry {
        new_machine := model.Machine{
            uuid = 3,
            def_id = "manufacturer",
            pos = {600, 250},
        };
        append(&factory.machines, new_machine);
    }

    if "refinery" in factory.machine_registry {
        new_machine := model.Machine{
            uuid = 4,
            def_id = "refinery",
            pos = {200, 250},
        };
        append(&factory.machines, new_machine);
    }

    if "splitter" in factory.machine_registry {
        new_machine := model.Machine{
            uuid = 5,
            def_id = "splitter",
            pos = {350, 350},
        };
        append(&factory.machines, new_machine);
    }

    if "merger" in factory.machine_registry {
        new_machine := model.Machine{
            uuid = 6,
            def_id = "merger",
            pos = {400, 400},
        };
        append(&factory.machines, new_machine);
    }

    if "iron_node" in factory.ore_node_registry {
        new_node := model.OreNode {
            uuid = 100,
            def_id = "iron_node",
            pos = {300, 300},
            purity = .Normal,
            radius = 40.0,
        }
        append(&factory.ore_nodes, new_node);
    }
    // END_TEMP

    camera := ray.Camera2D{zoom = 1.0}

    for !ray.WindowShouldClose() {
        controller.update_input(&factory, camera);

        update_camera_controls(&camera);

        ray.BeginDrawing();
        ray.ClearBackground(BACKGROUND_COLOR);

        ray.BeginMode2D(camera);
            view.draw_factory(&factory);
            view.draw_connections(&factory, camera);
            ghost, is_building := controller.get_ghost_connection();
            if is_building {
                view.draw_single_connection(&factory, ghost, true, camera);
            }
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