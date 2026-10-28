local S = core.get_translator(core.get_current_modname())

-- Glass Jar: a container crafted from glass, mirroring mcl_potions:glass_bottle
-- but with a deeper "beaker" layout (seven glass in a U) instead of the bottle's
-- three-glass V. Intended as a crafting ingredient (e.g. for jam).
core.register_craftitem("leo_mcl_addons:jar", {
	description = S("Jar"),
	inventory_image = "leo_mcl_addons_jar.png",
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
	output = "leo_mcl_addons:jar",
	recipe = {
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "mcl_core:glass", "mcl_core:glass", "mcl_core:glass" },
	},
})
