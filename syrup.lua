local S = core.get_translator(core.get_current_modname())

-- Sugar syrup / honey jars: the intermediates of the two-step marmelade
-- brew. A jar with sugar or a honeycomb in the brewing stand's middle slot
-- becomes a sugar syrup jar or a honey jar, which is then combined with a
-- strawberry for the marmelade (see marmelade.lua). The intermediate jars
-- are brewing ingredients, not food, hence the craftitem and empty_bottle
-- groups and no eatable group. empty_bottle is what lets them go back into a
-- bottle slot for the second step.
core.register_craftitem("leo_mcl_addons:sugar_syrup", {
	description = S("Sugar Syrup Jar"),
	inventory_image = "leo_mcl_addons_sugar_syrup.png",
	groups = { craftitem = 1, empty_bottle = 1 },
})

core.register_craftitem("leo_mcl_addons:honey_jar", {
	description = S("Honey Jar"),
	inventory_image = "leo_mcl_addons_honey_jar.png",
	groups = { craftitem = 1, empty_bottle = 1 },
})

-- First brew step: jar + mcl_core:sugar -> sugar syrup jar, and
-- jar + mcl_honey:honeycomb -> honey jar. The stand supplies the
-- blaze powder fuel and consumes one ingredient per brew, as with potions.
mcl_potions.register_ingredient_potion("leo_mcl_addons:jar", {
	["mcl_core:sugar"] = "leo_mcl_addons:sugar_syrup",
	["mcl_honey:honeycomb"] = "leo_mcl_addons:honey_jar",
})
