local BASE_URL = "https://raw.githubusercontent.com/division4/taurus-universal/refs/heads/main/src/Modules/"
local CONFIG_FOLDER = "taurus/configs"
local ASSET_FOLDER = "taurus/assets"
local ASSET_CACHE = {}

local function EnsureFolders()
    if not isfolder("taurus") then makefolder("taurus") end
    if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    if not isfolder(ASSET_FOLDER) then makefolder(ASSET_FOLDER) end
end

local function Serialize(value, indent)
    indent = indent or 0
    local t = type(value)

    if t == "string" then
        return string.format("%q", value)
    elseif t == "number" or t == "boolean" then
        return tostring(value)
    elseif t == "table" then
        local parts = {}
        local padding = string.rep("\t", indent + 1)
        local closing = string.rep("\t", indent)

        for k, v in value do
            local key
            if type(k) == "string" then
                key = string.format("[%q]", k)
            else
                key = string.format("[%d]", k)
            end
            table.insert(parts, string.format("%s%s = %s", padding, key, Serialize(v, indent + 1)))
        end

        return string.format("{\n%s\n%s}", table.concat(parts, ",\n"), closing)
    end

    return "nil"
end

local function Deserialize(src)
    local fn, err = loadstring(string.format("return %s", src))
    assert(fn, string.format("[Taurus] Config deserialize failed: %s", err))
    return fn()
end

local function ConfigPath(name)
    return string.format("%s/%s.cfg", CONFIG_FOLDER, name)
end

local function AssetPath(name)
    return string.format("%s/%s", ASSET_FOLDER, name)
end

local Configs = {}

function Configs:Save(name, data)
    assert(type(name) == "string", "[Taurus] Config name must be a string.")
    assert(type(data) == "table", "[Taurus] Config data must be a table.")

    local ok, err = pcall(writefile, ConfigPath(name), Serialize(data))
    if not ok then
        warn(string.format("[Taurus] Failed to save config '%s': %s", name, err))
        return false
    end

    getgenv().taurus.configs[name] = data
    return true
end

function Configs:Load(name)
    assert(type(name) == "string", "[Taurus] Config name must be a string.")

    local path = ConfigPath(name)
    if not isfile(path) then
        warn(string.format("[Taurus] Config '%s' does not exist.", name))
        return nil
    end

    local ok, result = pcall(function()
        return Deserialize(readfile(path))
    end)

    if not ok then
        warn(string.format("[Taurus] Failed to load config '%s': %s", name, result))
        return nil
    end

    getgenv().taurus.configs[name] = result
    return result
end

function Configs:Delete(name)
    assert(type(name) == "string", "[Taurus] Config name must be a string.")

    local path = ConfigPath(name)
    if not isfile(path) then
        warn(string.format("[Taurus] Config '%s' does not exist.", name))
        return false
    end

    local ok, err = pcall(delfile, path)
    if not ok then
        warn(string.format("[Taurus] Failed to delete config '%s': %s", name, err))
        return false
    end

    getgenv().taurus.configs[name] = nil
    return true
end

function Configs:List()
    local result = {}
    local ok, files = pcall(listfiles, CONFIG_FOLDER)
    if not ok then return result end

    for _, path in files do
        local name = path:match("([^/\\]+)%.cfg$")
        if name then
            table.insert(result, name)
        end
    end

    return result
end

local Assets = {}

function Assets:Fetch(name, url)
    assert(type(name) == "string", "[Taurus] Asset name must be a string.")
    assert(type(url) == "string", "[Taurus] Asset URL must be a string.")

    if ASSET_CACHE[name] then
        return ASSET_CACHE[name]
    end

    local path = AssetPath(name)

    if isfile(path) then
        local asset = getcustomasset(path)
        ASSET_CACHE[name] = asset
        return asset
    end

    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        warn(string.format("[Taurus] Failed to fetch asset '%s': %s", name, result))
        return nil
    end

    local writeOk, writeErr = pcall(writefile, path, result)
    if not writeOk then
        warn(string.format("[Taurus] Failed to write asset '%s': %s", name, writeErr))
        return nil
    end

    local asset = getcustomasset(path)
    ASSET_CACHE[name] = asset
    return asset
end

function Assets:Purge(name)
    assert(type(name) == "string", "[Taurus] Asset name must be a string.")

    ASSET_CACHE[name] = nil

    local path = AssetPath(name)
    if not isfile(path) then return false end

    local ok, err = pcall(delfile, path)
    if not ok then
        warn(string.format("[Taurus] Failed to purge asset '%s': %s", name, err))
        return false
    end

    return true
end

function Assets:PurgeAll()
    local ok, files = pcall(listfiles, ASSET_FOLDER)
    if not ok then return end

    for _, path in files do
        pcall(delfile, path)
    end

    table.clear(ASSET_CACHE)
end

local Modules = {}

local MODULE_REGISTRY = {
    "Test",
}

function Modules:Load(name)
    assert(type(name) == "string", "[Taurus] Module name must be a string.")

    if getgenv().taurus.modules[name] then
        return getgenv().taurus.modules[name]
    end

    local url = string.format("%s%s.luau", BASE_URL, name)

    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        warn(string.format("[Taurus] Failed to fetch module '%s': %s", name, result))
        return nil
    end

    local fn, err = loadstring(result)
    if not fn then
        warn(string.format("[Taurus] Failed to compile module '%s': %s", name, err))
        return nil
    end

    local execOk, module = pcall(fn)
    if not execOk then
        warn(string.format("[Taurus] Failed to execute module '%s': %s", name, module))
        return nil
    end

    getgenv().taurus.modules[name] = module
    return module
end

function Modules:LoadAll()
    for _, name in MODULE_REGISTRY do
        self:Load(name)
    end
end

function Modules:Register(name)
    assert(type(name) == "string", "[Taurus] Module name must be a string.")

    for _, existing in MODULE_REGISTRY do
        if existing == name then
            warn(string.format("[Taurus] Module '%s' is already registered.", name))
            return
        end
    end

    table.insert(MODULE_REGISTRY, name)
end

EnsureFolders()

getgenv().taurus.configs  = Configs
getgenv().taurus.assets   = Assets
getgenv().taurus.modules  = Modules

Assets:Fetch("TaurusLogo.png", "https://raw.githubusercontent.com/division4/taurus-universal/refs/heads/main/assets/TaurusLogo.png")
Modules:LoadAll()