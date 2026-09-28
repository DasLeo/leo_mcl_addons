from PIL import Image

def png_16x16_to_svg(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    
    if (width, height) != (16, 16):
        raise ValueError(f"Expected a 16x16 image, but received {width}x{height}.")

    svg_parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16" shape-rendering="crispEdges">'
    ]
    
    for y in range(16):
        for x in range(16):
            r, g, b, a = img.getpixel((x, y))
            if a > 0:  # Skip transparent pixels
                fill = f"rgb({r},{g},{b})" if a == 255 else f"rgba({r},{g},{b},{round(a / 255.0, 2)})"
                svg_parts.append(f'  <rect x="{x}" y="{y}" width="1" height="1" fill="{fill}"/>')
                
    svg_parts.append('</svg>')
    
    with open(output_path, "w") as f:
        f.write("\n".join(svg_parts))

# Usage
png_16x16_to_svg("leo_strawberry_strawberry.png", "output.svg")
