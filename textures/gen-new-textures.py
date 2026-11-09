import os
from PIL import Image

# All paths are relative to this script's own directory (textures/).
BASE = os.path.dirname(os.path.abspath(__file__))
os.chdir(BASE)

# Textures that are hand-authored in GIMP (their .xcf files are the real source).
# This script must NEVER (re)generate or overwrite them; it only produces the
# derived textures listed in OUT. Re-running the script leaves these untouched.
HANDMADE = {
	"toast":         "leo_mcl_addons_toast.png",
	"jam_toast":     "leo_mcl_addons_jam_toast.png",
	"bio_jam": "leo_mcl_addons_bio_jam.png",
}

# Derived textures this script (re)generates. Keep hand-authored ones OUT of here.
OUT = {
	"sugar_syrup":  "leo_mcl_addons_sugar_syrup.png",
	"honey_jar":    "leo_mcl_addons_honey_jar.png",
	"bread_top":    "leo_mcl_addons_bread_top.png",
	"bread_side":   "leo_mcl_addons_bread_side.png",
	"bread_bottom": "leo_mcl_addons_bread_bottom.png",
}

# Filling pixel colours of leo_mcl_addons_jam.png, remapped per variant.
# Sugar syrup = pale, honey jar = the mcl_honey amber palette. Only the jam
# "content" colours are swapped; the glass highlights and label band stay put.
JAR_VARIANTS = {
	"sugar_syrup": {"a8372f": "f2f2e6", "8f3027": "d8d8c8", "d8ad7f": "ffffff"},
	"honey_jar":   {"a8372f": "ffc243", "8f3027": "d87803", "d8ad7f": "faab1c"},
}

# Bread loaf palette, from the farming_bread.png colours.
BREAD = {
	"crust_dark": "6a4432", "crust": "7c503b", "crust_mid": "8a5a33",
	"body_dark": "946144", "body": "b57b4c", "body_light": "d19866",
}


def rgb(h):
	return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def put(im, x, y, colour):
	im.putpixel((x, y), rgb(colour) + (255,))


def remap(im, mapping):
	for y in range(16):
		for x in range(16):
			p = im.getpixel((x, y))
			if p[3] > 0:
				key = "%02x%02x%02x" % p[:3]
				if key in mapping:
					im.putpixel((x, y), rgb(mapping[key]) + (255,))


def save(im, name):
	path = OUT[name]
	# Belt-and-suspenders: never clobber a hand-authored texture.
	if path in set(HANDMADE.values()):
		raise SystemExit("refusing to overwrite hand-authored texture: " + path)
	im.save(path)
	print("  wrote " + path)


# --- jar variants: palette-swapped copies of the jam jar ---------------
for name, mapping in JAR_VARIANTS.items():
	im = Image.open("leo_mcl_addons_jam.png").convert("RGBA")
	remap(im, mapping)
	save(im, name)

# --- placed-bread node tiles -------------------------------------------------
bread_top = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
for y in range(16):
	for x in range(16):
		put(bread_top, x, y, BREAD["crust"] if (x + y) % 7 == 0 else BREAD["body_dark"])
for x, y in ((4, 5), (10, 3), (7, 10), (12, 11), (2, 12)):
	put(bread_top, x, y, BREAD["body"])
save(bread_top, "bread_top")

bread_side = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
for y in range(16):
	for x in range(16):
		if y <= 2:
			colour = BREAD["crust_mid"]
		elif y >= 13:
			colour = BREAD["crust_dark"]
		elif y % 4 == 0:
			colour = BREAD["body"]
		elif x % 5 == 2 and y % 3 == 1:
			colour = BREAD["body_dark"]
		else:
			colour = BREAD["body_light"]
		put(bread_side, x, y, colour)
save(bread_side, "bread_side")

bread_bottom = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
for y in range(16):
	for x in range(16):
		put(bread_bottom, x, y, BREAD["crust"] if (x * 3 + y * 5) % 11 == 0 else BREAD["crust_dark"])
save(bread_bottom, "bread_bottom")

print("done (hand-authored toast/jam_toast/bio_jam left untouched)")
