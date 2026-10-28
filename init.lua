local S = core.get_translator(core.get_current_modname())
local modpath = core.get_modpath(core.get_current_modname())

-- Strawberry Seeds: the dedicated seed item, crafted from a strawberry
-- (see _mcl_crafting_output below). Mirrors mcl_farming:melon_seeds: rightclick
-- on farmland to plant a strawberry plant. Planting suppresses eating (via
-- mcl_hunger.prevent_eating, the old strawberry behaviour) so you can't
-- accidentally eat seeds while farming. Not food, hence the craftitem group
-- and no "eatable" group.
core.register_craftitem("leo_strawberry:strawberry_seeds", {
	description = S("Strawberry Seeds"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Grows into a strawberry plant which in turn produces strawberries."),
	_doc_items_usagehelp = S("Place the strawberry seeds on farmland (which can be created with a hoe) to plant a strawberry plant. Strawberry plants grow in sunlight and grow faster on hydrated farmland."),
	inventory_image = "farming_leo_strawberry_seeds.png",
	groups = { craftitem = 1, compostability = 30 },
	_mcl_places_plant = "leo_strawberry:plant_1",
	on_place = function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, "leo_strawberry:plant_1")
		if new then
			mcl_hunger.prevent_eating(placer)
			return new
		end
	end,
})

-- Strawberry: an ordinary small-berry food item. Crafting it yields a single
-- strawberry seed (see _mcl_crafting_output), mirroring mcl_farming:melon_item
-- -> mcl_farming:melon_seeds. Sowing is handled by leo_strawberry:strawberry_seeds
-- instead, so the fruit itself is eaten, not sown. Hunger points come from the
-- "eatable" group (2 = one full hunger icon); saturation follows the glow berry
-- / melon slice convention (see mcl_lush_caves:glow_berry and
-- mcl_farming:melon_item). Eating is handled entirely by mcl_hunger's
-- hold-to-eat system, so no on_use/on_eat and no direct HP change is defined here.
core.register_craftitem("leo_strawberry:strawberry", {
	description = S("Strawberry"),
	inventory_image = "leo_strawberry_strawberry.png",
	groups = { food = 2, eatable = 2, compostability = 30 },
	_mcl_saturation = 1.2,
	-- Crafting a strawberry yields one strawberry seed, exactly like a melon
	-- slice yields one melon seed. "single" is the 1x1 shapeless recipe shape
	-- understood by _mcl_autogroup.
	_mcl_crafting_output = {
		single = {output = "leo_strawberry:strawberry_seeds"},
	},
})

-- Glass Jar: a container crafted from glass, mirroring mcl_potions:glass_bottle
-- but with a deeper "beaker" layout (seven glass in a U) instead of the bottle's
-- three-glass V. Intended as a crafting ingredient (e.g. for jam).
core.register_craftitem("leo_strawberry:jar", {
	description = S("Jar"),
	inventory_image = "leo_strawberry_jar.png",
	-- empty_bottle lets the jar sit in a brewing stand's bottle slots just
	-- like mcl_potions:glass_bottle (routed there by that stand's sort_stack).
	-- brewitem files it under the brewing creative tab. It stays a craftitem
	-- too so it can still be used as a crafting ingredient (e.g. jam).
	groups = { craftitem = 1, brewitem = 1, empty_bottle = 1 },
})

-- Craft a jar from glass in a U/beaker shape:
--   g g
--   g g
--   g g g   (g = mcl_core:glass, blank = empty)
core.register_craft({
	output = "leo_strawberry:jar",
	recipe = {
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "mcl_core:glass", "mcl_core:glass", "mcl_core:glass" },
	},
})

-- Strawberry Marmalade: a jarred preserve, twice as filling as a raw
-- strawberry (eatable 4 vs 2, saturation 2.4 vs 1.2). It is brewed in a brewing
-- stand like a potion: blaze powder as fuel, a strawberry as the ingredient and
-- up to three empty jars in the bottle slots (see register_ingredient_potion
-- below). Eating it empties the jar, returning a reusable leo_strawberry:jar.
core.register_craftitem("leo_strawberry:marmelade", {
	description = S("Strawberry Marmalade"),
	inventory_image = "leo_strawberry_marmelade.png",
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 2.4,
	_mcl_eat_replace_with = "leo_strawberry:jar",
})

-- Brew marmelade: register the jar as the "base bottle" that a strawberry turns
-- into marmelade, mirroring the potion API. The brewing stand supplies the
-- blaze-powder fuel and consumes one strawberry per brew; each jar in a bottle
-- slot becomes a marmelade.
mcl_potions.register_ingredient_potion("leo_strawberry:jar", {
	["leo_strawberry:strawberry"] = "leo_strawberry:marmelade",
})

dofile(modpath .. "/farming.lua")

-- Digging a red tulip yields either one strawberry (50%) or the tulip's
-- normal drop (50%), never both and never nothing. Rarity = 2 on the first
-- entry gives a 1-in-2 chance; if it fails, the unconditional second entry
-- supplies the normal drop. max_items = 1 caps the result at a single item.
core.override_item("mcl_flowers:tulip_red", {
	drop = {
		max_items = 1,
		items = {
			{ items = { "leo_strawberry:strawberry" }, rarity = 2 },
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
			"leo_strawberry:jar 64",
			"leo_strawberry:strawberry 64",
			"leo_strawberry:strawberry_seeds 64",
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
