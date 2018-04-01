# a set of functions that remove objects from tables
# the function passed in will take the item as input, and return true if it should be removed, false otherwise

# given an array of items, collapses the array by removing destroyed items and shifting them down

local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove



function collapseArray(objectArray, isDestroyedFunc)
    local arraySize = LOUDGETN(objectArray)
    local removeTable = {}
	local counter = 0
    for index = 1, arraySize do
        if isDestroyedFunc(objectArray[index]) then
            removeTable[counter+1] = index
			counter = counter + 1
        end
    end

    for k,index in removeTable do
        LOUDREMOVE(objectArray, index)
    end
end

# given a table of items, collapses the array by removing entries, but not changing keys
function collapseTable(objectTable, isDestroyedFunc)
    local removeTable = {}
    for k,v in objectTable do
        if isDestroyedFunc(v) then
            LOUDINSERT(removeTable, k)
        end
    end

    for k,v in removeTable do
        objectTable[v] = nil
    end
end

