path = {}

local function mount_dir(dir, mountpoint)
    table.insert(path, { dir = dir, mountpoint = mountpoint } )
end

local function mount_contents(dir, mountpoint)
    LOG('checking ' .. dir)
    for _,entry in io.dir(dir .. '\\*') do
        if entry != '.' and entry != '..' then
            local mp = string.lower(entry)
            mp = string.gsub(mp, '[.]scd$', '')
            mp = string.gsub(mp, '[.]zip$', '')
            mount_dir(dir .. '\\' .. entry, mountpoint .. '/' .. mp)
        end
    end
end

--LOUD Strat Icons - various sizes
mount_dir(InitFileDir .. '\\..\\..\\LOUD\\usermods\\BrewLAN-StrategicIcons*.scd', '/')

--Git-LOUD content
mount_dir(InitFileDir .. '\\..\\gamedata\\4D-CompatabilityPack\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\TotalMayhem\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\WyvernBattlePack\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\WyvernBattlePack\\Sounds', '/sounds')
mount_dir(InitFileDir .. '\\..\\gamedata\\WyvernBattlePack\\textures', '/textures')
mount_dir(InitFileDir .. '\\..\\gamedata\\BlackOps\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\BrewLAN_LOUD\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\civ_units\\units', '/units')
mount_dir(InitFileDir .. '\\..\\gamedata\\effects\\effects', '/effects')
mount_dir(InitFileDir .. '\\..\\gamedata\\env\\env', '/env')
mount_dir(InitFileDir .. '\\..\\gamedata\\extra_env\\env', '/env')
mount_dir(InitFileDir .. '\\..\\gamedata\\loc_US\\loc', '/loc')
mount_dir(InitFileDir .. '\\..\\gamedata\\LOUD_Misc\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\LOUD_Units\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\lua\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\projectiles\\projectiles', '/projectiles')
mount_dir(InitFileDir .. '\\..\\gamedata\\textures\\textures', '/textures')
mount_dir(InitFileDir .. '\\..\\gamedata\\units\\units', '/units')
mount_dir(InitFileDir .. '\\..\\sounds', '/sounds')

--LOUD content
mount_dir(InitFileDir .. '\\..\\..\\LOUD\\maps', '/maps')

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

--Versioning
mount_dir(InitFileDir .. '\\..\\gamedata\\loc_US\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\textures\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\effects\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\env\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\projectiles\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\units\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\LOUD_Misc\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\LOUD_Units\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\TotalMayhem\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\BlackOps\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\4D-CompatabilityPack\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\BrewLAN_LOUD\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\WyvernBattlePack\\lua', '/lua')

--LOUD directory user maps & mods
mount_dir(InitFileDir .. '\\..\\..\\LOUD\\usermaps', '/maps')
mount_dir(InitFileDir .. '\\..\\..\\LOUD\\usermods', '/mods')

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
