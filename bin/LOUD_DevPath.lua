
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

--mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\mods', '/mods')
--mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\maps', '/maps')
--mount_dir(InitFileDir .. '\\..\\gamedata\\*.scd', '/')
mount_dir(InitFileDir .. '\\..', '/')
mount_dir(InitFileDir .. '\\..\\gamedata', '/')
mount_dir(InitFileDir .. '\\..\\gamedata\\lua\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\loc_US\\loc', '/loc')
mount_dir(InitFileDir .. '\\..\\gamedata\\textures\\textures', '/textures')
mount_dir(InitFileDir .. '\\..\\gamedata\\meshes\\meshes', '/meshes')
mount_dir(InitFileDir .. '\\..\\gamedata\\effects\\effects', '/effects')
mount_dir(InitFileDir .. '\\..\\gamedata\\props\\props', '/props')
mount_dir(InitFileDir .. '\\..\\gamedata\\env\\env', '/env')
mount_dir(InitFileDir .. '\\..\\gamedata\\projectiles\\projectiles', '/projectiles')
mount_dir(InitFileDir .. '\\..\\gamedata\\units\\units', '/units')
mount_dir(InitFileDir .. '\\..\\gamedata\\Domino_Mod_Support\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\LOUD_Mods\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\TotalMayhem\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\BlackOps\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\4D-CompatabilityPack\\mods', '/mods')
mount_dir(InitFileDir .. '\\..\\gamedata\\03_LobbyEnhancement\\textures', '/textures')
mount_dir(InitFileDir .. '\\..\\gamedata\\03_LobbyEnhancement\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\GAZ_UI\\mods', '/mods')
--Versioning
mount_dir(InitFileDir .. '\\..\\gamedata\\loc_US\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\textures\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\effects\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\env\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\projectiles\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\units\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\Domino_Mod_Support\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\LOUD_Mods\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\TotalMayhem\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\BlackOps\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\4D-CompatabilityPack\\lua', '/lua')
mount_dir(InitFileDir .. '\\..\\gamedata\\GAZ_UI\\lua', '/lua')
--Non Game-data
mount_dir(InitFileDir .. '\\..\\maps', '/maps')
--mount_dir(InitFileDir .. '\\..\\sounds', '/sounds')


hook = {
    '/schook'
}



protocols = {
    'http',
    'https',
    'mailto',
    'ventrilo',
    'teamspeak',
    'daap',
    'im',
}
