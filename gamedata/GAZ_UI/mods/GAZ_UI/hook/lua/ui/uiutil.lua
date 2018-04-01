do
	--allows skins to work with non standard textures
	function GUIUIFile(filespec)
		local skins = import('/lua/skins/skins.lua').skins
	    local visitingSkin = currentSkin()

	    if visitingSkin == nil then
	        return nil
	    end

	    local currentPath = '/mods/GAZ_UI/textures/'..visitingSkin

	    -- if current skin is default, then don't bother trying to look for it, just append the default dir
	    if visitingSkin == 'default' then
	        return currentPath .. filespec
	    else
	        while visitingSkin do
	            local curFile = currentPath .. filespec
	            if DiskGetFileInfo(curFile) then
	                return curFile
	            else
	                visitingSkin = skins[visitingSkin].default
	                if visitingSkin then currentPath = '/mods/GAZ_UI/textures/'..visitingSkin end
	            end
	        end
	    end

	    LOG("Warning: Unable to find file ", filespec)
	    -- pass out the final string anyway so resource loader can gracefully fail
	    return filespec
	end
	
	function GUITexture(filespec)
	    return function()
	        return GUIUIFile(filespec)
	    end
	end
end
