local mp = require("mp")

-- Jump near live edge, then creep forward until we can't anymore.
-- Keeps buffer intact (no reload).

local BIG_BACKOFF = 2.0 -- seconds to stay behind edge on first jump
local HOP = 0.5 -- seconds per forward hop
local MAX_HOPS = 30 -- safety limit
local CHECK_DELAY = 0.08 -- wait after each hop
local MIN_PROGRESS = 0.03 -- threshold to detect "no movement"

local function jump_live_edge()
	local t = mp.get_property_number("playback-time")
	local ahead = mp.get_property_number("demuxer-cache-duration")

	if not t or not ahead then
		mp.osd_message("live-edge: no cache info", 0.8)
		return
	end

	-- First: big safe jump close to edge
	local big = ahead - BIG_BACKOFF
	if big > 0.05 then
		mp.commandv("seek", big, "relative+keyframes")
	end

	-- Then: small hops forward until no progress
	local hops = 0
	local function hop()
		if hops >= MAX_HOPS then
			return
		end
		hops = hops + 1

		local before = mp.get_property_number("playback-time")
		if not before then
			return
		end

		mp.commandv("seek", HOP, "relative+keyframes")

		mp.add_timeout(CHECK_DELAY, function()
			local after = mp.get_property_number("playback-time")
			if not after then
				return
			end

			if (after - before) < MIN_PROGRESS then
				-- reached edge
				return
			end

			hop()
		end)
	end

	mp.add_timeout(0.10, hop)
end

mp.add_key_binding(nil, "live-edge", jump_live_edge)
