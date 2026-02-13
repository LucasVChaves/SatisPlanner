package controller

import "core:math";
import ray "vendor:raylib";
import "../model";

State :: struct {
    drag_offset: [2]f32,
}

@(private="file")
ctrl_state: State;

update_input :: proc(factory: ^model.Factory, camera: ray.Camera2D) {
    mouse_screen := ray.GetMousePosition();
    mouse_world := ray.GetScreenToWorld2D(mouse_screen, camera);

    if ray.IsMouseButtonPressed(ray.MouseButton.LEFT) {
        clicked_on_something := false;
        #reverse for &machine in factory.machines {
            // AABB Collision
            if mouse_world.x >= machine.pos.x &&
            mouse_world.x <= machine.pos.x + machine.pos.x &&
            mouse_world.y >= machine.pos.y &&
            mouse_world.y <= machine.pos.y + machine.pos.y {
                machine.is_selected = true;
                machine.is_dragging = true;
                clicked_on_something = true;

                ctrl_state.drag_offset.x = mouse_world.x - machine.pos.x;
                ctrl_state.drag_offset.y = mouse_world.y - machine.pos.y;

                break;
            }
        }

        if !clicked_on_something {
            for &m in factory.machines {
                m.is_selected = false;
            }
        }

        if !clicked_on_something {
            for &node in factory.ore_nodes {
                // Point-Cicle COllision
                dx := mouse_world.x - node.pos.x;
                dy := mouse_world.y - node.pos.y;
                distance := math.sqrt_f32(dx*dx + dy*dy);

                if distance <= node.radius {
                    node.is_selected = true;
                    node.is_dragging = true;
                    clicked_on_something = true;
                    
                    ctrl_state.drag_offset.x = dx
                    ctrl_state.drag_offset.y = dy
                    break
                }
            }
        }
    }

    if ray.IsMouseButtonDown(ray.MouseButton.LEFT) {
        for &machine in factory.machines {
            if machine.is_dragging {
                machine.pos.x = mouse_world.x - ctrl_state.drag_offset.x;
                machine.pos.y = mouse_world.y - ctrl_state.drag_offset.y;
            }
        }

        for &node in factory.ore_nodes {
            if node.is_dragging {
                node.pos.x = mouse_world.x - ctrl_state.drag_offset.x
                node.pos.y = mouse_world.y - ctrl_state.drag_offset.y
            }
        }
    }

    if ray.IsMouseButtonReleased(ray.MouseButton.LEFT) {
        for &machine in factory.machines {
            machine.is_dragging = false;
        }

        for &node in factory.ore_nodes {
            node.is_dragging = false;
        }
    }
}