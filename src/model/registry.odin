package model

import "core:fmt"
import "core:os"
import "core:strings"
import ray "vendor:raylib"

import "../../vendor/toml" 

load_registry :: proc(path: string) -> map[string]MachineDef {
    registry := make(map[string]MachineDef);

    handle, err := os.open(path);
    if err != os.ERROR_NONE {
        fmt.println("Erro ao abrir pasta:", err);
        return registry;
    }
    defer os.close(handle);

    file_infos, _ := os.read_dir(handle, -1);
    
    for info in file_infos {
        if info.is_dir { continue; }
        if !strings.has_suffix(info.name, ".toml") { continue; }

        full_path := fmt.tprintf("%s/%s", path, info.name);

        def, success := parse_machine_toml(full_path);
        if success {
            registry[def.id] = def;
            fmt.printf("Carregado [TOML]: %s (%s)\n", def.name, def.id);
        }
    }
    return registry
}

parse_machine_toml :: proc(filepath: string) -> (MachineDef, bool) {
    doc, err := toml.parse_file(filepath, context.temp_allocator);

    if toml.print_error(err) do return MachineDef{}, false;

    def := MachineDef{};

    if id_val, ok := toml.get_string(doc, "id"); ok {
        def.id = strings.clone(id_val);
    } else {
        return def, false;
    }

    if name_val, ok := toml.get_string(doc, "name"); ok {
        def.name = strings.clone(name_val);
    }

    if w, ok := toml.get_i64(doc, "width"); ok { def.size.x = f32(w) }
    if h, ok := toml.get_i64(doc, "height"); ok { def.size.y = f32(h) }
    
    if inp, ok := toml.get_i64(doc, "inputs"); ok { def.input_ports = int(inp) }
    if out, ok := toml.get_i64(doc, "outputs"); ok { def.output_ports = int(out) }

    if list, ok := toml.get_list(doc, "color"); ok && len(list) >= 3 {
        get_u8 :: proc(val: toml.Type) -> u8 {
            #partial switch v in val {
                case i64: return u8(v)
                case f64: return u8(v)
                case: return 0
            }
        }

        r := get_u8(list[0]);
        g := get_u8(list[1]);
        b := get_u8(list[2]);
        a := u8(255);
        if len(list) > 3 { a = get_u8(list[3]); }
        
        def.color = ray.Color{r, g, b, a};
    } else {
        def.color = ray.GRAY;
    }

    return def, true;
}