local S = core.get_translator(core.get_current_modname())
local modpath = core.get_modpath(core.get_current_modname())

-- Load each feature on its own, mirroring how Mineclonia splits a mod into
-- per-crop / per-system files. Order matters: jar.lua and marmelade.lua build on
-- the strawberry crop, so strawberry.lua loads first.
dofile(modpath .. "/strawberry.lua")
dofile(modpath .. "/jar.lua")
dofile(modpath .. "/marmelade.lua")

-- Digging a red tulip yields either one strawberry (50%) or the tulip's
-- normal drop (50%), never both and never nothing. Rarity = 2 on the first
-- entry gives a 1-in-2 chance; if it fails, the unconditional second entry
-- supplies the normal drop. max_items = 1 caps the result at a single item.
core.override_item("mcl_flowers:tulip_red", {
	drop = {
		max_items = 1,
		items = {
			{ items = { "leo_mcl_addons:strawberry" }, rarity = 2 },
			{ items = { "mcl_flowers:tulip_red" } },
		},
	},
})

-- leo_mcl_addons_test: a dev/test chat command that grants the executing player
-- a full set of items for exercising this addon (jar brewing, farming, etc.).
-- Everything comes in stacks of 64 except a single crafting table. add_item puts
-- each stack into the player's main inventory and drops any overflow at their
-- feet if it is full.
core.register_chatcommand("leo_mcl_addons_test", {
	description = S("Give yourself a set of leo_mcl_addons test items"),
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found."
		end
		local inv = player:get_inventory()
		local grant = {
			"mcl_core:glass 64",
			"leo_mcl_addons:jar 64",
			"leo_mcl_addons:strawberry 64",
			"leo_mcl_addons:strawberry_seeds 64",
			"mcl_brewing:stand_000 64",
			"mcl_mobitems:blaze_powder 64",
			"mcl_bone_meal:bone_meal 64",
			"mcl_crafting_table:crafting_table 1",
			"mcl_flowers:tulip_red 64",
		}
		for _, itemstring in ipairs(grant) do
			inv:add_item("main", itemstring)
		end
		return true, "Granted the leo_mcl_addons test items to your inventory."
	end,
})
