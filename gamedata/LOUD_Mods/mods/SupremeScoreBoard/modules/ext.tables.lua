 

-- local tab = import('ext.tables.lua')
-- local num = import('ext.numbers.lua')
local str = import('ext.strings.lua')

function isTab(element) return type(element) == "table" end
function isStr(element) return type(element) == "string" end
function isBool(element) return type(element) == "boolean" end
function isFunt(element) return type(element) == "function" end

function Size(tab) 
    local size = 0 
    if tab then 
        for k,v in tab do
           size = size + 1
       end
    end
    return size
end

-- gets table value or its sub-table for specified column, (tab1.key)  table[tab1].key
function Get(tab, column)
    if (column == nil or column == '') then
        return 0
    end
    -- if multiple columns separated by '|'
    if string.find(column,"|") then
        --LOG('column ' ..column)
        local columns = str.split(column, '|')
        local val = 0
        for key,col in pairs(columns) do
            val = val + Get(tab,col) 
            --LOG('col ' ..col..'='..val)
        end
        return val
    else -- single column
        if not string.find(column,"%.") then
           return tab[column] or 0
        end
        local ind = string.find(column,"%.") 
        local key = string.sub(column, 1, ind-1)
        local col = string.sub(column, ind+1)
        tab = tab[key]
        -- LOG('col2='..column)     
        local val = Get(tab, col)
        --LOG('>>>> HUSSAR: '..column..'='..val)  
        return val     
    end
    
end
-- sets table value or its sub-table for specified column, (tab1.key) table[tab1].key = value
function Set(tab, column, value) 
    if (not string.find(column,"%.")) then
        --LOG(column..'='..tab[column])  
        tab[column] = value
        --LOG(column..'='..tab[column])  
       return
    end     
    ind = string.find(column,"%.") 
    key = string.sub(column, 1, ind-1)
    col = string.sub(column, ind+1)
    tab = tab[key] 
    Set(tab, col, value) 
end
-- gets table pairs in alpha order
function GetPairs(tab, f)
   local arr = {}
   for n in pairs(tab) do 
       table.insert(arr, n) 
   end
   table.sort(arr, f)
   local i = 0              -- iterator variable
   local iter = function () -- iterator function
     i = i + 1
     if arr[i] == nil then return nil
     else return arr[i], tab[arr[i]]
     end
   end
   return iter
end
 
 