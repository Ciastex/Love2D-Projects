require("framework.extensions.coroutine")
require("framework.extensions.string")
require("framework.extensions.table")

Object = require("framework.Object")
require("framework.Color")
require("framework.KeyBinding")

require("framework.managers.SoundManager")
require("framework.managers.FontManager")
require("framework.managers.InputManager")

_G.managers = { 
    sound = SoundManager("resources/sounds/"),
    font = FontManager("resources/fonts/"),
    input = InputManager()
}
