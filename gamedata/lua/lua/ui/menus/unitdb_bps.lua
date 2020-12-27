-- unitdb_bps.lua
-- Author: Rat Circus

local UnitDB = import('/lua/ui/menus/unitdb.lua')

function UnitBlueprint(bp)
	-- Courtesy of PhoenixMT
	-- See lua_utils/bluePrintExtractor/threatParser_v006.lua
	UnitDB.countBPs = UnitDB.countBPs + 1
    -- if not bp.Merge then
    --     table.insert(UnitDB.allBlueprints, bp)
    -- end
    if 
    table.find(bp.Categories, 'CIVILIAN') or
    table.find(bp.Categories, 'INSIGNIFICANTUNIT') or
    table.find(bp.Categories, 'BENIGN') then
        return
    end
    UnitDB.temp = bp
end