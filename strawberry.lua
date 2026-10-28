local S = core.get_translator(core.get_current_modname())

-- Strawberry Seeds: the dedicated seed item, crafted from a strawberry
-- (see _mcl_crafting_output below). Mirrors mcl_farming:melon_seeds: rightclick
-- on farmland to plant a strawberry plant. Planting suppresses eating (via
-- mcl_hunger.prevent_eating, the old strawberry behaviour) so you can't
-- accidentally eat seeds while farming. Not food, hence the craftitem group
-- and no "eatable" group.
core.register_craftitem("leo_mcl_addons:strawberry_seeds", {
	description = S("Strawberry Seeds"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Grows into a strawberry plant which in turn produces strawberries."),
	_doc_items_usagehelp = S("Place the strawberry seeds on farmland (which can be created with a hoe) to plant a strawberry plant. Strawberry plants grow in sunlight and grow faster on hydrated farmland."),
	inventory_image = "leo_mcl_addons_seeds.png",
	groups = { craftitem = 1, compostability = 30 },
	_mcl_places_plant = "leo_mcl_addons:plant_1",
	on_place = function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, "leo_mcl_addons:plant_1")
		if new then
			mcl_hunger.prevent_eating(placer)
			return new
		end
	end,
})

-- Strawberry: an ordinary small-berry food item. Crafting it yields a single
-- strawberry seed (see _mcl_crafting_output), mirroring mcl_farming:melon_item
-- -> mcl_farming:melon_seeds. Sowing is handled by leo_mcl_addons:strawberry_seeds
-- instead, so the fruit itself is eaten, not sown. Hunger points come from the
-- "eatable" group (2 = one full hunger icon); saturation follows the glow berry
-- / melon slice convention (see mcl_lush_caves:glow_berry and
-- mcl_farming:melon_item). Eating is handled entirely by mcl_hunger's
-- hold-to-eat system, so no on_use/on_eat and no direct HP change is defined here.
core.register_craftitem("leo_mcl_addons:strawberry", {
	description = S("Strawberry"),
	inventory_image = "leo_mcl_addons_strawberry.png",
	groups = { food = 2, eatable = 2, compostability = 30 },
	_mcl_saturation = 1.2,
	-- Crafting a strawberry yields one strawberry seed, exactly like a melon
	-- slice yields one melon seed. "single" is the 1x1 shapeless recipe shape
	-- understood by _mcl_autogroup.
	_mcl_crafting_output = {
		single = {output = "leo_mcl_addons:strawberry_seeds"},
	},
})

-- Strawberry plant: farmable like wheat/carrots via mcl_farming.
-- 5 visual stages (plant_1..plant_5); plant_1..4 are immature and return a
-- single strawberry when harvested, plant_5 is mature and drops 1 strawberry
-- always plus a second one 40% of the time.

local function on_bone_meal(itemstack, placer, pointed_thing, pos, node)
	-- Pass stages = 1 like the other few-stage crops (beetroot, sweet_berry)
	-- so bone meal advances gradually instead of overshooting to maturity.
	return mcl_farming.on_bone_meal(itemstack, placer, pointed_thing, pos, node, "plant_leo_mcl_addons", 1)
end

local sel_heights = {
	-0.5 + (3 / 16),
	-0.5 + (5 / 16),
	-0.5 + (8 / 16),
	-0.5 + (10 / 16),
	-0.5 + (12 / 16),
}

for i = 1, 5 do
	local texture = "leo_mcl_addons_plant_" .. i .. ".png"
	local create = (i == 1)
	local def = {
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 3,
		sunlight_propagates = true,
		walkable = false,
		drawtype = "plantlike",
		tiles = { texture },
		inventory_image = texture,
		wield_image = texture,
		selection_box = {
			type = "fixed",
			fixed = { -7 / 16, -0.5, -7 / 16, 7 / 16, sel_heights[i], 7 / 16 },
		},
		groups = {
			dig_immediate = 3, not_in_creative_inventory = 1, plant = 1, attached_node = 1,
			dig_by_water = 1, destroy_by_lava_flow = 1, dig_by_piston = 1, unsticky = 1,
			compostability = 30,
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_hardness = 0,
		_on_bone_meal = on_bone_meal,
		_mcl_baseitem = "leo_mcl_addons:strawberry_seeds",
	}

	if i < 5 then
		def.description = S("Premature Strawberry Plant (Stage @1)", i)
		-- Immature plants return a single strawberry when harvested.
		def.drop = "leo_mcl_addons:strawberry"
		def._doc_items_create_entry = create
		if i == 1 then
			def._doc_items_entry_name = S("Premature Strawberry Plant")
			def._doc_items_longdesc = S([[
				Premature strawberry plants grow on farmland under sunlight in 5 stages.
				On hydrated farmland, they grow faster. They can be harvested at any time but will only yield a profit when mature.
			]])
		end
		core.register_node("leo_mcl_addons:plant_" .. i, def)
	end
end

core.register_node("leo_mcl_addons:plant_5", {
	description = S("Mature Strawberry Plant"),
	_doc_items_longdesc = S([[
		Mature strawberry plants are ready to be harvested. They always drop at least one
		strawberry, and occasionally drop two.
	]]),
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	tiles = { "leo_mcl_addons_plant_5.png" },
	inventory_image = "leo_mcl_addons_plant_5.png",
	wield_image = "leo_mcl_addons_plant_5.png",
	-- Always drop at least 1 strawberry; drop a second one 40% of the time.
	-- First-match-wins with max_items = 1: rarity 5 (20%) + rarity 4 (25% of the
	-- remaining 80% = 20%) = 40% chance of two, otherwise the unconditional entry
	-- yields exactly one. Mirrors the wheat/carrot rarity-drop convention.
	drop = {
		max_items = 1,
		items = {
			{ items = { "leo_mcl_addons:strawberry 2" }, rarity = 5 },
			{ items = { "leo_mcl_addons:strawberry 2" }, rarity = 4 },
			{ items = { "leo_mcl_addons:strawberry" } },
		},
	},
	selection_box = {
		type = "fixed",
		fixed = { -7 / 16, -0.5, -7 / 16, 7 / 16, sel_heights[5], 7 / 16 },
	},
	groups = {
		dig_immediate = 3, not_in_creative_inventory = 1, plant = 1, attached_node = 1,
		dig_by_water = 1, destroy_by_lava_flow = 1, dig_by_piston = 1, unsticky = 1,
		compostability = 65, strawberry = 8,
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_hardness = 0,
	_on_bone_meal = on_bone_meal,
	_mcl_baseitem = "leo_mcl_addons:strawberry_seeds",
})

mcl_farming:add_plant("plant_leo_mcl_addons", "leo_mcl_addons:plant_5", {
	"leo_mcl_addons:plant_1",
	"leo_mcl_addons:plant_2",
	"leo_mcl_addons:plant_3",
	"leo_mcl_addons:plant_4",
}, 25, 20)

for i = 2, 4 do
	doc.add_entry_alias("nodes", "leo_mcl_addons:plant_1", "nodes", "leo_mcl_addons:plant_" .. i)
end
