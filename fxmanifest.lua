fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'lumberjack'
author 'Jamie'
description 'Standalone RedM Lumberjack Job'
version '0.1.0'

lua54 'yes'

shared_scripts {
    'config.lua',
    'shared/sh_construction.lua',
}

client_scripts {
    'client/cl_notify.lua',
    'client/cl_business.lua',
    'client/cl_office.lua',

    -- Construction system
    'client/cl_construction.lua',
    'client/cl_phases.lua',

    -- Existing client files
    'client/main.lua',
    'client/chopping.lua',
    'client/shop.lua',
    'client/wagon.lua',
    'client/ui.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    -- Construction system
    'server/sv_phases.lua',
    'server/sv_construction.lua',

    -- Existing server files
    'server/sv_business.lua',
    'server/database.lua',
    'server/company.lua',
    'server/payouts.lua',
    'server/main.lua'
    'server/shop.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

server_ignore {
    'server/debug.lua'
}
