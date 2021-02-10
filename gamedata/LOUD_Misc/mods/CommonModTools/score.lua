local score_data

function Update(newData)
    score_data = table.deepcopy(newData)
end

function Get()
    return score_data
end
