local S = core.get_translator(core.get_current_modname())

-- Strawberry Marmalade: a jarred preserve, twice as filling as a raw
-- strawberry (eatable 4 vs 2, saturation 2.4 vs 1.2). It is brewed in a brewing
-- stand like a potion: blaze powder as fuel, a strawberry as the ingredient and
-- up to three empty jars in the bottle slots (see register_ingredient_potion
-- below). Eating it empties the jar, returning a reusable leo_mcl_addons:jar.
core.register_craftitem("leo_mcl_addons:marmelade", {
	description = S("Strawberry Marmalade"),
	inventory_image = "leo_mcl_addons_marmelade.png",
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 2.4,
	_mcl_eat_replace_with = "leo_mcl_addons:jar",
})

-- Brew marmelade: register the jar as the "base bottle" that a strawberry turns
-- into marmelade, mirroring the potion API. The brewing stand supplies the
-- blaze-powder fuel and consumes one strawberry per brew; each jar in a bottle
-- slot becomes a marmelade.
mcl_potions.register_ingredient_potion("leo_mcl_addons:jar", {
	["leo_mcl_addons:strawberry"] = "leo_mcl_addons:marmelade",
})
