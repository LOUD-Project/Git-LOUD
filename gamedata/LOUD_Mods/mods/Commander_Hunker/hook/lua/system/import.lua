--import.lua
--improvised hooking for mod scripts, by Mithy
--version 2

--import is non-destructively hooked to detect non-original script modules (e.g. any mod script files) and search for
--path-equivalent files in the hook folders of all other later load-order mods and doscript them into the same environment.
--The only drawback is the inabiliity to access the original script module's locally-declared variables; all global variables,
--classes, and functions are available.

--Locations that this script will look for files to hook with, for example, /mods/OtherMod/lua/OtherModFile.lua:
-- /mods/MyMod/hook/lua/OtherModFile.lua
-- /mods/MyMod/hook/OtherMod/lua/OtherModFile.lua
--The second location is available should you want to insure that your file is only hooked with OtherMod's script file. The
--first location will hook with any imports of /lua/OtherModFile.lua in any other mods as well, and in some cases this may be
--desirable.  Unit, projectile, and other type class filenames must be unique, so the second method is not necessary for them.

--Set this to false to also check for hooks for UI mod files, and in UI mod hook folders.  By default, only sim mods are
--checked, in part to to limit any potential performance hitches when importing big batches of files mid-game.
local SimOnly = true

--Set this to false to be able to hook files in mods with an earlier load order than yours.  This does not make the script
--completely ignore load order; any other mod attempting to do the same later in the load order will still hook after yours.
--This simply allows your mod to hook files in a mod that has a higher UID, which might sometimes be necessary for hooked
--compatibility fixes.
local UseLoadOrder = true


--ModLocator-lite function, for getting the source mod data for the provided module (or nil, if not a mod's script module)
--Credit to Manimal for the basic idea/implementation
function GetModByModuleName(modulename)
    if string.sub(modulename, 1, 5) == '/mods' then
        for uid, moddata in __active_mods do
            if string.find(moddata.location, string.gsub(modulename, '/mods/([^/]+)/.+$', '%1')) then
                return moddata
            end
        end
    end
end


--import hook
local previmport = import

function import(name)
    --import the requested file
    local env = previmport(name)

    --If the original import was successful,
    if env and not env.__moduleinfo.modhooked then
        --and the module is from a mod (defaulting to sim-only), search for hooks in other mods
        local ownmod = GetModByModuleName(name)
        if ownmod and (not SimOnly or not ownmod.ui_only) then

            --Define a function to execute mod script hooks
            local function ModHook(hook)
                SPEW("Hooking mod script module '" .. name .. "' with file '" .. hook .."'")
                local ok, msg = pcall(doscript, hook, env)
                if not ok then
                    WARN("Problem hooking file '" .. hook .."'!\n" .. msg)
                    __modules[name] = nil
                end
            end

            --Derive paths from the original module name
            local moddir = string.gsub(name, '/mods/([^/]+)/.+$', '%1')
            local relativepath = string.gsub(name, '/mods/[^/]+', '')

            local starthook = false
            for uid, moddata in __active_mods do
                --Filter out ui-only mods, unless requested
                if not SimOnly or not moddata.ui_only then
                    if starthook or not UseLoadOrder then
                        --If we're past the module's owning mod in the load order, start looking for and executing hooks
                        local hook = moddata.location .. '/hook' .. relativepath            -- /mods/MyMod/hook/relativepath
                        local moddirhook = string.gsub(hook, '/hook', '/hook/' .. moddir)   -- /mods/MyMod/hook/OtherMod/relativepath
                        if DiskGetFileInfo(hook) then
                            ModHook(hook)
                        elseif DiskGetFileInfo(moddirhook) then
                            ModHook(moddirhook)
                        end
                    end
                    if UseLoadOrder and not starthook and moddata == ownmod then
                        --We've found the mod that owns this module, start looking for hooks further down the load order
                        starthook = true
                    end
                end
            end
        end
        --Flag this module as having been checked for mod hooks, so we don't continually recheck it on every import
        --This is necessary because checking for __modules[name] will always be true so long as the original import was successful
        env.__moduleinfo.modhooked = true
    end

    return env
end