package view

import ray "vendor:raylib";
import "core:strings";
import "../model";

COLOR_MACHINE_BODY :: ray.Color{200, 200, 200, 255}
COLOR_MACHINE_OUTLINE :: ray.Color{50, 50, 50, 255}
COLOR_SELECTED :: ray.Color{230, 41, 55, 255}

draw_factory :: proc(factory: ^model.Factory) {
    for &node in factory.ore_nodes {
        def, exists := factory.ore_node_registry[node.def_id];
        if !exists {continue;}

        posX := i32(node.pos.x);
        posY := i32(node.pos.y);
        radius := node.radius;

        color := def.color;

        if node.is_selected {
            ray.DrawCircleLines(posX, posY, radius + 4, ray.WHITE);
        }

        ray.DrawCircle(posX, posY, radius, color);
        ray.DrawCircleLines(posX, posY, radius, ray.BLACK);
    
        ray.DrawText(
            strings.clone_to_cstring(def.name), 
            posX - 20, 
            posY - 10, 
            10, 
            ray.BLACK
        );

        base_rate := def.rates[node.purity]
        
        purity_text := ray.TextFormat("%v (%.0f/min)", node.purity, base_rate)
        ray.DrawText(purity_text, posX - 30, posY + 5, 10, ray.DARKGRAY)
    }

    for &machine in factory.machines {
        def, exists := factory.machine_registry[machine.def_id];
        if !exists {continue;}

        posX := i32(machine.pos.x);
        posY := i32(machine.pos.y);
        width := i32(def.size.x);
        height := i32(def.size.y);

        body_color := def.color;

        if machine.is_selected {
            ray.DrawRectangleLinesEx(
                ray.Rectangle{f32(posX)-2, f32(posY)-2, f32(width)+4, f32(height)+4},
                2,
                ray.WHITE,
            )
        }

        ray.DrawRectangle(posX, posY, width, height, body_color);
        ray.DrawRectangleLines(posX, posY, width, height, ray.BLACK);

        ray.DrawText(
            strings.clone_to_cstring(def.name),
            posX + 5, 
            posY + 5, 
            10, 
            ray.BLACK,
        )
    }
}