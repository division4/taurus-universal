local Library = {}

local UserInputService = game:GetService("UserInputService")

Library.Themes = {}
Library.ActiveTheme = nil
Library.Registry = {}
Library.Settings = {
    DefaultTheme = "Dark",
    AnimationsEnabled = true,
    NotificationsEnabled = true,
    KeybindEnabled = true,
}
Library.Flags = {}
Library.Keymap = {
    ["a"] = Enum.KeyCode.A,
    ["b"] = Enum.KeyCode.B,
    ["c"] = Enum.KeyCode.C,
    ["d"] = Enum.KeyCode.D,
    ["e"] = Enum.KeyCode.E,
    ["f"] = Enum.KeyCode.F,
    ["g"] = Enum.KeyCode.G,
    ["h"] = Enum.KeyCode.H,
    ["i"] = Enum.KeyCode.I,
    ["j"] = Enum.KeyCode.J,
    ["k"] = Enum.KeyCode.K,
    ["l"] = Enum.KeyCode.L,
    ["m"] = Enum.KeyCode.M,
    ["n"] = Enum.KeyCode.N,
    ["o"] = Enum.KeyCode.O,
    ["p"] = Enum.KeyCode.P,
    ["q"] = Enum.KeyCode.Q,
    ["r"] = Enum.KeyCode.R,
    ["s"] = Enum.KeyCode.S,
    ["t"] = Enum.KeyCode.T,
    ["u"] = Enum.KeyCode.U,
    ["v"] = Enum.KeyCode.V,
    ["w"] = Enum.KeyCode.W,
    ["x"] = Enum.KeyCode.X,
    ["y"] = Enum.KeyCode.Y,
    ["z"] = Enum.KeyCode.Z,

    ["0"] = Enum.KeyCode.Zero,
    ["1"] = Enum.KeyCode.One,
    ["2"] = Enum.KeyCode.Two,
    ["3"] = Enum.KeyCode.Three,
    ["4"] = Enum.KeyCode.Four,
    ["5"] = Enum.KeyCode.Five,
    ["6"] = Enum.KeyCode.Six,
    ["7"] = Enum.KeyCode.Seven,
    ["8"] = Enum.KeyCode.Eight,
    ["9"] = Enum.KeyCode.Nine,

    ["numpad0"] = Enum.KeyCode.KeypadZero,
    ["numpad1"] = Enum.KeyCode.KeypadOne,
    ["numpad2"] = Enum.KeyCode.KeypadTwo,
    ["numpad3"] = Enum.KeyCode.KeypadThree,
    ["numpad4"] = Enum.KeyCode.KeypadFour,
    ["numpad5"] = Enum.KeyCode.KeypadFive,
    ["numpad6"] = Enum.KeyCode.KeypadSix,
    ["numpad7"] = Enum.KeyCode.KeypadSeven,
    ["numpad8"] = Enum.KeyCode.KeypadEight,
    ["numpad9"] = Enum.KeyCode.KeypadNine,
    ["numpad_add"] = Enum.KeyCode.KeypadPlus,
    ["numpad_sub"] = Enum.KeyCode.KeypadMinus,
    ["numpad_dot"] = Enum.KeyCode.KeypadPeriod,
    ["numpad_enter"] = Enum.KeyCode.KeypadEnter,

    ["f1"] = Enum.KeyCode.F1,
    ["f2"] = Enum.KeyCode.F2,
    ["f3"] = Enum.KeyCode.F3,
    ["f4"] = Enum.KeyCode.F4,
    ["f5"] = Enum.KeyCode.F5,
    ["f6"] = Enum.KeyCode.F6,
    ["f7"] = Enum.KeyCode.F7,
    ["f8"] = Enum.KeyCode.F8,
    ["f9"] = Enum.KeyCode.F9,
    ["f10"] = Enum.KeyCode.F10,
    ["f11"] = Enum.KeyCode.F11,
    ["f12"] = Enum.KeyCode.F12,

    ["lshift"] = Enum.KeyCode.LeftShift,
    ["rshift"] = Enum.KeyCode.RightShift,
    ["lctrl"] = Enum.KeyCode.LeftControl,
    ["rctrl"] = Enum.KeyCode.RightControl,
    ["lalt"] = Enum.KeyCode.LeftAlt,
    ["ralt"] = Enum.KeyCode.RightAlt,

    ["up"] = Enum.KeyCode.Up,
    ["down"] = Enum.KeyCode.Down,
    ["left"] = Enum.KeyCode.Left,
    ["right"] = Enum.KeyCode.Right,
    ["home"] = Enum.KeyCode.Home,
    ["end"] = Enum.KeyCode.End,
    ["pageup"] = Enum.KeyCode.PageUp,
    ["pagedown"] = Enum.KeyCode.PageDown,
    ["insert"] = Enum.KeyCode.Insert,
    ["delete"] = Enum.KeyCode.Delete,

    ["space"] = Enum.KeyCode.Space,
    ["enter"] = Enum.KeyCode.Return,
    ["tab"] = Enum.KeyCode.Tab,
    ["backspace"] = Enum.KeyCode.Backspace,
    ["escape"] = Enum.KeyCode.Escape,
    ["capslock"] = Enum.KeyCode.CapsLock,
    ["numlock"] = Enum.KeyCode.NumLock,
    ["scrolllock"] = Enum.KeyCode.ScrollLock,
    ["pause"] = Enum.KeyCode.Pause,
    ["print"] = Enum.KeyCode.Print,

    ["semicolon"] = Enum.KeyCode.Semicolon,
    ["equals"] = Enum.KeyCode.Equals,
    ["comma"] = Enum.KeyCode.Comma,
    ["minus"] = Enum.KeyCode.Minus,
    ["period"] = Enum.KeyCode.Period,
    ["slash"] = Enum.KeyCode.Slash,
    ["backtick"] = Enum.KeyCode.BackQuote,
    ["lbracket"] = Enum.KeyCode.LeftBracket,
    ["backslash"] = Enum.KeyCode.BackSlash,
    ["rbracket"] = Enum.KeyCode.RightBracket,
    ["quote"] = Enum.KeyCode.Quote,
}
Library.Binds = {}
Library.Connections = {}
Library.Notifications = {}

