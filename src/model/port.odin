package model;

import "core:math/linalg"
import ray "vendor:raylib"

PortType :: enum {
    Input,
    Output,
}

PortContent :: enum {
    Item,
    Fluid,
}

PortDef :: struct {
    type: PortType,
    content: PortContent,
    size: linalg.Vector2f32,
    offset: linalg.Vector2f32,
    color: ray.Color,

    ports: [dynamic]PortDef,
}