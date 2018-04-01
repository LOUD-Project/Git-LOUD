#A couple helper functions for mods

--My Code # Moolio was kind enough to let us use his mod
function GetAlliedMobileUnitsInSphere(unit, position, radius)
	local x1 = position.x - radius
	local y1 = position.y - radius
	local z1 = position.z - radius
	local x2 = position.x + radius
	local y2 = position.y + radius
	local z2 = position.z + radius
	local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
	#Check for empty rectangle
	if not UnitsinRec then
		return false
	end
	local RadEntities = {}
    for k, v in UnitsinRec do
		local dist = VDist3(position, v:GetPosition())
		if IsAlly(v:GetArmy(), unit:GetArmy()) and dist <= radius and v:GetBlueprint().Physics.MotionType != 'RULEUMT_None' then
			table.insert(RadEntities, v)
		end
	end

	return RadEntities
end

function GetEnemyTech2AntiTeleport(unit, position, radius)
	local x1 = position.x - radius
	local y1 = position.y - radius
	local z1 = position.z - radius
	local x2 = position.x + radius
	local y2 = position.y + radius
	local z2 = position.z + radius
	local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
	#Check for empty rectangle
	if not UnitsinRec then
		return false
	end
	local RadEntities = {}
    for k, v in UnitsinRec do
		local dist = VDist3(position, v:GetPosition())
		local vbpid = v:GetBlueprint().BlueprintId
		if IsEnemy(v:GetArmy(), unit:GetArmy()) and dist <= radius and table.find(v:GetBlueprint().Categories, 'ANTITELEPORT') and table.find(v:GetBlueprint().Categories, 'TECH2') then
			table.insert(RadEntities, v)
		end
	end

	return RadEntities
end

function GetEnemyTech3AntiTeleport(unit, position, radius)
	local x1 = position.x - radius
	local y1 = position.y - radius
	local z1 = position.z - radius
	local x2 = position.x + radius
	local y2 = position.y + radius
	local z2 = position.z + radius
	local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
	#Check for empty rectangle
	if not UnitsinRec then
		return false
	end
	local RadEntities = {}
    for k, v in UnitsinRec do
		local dist = VDist3(position, v:GetPosition())
		local vbpid = v:GetBlueprint().BlueprintId
		if IsEnemy(v:GetArmy(), unit:GetArmy()) and dist <= radius and table.find(v:GetBlueprint().Categories, 'ANTITELEPORT') and table.find(v:GetBlueprint().Categories, 'TECH3') then
			table.insert(RadEntities, v)
		end
	end

	return RadEntities
end

--Ghaleon's code
--[[function GetAlliedMobileUnitsInSphere(unit, position, radius)
    local x1 = position.x - radius
    local y1 = position.y - radius
    local z1 = position.z - radius
    local x2 = position.x + radius
    local y2 = position.y + radius
    local z2 = position.z + radius
    local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
    if not UnitsinRec then return false end
    local RadEntities = {}
    for k,v in UnitsinRec do
        if not IsAlly(v:GetArmy(), unit:GetArmy()) then continue end
        local dist = VDist3(position, v:GetPosition())
        if dist > radius then continue end
        if v:GetBlueprint().Physics.MotionType !='RULEUMT_None' then
            table.insert(RadEntities, v)
        end
    end
    return RadEntities
end 

function GetAlliedStructureUnitsInSphere(unit, position, radius)
    local x1 = position.x - radius
    local y1 = position.y - radius
    local z1 = position.z - radius
    local x2 = position.x + radius
    local y2 = position.y + radius
    local z2 = position.z + radius
    local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
    if not UnitsinRec then return false end
    local RadEntities = {}
    for k,v in UnitsinRec do
        if not IsAlly(v:GetArmy(), unit:GetArmy()) then continue end
        local dist = VDist3(position, v:GetPosition())
        if dist > radius then continue end
        if v:GetBlueprint().Physics.MotionType =='RULEUMT_None' then
            table.insert(RadEntities, v)
        end
    end
    return RadEntities
end ]]--