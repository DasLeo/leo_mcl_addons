local S = core.get_translator(core.get_current_modname())

-- Strawberry: an ordinary small-berry food item.
-- Hunger points come from the "eatable" group (2 = one full hunger icon);
-- saturation follows the glow berry / melon slice convention (see
-- mcl_lush_caves:glow_berry and mcl_farming:melon_item). Eating is handled
-- entirely by mcl_hunger's hold-to-eat system, so no on_use/on_eat and no
-- direct HP change is defined here.
core.register_craftitem("leo_strawberry:strawberry", {
	description = S("Strawberry"),
	inventory_image = "leo_strawberry_strawberry.png",
	groups = { food = 2, eatable = 2, compostability = 30 },
	_mcl_saturation = 1.2,
})

-- Digging a red tulip yields either one strawberry (50%) or the tulip's
-- normal drop (50%), never both and never nothing. Rarity = 2 on the first
-- entry gives a 1-in-2 chance; if it fails, the unconditional second entry
-- supplies the normal drop. max_items = 1 caps the result at a single item.
core.override_item("mcl_flowers:tulip_red", {
	drop = {
		max_items = 1,
		items = {
			{ items = {"leo_strawberry:strawberry"}, rarity = 2 },
			{ items = {"mcl_flowers:tulip_red"} },
		},
	},
})
