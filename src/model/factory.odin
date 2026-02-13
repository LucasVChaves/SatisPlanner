package model;

Factory :: struct {
    machines: [dynamic]Machine,
    next_id: int,
}

factory_make_machine :: proc(type: MachineType, x, y: f32) -> Machine {
    width, height: f32;

    // TODO: Extract from TOML files too
    switch type {
        case .Miner: width, height = 120, 120
        case .Smelter: width, height = 100, 80
        case .Constructor: width, height = 80, 80
        case .Merger: width, height = 40, 40
        case .Splitter: width, height = 40, 40
    }

    return Machine {
        type = type,
        pos = {x, y},
        size = {width, height},
        name = "Machine" // TODO: extract from TOML file
    }
}