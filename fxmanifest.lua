fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'jims-lumberjack'
author 'Jamie'
description 'Standalone Lumber Company System'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared/sh_config.lua',
    'shared/sh_permissions.lua',
    'shared/sh_utils.lua'
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_blips.lua',
    'client/cl_trees.lua',
    'client/cl_sap.lua',
    'client/cl_processing.lua',
    'client/cl_storage.lua',
    'client/cl_shopfront.lua',
    'client/cl_wagons.lua',
    'client/cl_deliveries.lua',
    'client/cl_office.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_permissions.lua',
    'server/sv_trees.lua',
    'server/sv_sap.lua',
    'server/sv_processing.lua',
    'server/sv_storage.lua',
    'server/sv_shopfront.lua',
    'server/sv_wagons.lua',
    'server/sv_deliveries.lua',
    'server/sv_office.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
    'data/trees.json',
}
