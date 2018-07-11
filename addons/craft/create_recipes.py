import urllib2
from bs4 import BeautifulSoup
from slpp import slpp as lua
import os
import platform


hdr = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
    'Accept-Encoding': 'none',
    'Accept-Language': 'en-US,en;q=0.8',
    'Connection': 'keep-alive',
}

sphere = None

def get_recipe(row):
    crystals = [
        'Dark Crystal',
        'Light Crystal',
        'Earth Crystal',
        'Water Crystal',
        'Fire Crystal',
        'Wind Crystal',
        'Lightning Crystal',
        'Ice Crystal',
        'Pyre Crystal',
        'Frost Crystal',
        'Vortex Crystal',
        'Geo Crystal',
        'Terra II Crystal',
        'Bolt Crystal',
        'Fluid Crystal',
        'Glimmer Crystal',
        'Shadow Crystal',
    ]
    y, r, c, i = [
        td for td in row.findAll('td')
    ]
    name = str(y.findAll('a')[0]['title'])
    crystal = None
    ingredients = []
    for li in i.findAll('li'):
        english = str(li.findAll('a')[0]['title'])
        if english in crystals:
            crystal = english
            continue
        if li.text[-1].isdigit() and not "Kit" in english:
            for n in range(int(li.text[-1])):
                ingredients.append(english)
        else:
            ingredients.append(english)
    return [(name, crystal, ingredients)]

def get_sphere_recipe(row):
    spheres = [
        'Liquefaction Sphere',
        'Transfixion Sphere',
        'Detonation Sphere',
        'Impaction Sphere',
        'Induration Sphere',
        'Reverberation Sphere',
        'Scission Sphere',
        'Compression Sphere',
    ]
    global sphere
    cells = [td for td in row.findAll('td')]
    if len(cells) > 4:
        rare_ex, rare, ex, c, s = cells[:5]
        if str(s.findAll('a')[0]['title']) in spheres:
            sphere = str(s.findAll('a')[0]['title'])
    else:
        rare_ex, rare, ex, c = cells[:4]
    recipes = []
    crystal = str(c.findAll('img')[0]['alt']).rstrip(' icon.png')
    ingredients = []
    for cell in cells[:3]:
        for a in cell.findAll('a'):
            recipes.append((sphere, crystal, [str(a['title'])]))
    return recipes

def get_recipes_from_rows(rows, spheres=False):
    recipes = {}
    for row in rows:
        if spheres:
            subrecipes = get_sphere_recipe(row)
        else:
            subrecipes = get_recipe(row)
        for (name, crystal, ingredients) in subrecipes:
            while name in recipes.keys():
                if name[-1].isdigit():
                    name = name[:-2] + (" %d" % (int(name[-1]) + 1))
                else:
                    name = name + " 2"
            recipes[name] = [crystal, ingredients]
    return recipes

def get_recipes_from_soup(soup, spheres=False):
    string = "Sphere Obtained" if spheres else "Synthesis Information"
    lengths = [4, 5, 6, 7] if spheres else [4]
    subtables = [
        descendant.parent.parent.parent
        for descendant in soup.descendants
        if string in descendant
    ]
    rows = []
    for subtable in subtables:
        children = [
            row
            for row in subtable.children
            if (hasattr(row, 'findAll') and
                len(row.findAll('td')) in lengths)
        ]
        rows.extend(children)
    return get_recipes_from_rows(rows, spheres)

def get_items_dictionary():
    if platform.system() == 'Windows':
        path = 'C:\\Program Files (x86)\\Windower4\\res\\items.lua'
    else:
        path = os.path.join(os.path.expanduser("~"), 'Resources/lua/items.lua')
    with open(path) as fd:
        data = fd.read().replace('return', '', 1)
        return lua.decode(data)

