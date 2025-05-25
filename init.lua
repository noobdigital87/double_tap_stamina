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
    stamina.enable_sprint = true
    stamina.enable_sprint_particles = false
elseif mod_settings.author == "sofar" then
   stamina.settings.sprint = true
   stamina.settings.sprint_particles = false
   stamina.settings.sprint_with_fast = false
end

local your_mod_name = core.get_current_modname()

local function get_settings_boolean(setting_name, default)
    return core.settings:get_bool(setting_name, default)
end

local function get_settings_number(setting_name, default)
    return tonumber(core.settings:get(setting_name)) or default
end

local settings = {
    	aux1 = false,
    	double_tap = get_settings_boolean(your_mod_name .. ".double_tap", true),
    	particles = get_settings_boolean(your_mod_name .. ".particles", true),
    	tap_interval = get_settings_number(your_mod_name .. ".tap_interval", 0.5),
    	drain_rate = get_settings_number(your_mod_name .. ".drain_rate", 1),
        detection_step = get_settings_number(your_mod_name .. ".detection_step", 0.1),
        sprint_step = get_settings_number(your_mod_name .. ".sprint_step", 0.5),
        drain_step = get_settings_number(your_mod_name .. ".drain_step", 0.1),
        speed = get_settings_number(your_mod_name .. ".speed", 0.8),
        jump = get_settings_number(your_mod_name .. ".jump", 0.1),
}

dg_sprint_core.RegisterStep(your_mod_name, "DETECT", settings.detection_step, function(player, state, dtime)
	local detected = dg_sprint_core.IsSprintKeyDetected(player, settings.aux1, settings.double_tap, settings.tap_interval) and dg_sprint_core.ExtraSprintCheck(player)
	if detected ~= state.detected then
		state.detected = detected
	end
end)

dg_sprint_core.RegisterStep(your_mod_name, "SPRINT", settings.sprint_step, function(player, state, dtime)
	if state.detected and settings.particles then
		dg_sprint_core.ShowParticles(player:get_pos())
	end	
	if state.detected ~= state.is_sprinting then
		state.is_sprinting = state.detected
        dg_sprint_core.Sprint(your_mod_name, player, state.is_sprinting, {speed = settings.speed, jump = settings.jump})
	end
end)


    dg_sprint_core.RegisterStep(your_mod_name, "DRAIN", settings.drain_step, function(player, state, dtime)
    	local is_sprinting = state.is_sprinting
    	local control = player:get_player_control()
        if is_sprinting then
    	    if dg_sprint_core.ExtraDrainCheck(player) or control.jump then
                local player_name = player:get_player_name()
                local saturation = stamina.get_saturation(player)
                stamina.update_saturation(player, saturation - (settings.drain_rate * dtime))
    	    end
        end
    end)


