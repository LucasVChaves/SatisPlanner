package model;

import "core:math/linalg"

Connection :: struct {
    type: PortContent, // Item (belt) or fluid (pipe)
    from: PortRef,
    to: Maybe(PortRef),

    waypoints: [dynamic]linalg.Vector2f32,
}

