 
--LOG("HUSSAR: " .. "Loading string extensions module: stringX.LUA... "  )
local Tab = import('ext.tables.lua')
 
--[[
TODO:
-  
-  
--]]

Prefix = 'HUSSAR >>>' --'
Level = 'error|warning|info|trace|table'
IsEnabled = true

-- record Info in log console/file 
function Info(message)  
    Record('info', message)
end
-- record Trace function in log console/file 
function Trace(message)
    Record('trace', message)
end
-- record Error in log console/file 
function Error(message)
    Record('error', message)
end
-- record Warning in log console/file 
function Warning(message)
    Record('warning', message)
end
-- record a message in log console/file based on message type
function Record(msgType, message)
    if (not IsEnabled) then return end
    if (string.find(Level,msgType)) then
        --message = string.upper(msgType) .. ' '  .. message
        message = msgType and string.upper(msgType) .. ' ' .. message or message
        --message = Source and Source .. ' ' .. message or message
        message = Prefix and Prefix .. ' ' .. message or message
        LOG(message)
        --print(message)
    else 
        LOG('skipped message type ' .. msgType)
    end
end
-- record recursively table with its keys and corresponding values  
-- useful for looking up values in a table 
function Table(tblValue, tblName)
    if tblName == nil then tblName = "?table?" end
    local msgType = 'table'
    
    local tblType = type(tblValue)
    if (not tblValue) then
        Record(msgType, tblName .. ' is nil')
        return
    elseif (tblType == "table") then
        Record(msgType, tblName .. ' = {}')
        for key,val in Tab.GetPairs(tblValue) do
            if (tblType == "table") then
                Table(val, tblName .. '.' ..key)
            else
                Record(msgType, tblName .. '.' .. key .. ' = ' .. ToString(val))
            end  
        end
    else
        Record(msgType, tblName .. ' = ' .. ToString(tblValue))
    end 
end
-- converts value of a variable to readable string
function ToString(val)
    local valType = type(val)
    local valString = ''
    if (valType == "boolean") then
        valString = val and 'true' or 'false'
    elseif (valType == "table") then
        valString = 'table'
    elseif (valType == "function") then
        valString = 'funtion'
    else
        valString = val or 'nil'
    end 
    return valString
end


