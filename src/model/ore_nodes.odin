package model;

import ray"vendor:raylib";
import "core:math/linalg";

OreNodeDef :: struct {
    id: string,
    name: string,
    color: ray.Color,

    rates: [Purity]f32,
}

Purity :: enum {
    Impure,
    Normal,
    Pure,
}

OreNode :: struct {
    uuid:        u64,
    def_id:      string,
    pos:    linalg.Vector2f32,
    purity:      Purity,
    radius:      f32,
    
    is_selected: bool,
    is_dragging: bool,
}

get_purity_multiplier :: proc(p: Purity) -> f32 {
    switch p {
        case .Impure: return 0.5
        case .Normal: return 1.0
        case .Pure:   return 2.0
    }
    return 1.0
}