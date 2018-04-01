

do

--Lets Populate all our tables with default values and values that cannot be overriden.
local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 
__DMSI.Populate_All_DMod_Tables()

--[[
--   doscript fix for mod support.
--      
--      Lovingly made by BulletMagnet, in the space of an hour, one Summer afternoon.
--      
--      TL; DR (the code).
--         The script should have some smarts about it, and only hokey about with the
--            doscript function once - no matter how many times, this code appears
--            in loaded mods.
--         
--         When doscript is called, it first tries to run in the conventional manner.
--         If that fails, for whatever reason (primarily because files are 404),
--            it searches the folders listed in the __active_mods table for files
--            with matching a directory+name.
--         Each potential file is checked, and the first to successfully complete will
--            cause the script to return.
--         If the script still can't process any files successfully, it will then
--            error-out and return the error from the initial doscript call.
--      
--      This script assumes that the first file found is the desired one, and won't bother
--         trying subsequent mods. If this were to change, or be added, then mod-order
--         would have to be checked too.
--      
--      Hooking files that another mod introduces isn't recommended.
--         ...It probably doesn't work.
--      
--      Script is such a weird looking word, like sombrero.


local m_ok, m_msg = pcall(function() return modscript end)
if not m_ok then
   modscript = true
   
   WARN('*BM: Hooked doscript with mod support fix.')
   WARN('*BM:\tIf you see this message more than once per Lua state then something bad happened.')
   
   local olddoscript = doscript
   doscript = function(script, env)
      local ok, msg = pcall(olddoscript, script, env)
      
      if not ok then
         SPEW('*BM: Problem loading script ' .. repr(script) .. '. Searching active mods for the file.')
         
         for index, info in __active_mods or {} do
            SPEW('*BM:\tTrying doscript on file ' .. info.location .. script)
            
            local ok, msg = pcall(olddoscript, info.location .. script, env)
            
            if ok then
               SPEW('*BM: doscript on file introduced from ' .. info.location .. ' :D')
               
               return env
            else
               continue
            end   
         end
         
         WARN('*BM: ' .. msg)
         
         error('Couldn\'t doscript the file ' .. script .. ' and no other files were found in mods. :(', 2)
      end
   end
end
--]]
end
