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

-- Begin helper functions to improve functionality for loading custom maps & mods (By Lexxy)
local upvString_lower = string.lower;
local upvString_sub = string.sub;
local upvIo_dir = io.dir;
local upvTable_insert = table.insert;

-- Forged Alliance is no longer maintained by GPG. For perf reasons a hard list of FA soundbanks is better than asking the file system every time we launch the game
local loaded_sounds = {
    "aeonselect.xwb",
    "ambienttest.xwb",
    "cybranselect.xwb",
    "explosions.xwb",
    "explosionsstream.xwb",
    "fmv_bg.xwb",
    "impacts.xwb",
    "interface.xwb",
    "music.xwb",
    "op_briefing.xwb",
    "seraphimselect.xwb",
    "uaa.xwb",
    "uaadestroy.xwb",
    "uaaweapon.xwb",
    "uab.xwb",
    "ual.xwb",
    "ualdestroy.xwb",
    "ualweapon.xwb",
    "uas.xwb",
    "uasdestroy.xwb",
    "uasweapon.xwb",
    "uea.xwb",
    "ueadestroy.xwb",
    "ueaweapon.xwb",
    "ueb.xwb",
    "uefselect.xwb",
    "uel.xwb",
    "ueldestroy.xwb",
    "uelweapon.xwb",
    "ues.xwb",
    "uesdestroy.xwb",
    "uesweapon.xwb",
    "unitrumble.xwb",
    "unitsglobal.xwb",
    "ura.xwb",
    "uradestroy.xwb",
    "uraweapon.xwb",
    "urb.xwb",
    "url.xwb",
    "urldestroy.xwb",
    "urlweapon.xwb",
    "urs.xwb",
    "ursdestroy.xwb",
    "ursstream.xwb",
    "ursweapon.xwb",
    "xaa_weapon.xwb",
    "xab.xwb",
    "xal.xwb",
    "xal_weapon.xwb",
    "xas.xwb",
    "xas_weapons.xwb",
    "xea.xwb",
    "xea_weapons.xwb",
    "xeb.xwb",
    "xel.xwb",
    "xel_weapons.xwb",
    "xes.xwb",
    "xes_destroy.xwb",
    "xes_weapons.xwb",
    "xra.xwb",
    "xra_weapon.xwb",
    "xrb.xwb",
    "xrl.xwb",
    "xrl_stream.xwb",
    "xrl_weapon.xwb",
    "xrs.xwb",
    "xrs_weapon.xwb",
    "xsa.xwb",
    "xsa_destroy.xwb",
    "xsa_weapon.xwb",
    "xsb.xwb",
    "xsb_weapon.xwb",
    "xsl.xwb",
    "xsl_destroy.xwb",
    "xsl_weapon.xwb",
    "xss.xwb",
    "xss_destroy.xwb",
    "xss_weapon.xwb",
};

local loaded_mods = {};         -- Reserved for future usage.

-- IO function to find files, normalised to lower case
local function io_findFiles(dir, extension, files)
    local files = files or { };
    local extensionLower = upvString_lower(extension);
    for _, fileOrFolder in upvIo_dir(dir.."/*") do
        if fileOrFolder == "." or fileOrFolder == ".." then continue end;
        local fileOrFolderLower = upvString_lower(fileOrFolder);
        if upvString_sub(fileOrFolderLower, -4) == "."..extensionLower then
            upvTable_insert(files, fileOrFolderLower)
        end
    end
    return files
end

-- Helper function to mount a user mod
local function mount_mod(modName, modDir)
    LOG("Mounting mod '"..modName.."' with additional functionality (e.g. sounds)");
    loaded_mods[modName] = true;
    mount_dir(modDir, "/mods/"..modName);
    for _, fileOrFolder in upvIo_dir(modDir.."/*") do
        local fullPath = modDir.."/"..fileOrFolder;
        if fileOrFolder == 'sounds' then
            local loadSounds = true;
            for _, soundBank in io_findFiles(fullPath, "xwb") do
                if loaded_sounds[soundBank] then
                    loadSounds = false;
                    break;
                else
                    loaded_sounds[soundBank] = true;
                end
            end
            if loadSounds then
                mount_dir(fullPath, "/sounds");
            else
                LOG("Did not load the custom sounds for '"..modName.."' because there were conflicting file names");
            end
        end
    end
end

-- Helper function which mounts user mods
local function mount_mods(modsDir)
    for _, fileOrFolder in upvIo_dir(modsDir.."/*") do
        if fileOrFolder == "." or fileOrFolder == ".." then continue end;
        local fileOrFolderLower = upvString_lower(fileOrFolder);
        local modDir = modsDir.."/"..fileOrFolderLower;
        local fileOrFolderLowerExt = upvString_sub(fileOrFolderLower, -4);
        if fileOrFolderLowerExt == ".zip" or fileOrFolderLowerExt == ".scd" or fileOrFolderLowerExt == ".rar" then
            -- Zipped mods are loaded without additional functionality
            LOG("Mounting mod '"..fileOrFolderLower.."' without additional functionality (e.g. sounds)");
            mount_dir(modDir, "/");
        else
            mount_mod(fileOrFolderLower, modDir);
        end
    end
end

-- End helper functions to improve functionality for loading custom maps & mods

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
