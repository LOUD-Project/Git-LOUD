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

--Original game content
mount_dir(InitFileDir .. '\\..\\..\\fonts', '/fonts')
mount_dir(InitFileDir .. '\\..\\..\\sounds', '/sounds')

--LOUD content
mount_dir(InitFileDir .. '\\..\\gamedata\\*.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\textures.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\env.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\props.scd', '/')
mount_dir(InitFileDir .. '\\..\\..\\gamedata\\meshes.scd', '/')
mount_dir(InitFileDir .. '\\..\\usermods\\*.scd', '/')
mount_dir(InitFileDir .. '\\..\\usermods', '/mods')
mount_dir(InitFileDir .. '\\..\\maps', '/maps')
mount_dir(InitFileDir .. '\\..\\usermaps', '/maps')
mount_dir(InitFileDir .. '\\..\\sounds', '/sounds')
mount_dir(InitFileDir .. '\\..\\movies', '/movies')

--User mods & maps
--mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\mods', '/mods')
mount_contents(SHGetFolderPath('PERSONAL') .. 'My Games\\Gas Powered Games\\Supreme Commander Forged Alliance\\maps', '/maps')

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
