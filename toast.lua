local S = core.get_translator(core.get_current_modname())

-- Toast: a slice of bread, obtained by breaking a placed loaf with an axe
-- (see bread.lua). Two hunger icons (eatable 4) with generous saturation.
core.register_craftitem("leo_mcl_addons:toast", {
	description = S("Toast"),
	inventory_image = "leo_mcl_addons_toast.png",
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 4.8,
})
