-- ====================================================================================--
--  MIT License 2020 : Twiitchter
-- ====================================================================================--
_c.sql = {} -- server
--[[
NOTES.
    - All sql querys should have a call back as a function at the end to chain code execution upon completion.
    - All data should be encoded or decoded here, if possible. the fetchALL commands are decoded in the _data.lua
]]--
math.randomseed(_c.seed)
-- ====================================================================================--

-- @local id for async store & Store Query
local SaveData = -1
MySQL.Async.store(
    "UPDATE `characters` SET `Coords` = @Coords, `Inventory` = @Inventory, `Bank` = @Bank,  `Last_Login` = current_timestamp() WHERE `Character_ID` = @Character_ID;",
    function(id)
        SaveData = id
end)

--- Save Single User/Character
-- @source
-- @callback
function _c.sql.SaveUser(data, cb)
    if data then
        local ords = json.encode(data.GetCoords())
        local inv = json.encode(data.GetInventory())
        local bank = data.GetBank()
        MySQL.Async.insert(SaveData, {
            ['@Coords'] = ords,
            ['@Inventory'] = inv,
            ['@Character_ID'] = data.Character_ID,
            ['@Bank'] = bank
        }, function(r)
            --do
        end)
    else
        --do
    end
end

function _c.sql.SaveData(cb)
    local users = GetPlayers()
    for i = 1, #users, 1 do
        local data = _c.data.GetPlayer(users[i])
        if (type(data) == 'table') and (data.Coords ~= nil) then
            local ords = json.encode(data.GetCoords())
            local inv = json.encode(data.GetInventory())
            local bank = data.GetBank()
            MySQL.Async.insert(SaveData, {
                ['@Coords'] = ords,
                ['@Inventory'] = inv,
                ['@Character_ID'] = data.Character_ID,
                ['@Bank'] = bank
            }, function(r)
                --do
            end)
        else
            --do
        end
    end
    -- These will all be completed prior to cb being run.
    -- upon the entire loop of saving/pasing data to the DB via a stored query, run the cb passed.
    if cb then
        cb()
    end
end

function _c.sql.GenerateCharacterID()
    local bool = false
    local new = nil
    repeat
        new = _c.rng.chars(50)
        MySQL.Async.fetchScalar('SELECT `Primary_ID` FROM characters WHERE `Character_ID` = @Character_ID LIMIT 1;', {
            ['@Character_ID'] = new
        }, function(r)
            if r then
                bool = true
            else
                bool = false
            end
        end)
    until bool == false
    return new
end

function _c.sql.GenerateCityID()
    local bool = false
    local new = nil
    repeat
        local s1 = string.upper(_c.rng.let())
        local s2 = _c.rng.nums(5)
        new = string.format("%s-%s", s1, s2)
        MySQL.Async.fetchScalar('SELECT `Primary_ID` FROM characters WHERE `City_ID` = @City_ID LIMIT 1;', {
            ['@City_ID'] = new
        }, function(r)
            if r then
                bool = true
            else
                bool = false

            end
        end)
    until bool == false
    return new
end

function _c.sql.GeneratePhoneNumber()
    local bool = false
    local new = nil
    repeat
        local s1 = math.random(02, 06)
        local s2 = math.random(00000, 99999)
        new = string.format("%02d%05d", s1, s2)
        MySQL.Async.fetchScalar('SELECT `Primary_ID` FROM characters WHERE `Phone` = @Phone LIMIT 1;', {
            ['@Phone'] = new
        }, function(r)
            if r then
                bool = true
            else
                bool = false
            end
        end)
    until bool == false
    return new
end

function _c.sql.CreateCharacter(t, cb)
    MySQL.Async.execute(
        'INSERT INTO characters (`Primary_ID`, `Character_ID`, `City_ID`, `First_Name`, `Last_Name`, `Height`, `Birth_Date`, `Phone`, `Coords`, `Active`, `Wanted`) VALUES (@Primary_ID, @Character_ID, @City_ID, @First_Name, @Last_Name, @Height, @Birth_Date, @Phone, @Coords, @Active, @Wanted);',
        {
            Primary_ID = t.Primary_ID,
            Character_ID = t.Character_ID,
            City_ID = t.City_ID,
            First_Name = t.First_Name,
            Last_Name = t.Last_Name,
            Height = t.Height,
            Birth_Date = t.Birth_Date,
            Phone = t.Phone,
            Coords = t.Coords,
            Active = 0,
            Wanted = 0
        }, function(r)
            if r then

            end
        end)
    if cb ~= nil then
        cb()
    end
