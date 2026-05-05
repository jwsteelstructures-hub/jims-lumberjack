fx_version 'cerulean'
game 'rdr3'
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'jims-lumberjack'
author 'Jamie'
description 'Standalone RedM Lumber Company System'
version '0.2.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_scripts {
}

client_scripts {
    'config.lua',
    'client/ui.lua',
    'client/ui_placement.lua',
    'client/upgrades.lua',
    'client/stables.lua',
    'client/delivery.lua',
    'client/shop.lua',
    'client/utils.lua'
    'client/chopping.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/main.lua',
    'server/upgrades.lua',
    'server/stables.lua',
    'server/delivery.lua',
    'server/shop.lua',
    'server/database.lua'
    'server/chopping.lua'
}
