-- Author: c04spoon#0623 (https://github.com/joinr)
-- Summary: Utilities for improved faction randomization

--[[

Sample data extrapolated from LOUD lobby and AssignRandomFactions

randomfac = 5
players = {5,5,1,5,5,4,5,5,3,5,5,2}
small    = {1,5,5,5} --typical

--]]

-- Compute a frequency table from a table's values.
function vfreqs(tbl)
    local res = {}
    for k,v in pairs(tbl) do
        if not res[v] then 
            res[v] = 1
        else 
            res[v] = res[v]+1
        end
    end
    return res
end

function exclude(tbl, v)
   local res = {}
   for k,d in pairs(tbl) do
        if v == d then

        else
           res[k] = d
        end
   end
   return res
end

function filter(tbl, v)
   local res = {}
   for k,v2 in pairs(tbl) do
       if  v == v2 then
           res[k] = v2
       end
   end
   return res
end

function keys(tbl)
    res = {}
    for k,v in pairs(tbl) do 
        table.insert(res,k)
    end 
    return res
end

function shuffle(tbl)
  for i=table.getn(tbl),2,-1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

-- Implementation

function draw(fs)
    local least = 1000000
    local candidates = {}
    for e,v in pairs(fs) do
        if v < least then
            least = v
            candidates = {}
            table.insert(candidates,e)
        elseif v == least then
            table.insert(candidates,e)
        end
    end
    local idx = math.random(table.getn(candidates))
    local choice = candidates[idx]
    fs[choice] = fs[choice] + 1
    return choice
end

-- Ensure we have 0 recorded for factions in the
--frequency table that weren't selected yet.
function zeroes(fs)
    for i=1,4,1 do
        if not fs[i] then
            fs[i] = 0
        end
    end
    return fs
end

-- Given an array of player faction selections, 
-- builds a frequency table and traverses the random
-- players. Each random player is dealt a selection
-- from the least-frequent faction at the time. If
-- there are multiple candidates, we do a random 
-- draw to determine which is selected. After 
-- each draw, we update the frequency table to 
-- ensure de-duplication of factions until 
-- frequencies are even. This should evenly
-- distribute the random factions while accounting
-- for the existing user selection while maintaining
-- variety in representation. We can easily
-- tweak this to bias toward distributions and the
-- like. We don't take location into account, since
-- map placement is varied. So it's possible to 
-- have disparate factions working together on the
-- same side of the map.
function assignments(ps,randomFactionID)
  local fs = zeroes(vfreqs(exclude(ps,randomFactionID)))
  local order = shuffle(keys(filter(ps,randomFactionID)))
    local choices = {}
    for k, playerindex in pairs(order) do
        choices[playerindex] = draw(fs)
    end
    for k,faction in pairs(ps) do
        if not choices[k] then 
            choices[k] = faction
        end
    end
    return choices
end
