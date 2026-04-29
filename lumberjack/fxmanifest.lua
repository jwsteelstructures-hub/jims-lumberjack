fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resource may break.'

name 'lumberjack'
author 'Jamie'
description 'Standalone RedM Lumberjack Job'
version '0.1.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/chopping.lua',
    'client/wagon.lua',
    'client/ui.lua'
}

server_scripts {
    'server/main.lua',
    'server/payouts.lua',
    'server/company.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}
