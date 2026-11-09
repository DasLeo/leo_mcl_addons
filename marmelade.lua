local S = core.get_translator(core.get_current_modname())

-- Strawberry Marmalade: a jarred preserve, twice as filling as a raw
-- strawberry (eatable 4 vs 2, saturation 2.4 vs 1.2). It is brewed in a brewing
-- stand like a potion in two steps: the jar is first turned into sugar syrup
-- (see syrup.lua) and then combined with a strawberry. Eating it empties the
-- jar, returning a reusable leo_mcl_addons:jar.
core.register_craftitem("leo_mcl_addons:marmelade", {
	description = S("Strawberry Marmalade"),
	inventory_image = "leo_mcl_addons_marmelade.png",
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 2.4,
	_mcl_eat_replace_with = "leo_mcl_addons:jar",
})

-- Second brew step: sugar syrup jar + strawberry -> marmelade. Registered with
-- register_ingredient_potion exactly like the potion API; the stand supplies
-- the blaze powder fuel and consumes one strawberry per brew.
mcl_potions.register_ingredient_potion("leo_mcl_addons:sugar_syrup", {
	["leo_mcl_addons:strawberry"] = "leo_mcl_addons:marmelade",
})

-- Bio Marmelade: the gentler preserve brewed from a honey jar instead of a
-- sugar syrup jar. Same values as the regular marmelade.
core.register_craftitem("leo_mcl_addons:bio_marmelade", {
	description = S("Bio Marmelade"),
	inventory_image = "leo_mcl_addons_bio_marmelade.png",
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 2.4,
	_mcl_eat_replace_with = "leo_mcl_addons:jar",
})

mcl_potions.register_ingredient_potion("leo_mcl_addons:honey_jar", {
	["leo_mcl_addons:strawberry"] = "leo_mcl_addons:bio_marmelade",
})
