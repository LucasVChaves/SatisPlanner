package model

import "core:math/linalg";
import "core:fmt";
import ray "vendor:raylib";

MachineDef :: struct {
    id: string,
    name: string,
    size: linalg.Vector2f32,
    color: ray.Color,
    input_ports: int,
    output_ports: int,
    ports: [dynamic]PortDef,
}

Machine :: struct {
    uuid: u64,
    def_id: string,
    pos: linalg.Vector2f32,

    is_selected: bool,
    is_dragging: bool,
}

get_machine_by_uuid :: proc(factory: ^Factory, uuid: u64) -> (^Machine, bool) {
    for &m in factory.machines {
        if m.uuid == uuid {
            return &m, true;
        }
    }
    fmt.printfln("WARNING: No machine found with uuid %v in factory", uuid);
    return nil, false;
}