Library.FlagTypes = {
    Toggle   = "Toggle",
    Slider   = "Slider",
    Dropdown = "Dropdown",
    Input    = "Input",
    Color    = "Color",
    Bind     = "Bind",
}

local function AssertType(value, expected, argname)
    assert(type(value) == expected, string.format("[Library] Argument '%s' expected %s, got %s", argname, expected, type(value)))
end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[Library] Error in callback: " .. tostring(err))
    end
end

function Library:AddConnection(connection)
    assert(typeof(connection) == "RBXScriptConnection", "[Library] Expected an RBXScriptConnection.")
    table.insert(self.Connections, connection)
    return connection
end

function Library:Create(class, properties)
    AssertType(class, "string", "class")
    AssertType(properties, "table", "properties")

    local element = Instance.new(class)

    for property, value in properties do
        local ok, err = pcall(function()
            element[property] = value
        end)
        if not ok then
            warn(string.format("[Library] Failed to set property '%s' on '%s': %s", property, class, err))
        end
    end

    return element
end

function Library:AddTheme(name, theme)
    AssertType(name, "string", "name")
    AssertType(theme, "table", "theme")

    local required = {"Primary", "Secondary", "Accent", "Text", "SubText", "Border"}
    for _, key in required do
        assert(theme[key] ~= nil, string.format("[Library] Theme '%s' is missing required key: '%s'", name, key))
    end

    self.Themes[name] = theme
end

function Library:SetTheme(name)
    AssertType(name, "string", "name")
    assert(self.Themes[name], string.format("[Library] Theme '%s' does not exist.", name))

    self.ActiveTheme = self.Themes[name]

    for _, entry in self.Registry do
        self:SetState(entry, entry.CurrentState)
    end
end

function Library:GetTheme()
    return self.ActiveTheme or {}
end

function Library:AddToRegistry(element, states)
    assert(typeof(element) == "Instance", "[Library] Expected an Instance for 'element'.")
    AssertType(states, "table", "states")
    assert(states["Default"] ~= nil, "[Library] Registry entry must have a 'Default' state.")

    local entry = {
        Element = element,
        States = states,
        CurrentState = "Default"
    }

    table.insert(self.Registry, entry)
    self:SetState(entry, "Default")

    return entry
end

function Library:SetState(entry, state)
    AssertType(state, "string", "state")

    local resolvedState = entry.States[state] or entry.States["Default"]
    entry.CurrentState = entry.States[state] and state or "Default"

    for property, value in resolvedState do
        if type(value) == "string" and self.ActiveTheme and self.ActiveTheme[value] then
            value = self.ActiveTheme[value]
        end

        local ok, err = pcall(function()
            entry.Element[property] = value
        end)
        if not ok then
            warn(string.format("[Library] Failed to apply state property '%s': %s", property, err))
        end
    end
end

function Library:RemoveFromRegistry(element)
    for index, entry in self.Registry do
        if entry.Element == element then
            table.remove(self.Registry, index)
            return true
        end
    end
    return false
end

function Library:NewFlag(name, flagType, options)
    AssertType(name, "string", "name")
    AssertType(flagType, "string", "flagType")
    AssertType(options, "table", "options")
    assert(self.FlagTypes[flagType], string.format("[Library] Unknown flag type: '%s'", flagType))
    assert(not self.Flags[name], string.format("[Library] Flag '%s' already exists.", name))

    local flag = {
        Name      = name,
        Type      = flagType,
        Value     = options.Default,
        Options   = options,
        Callbacks = {},
    }

    if flagType == self.FlagTypes.Toggle then
        flag.Value = options.Default ~= nil and options.Default or false

    elseif flagType == self.FlagTypes.Slider then
        assert(options.Min and options.Max, "[Library] Slider flag requires 'Min' and 'Max' options.")
        flag.Value = math.clamp(options.Default or options.Min, options.Min, options.Max)

    elseif flagType == self.FlagTypes.Dropdown then
        assert(type(options.Choices) == "table", "[Library] Dropdown flag requires a 'Choices' table.")
        flag.Value = options.Default or options.Choices[1]

    elseif flagType == self.FlagTypes.Color then
        flag.Value = options.Default or Color3.new(1, 1, 1)

    elseif flagType == self.FlagTypes.Bind then
        flag.Value = options.Default or nil
    end

    self.Flags[name] = flag
    return flag