end

------------------------------------------------------------------------------
--- USERS TABLE
------------------------------------------------------------------------------

--- Get - `Locale` from the users License_ID
-- @License_ID
function _c.sql.DBGetLocale(License_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Locale` FROM users WHERE `License_ID` = @License_ID LIMIT 1;', {
        ['@License_ID'] = License_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Set - Prefered locale or `Locale` for the users License_ID
-- @License_ID
function _c.sql.DBSetLocale(Locale, License_ID, cb)
    local Locale = Locale
    MySQL.Async.execute('UPDATE users SET `Locale` = @Locale WHERE `License_ID` = @License_ID;', {
        ['@Locale'] = Locale,
        ['@License_ID'] = License_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

--- Get - `Ace` from the users License_ID identifier
-- @License_ID
function _c.sql.DBGetAce(License_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Ace` FROM users WHERE `License_ID` = @License_ID LIMIT 1;', {
        ['@License_ID'] = License_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - `Ban` from the users License_ID identifier
-- @License_ID
function _c.sql.DBGetBanStatus(License_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Ban` FROM users WHERE `License_ID` = @License_ID LIMIT 1;', {
        ['@License_ID'] = License_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Set - `Ban` = TRUE from the users License_ID identifier
-- @License_ID
function _c.sql.DBSetBanned(License_ID, cb)
    MySQL.Async.execute('UPDATE users SET `Ban` = TRUE WHERE `License_ID` = @License_ID LIMIT 1;', {
        ['@License_ID'] = License_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

--- Set - `Ban` = FALSE from the users License_ID identifier
-- @License_ID
function _c.sql.DBSetUnBanned(License_ID, cb)
    MySQL.Async.execute('UPDATE users SET `Ban` = FALSE WHERE `License_ID` = @License_ID LIMIT 1;', {
        ['@License_ID'] = License_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

------------------------------------------------------------------------------
--- CHARACTERS TABLE
------------------------------------------------------------------------------

--- Get - Info on the characters owned to prefill the multicharacter selection
-- @License_ID
function _c.sql.DBGetUserCharacters(Primary_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll('SELECT * FROM characters WHERE `Primary_ID` = @Primary_ID LIMIT 100;', {
        ['@Primary_ID'] = Primary_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - # of characters owned = FALSE
-- @Primary_ID
function _c.sql.DBGetCharacterCount(Primary_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT COUNT(`Primary_ID`) AS "Count" FROM characters WHERE `Primary_ID` = @Primary_ID;',
        {
            ['@Primary_ID'] = Primary_ID
        }, function(data)
            result = data
            IsBusy = false
        end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    -- Always return a value.
    if result == nil then
        result = 0
    end
    --
    return result
end

--- Get - The entire ROW of data from Characters table where the Character_ID is the character id.
-- @Primary_ID
function _c.sql.DBGetCharacterRow(Character_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll('SELECT * FROM characters WHERE `Character_ID` = @Character_ID LIMIT 1;', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        result = data[1]
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - All `Character_ID` that are currently marked as `Active` IS TRUE
function _c.sql.DBGetActiveCharacters(cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll('SELECT `Character_ID` FROM characters WHERE `Active` IS TRUE', {}, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - The `Active` = TRUE `Character_ID` from the Primary_ID identifier
-- @Primary_ID
function _c.sql.DBGetActiveCharacter(Primary_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar(
        'SELECT `Character_ID` FROM characters WHERE `Active` IS TRUE AND `Primary_ID` = @Primary_ID', {
            ['@Primary_ID'] = Primary_ID
        }, function(data)
            result = data
            IsBusy = false
        end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- SET - The `Active` = FALSE `Character_ID` from the Primary_ID identifier
-- @`Character_ID`
function _c.sql.DBSetCharacterInActive(Character_ID, cb)
    MySQL.Async.execute('UPDATE characters SET `Active` = FALSE WHERE `Character_ID` = @Character_ID', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

--- SET - The `Active` = TRUE `Character_ID` from the Primary_ID identifier
-- @`Character_ID`
function _c.sql.DBSetCharacterActive(Character_ID, cb)
    MySQL.Async.execute('UPDATE characters SET `Active` = TRUE WHERE `Character_ID` = @Character_ID', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

-- Should the Server crash, this one is to reset all Active Characters Just incasethe Active Column is used to data identify users/characters in data pulls.
function _c.sql.DBResetActiveCharacters(cb)
    MySQL.Async.execute('UPDATE characters SET `Active` = FALSE;', {}, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

function _c.sql.DBGetWantedCharacters(cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Character_ID` FROM characters WHERE `Wanted` IS TRUE', {}, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

function _c.sql.DBSetCharacterWanted(Character_ID, cb)
    MySQL.Async.execute('UPDATE characters SET `Wanted` IS TRUE WHERE `Character_ID` = @Character_ID', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

function _c.sql.DBSetCharacterUnWanted(Character_ID, cb)
    MySQL.Async.execute('UPDATE characters SET `Wanted` IS FALSE WHERE `Character_ID` = @Character_ID', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

--- Get - The `City_ID` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBGetCharacterFromPhone(Phone, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Character_ID` FROM characters WHERE `Phone` = @Phone LIMIT 1;', {
        ['@Phone'] = Phone
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - The `City_ID` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBGetPhoneFromCharacter(Character_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Phone` FROM characters WHERE `Character_ID` = @Character_ID LIMIT 1;', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - The `City_ID` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBGetCityIdFromCharacter(Character_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `City_ID` FROM characters WHERE `Character_ID` = @Character_ID LIMIT 1;', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - The `Character_ID` from the `City_ID`
-- @`City_ID`
function _c.sql.DBGetCharacterFromCityId(City_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Character_ID` FROM characters WHERE `City_ID` = @City_ID LIMIT 1;', {
        ['@City_ID'] = City_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- Get - The `Coords` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBGetCharacterCoords(Character_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Coords` FROM characters WHERE `Character_ID` = @Character_ID LIMIT 1;', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            result = json.decode(data)
            IsBusy = false
        end
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- SET - The `Coords` from the `Character_ID`
-- @`Character_ID`
-- @Table of coords. {x=32.2,y=etc}
-- cb if any.
function _c.sql.DBSetCharacterCoords(Character_ID, Vector3, cb)
    local Coords = json.encode(Vector3)
    MySQL.Async.execute('UPDATE characters SET `Coords` = @Coords WHERE `Character_ID` = @Character_ID;', {
        ['@Coords'] = Coords,
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

--- Get - The `Appearance` from the `Character_ID`
-- @`Character_ID`
-- cb if any.
function _c.sql.DBGetCharacterAppearance(Character_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Appearance` FROM characters WHERE `Character_ID` = @Character_ID;', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            result = json.decode(data)
            IsBusy = false
        end
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- SET - The `Appearance` from the `Character_ID`
-- @`Character_ID`
-- @style - TABLE VALUE
-- cb if any.
function _c.sql.DBSetCharacterAppearance(Character_ID, style, cb)
    local Appearance = json.encode(style)
    MySQL.Async.execute('UPDATE characters SET `Appearance` = @Appearance WHERE `Character_ID` = @Character_ID;', {
        ['@Appearance'] = Appearance,
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

--- GET - The `Inventory` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBGetCharacterInventory(Character_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Inventory` FROM characters WHERE `Character_ID` = @Character_ID;', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            result = json.decode(data)
            IsBusy = false
        end
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- SET - The `Inventory` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBSetCharacterInventory(Character_ID, Inventory, cb)
    local Inventory = json.encode(Inventory)
    MySQL.Async.execute('UPDATE characters SET `Inventory` = @Inventory WHERE `Character_ID` = @Character_ID;', {
        ['@Inventory'] = Inventory,
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

--- GET - The `Inventory` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBGetCharacterBank(Character_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchScalar('SELECT `Bank` FROM characters WHERE `Character_ID` = @Character_ID;', {
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            result = data
            IsBusy = false
        end
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

--- SET - The `Inventory` from the `Character_ID`
-- @`Character_ID`
function _c.sql.DBSetCharacterBank(Character_ID, amount, cb)
    MySQL.Async.execute('UPDATE characters SET `Bank`= Bank + @amount WHERE `Character_ID` = @Character_ID;', {
        ['@amount'] = amount,
        ['@Character_ID'] = Character_ID
    }, function(data)
        if data then
            --
        end
        if cb ~= nil then
            cb()
        end
    end)
end

------------------------------------------------------------------------------
--- Vehicles
-------------------------------------------------------------------------------

function _c.sql.DBGetVehiclesByLicense(City_ID, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE `City_ID` = @City_ID LIMIT 100;', {
        ['@City_ID'] = City_ID
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end

function _c.sql.DBGetVehiclesByPlate(Plate, cb)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE `Plate` = @Plate LIMIT 1;', {
        ['@Plate'] = Plate
    }, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Wait(0)
    end
    if cb ~= nil then
        cb()
    end
    return result
end