package controller

import "core:math/linalg"
import "core:math";
import "core:slice";
import "core:fmt";
import ray "vendor:raylib";
import "../model";

ToolMode :: enum {
    Select,
    Connect,
}

State :: struct {
    mode: ToolMode,
    ghost_connection: model.Connection,
    is_building: bool,
    drag_offset: linalg.Vector2f32,
}

@(private="file")
ctrl_state: State;

find_port_at_mouse :: proc(factory: ^model.Factory, mouse_world: ray.Vector2) -> (model.PortRef, bool) {
    threshold :: 10.0;

    for &machine in factory.machines {
        def := factory.machine_registry[machine.def_id] or_continue;
        
        for port, idx in def.ports {
            px := machine.pos.x + port.offset.x;
            py := machine.pos.y + port.offset.y;
            
            // Squared dist; No need for sqrt
            dx := mouse_world.x - px;
            dy := mouse_world.y - py;
            if (dx*dx + dy*dy) < (threshold*threshold) {
                //fmt.println("DEBUG: Found port at {%v, %v} in machine %s", px, py, machine.uuid);
                return model.PortRef{
                    machine_uuid = machine.uuid, 
                    port_idx = idx,
                    abs_pos = {px, py},
                }, true;
            }
        }
    }
    return model.PortRef{}, false;
}

update_input :: proc(factory: ^model.Factory, camera: ray.Camera2D) {
    mouse_screen := ray.GetMousePosition();
    mouse_world_vec2 := ray.GetScreenToWorld2D(mouse_screen, camera);
    mouse_world := linalg.Vector2f32{mouse_world_vec2.x, mouse_world_vec2.y};

    // TODO: Change to toolbox tool. May keep shortcut
    if ray.IsKeyPressed(.C) {
        if ctrl_state.mode == .Connect {
            ctrl_state.mode = .Select;
            ctrl_state.is_building = false;
        } else {
            ctrl_state.mode = .Connect;
            ctrl_state.is_building = false;
        }

        if len(ctrl_state.ghost_connection.waypoints) > 0 {
            delete(ctrl_state.ghost_connection.waypoints);
        }
        ctrl_state.ghost_connection = model.Connection{};
    }

    if ray.IsKeyPressed(.ESCAPE) {
        ctrl_state.mode = .Select;
        ctrl_state.is_building = false;
        if len(ctrl_state.ghost_connection.waypoints) > 0 {
            delete(ctrl_state.ghost_connection.waypoints);
        }
        ctrl_state.ghost_connection = model.Connection{};
    }

    switch ctrl_state.mode {
        case .Select:
            update_select_mode(factory, mouse_world);
        case .Connect:
            update_connect_mode(factory, mouse_screen);
    }
}

update_select_mode :: proc(factory: ^model.Factory, mouse_world: linalg.Vector2f32) {
    ray.SetMouseCursor(.DEFAULT);

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
                // Point-Cicle Collision
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

update_connect_mode :: proc(factory: ^model.Factory, mouse_world: linalg.Vector2f32) {
    ray.SetMouseCursor(.CROSSHAIR);

    hover_port, has_hover := find_port_at_mouse(factory, {mouse_world.x, mouse_world.y})

    if ray.IsMouseButtonPressed(.LEFT) {
        if !ctrl_state.is_building {
            if has_hover {
                if is_port_occupied(factory, hover_port) {
                    fmt.println("WARNING: Port already has connection.");
                    return;
                }

                ctrl_state.is_building = true;
                ctrl_state.ghost_connection.from = hover_port;
                
                def, _ := get_port_definition(factory, hover_port);
                ctrl_state.ghost_connection.type = def.content;
            }
            return;
        }

        if has_hover {
            if ctrl_state.ghost_connection.from.machine_uuid == hover_port.machine_uuid {
                fmt.println("WARNING: Cannot connect to self");
                return ;
            }
            
            if is_port_occupied(factory, hover_port) {
                fmt.println("WARNING: Port already occupied");
                return;
            }

            start_def, ok1 := get_port_definition(factory, ctrl_state.ghost_connection.from);
            end_def, ok2 := get_port_definition(factory, hover_port);
            if !ok1 || !ok2 { return; }

            if start_def.type == end_def.type {
                fmt.println("WARNING: Cannot connect input to input or output to output");
                return;
            }

            if start_def.content != end_def.content {
                fmt.println("WARNING: Content not compatible");
                return;
            }

            final_conn := ctrl_state.ghost_connection;
            
            if start_def.type == .Input {
                final_conn.from = hover_port;
                final_conn.to = ctrl_state.ghost_connection.from;
                if len(ctrl_state.ghost_connection.waypoints) > 0 {
                    slice.reverse(ctrl_state.ghost_connection.waypoints[:]);
                }
            } else {
                final_conn.to = hover_port;
            }
            
            if len(ctrl_state.ghost_connection.waypoints) > 0 {
                final_conn.waypoints = make([dynamic]linalg.Vector2f32, len(ctrl_state.ghost_connection.waypoints));
                copy(final_conn.waypoints[:], ctrl_state.ghost_connection.waypoints[:]);
            }
            
            final_conn.type = start_def.content;
            append(&factory.connections, final_conn);
            
            ctrl_state.is_building = false;
            delete(ctrl_state.ghost_connection.waypoints);
            ctrl_state.ghost_connection = model.Connection{};
            
        } else {
            point := mouse_world;
            
            if ray.IsKeyDown(.V) {
                last_pos := linalg.Vector2f32{0, 0};
                
                if len(ctrl_state.ghost_connection.waypoints) > 0 {
                    last_pos = ctrl_state.ghost_connection.waypoints[len(ctrl_state.ghost_connection.waypoints)-1];
                } else {
                    start_mach, _ := model.get_machine_by_uuid(factory, ctrl_state.ghost_connection.from.machine_uuid);
                    def, _ := factory.machine_registry[start_mach.def_id];
                    port := def.ports[ctrl_state.ghost_connection.from.port_idx];
                    last_pos = start_mach.pos + port.offset;
                }

                dx := abs(point.x - last_pos.x);
                dy := abs(point.y - last_pos.y);
                
                if dx > dy { point.y = last_pos.y; } else { point.x = last_pos.x; }
            }

            append(&ctrl_state.ghost_connection.waypoints, point);
        }
    }
}

get_ghost_connection :: proc() -> (model.Connection, bool){
    return ctrl_state.ghost_connection, ctrl_state.is_building;
}

get_port_definition :: proc(factory: ^model.Factory, ref: model.PortRef) -> (model.PortDef, bool) {
    machine_ptr: ^model.Machine = nil;
    for &m in factory.machines {
        if m.uuid == ref.machine_uuid {
            machine_ptr = &m;
            break;
        }
    }
    if machine_ptr == nil { return model.PortDef{}, false; }

    def, exists := factory.machine_registry[machine_ptr.def_id];
    if !exists { return model.PortDef{}, false; }

    if ref.port_idx < 0 || ref.port_idx >= len(def.ports) {
        return model.PortDef{}, false;
    }

    return def.ports[ref.port_idx], true;
}

is_port_occupied :: proc(factory: ^model.Factory, ref: model.PortRef) -> bool {
    for conn in factory.connections {
        if conn.from.machine_uuid == ref.machine_uuid && conn.from.port_idx == ref.port_idx {
            return true;
        }
        if dest, ok := conn.to.?; ok {
            if dest.machine_uuid == ref.machine_uuid && dest.port_idx == ref.port_idx {
                return true;
            }
        }
    }
    return false;
}