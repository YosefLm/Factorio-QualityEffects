local qualities = table.deepcopy(data.raw["quality"])

local new_machines = {}

for mname, machine_orig in pairs(data.raw["assembling-machine"]) do
    for qname, qvalue in pairs(qualities) do
        if machine_orig.module_slots ~= nil and machine_orig.module_slots > 0 and qvalue.level > 0 then
            local machine = table.deepcopy(machine_orig)
            if machine_orig.placeable_by == nil then
                if machine_orig.minable == nil then
                    -- placeable_by is nil
                    -- minable is nil
                    -- how am I supposed to figure out what item places this
                    -- if anyone has another idea, make a PR and fix and cleanup the code yourself
                    -- man it's like holoitems again

                    machine.placeable_by = nil
                elseif machine_orig.minable.result ~= nil then
                    machine.placeable_by = {item=machine_orig.minable.result, count=1, quality=qvalue}
                elseif machine_orig.minable.results ~= nil and type(machine_orig.minable.results) == "table" and #machine_orig.minable.results > 0 and machine_orig.minable.results[1].name ~= nil then
                    machine.placeable_by = {item=machine_orig.minable.results[1].name, count=1, quality=qvalue}
                else
                -- true for most machines tbh, actually most machines dont even use more than one results[] value
                    machine.placeable_by = nil
                end
            elseif type(machine_orig.placeable_by) == "table" then
                if machine_orig.placeable_by["item"] ~= nil then
                    machine.placeable_by = table.deepcopy(machine_orig.placeable_by)
                    machine.placeable_by["quality"] = qvalue
                else
                    machine.placeable_by = table.deepcopy(machine_orig.placeable_by)
                    for idx, value in ipairs(machine_orig.placeable_by) do
                        if type(value) == "table" and value["item"] ~= nil then
                            machine.placeable_by[idx]["quality"] = qvalue
                        end
                    end
                end
                log(tostring(machine.placeable_by[1]["item"]))
            else
                machine.placeable_by = nil
            end
            machine.localised_name = {"entity-name." .. mname}
            machine.localised_description = {"entity-description." .. mname}
            machine.hidden = true
            machine.name = "QualityEffects-" .. qname .. "-" .. machine.name
            machine.module_slots = machine.module_slots + qvalue.level

            table.insert(new_machines, machine)
        end
    end
end

data.extend(new_machines)
