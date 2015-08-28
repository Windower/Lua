config = require('config')
file = require('files')
packets = require('packets')
images = require('images')
texts = require('texts')

defaults = {}
defaults.global = {}
defaults.global.Width = 598
defaults.global.Height = 10
defaults.global.X = windower.get_windower_settings().x_res / 2 - defaults.global.Width / 2
defaults.global.Y = 50
defaults.global.BGPath = windower.addon_path.. 'bar_bg.png'
defaults.global.FGPath = windower.addon_path.. 'bar_fg.png'
defaults.global.visible = false
defaults.global.font = 'Arial'
defaults.global.txtSize = 14
defaults.global.strkSize = 1
defaults.global.style = 0

settings = config.load(defaults)
config.save(settings)

bg_image = images.new()
fg_image = images.new()
txtMain = texts.new()

function init_images()
	bg_image:pos(400, 50)
	bg_image:path(settings.global.BGPath)
	bg_image:color(255, 255, 255, 255)
	bg_image:fit(true)
	bg_image:size(settings.global.Height, settings.global.Width)
	bg_image:repeat_xy(1, 1)
	
	fg_image:pos(400 + 2, 50 + 1)
	fg_image:path(settings.global.FGPath)
	fg_image:fit(true)
	fg_image:size(settings.global.Height, settings.global.Width)
	fg_image:repeat_xy(1, 1)
	
	txtMain:pos(400, 50)
	txtMain:font(settings.global.font)
	txtMain:size(settings.global.size)
	txtMain:bold(true)
	txtMain:text('Enemy Name')
	
	txtMain:bg_visible(false)
	txtMain:color(255, 255, 255)
	txtMain:alpha(255)
	
	txtMain:stroke_width(settings.global.strkSize)
	txtMain:stroke_color(50, 50, 50)
	txtMain:stroke_transparency(127)
		
end