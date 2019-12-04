--#****************************************************************************
--#*                                                                             
--#*  New File  :  /lua/ui/uiutil.lua                                       
--#*                                                                             
--#*  Author    : GPG Devs                                              
--#*                                                                                                                                           
--#*  Revised   : December 4 2010, Domino                                                    
--#*                                                                             
--#*  Summary   : find local textures for almost all ui icons/textures in active mods local textures folders                                         
--#*                                                                                                                                                       
--#****************************************************************************

--****************************************************************************************************


local gsub = string.gsub
local lower = string.lower
local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua') 
local __Badtextures = __DMSI.__DModBadTextures
local __Textures = __DMSI.__DModTextures
local __FileNameTextures = __DMSI.__DModFileNamePath
local oldLayouts = import('/lua/skins/layouts.lua')
local newLayouts = __DMSI.__DMod_Custom_Layouts
CurSkin = false

do

Layouts = table.merged(newLayouts, oldLayouts)

----------------------------------------------------------------------------------------
local oldSetCurrentSkin = SetCurrentSkin
function SetCurrentSkin(skin)
	oldSetCurrentSkin(skin)
	CurSkin = skin
end

local OldUIFile = UIFile
function UIFile(filespec, param)

	if not filespec then return end

	local filename = filespec
	
	if filename then 
		filename = gsub(filename, "/", "", 1) 
	end
	
	--we get the texture from our mods textures table keyed by path
	--we ommit the first / because we removed it when parseing the path
	-- to add the entry to our mods textures table. (in DMS initialize.lua)
	local modpath = __Textures[filename].filepath or false
	
	if __Badtextures[filename] then 
		return filespec 
	end

	if modpath then 
		return modpath 
	else 
		--were going to run the default uifile code here to get normal game textures and add them to our mod texture table
		--for faster retreivel when the texture is requested again.
		local skins = import('/lua/skins/skins.lua').skins
		local visitingSkin = currentSkin()
		local currentPath = skins[visitingSkin].texturesPath
		local filefound = false

		if visitingSkin == nil or currentPath == nil then
			return nil
		end

		-- if current skin is default, then don't bother trying to look for it, just append the default dir
		if visitingSkin == 'default' then
			return currentPath .. filespec
		else
			while visitingSkin do
				local curFile = currentPath .. filespec
				if DiskGetFileInfo(curFile) then
					filefound = curFile
					break
				else
					visitingSkin = skins[visitingSkin].default
					if visitingSkin then 
						currentPath = skins[visitingSkin].texturesPath 
					else
						break
					end
				end
			end
		end
		
		if filefound then
			local Path = lower(filefound)
			__DMSI.AddTexture(Path, filefound)
			return filefound
		else
			--if were here we havent found the texture at all
			--so now lets search for the filename
			local fileName = Basename(filename,true)
			modpath = __FileNameTextures[fileName].filepath
						
			if modpath then
				--going to throw in a warning here to show people/modders where the texture is expected to be and where it actually is.
				-- i cant give the full path to where the texture needs to be because it could be a skin texture.. i can only give a partial path
				--given by the function that called uifile, besides if were here you should KNOW where the texture needs to be.. its you that called it.
				
				if not __FileNameTextures[fileName].alerted then 
					WARN('-------------------------------------')
					WARN('Texture in wrong location --> ' .. fileName)
					WARN('Found in: --> ' .. repr(modpath))
					WARN('Should be in: --> ' .. repr(filespec))
					WARN('-------------------------------------')
					__FileNameTextures[fileName].alerted = true
				end

				local Path = lower(modpath)
				__DMSI.AddTexture(Path, modpath)
				return modpath
			else
				--no texture found at all using our means.. lets add the texture to our bad textures table and run the old code.
				if not __Badtextures[filename] then 
					__DMSI.AddBadTexture(filename, 'NoTexture')
				end
				--lets en our hook and allow other hooks to run.
				OldUIFile(filespec)
			end
		end
	end	
		
	-- pass out the final string so resource loader can gracefully fail
	return filespec
end

end

--helper functions.. 
function CheckUIFile(filespec)
    local skins = import('/lua/skins/skins.lua').skins
    local visitingSkin = currentSkin()
    local currentPath = skins[visitingSkin].texturesPath
	
    if visitingSkin == nil or currentPath == nil then
        return nil
    end

    if visitingSkin == 'default' then
        return currentPath .. filespec
    else
        while visitingSkin do
            local curFile = currentPath .. filespec
            if DiskGetFileInfo(curFile) then
                return curFile
            else
                visitingSkin = skins[visitingSkin].default
                if visitingSkin then currentPath = skins[visitingSkin].texturesPath end
            end
        end
    end

	local FileNotFound = 'Unable to find file ' .. filespec

	return FileNotFound
end

function UIVideo(filespec)

	if not filespec then return end
	 	
	local filename = string.lower(filespec)
	local validvid = false
			
	local modpath = __DMSI.__DModVideoPaths[filename].filepath
		
	if modpath and DiskGetFileInfo(modpath) then 
		validvid = modpath 
	end
	
	return validvid
end

function DMod_Return_Skin()
	local skins = import('/lua/skins/skins.lua').skins
    local CurrentSkin = currentSkin()
	
	return CurrentSkin
end 

function DMod_Return_Skin_Params()
	local skins = import('/lua/skins/skins.lua').skins
    local CurrentSkin = currentSkin()
	
	return skins[CurrentSkin]
end

function DMod_ordericonsize()
	local params = DMod_Return_Skin_Params().layout_params[currentLayout].Orders.iconsize
	
	if params then 
		return params
	else 
		return false
	end	
end

function OrderLayout_Params(key)
	local params = DMod_Return_Skin_Params().layout_params[currentLayout]
		
	if params.Orders[key] then 
		return params.Orders[key]
	else
		return false
	end
end

function DMod_Layout_Params()
	local params = DMod_Return_Skin_Params().layout_params[currentLayout]
	
	if params then 
		return params
	else 
		return false
	end	
end