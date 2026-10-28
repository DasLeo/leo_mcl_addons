local S = core.get_translator(core.get_current_modname())

-- Strawberry plant: farmable like wheat/carrots via mcl_farming.
-- 5 visual stages (plant_1..plant_5); plant_1..4 are immature and return a
-- single strawberry when harvested, plant_5 is mature and drops 1 strawberry
-- always plus a second one 40% of the time.

local function on_bone_meal(itemstack, placer, pointed_thing, pos, node)
	-- Pass stages = 1 like the other few-stage crops (beetroot, sweet_berry)
	-- so bone meal advances gradually instead of overshooting to maturity.
	return mcl_farming.on_bone_meal(itemstack, placer, pointed_thing, pos, node, "plant_leo_strawberry", 1)
end

local sel_heights = {
	-0.5 + (3 / 16),
	-0.5 + (5 / 16),
	-0.5 + (8 / 16),
	-0.5 + (10 / 16),
	-0.5 + (12 / 16),
}

for i = 1, 5 do
	local texture = "farming_leo_strawberry_" .. i .. ".png"
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
		_mcl_baseitem = "leo_strawberry:strawberry_seeds",
	}

	if i < 5 then
		def.description = S("Premature Strawberry Plant (Stage @1)", i)
		-- Immature plants return a single strawberry when harvested.
		def.drop = "leo_strawberry:strawberry"
		def._doc_items_create_entry = create
		if i == 1 then
			def._doc_items_entry_name = S("Premature Strawberry Plant")
			def._doc_items_longdesc = S([[
				Premature strawberry plants grow on farmland under sunlight in 5 stages.
				On hydrated farmland, they grow faster. They can be harvested at any time but will only yield a profit when mature.
			]])
		end
		core.register_node("leo_strawberry:plant_" .. i, def)
	end
end

core.register_node("leo_strawberry:plant_5", {
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
	tiles = { "farming_leo_strawberry_5.png" },
	inventory_image = "farming_leo_strawberry_5.png",
	wield_image = "farming_leo_strawberry_5.png",
	-- Always drop at least 1 strawberry; drop a second one 40% of the time.
	-- First-match-wins with max_items = 1: rarity 5 (20%) + rarity 4 (25% of the
	-- remaining 80% = 20%) = 40% chance of two, otherwise the unconditional entry
	-- yields exactly one. Mirrors the wheat/carrot rarity-drop convention.
	drop = {
		max_items = 1,
		items = {
			{ items = { "leo_strawberry:strawberry 2" }, rarity = 5 },
			{ items = { "leo_strawberry:strawberry 2" }, rarity = 4 },
			{ items = { "leo_strawberry:strawberry" } },
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
	_mcl_baseitem = "leo_strawberry:strawberry_seeds",
})

mcl_farming:add_plant("plant_leo_strawberry", "leo_strawberry:plant_5", {
	"leo_strawberry:plant_1",
	"leo_strawberry:plant_2",
	"leo_strawberry:plant_3",
	"leo_strawberry:plant_4",
}, 25, 20)

for i = 2, 4 do
	doc.add_entry_alias("nodes", "leo_strawberry:plant_1", "nodes", "leo_strawberry:plant_" .. i)
end
