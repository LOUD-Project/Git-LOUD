do
dofile(InitFileDir.."/CommonDataPath.lua");

--LOUD Strat Icons - various sizes
mount_dir(InitFileDir .. '\\..\\usermods\\BrewLAN-StrategicIcons*.scd', '/')

--LOUD content
mount_dir(InitFileDir .. '\\..\\gamedata\\*.scd', '/')
mount_dir(InitFileDir .. '\\..\\maps', '/maps')
mount_dir(InitFileDir .. '\\..\\sounds', '/sounds')

--Vanilla content
mount_dir(InitFileDir .. '\\..\\..\\fonts', '/fonts')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\textures.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\effects.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\env.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\projectiles.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\props.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\meshes.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\movies', '/movies')
mount_dir(InitFileDir .. '\\..\\..\\sounds', '/sounds')

--LOUD directory user maps & mods
mount_dir(InitFileDir .. '\\..\\usermaps', '/maps')
mount_mods(InitFileDir .. '\\..\\usermods', '/mods')

--Documents directory user maps & mods (SCFA default)
--mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\maps', '/maps')
--mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\mods', '/mods')


hook = {
    '/schook'
}

protocols = {
    'http',
    'https',
}
end