-- ##########################################################################################
--  File:    /LUA/modules/UI/game/score.LUA
--  Summary: Module for working with numbers
--  Author:  HUSSAR
-- ##########################################################################################

function round100(value)
    target = value or 0
    local result = value / 100.0
    result = math.floor(result + 0.5) 
    result = result * 100.0
    return result
end
 
-- initializes value to zero if it is nil   
function init(value) 
    return value or 0 
end
-- safely subtract values that might be uninitialized  
function subt(a, b) 
    return init(a) - init(b) 
end
function subt0(a, b) 
    local v = subt(a, b)
    return v > 0 and v or 0 
end
-- safely add values that might be uninitialized  
function adds(a, b) return init(a) + init(b) end
-- safely multiple values that might be uninitialized  
function mult(a, b) return init(a) * init(b) end
-- safely divide values that might be uninitialized  
function div(value, divisor)
    if not value or value == 0 then return 0 end
    if not divisor or divisor == 0 then return 0 end
    --value = value or 0
    --divisor = divisor or 0
    --if (divisor == 0) then 
    --    return 0
    --end
    return value / (1.0 * divisor)
end
function mod(a, b)
    a = init(a)
    b = init(b)    
    if b == 0 then return 0 end
	return a - math.floor(a / b) * b
end
-- sort two variables based on their numeric value or alpha order (strings)
function sort(valueA, valueB)
    if type(valueA) == "string" or 
       type(valueB) == "string"  then
        if string.lower(valueA) == string.lower(valueB) then
            return 0
        else
            -- sort string using alpha order
            return string.lower(valueA) < string.lower(valueB) 
        end
    else 
       if math.abs(valueA - valueB) < 0.0001 then
            return 0
       else
            -- sort numbers in decreasing order
            return valueA > valueB
       end
    end
end

-- HUSSAR: added formatting for very large and negative numbers, 
-- NOTES: this is useful to format negative score numbers, e.g. in Phantom games!
function frmt(value)
    if value == nil then return 0 end 
      
    local isNegative = value < 0
    if isNegative then value = value * -1 end
    local ret = ""
    if value < 1000 then             -- 0 to 999
        ret = string.format("%01.0f", value)
    elseif value < 10000 then        -- 1.0K to 9.9K
        ret = string.format("%01.1fk", value / 1000)
    elseif value < 1000000 then      -- 10K to 999K
        ret = string.format("%01.0fk", value / 1000)
    elseif value < 10000000 then   -- 1.0M to 9.9M
        ret = string.format("%01.1fm", value / 1000000)
    elseif value < 1000000000 then  -- 10.0M to 999M
        ret = string.format("%01.0fm", value / 1000000)
    else                             -- 1.0B to ....
        ret = string.format("%01.1fb", value / 1000000000)
    end
    if isNegative then ret = "-" .. ret end
        
    return ret
end