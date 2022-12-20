local modpath = "/mods/buildRangePreview/"
local CM = import('/lua/ui/game/commandmode.lua')
local Decal = import('/lua/user/userdecal.lua').UserDecal

local isPreviewAlive = false

local ringGroups = {
    buildrange = {},
}

local function isAcceptablePreviewMode()
    local mode = CM.GetCommandMode()
    return not mode[2] or (mode[1] == "order" and mode[2].name == "RULEUCC_Move")
end

local function createBuildRangeRingIfNecessary(radius)
    if not ringGroups.buildrange[radius] then
        local ring = Decal(GetFrame(0))
        ring:SetTexture(modpath..'textures/range_ring.dds')
        ring:SetScale({math.floor(2.05 * (radius + 2)), 0, math.floor(2.05 * (radius + 2))})
        ring:SetPosition(GetMouseWorldPos())
        ringGroups.buildrange[radius] = ring
    end
end

local function createRangeRingPreviews()
    local units = GetSelectedUnits() or {}
    for _, unit in EntityCategoryFilterDown(categories.ENGINEER, units) do
        local bp = unit:GetBlueprint()
        local radius = bp.Economy.MaxBuildDistance
        if radius then
            createBuildRangeRingIfNecessary(radius)
        end
    end

    isPreviewAlive = true
end

local function updateRingPositions()
    for _, group in ringGroups do
        for __, ring in group do
            ring:SetPosition(GetMouseWorldPos())
        end
    end
end

local function updatePreview()
    if (not isPreviewAlive) then
        createRangeRingPreviews()
    end
    updateRingPositions()
end

local function removePreview()
    if (not isPreviewAlive) then
        return
    end
    for i, group in ringGroups do
        for j, ring in group do
            ring:Destroy()
            group[j] = nil
        end
    end
    isPreviewAlive = false
end

local oldWorldView = WorldView 
WorldView = Class(oldWorldView, Control) {

    previewKey = "SHIFT",

    OnUpdateCursor = function(self)
        if isAcceptablePreviewMode() then
            if IsKeyDown(self.previewKey) then
                updatePreview()
            else
                removePreview()
            end
        end
        return oldWorldView.OnUpdateCursor(self)
    end,
}
