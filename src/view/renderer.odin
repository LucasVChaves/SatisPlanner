package view

import ray "vendor:raylib";
import "../model";

COLOR_MACHINE_BODY :: ray.Color{200, 200, 200, 255}
COLOR_MACHINE_OUTLINE :: ray.Color{50, 50, 50, 255}
COLOR_SELECTED :: ray.Color{230, 41, 55, 255}

draw_factory :: proc(factory: ^model.Factory) {
    for &machine in factory.machines {
        posX := i32(machine.pos.x);
        posY := i32(machine.pos.y);
        width := i32(machine.size.x);
        height := i32(machine.size.y);

        outline_color := machine.is_selected ? COLOR_SELECTED : COLOR_MACHINE_OUTLINE;
        thickness := machine.is_selected ? i32(3) : i32(1);

        ray.DrawRectangle(posX, posY, width, height, COLOR_MACHINE_BODY);

        ray.DrawRectangleLinesEx(
            ray.Rectangle{f32(posX), f32(posY), f32(width), f32(height)},
            f32(thickness),
            outline_color,
        );

        ray.DrawText(
            ray.TextFormat("%v", machine.type),
            posX + 5,
            posY + 5,
            10,
            ray.BLACK,
        );
    }
}