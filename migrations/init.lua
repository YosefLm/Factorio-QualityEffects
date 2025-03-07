local function stringStarts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local machines = {}
for name, machine in pairs(game.entity_prototypes) do
    if machine.type == "assembling-machine" and machine.module_inventory_size > 0 and not stringStarts(name, "QualityEffects-") then
        machines[name] = true
    end
end

local function check_entity(entity_name)
    return machines[entity_name] ~= nil
end

for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "assembling-machine"})) do
        if entity.quality and entity.quality.level and entity.quality.level > 0 and check_entity(entity.name) then 
            local recipe, qual = entity.get_recipe()
            local module_inventory = entity.get_module_inventory()
            local modules = module_inventory and module_inventory.get_contents() or {}
            
            local info = {
                name = "QualityEffects-" .. entity.quality.name .. "-" .. entity.name,
                position = entity.position,
                direction = entity.direction,
                quality = entity.quality,
                force = entity.force,
                fast_replace = true,
                player = entity.last_user,
            }
            
            entity.destroy()
            local new_entity = surface.create_entity(info)
            if new_entity then
                new_entity.set_recipe(recipe, qual)
                local new_inventory = new_entity.get_module_inventory()
                if new_inventory then
                    for module, count in pairs(modules) do
                        new_inventory.insert({name = module, count = count})
                    end
                end
            else
                log("ERROR: Failed to create entity " .. info.name)
            end
        end
    end
end