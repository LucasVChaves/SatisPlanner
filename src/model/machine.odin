package model

import "core:math/linalg";

// TODO: Move to TOML files and extract from them
MachineType :: enum {
    Miner,
    Smelter,
    Constructor,
    Merger,
    Splitter,
}

Machine :: struct {
    id: int,
    type: MachineType,
    pos: linalg.Vector2f32,
    size: linalg.Vector2f32,
    name: string,

    is_selected: bool,
    is_dragging: bool,
}