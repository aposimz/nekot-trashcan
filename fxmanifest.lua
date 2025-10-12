fx_version 'cerulean'
game 'gta5'

name 'nekot-trashcan'
author 'nekot'
description 'Trashcan'
version '1.0.0'

lua54 'yes'

shared_scripts {
	'config.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'server.lua'
}

dependencies {
	'qb-core',
	'qb-target',
	'ox_inventory'
}
