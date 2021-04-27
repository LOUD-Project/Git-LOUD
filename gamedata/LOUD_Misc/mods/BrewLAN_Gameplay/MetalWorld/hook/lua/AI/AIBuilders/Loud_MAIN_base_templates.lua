do
    local MetalWorldLocations = {
        {'T1MetalWorldResource'},
        -- Western outer columns
        { -23, 13 },
        { -23, 11 },
        { -23,  9 },
        { -23,  7 },
        { -23, -7 },
        { -23, -9 },
        { -23, -11 },
        { -23, -13 },
        -- Eastern outer columns
        { 23, 13 },
        { 23, 11 },
        { 23,  9 },
        { 23,  7 },
        { 23, -7 },
        { 23, -9 },
        { 23, -11 },
        { 23, -13 },
        -- Northern outer rows
        {-13, -23 },
        {-11, -23 },
        { -9, -23 },
        { -7, -23 },
        {  7, -23 },
        {  9, -23 },
        { 11, -23 },
        { 13, -23 },
        -- Southern outer rows
        {-13, 23 },
        {-11, 23 },
        { -9, 23 },
        { -7, 23 },
        {  7, 23 },
        {  9, 23 },
        { 11, 23 },
        { 13, 23 },
    }
    MetalWorldLayout = {{},{},{},{}}
    for i = 1, 4 do
        table.insert(MetalWorldLayout[i], MetalWorldLocations)
    end
end
