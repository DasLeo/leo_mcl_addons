local S = core.get_translator(core.get_current_modname())
local modpath = core.get_modpath(core.get_current_modname())

-- Strawberry: an ordinary small-berry food item that can also be planted on
-- farmland (see farming.lua). Hunger points come from the "eatable" group
-- (2 = one full hunger icon); saturation follows the glow berry / melon slice
-- convention (see mcl_lush_caves:glow_berry and mcl_farming:melon_item). Eating
-- is handled entirely by mcl_hunger's hold-to-eat system, so no on_use/on_eat
-- and no direct HP change is defined here.
core.register_craftitem("leo_strawberry:strawberry", {
	description = S("Strawberry"),
	inventory_image = "leo_strawberry_strawberry.png",
	groups = { food = 2, eatable = 2, compostability = 30 },
	_mcl_saturation = 1.2,
	-- The strawberry doubles as its own seed, like carrots. Rightclick on
	-- farmland to plant; otherwise it can be eaten.
	_mcl_places_plant = "leo_strawberry:plant_1",
	on_place = function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, "leo_strawberry:plant_1")
		if new then
			mcl_hunger.prevent_eating(placer)
			return new
		end
	end,
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