def get_items():
    exceptions = {
        'geo crystal' : 6509,
        'terra ii crystal' : 6509,
        'broken single-hook fishing rod' : 472,
        'broken hume rod' : 1832,
        'broken bamboo rod' : 487,
        'dark adaman sheet' : 2001,
        'black chocobo fletchings' : 1254,
        'broken willow rod' : 485,
        'four-leaf korringan bud' : 1265,
        'broken fastwater rod' : 488,
        'h. q. coeurl hide' : 1591,
        'broken yew rod' : 486,
        'broken mithran rod' : 483,
        'broken tarutaru rod' : 484,
        "broken lu shang's rod" : 489,
        'fire emblem card' : 9764,
        'ice emblem card' : 9765,
        'wind emblem card' : 9766,
        'earth emblem card' : 9767,
        'lightning emblem card': 9768,
        'water emblem card' : 9769,
        'light emblem card': 9770,
        'dark emblem card': 9771,
    }
    items = get_items_dictionary()
    inverted = {}
    for k, v in items.items():
        if not v['en'].lower() in inverted:
            inverted[v['en'].lower()] = k
        if not v['enl'].lower() in inverted:
            inverted[v['enl'].lower()] = k
    inverted.update(exceptions)
    return items, inverted

def get_item(ingredient, inverted):
    results = []
    exceptions = {
        'behemoth leather' : 'square of behemoth leather',
        'puk fletchings' : 'bag of puk fletchings',
        'phrygian gold' : 'phrygian gold ingot',
        'smilodon leather' : 'square of smilodon leather',
        'chocobo fletchings' : 'bag of chocobo fletchings',
        'vermilion lacquer' : 'pot of vermilion lacquer',
    }
    if ingredient in exceptions:
        return inverted[exceptions[ingredient]]
    for name, iid in inverted.items():
        if ingredient in name:
            return iid

def fix_recipes(recipes):
    items, inverted = get_items()
    for name, (crystal, ingredients) in recipes.items():
        crystal = items[inverted[crystal.lower()]]['en']
        sorted = []
        for ingredient in ingredients:
            ingredient = ingredient.lower()
            if ingredient in inverted:
                sorted.append(inverted[ingredient])
            else:
                sorted.append(get_item(ingredient, inverted))
        sorted.sort()
        ingredients = [
            items[ingredient]['en']
            for ingredient in sorted
        ]
        recipes[name] = [crystal, ingredients]

def build_recipe_string(name, crystal, ingredients):
    recipe = "    [\"%s\"] = {\n        [\"crystal\"] = \"%s\",\n        [\"ingredients\"] = {\n" % (name, crystal)
    for ingredient in ingredients:
        recipe += "            \"%s\",\n" % ingredient
    recipe += "        },\n    },\n"
    return recipe

def save_recipes(recipes):
    with open('recipes.lua', 'w') as fd:
        fd.write("return {\n")
        for key in sorted(recipes.iterkeys()):
            fd.write(build_recipe_string(key, *recipes[key]))
        fd.write("}\n")

def get_recipes(craft, spheres=False):
    base = "https://www.bg-wiki.com/bg/"
    name = "%s.html" % craft
    if not os.path.exists(name):
        req = urllib2.Request(base + craft, headers=hdr)
        try:
            page = urllib2.urlopen(req).read()
        except urllib2.HTTPError, e:
            return
        with open(name, 'w') as fd:
            fd.write(page)
    with open(name, 'r') as fd:
        page = fd.read()
        soup = BeautifulSoup(page, 'lxml')
        return get_recipes_from_soup(soup, spheres)

if __name__ == "__main__":
    crafts = [
        'Alchemy',
        'Bonecraft',
        'Clothcraft',
        'Cooking',
        'Goldsmithing',
        'Leathercraft',
        'Smithing',
        'Woodworking',
    ]
    recipes = {}
    for craft in crafts:
        recipes.update(get_recipes(craft))
    recipes.update(get_recipes('Category:Escutcheons', True))
    fix_recipes(recipes)
    save_recipes(recipes)
