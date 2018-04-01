do

local OldImport = import
-- we can prolly use this tecnique to overcome other hard coded import paths by matching the name param to the file being imported..
function import(name)

	local taskpath = string.gsub(name, "[/]?([^/]+)$", "")
	local taskfilename = string.gsub(name, '.*/', '')
	local name = name
	
	if taskpath == '/lua/sim/tasks' and taskfilename != 'TargetLocation' then 
		for index, info in __active_mods or {} do
			if DiskGetFileInfo(info.location .. taskpath .. '/' .. taskfilename) then
				name = info.location .. taskpath .. '/' ..taskfilename
				break
			else
				continue
            end   
		end
	end
	
	return OldImport(name)
	
end

end