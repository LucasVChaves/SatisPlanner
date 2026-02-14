package view

import "core:math/linalg"
import "core:fmt";
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

        draw_ports(machine, def);

        ray.DrawText(
            strings.clone_to_cstring(def.name),
            posX + 5, 
            posY + 5, 
            10, 
            ray.BLACK,
        )
    }
}

draw_ports :: proc(machine: model.Machine, def: model.MachineDef) {
    // TODO: Move to config file
    size :: 12.0;
    half_size :: size / 2.0;

    for port in def.ports {
        px := machine.pos.x + port.offset.x;
        py := machine.pos.y + port.offset.y;

        color := port.type == .Input ? ray.ORANGE : ray.GREEN;
        if port.content == .Fluid {
            ray.DrawCircle(i32(px), i32(py), half_size, color);
            ray.DrawCircleLines(i32(px), i32(py), half_size, ray.BLACK);
        } else {
            rect := ray.Rectangle{px - half_size, py - half_size, size, size};
            ray.DrawRectangleRec(rect, color);
            ray.DrawRectangleLinesEx(rect, 1.0,  ray.BLACK);
        }
    }
}

draw_connections :: proc(factory: ^model.Factory, camera: ray.Camera2D) {
    for conn in factory.connections {
        draw_single_connection(factory, conn, false, camera);
    }

    // TODO: Draw ghost connections
}

draw_single_connection :: proc(factory: ^model.Factory, conn: model.Connection, is_ghost: bool, camera: ray.Camera2D) {
    start_pos: linalg.Vector2f32;
    end_pos: linalg.Vector2f32;
    has_end := false;

    start_machine, found_s := get_machine_by_uuid(factory, conn.from.machine_uuid);
    if !found_s {return;}

    start_def := factory.machine_registry[start_machine.def_id];
    start_port := start_def.ports[conn.from.port_idx];
    start_pos = start_machine.pos + start_port.offset;

    if dest, ok := conn.to.?; ok {
        end_machine, found_e := get_machine_by_uuid(factory, dest.machine_uuid);
        if found_e {
            end_def := factory.machine_registry[end_machine.def_id];
            end_port := end_def.ports[dest.port_idx];
            end_pos = end_machine.pos + end_port.offset;
            has_end = true;
        }
    } else if is_ghost {
        mouse_v2 := ray.GetScreenToWorld2D(ray.GetMousePosition(), camera);
        end_pos = {mouse_v2.x, mouse_v2.y};
        has_end = true;
    }

    if !has_end { return }

    // Polyline
    thick := f32(4.0);
    color := (conn.type == .Fluid) ? ray.Color{200, 100, 50, 200} : ray.Color{50, 50, 50, 200};
    if is_ghost { color.a = 100 };

    prev := start_pos
    
    for wp in conn.waypoints {
        ray.DrawLineEx({prev.x, prev.y}, {wp.x, wp.y}, thick, color);
        ray.DrawCircleV({wp.x, wp.y}, thick, color);
        prev = wp;
    }

    ray.DrawLineEx({prev.x, prev.y}, {end_pos.x, end_pos.y}, thick, color);
}

get_machine_by_uuid :: proc(factory: ^model.Factory, uuid: u64) -> (^model.Machine, bool) {
    for &m in factory.machines {
        if m.uuid == uuid {
            return &m, true;
        }
    }
    fmt.printfln("WARNING: No machine found with uuid %v in factory", uuid);
    return nil, false;
}