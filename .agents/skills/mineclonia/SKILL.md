---
name: mineclonia
description: Use for any Mineclonia item task — adding, editing, or debugging a Mineclonia item, food, crop, potion, node, or crafting/brewing recipe, or explaining how a Mineclonia item ID (modname:itemname) works. Front-loads where to read the source (~/.minetest/games/mineclonia/), register_craftitem, register_node, groups, _mcl_crafting_output, mcl_farming and mcl_potions APIs.
---

# Mineclonia modding

Guidance for creating new items for [Mineclonia](https://github.com/Sfiet_Ingvar/mineclonia),
a Minecraft-clone **game** built as a large collection of [Luanti](https://luanti.org)
**mods**. Keep the two layers distinct:

- **Mineclonia** is the *game content* — the collection of mods under
  `~/.minetest/games/mineclonia/mods/`. It adds items, nodes, mobs, brewing,
  farming, etc.
- **Luanti** (the engine, formerly named Minetest) is what actually *runs* the
  game and exposes the Lua modding API (`core.*` / `minetest.*`). Item/node
  registration, groups, callbacks and item IDs are engine concepts; Mineclonia
  layers its `_mcl_*` conventions and helper mods on top.

Third-party addons (like this `leo_mcl_addons` mod) are just more Luanti mods
that depend on the relevant Mineclonia mods.

## Researching the Luanti engine source

Mineclonia documents *game* behaviour; the *engine* API (`core.register_*`,
`do_item_eat`, inventories, ABMs, …) lives in Luanti itself. When you need
engine-level detail, clone the engine separately and grep it:

```bash
git clone --filter=blob:none https://github.com/luanti-org/luanti.git /tmp/luanti
cd /tmp/luanti
git checkout "$(git for-each-ref --sort=-creatordate --format='%(refname:short)' refs/tags | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)"
```

- The checkout line selects the most recent tag (by creation date) whose name
  is **only digits and dots** — a full `major.minor.patch` release such as
  `5.17.0` — and skips anything else: `-rc`/`-dev` pre-releases, dated dev tags
  (`20120204_*`), letter-only markers, etc.
- `--filter=blob:none` makes a fast blobless clone; omit it for a full clone.
- Keep this clone at `/tmp/luanti` so it is never confused with the Mineclonia
  game checkout at `~/.minetest/games/mineclonia/`.

## Golden rules

- **Match existing patterns.** Before writing anything, find the closest
  existing item in the Mineclonia source and copy its shape. Every feature
  (food, seed, bottle, ore, crop) already has an example.
- **Item IDs are `modname:itemname`.** The part before `:` MUST equal the
  registering mod's `name` from its `mod.conf`. IDs are globally unique, so a
  collision with another mod's ID is a bug.
- **Prefer documented APIs.** `~/.minetest/games/mineclonia/API.md` explicitly
  warns that undocumented internal functions may change. Use the functions
  listed here and in the mod-specific `API.md`/`README.md` files.
- **Declare dependencies.** If your item references another mod's item or calls
  another mod's function, add that mod to your `mod.conf` `depends` so it loads
  first.

## How Mineclonia item IDs work

Every item/node is registered with a **namespaced itemstring** `modname:itemname`:

```lua
core.register_craftitem("leo_mcl_addons:strawberry", { ... })
core.register_node("leo_mcl_addons:plant_5", { ... })
```

- `modname` is the `name =` value in the mod's `mod.conf`. In code you can read
  it with `core.get_current_modname()` and its path with
  `core.get_modpath(core.get_current_modname())`.
- `itemname` is any lowercase identifier you choose (`_` is conventional).
- The same `modname` prefixes craftitem, node, and entity IDs from that mod.
- This repo (`leo_mcl_addons`) IS the `leo_mcl_addons` mod: `init.lua` is the
  entry point, `farming.lua` is pulled in with `dofile(...)`, and `textures/`
  holds the PNGs referenced by `inventory_image`.

## Where to read the source

The game lives at `~/.minetest/games/mineclonia/` (a git checkout of Mineclonia).

| Path | What it documents |
| --- | --- |
| `API.md` | Root API index: special item/node fields, callbacks, `_mcl_crafting_output` shapes, registered mod APIs. Read this first. |
| `GROUPS.md` | Every item/node **group** and its meaning. Groups drive creative tabs, digging tools, crafting `group:` recipes, composting, and more. |
| `ITEMS/mcl_farming/README.md` + `shared_functions.lua` | Crop/gourd planting API. |
| `ITEMS/mcl_potions/API.md` | Brewing/potion API (`register_ingredient_potion`, `register_water_brew`, ...). |
| `ITEMS/mcl_honey/`, `ITEMS/mcl_core/`, `ITEMS/mcl_mobitems/` | Canonical examples of `_mcl_crafting_output`, furnace fields, and food items. |

Mods are grouped into folders (`CORE/`, `ITEMS/`, `ENTITIES/`, `PLAYER/`,
`HUD/`, `MAPGEN/`, ...). Search them with `grep -rn "<thing>"`.

## Adding a simple held item (craftitem)

Use `core.register_craftitem`. This is the most common case (food, materials,
tools you hold but don't place).

```lua
local S = core.get_translator(core.get_current_modname())

core.register_craftitem("leo_mcl_addons:strawberry", {
	description = S("Strawberry"),
	inventory_image = "leo_mcl_addons_strawberry.png",
	groups = { food = 2, eatable = 2, compostability = 30 },
	_mcl_saturation = 1.2,
})
```

Key fields:

- `description` — wrap in `S(...)` (the translator) so it can be localized.
- `inventory_image` / `wield_image` — texture filenames (files live in your
  mod's `textures/`; the `.png` extension is implied).
- `groups` — see `GROUPS.md`. Common ones for items:
  - `food = 1/2/3` — comestible (2 = food, 3 = drink/soup, 1 = other).
  - `eatable = N` — can be wielded + right-clicked to eat; `N` = hunger points
    restored. This is the "gain" of a food.
  - `craftitem = 1` — primarily a crafting material.
  - `brewitem = 1` — primarily used in brewing.
  - `compostability = X` — 1–100, % chance to add a compost level.

### Food specifics

- Hunger gain comes purely from the `eatable` group value
  (`core.do_item_eat(def.groups.eatable, ...)`). Double the gain = double that
  number.
- `_mcl_saturation` — extra saturation points restored (read by `mcl_hunger`).
- `_mcl_eat_replace_with = "modname:item"` — item left behind after eating
  (e.g. honey bottle → glass bottle, stew → bowl, jar of jam → jar).
- Eating is handled by `mcl_hunger`'s hold-to-eat system; you normally do **not**
  write `on_use`/`on_eat` for food.

## Adding a placeable block (node)

Use `core.register_node`. Nodes need digging groups and usually `_mcl_hardness`.

```lua
core.register_node("leo_mcl_addons:berry_block", {
	description = S("Block of Strawberries"),
	tiles = { "leo_mcl_addons_berry_block.png" },
	groups = { building_block = 1, dig_by_piston = 1, compostability = 65 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_hardness = 0,
})
```

Useful node fields (see `API.md` → "Node definitions"):

- `_mcl_hardness` (0 = instant) and matching digging groups (`pickaxey`,
  `axey`, `handy`, ...).
- `_mcl_baseitem` — the item a placed node corresponds to (itemstring or
  `function(pos)`).
- `_on_bone_meal`, `_on_hopper_in/out`, etc. node callbacks.

## Crafting recipes

Two mechanisms. Prefer the one that matches the item you're mirroring.

### 1. `register_craft` (explicit recipe)

```lua
core.register_craft({
	output = "leo_mcl_addons:jar",
	recipe = {
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "mcl_core:glass", "mcl_core:glass", "mcl_core:glass" },
	},
})
```

- `""` = empty slot. You can also use `group:wood`, `group:cobble`, etc.
- Fuel: `core.register_craft({ type = "fuel", recipe = "modname:item", burntime = N })`.

### 2. `_mcl_crafting_output` (auto-registered simple shapes)

Set this field on the **item definition** to auto-generate recipes for common
shapes (handled by `_mcl_autogroup`). Mirrors how `mcl_farming:melon_item` turns
into `mcl_farming:melon_seeds`:

```lua
core.register_craftitem("leo_mcl_addons:strawberry", {
	-- ...
	_mcl_crafting_output = {
		single = { output = "leo_mcl_addons:strawberry_seeds" }, -- 1x1 shapeless
		square2 = { output = "..." },  -- 2x2 square
		square3 = { output = "..." },  -- 3x3 square
		-- also: line_wide2, line_wide3, line_tall2, line_tall3
	},
})
```

Supported shape keys (see `API.md`): `single`, `square2`, `square3`,
`line_wide2`, `line_wide3`, `line_tall2`, `line_tall3`. Each value is a table
with an `output` string (and optional `replacements`).

## Farming: crops and gourds

The `mcl_farming` API (namespace `mcl_farming`, see
`ITEMS/mcl_farming/shared_functions.lua`):

- `mcl_farming:place_seed(itemstack, placer, pointed_thing, plantname)` — plant
  on tilled soil; call from a seed item's `on_place`. Requires the `soil` group
  on the target.
- `mcl_farming:add_plant(identifier, full_grown, {stage_nodes...}, interval, chance)`
  — register growth ABM for a multi-stage plant.
- `mcl_farming:on_bone_meal(...)` — advance growth with bone meal.
- `mcl_farming:add_gourd(...)` — melon/pumpkin-style stems + fruit.

A seed item typically looks like:

```lua
core.register_craftitem("leo_mcl_addons:strawberry_seeds", {
	description = S("Strawberry Seeds"),
	inventory_image = "leo_mcl_addons_seeds.png",
	groups = { craftitem = 1, compostability = 30 },
	_mcl_places_plant = "leo_mcl_addons:plant_1",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "leo_mcl_addons:plant_1")
	end,
})
```

## Brewing: potions and brewed items

The `mcl_potions` API (see `ITEMS/mcl_potions/API.md`). To brew an item in the
brewing stand, register the **base container** as an ingredient-potion and map
ingredients to outputs. This is how a strawberry + 3 jars becomes jam:

```lua
mcl_potions.register_ingredient_potion("leo_mcl_addons:jar", {
	["leo_mcl_addons:strawberry"] = "leo_mcl_addons:jam",
})
```

- The brewing stand reads this via `mcl_potions.get_alchemy(ingredient, bottle)`.
- Related: `register_water_brew(ingr, potion)`, `register_awkward_brew`,
  `register_mundane_brew`, `register_thick_brew`, `register_table_modifier`.
- The stand routes items to bottle slots by group (`empty_bottle`, `potion`,
  `water_bottle`, ...); a plain food output should NOT carry those groups or it
  becomes re-brewable.

## Checklist before finishing

1. Item ID prefix matches `mod.conf` `name =`.
2. Any referenced external item/function is in `depends`.
3. Groups match `GROUPS.md` (especially `food`/`eatable` for food, digging
   groups for nodes).
4. Textures referenced by `inventory_image` exist in `textures/`.
5. Syntax-check every edited Lua file: `luac -p <file>`.
6. If the mod has an install script, run it and test in-game.
