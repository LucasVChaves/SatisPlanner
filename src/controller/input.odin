package controller

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
            mouse_world.x <= machine.pos.x + machine.size.x &&
            mouse_world.y >= machine.pos.y &&
            mouse_world.y <= machine.pos.y + machine.size.y {
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
    }

    if ray.IsMouseButtonDown(ray.MouseButton.LEFT) {
        for &machine in factory.machines {
            if machine.is_dragging {
                machine.pos.x = mouse_world.x - ctrl_state.drag_offset.x;
                machine.pos.y = mouse_world.y - ctrl_state.drag_offset.y;
            }
        }
    }

    if ray.IsMouseButtonReleased(ray.MouseButton.LEFT) {
        for &machine in factory.machines {
            machine.is_dragging = false;
        }
    }
}