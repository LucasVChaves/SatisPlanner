package model;

Factory :: struct {
    registry: map[string]MachineDef,
    machines: [dynamic]pos,
    next_uuid: u64,
}