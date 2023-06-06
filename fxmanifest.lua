fx_version 'adamant'

game 'gta5'

description 'ESX Mafia'

version '1.0'
author 'Bro0kS#1624'

shared_script '@es_extended/imports.lua'

server_scripts {
  '@es_extended/locale.lua',
  '@mysql-async/lib/MySQL.lua',
  'locales/br.lua',
  'locales/de.lua',
  'locales/en.lua',
  'locales/fr.lua',
  'locales/es.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/br.lua',
  'locales/de.lua',
  'locales/en.lua',
  'locales/fr.lua',
  'locales/es.lua',
  'config.lua',
  'client/main.lua'
}
