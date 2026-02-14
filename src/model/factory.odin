package model;

Factory :: struct {
    machine_registry: map[string]MachineDef,
    machines: [dynamic]Machine,

    ore_node_registry: map[string]OreNodeDef,
    ore_nodes: [dynamic]OreNode,

    connections: [dynamic]Connection,

    next_uuid: u64,
}