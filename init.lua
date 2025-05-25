local lib = {}

lib.get_mod_author = function(modname)
    local modpath = core.get_modpath(modname)
    if not modpath then
        return nil, "Mod not found"
    end

    local mod_conf = Settings(modpath .. "/mod.conf")
    if not mod_conf then
        return nil, "mod.conf not found"
    end

    local author = mod_conf:get("author")
    if author then
        return author
    else
        return nil, "Author field not found in mod.conf"
    end
end

local mod_settings = {
    author = lib.get_mod_author("stamina"),
}

if mod_settings.author == "TenPlus1" then
    stamina.enable_sprint = false
    stamina.enable_sprint_particles = false
elseif mod_settings.author == "sofar" then
   stamina.settings.sprint = false
   stamina.settings.sprint_particles = false
   stamina.settings.sprint_with_fast = false
end


