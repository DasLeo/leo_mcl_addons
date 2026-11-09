local S = core.get_translator(core.get_current_modname())

-- Jam Toast: a toast slice with marmelade spread on it, crafted shapeless from
-- one toast and one marmelade jar. The strongest food in this addon: eatable
-- 8, saturation 7.2.
core.register_craftitem("leo_mcl_addons:jam_toast", {
	description = S("Jam Toast"),
	inventory_image = "leo_mcl_addons_jam_toast.png",
	groups = { food = 2, eatable = 8 },
	_mcl_saturation = 7.2,
})

core.register_craft({
	type = "shapeless",
	output = "leo_mcl_addons:jam_toast",
	recipe = { "leo_mcl_addons:toast", "leo_mcl_addons:marmelade" },
})