end

function Library:SetFlag(name, value)
    local flag = self.Flags[name]
    assert(flag, string.format("[Library] Flag '%s' does not exist.", name))

    if flag.Type == self.FlagTypes.Slider then
        value = math.clamp(value, flag.Options.Min, flag.Options.Max)

    elseif flag.Type == self.FlagTypes.Dropdown then
        local valid = false
        for _, choice in flag.Options.Choices do
            if choice == value then valid = true break end
        end
        assert(valid, string.format("[Library] Invalid dropdown choice '%s' for flag '%s'.", tostring(value), name))
    end

    local previous = flag.Value
    flag.Value = value

    if previous ~= value then
        for _, callback in flag.Callbacks do
            SafeCall(callback, value, previous)
        end
    end
end

function Library:GetFlag(name)
    local flag = self.Flags[name]
    assert(flag, string.format("[Library] Flag '%s' does not exist.", name))
    return flag.Value
end

function Library:OnFlagChanged(name, callback)
    AssertType(callback, "function", "callback")
    local flag = self.Flags[name]
    assert(flag, string.format("[Library] Flag '%s' does not exist.", name))
    table.insert(flag.Callbacks, callback)
end

function Library:NewBind(name, key, callback, options)
    AssertType(name, "string", "name")
    AssertType(callback, "function", "callback")

    options = options or {}

    local resolvedKey = nil

    if key ~= nil then
        if type(key) == "string" then
            resolvedKey = self.Keymap[key:lower()]
            assert(resolvedKey, string.format("[Library] Unknown key name '%s' for bind '%s'.", key, name))
        else
            resolvedKey = key
        end
    end

    local bind = {
        Name     = name,
        Key      = resolvedKey,
        RawKey   = key,
        Callback = callback,
        Enabled  = options.Enabled ~= false,
        HoldMode = options.HoldMode or false,
        IsHeld   = false,
    }

    self.Binds[name] = bind
    return bind
end

function Library:SetBind(name, key)
    local bind = self.Binds[name]
    assert(bind, string.format("[Library] Bind '%s' does not exist.", name))

    if type(key) == "string" then
        local resolved = self.Keymap[key:lower()]
        assert(resolved, string.format("[Library] Unknown key name '%s'.", key))
        bind.Key = resolved
        bind.RawKey = key
    else
        bind.Key = key
        bind.RawKey = key
    end
end

function Library:SetBindEnabled(name, state)
    local bind = self.Binds[name]
    assert(bind, string.format("[Library] Bind '%s' does not exist.", name))
    bind.Enabled = state
end

function Library:_StartInputHandler()
    self:AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        for _, bind in self.Binds do
            if not bind.Enabled or not bind.Key then continue end

            if bind.Key == input.KeyCode then
                if bind.HoldMode then
                    bind.IsHeld = true
                end
                SafeCall(bind.Callback, "began", bind)
            end
        end
    end))

    self:AddConnection(UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        for _, bind in self.Binds do
            if not bind.Enabled or not bind.Key then continue end

            if bind.Key == input.KeyCode and bind.HoldMode then
                bind.IsHeld = false
                SafeCall(bind.Callback, "ended", bind)
            end
        end
    end))
end

function Library:Notify(options)
    AssertType(options, "table", "options")

    if not self.Settings.NotificationsEnabled then return end

    local notification = {
        Title    = options.Title or "Notification",
        Message  = options.Message or "",
        Duration = options.Duration or 5,
        Type     = options.Type or "Info",
        Callback = options.Callback or nil,
    }

    table.insert(self.Notifications, notification)

    task.delay(notification.Duration, function()
        for index, n in self.Notifications do
            if n == notification then
                table.remove(self.Notifications, index)
                break
            end
        end
    end)

    return notification
end

function Library:ExportConfig()
    local config = {}
    for name, flag in self.Flags do
        config[name] = flag.Value
    end
    return config
end

function Library:ImportConfig(config)
    AssertType(config, "table", "config")
    for name, value in config do
        if self.Flags[name] then
            self:SetFlag(name, value)
        else
            warn(string.format("[Library] ImportConfig: Flag '%s' does not exist, skipping.", name))
        end
    end
end

function Library:Unload()
    for _, connection in self.Connections do
        connection:Disconnect()
    end

    self.Connections   = {}
    self.Registry      = {}
    self.Flags         = {}
    self.Binds         = {}
    self.Notifications = {}
    self.ActiveTheme   = nil
end

Library:_StartInputHandler()

return Library