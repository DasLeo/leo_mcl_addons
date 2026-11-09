local S = core.get_translator(core.get_current_modname())

-- Placed Bread: a loaf you set down on the ground and slice up with an axe.
-- The loaf uses the same flat nodebox as the mcl_cake full cake (a 9/16 block
-- on the floor). It is dug with an axe of any material (axey group); by hand
-- it takes far too long to be worth it, as the _mcl_hardness makes clear.
-- Breaking it yields three toast slices.
local bread_box = { -0.4375, -0.5, -0.4375, 0.4375, 0, 0.4375 }

core.register_node("leo_mcl_addons:bread", {
	description = S("Placed Bread"),
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = bread_box },
	selection_box = { type = "fixed", fixed = bread_box },
	tiles = {
		"leo_mcl_addons_bread_top.png",
		"leo_mcl_addons_bread_bottom.png",
		"leo_mcl_addons_bread_side.png",
	},
	inventory_image = "farming_bread.png",
	wield_image = "farming_bread.png",
	drop = { items = { { items = {"leo_mcl_addons:toast 3"} } } },
	groups = {
		axey = 1, not_in_creative_inventory = 1, dig_by_piston = 1, unsticky = 1,
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_hardness = 2.5,
	_mcl_baseitem = "mcl_farming:bread",
})

-- Placing bread: rightclicking a solid surface with mcl_farming:bread in hand
-- puts a loaf on top of it instead of eating the bread. Mirrors
-- mcl_farming:place_seed. mcl_hunger.prevent_eating stops the hold-to-eat that
-- would otherwise start, since bread is an eatable item.
core.override_item("mcl_farming:bread", {
	on_place = function(itemstack, placer, pointed_thing)
		local pt = pointed_thing
		if not pt or pt.type ~= "node" then
			return
		end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then
			return rc
		end

		-- The support cell is the block being pointed at.
		local support_pos = vector.offset(pt.above, 0, -1, 0)
		local name = placer:get_player_name()
		if core.is_protected(support_pos, name) then
			core.record_protection_violation(support_pos, name)
			return
		end

		local support_node = core.get_node(support_pos)
		if not (core.get_item_group(support_node.name, "solid") > 0
				or core.get_item_group(support_node.name, "walkable") > 0)
			or core.get_node(pt.above).name ~= "air" then
			return
		end

		core.sound_play(core.registered_nodes["leo_mcl_addons:bread"].sounds.place, { pos = pt.above }, true)
		core.set_node(pt.above, {name = "leo_mcl_addons:bread"})
		mcl_hunger.prevent_eating(placer)

		if not core.is_creative_enabled(name) then
			itemstack:take_item()
		end
		return itemstack
	end,
})
