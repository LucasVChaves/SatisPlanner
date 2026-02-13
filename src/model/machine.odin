package model

import "core:math/linalg";
import ray "vendor:raylib";

MachineDef :: struct {
    id: string,
    name: string,
    size: linalg.Vector2f32,
    color: ray.Color,
    input_ports: int,
    output_ports: int,
}

Machine :: struct {
    uuid: u64,
    def_id: string,
    pos: linalg.Vector2f32,

    is_selected: bool,
    is_dragging: bool,
}