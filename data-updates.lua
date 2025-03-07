local qualities = data.raw["quality"] and table.deepcopy(data.raw["quality"]) or {}

if not qualities or next(qualities) == nil then
    log("ERROR: 'quality' data is missing or empty.")
    return
end

local new_machines = {}

for mname, machine_orig in pairs(data.raw["assembling-machine"]) do
    for qname, qvalue in pairs(qualities) do
        if machine_orig.module_slots and machine_orig.module_slots > 0 and qvalue.level > 0 then
            local machine = table.deepcopy(machine_orig)

            if not machine_orig.placeable_by then
                if not machine_orig.minable then
                    machine.placeable_by = nil
                elseif machine_orig.minable.result then
                    machine.placeable_by = { item = machine_orig.minable.result, count = 1, quality = qvalue }
                elseif type(machine_orig.minable.results) == "table" and #machine_orig.minable.results > 0 then
                    local first_result = machine_orig.minable.results[1]
                    if first_result and first_result.name then
                        machine.placeable_by = { item = first_result.name, count = 1, quality = qvalue }
                    else
                        machine.placeable_by = nil
                    end
                else
                    machine.placeable_by = nil
                end
            elseif type(machine_orig.placeable_by) == "table" then
                if machine_orig.placeable_by.item then
                    machine.placeable_by = table.deepcopy(machine_orig.placeable_by)
                    machine.placeable_by.quality = qvalue
                else
                    machine.placeable_by = table.deepcopy(machine_orig.placeable_by)
                    for idx, value in ipairs(machine_orig.placeable_by) do
                        if type(value) == "table" and value.item then
                            machine.placeable_by[idx].quality = qvalue
                        end
                    end
                end
                if machine.placeable_by[1] and machine.placeable_by[1].item then
                    log(tostring(machine.placeable_by[1].item))
                end
            else
                machine.placeable_by = nil
            end

            machine.localised_name = { "entity-name." .. mname }
            machine.localised_description = { "entity-description." .. mname }
            machine.hidden = true
            machine.name = "QualityEffects-" .. qname .. "-" .. machine.name
            machine.module_slots = machine.module_slots + qvalue.level

            table.insert(new_machines, machine)
        end
    end
end

data.extend(new_machines)
