import urllib2
from bs4 import BeautifulSoup
from slpp import slpp as lua
import os


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
    return name, crystal, ingredients

def get_sphere_recipe(row):
    c, i, r = [
        td for td in row.findAll('td')
    ]
    name = str(r.findAll('a')[0]['title'])
    crystal = str(c.findAll('img')[0]['alt']).rstrip(' icon.png')
    ingredients = [str(i.findAll('a')[0]['title'])]
    return name, crystal, ingredients

def get_recipes_from_rows(rows, spheres=False):
    recipes = {}
    for row in rows:
        if spheres:
            name, crystal, ingredients = get_sphere_recipe(row)
        else:
            name, crystal, ingredients = get_recipe(row)
        while name in recipes.keys():
            if name[-1].isdigit():
                name = name[:-2] + (" %d" % (int(name[-1]) + 1))
            else:
                name = name + " 2"
        recipes[name] = [crystal, ingredients]
    return recipes

def get_recipes_from_soup(soup, spheres=False):
    string = "Sphere Results" if spheres else "Synthesis Information"
    count = 3 if spheres else 4
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
                len(row.findAll('td')) == count)
        ]
        rows.extend(children)
    return get_recipes_from_rows(rows, spheres)

def get_items_dictionary():
    path = 'C:\\Program Files (x86)\\Windower4\\res\\items.lua'
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
        page = urllib2.urlopen(base + craft).read()
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
