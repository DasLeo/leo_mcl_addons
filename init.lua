local S = core.get_translator(core.get_current_modname())
local modpath = core.get_modpath(core.get_current_modname())

-- Load each feature on its own, mirroring how Mineclonia splits a mod into
-- per-crop / per-system files. Order matters: jar.lua, syrup.lua and
-- jam.lua build on the strawberry crop, and bread.lua builds on
-- mcl_farming:bread, so strawberry.lua loads first.
dofile(modpath .. "/strawberry.lua")
dofile(modpath .. "/jar.lua")
dofile(modpath .. "/syrup.lua")
dofile(modpath .. "/jam.lua")
dofile(modpath .. "/toast.lua")
dofile(modpath .. "/bread.lua")
dofile(modpath .. "/jam_toast.lua")

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

-- leo_mcl_addons_test: the privilege that gates the dev/test chat command below.
-- Registering it here makes it "known" to the server; without this, /grant and
-- /grantme reject the name as an "Unknown privilege". It is not handed out
-- automatically (give_to_admin/give_to_singleplayer = false), so even admins must
-- grant it explicitly with /grantme leo_mcl_addons_test.
core.register_privilege("leo_mcl_addons_test", {
	description = S("Allows use of the /leo_mcl_addons_test dev command"),
	give_to_singleplayer = false,
	give_to_admin = false,
})

-- leo_mcl_addons_test: a dev/test chat command that grants the executing player
-- a full set of items for exercising this addon (jar brewing, farming, etc.).
-- Everything comes in stacks of 64 except a single crafting table. add_item puts
-- each stack into the player's main inventory and drops any overflow at their
-- feet if it is full. It requires the "leo_mcl_addons_test" privilege so it stays
-- out of reach of ordinary players on a survival server.
core.register_chatcommand("leo_mcl_addons_test", {
	description = S("Give yourself a set of leo_mcl_addons test items"),
	privs = { leo_mcl_addons_test = true },
	func = function(name)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found."
		end
		local inv = player:get_inventory()
		local grant = {
			"mcl_core:glass 64",
			"mcl_core:sugar 64",
			"mcl_honey:honeycomb 64",
			"mcl_farming:bread 64",
			"mcl_tools:axe_wood 1",
			"mcl_farming:hoe_wood 1",
			"leo_mcl_addons:jar 64",
			"leo_mcl_addons:strawberry 64",
			"leo_mcl_addons:strawberry_seeds 64",
			"leo_mcl_addons:sugar_syrup 64",
			"leo_mcl_addons:honey_jar 64",
			"leo_mcl_addons:jam 64",
			"leo_mcl_addons:bio_jam 64",
			"leo_mcl_addons:toast 64",
			"leo_mcl_addons:jam_toast 64",
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
