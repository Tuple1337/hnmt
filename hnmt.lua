_addon.name = 'hnmtool'
_addon.author = 'Tuple'
_addon.version = '1.3.3.7'
_addon.commands = {'hnmt'}

config = require('config')
texts = require('texts')
timeit = require('timeit')

settings = config.load(defaults)
times = texts.new(settings)

timer = timeit.new()

times:visible(true)

local is_active = false
local set_time = nil
local alerts_triggered = {false, false, false, false, false, false, false}
local use_alert = true

-- Function to convert HH:MM:SS to seconds
local function time_to_seconds(time_str)
    local h, m, s = time_str:match("^(%d%d):(%d%d):(%d%d)$")
    return (tonumber(h) * 3600) + (tonumber(m) * 60) + tonumber(s)
end

-- Function to format seconds to HH:MM:SS
local function format_time(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function reset_alerts_triggered()
    for i = 1, 7 do
        alerts_triggered[i] = false
    end
end

-- Function to format seconds to MM:SS
local function format_time_to_mm_ss(seconds)
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d:%02d", m, s)
end

local function alert()
    windower.add_to_chat(207, "Get ready!")
	windower.play_sound(windower.addon_path..'sounds/alert.wav')
end

windower.register_event('prerender', function()
    if not windower.ffxi.get_info().logged_in then
        times:hide()
        return
    end

    local current_time = os.date("%H:%M:%S", os.time())
	
    local time_difference = ""
	
    if set_time then
        local current_seconds = time_to_seconds(current_time)
        local set_seconds = time_to_seconds(set_time)
		
   
	
	
	
	
	
		local time_differences = {}
        local time_windows = {}
        for i = 1, 7 do
            local time_diff_seconds = math.abs(math.min(current_seconds - (set_seconds + 600 * (i-1)), 0))
            local time_diff_formatted = format_time(time_diff_seconds)
            local time_window = format_time(set_seconds + 600 * (i-1))
            
            if time_diff_seconds < 15 then
                time_diff_formatted = "\\cs(255,0,0)" .. time_diff_formatted .. "\\cr"
           		
			elseif time_diff_seconds < 30 then
				if not alerts_triggered[i] and use_alert then
                    alert()
                    alerts_triggered[i] = true
                end
                time_diff_formatted = "\\cs(255,128,0)" .. time_diff_formatted .. "\\cr"
            end
			
            --times:text( time_diff_seconds .. "\n")
            table.insert(time_differences, time_diff_formatted)
            table.insert(time_windows, time_window)
        end
		
		times:text(
            "Open: " .. set_time .. "\n---\nCurrent Time: " .. current_time .. "\n=========\n" ..
            "Window 1:    " .. time_differences[1] .. "  -  " .. time_windows[1] .. "\n" ..
            "Window 2:    " .. time_differences[2] .. "  -  " .. time_windows[2] .. "\n" ..
            "Window 3:    " .. time_differences[3] .. "  -  " .. time_windows[3] .. "\n" ..
            "Window 4:    " .. time_differences[4] .. "  -  " .. time_windows[4] .. "\n" ..
            "Window 5:    " .. time_differences[5] .. "  -  " .. time_windows[5] .. "\n" ..
            "Window 6:    " .. time_differences[6] .. "  -  " .. time_windows[6] .. "\n" ..
            "Window 7:    " .. time_differences[7] .. "  -  " .. time_windows[7]
        )
		

    else
        times:text("No Poptime set!\n---\nCurrent Time: " .. current_time )
    end
end)

windower.register_event('addon command', function(command, ...)
    command = command:lower()
    local args = {...}

    if command == 'show' then
        if not is_active then
            is_active = true
            times:visible(true)
        end
        times:show()
    elseif command == 'set' then
        if #args == 1 and args[1]:match("^(%d%d):(%d%d):(%d%d)$") then
            set_time = args[1]
            reset_alerts_triggered()
			windower.add_to_chat(207, "Set open-time to: " .. set_time)
			
        else
            windower.add_to_chat(207, "Invalid input. Use: ht set <HH:MM:SS>")
        end
	elseif command == 'help' then
        windower.add_to_chat(207, "Usage:\nhnmt set HH:MM:SS   ->   Set window open time. Needs to be entered in 24h timeformat.\nhnmt hide   ->   Hide timers\nhnmt show   ->   Show timers\nhnmt alert   ->   Toggles alerts 30 sec prior to each window (default on)")
    elseif command == 'alert' then
		
        if not use_alert then
            use_alert = true
			windower.add_to_chat(207, "Alerts on.")
        else
			use_alert = false
			windower.add_to_chat(207, "Alerts off.")
        end
    		
    elseif command == 'hide' then
        if is_active then
            is_active = false
        end
        times:hide()
    end
end)
