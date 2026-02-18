local cuts = {}
local save_path = mp.command_native({ "expand-path", "~/cutpoints.txt" })

local function mark_cut()
	local pos = mp.get_property_number("time-pos")
	if pos then
		table.insert(cuts, pos)
		mp.osd_message("Cut @ " .. string.format("%.3f", pos))
	end
end

local function save_cuts()
	local f = io.open(save_path, "w")
	for _, t in ipairs(cuts) do
		f:write(string.format("%.3f\n", t))
	end
	f:close()
	mp.osd_message("Saved cuts to cutpoints.txt")
end

mp.add_key_binding("c", "add-cut", mark_cut)
mp.add_key_binding("s", "save-cuts", save_cuts)
