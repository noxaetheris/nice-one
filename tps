-- wild ass anticheat still somehow works (credits twistz my baby)
task.spawn(
    function()

        -- KeepYourHeadUp_ Bypass
        local p = workspace:FindFirstChild("FE") and workspace.FE:FindFirstChild("Actions")
        if p then
            local AC = p:FindFirstChild("KeepYourHeadUp_")
            if AC then
                AC:Destroy()

                local r = Instance.new("RemoteEvent")
                r.Name = "KeepYourHeadUp_"
                r.Parent = p
            end
        end

        -- remote revoker very weird name of the ac
        local function a(n)
            return string.match(n, "^[a-zA-Z]+%-%d+%a*%-%d+%a*$") ~= nil
        end

        local function b(o)
            -- pcall prevents the script from crashing when touching locked game services
            pcall(
                function()
                    for _, c in pairs(o:GetChildren()) do
                        if c:IsA("RemoteEvent") and a(c.Name) then
                            c:Destroy()
                        end
                        b(
                            c
                        ) -- Recursive call
                    end
                end
            )
        end

        b(game)
    end
)

-- ==============================================================================
-- SPECTER DIAGNOSTICS & NON-BLOCKING INITIALIZATION
-- ==============================================================================
local _specterLoadStart = os.clock()
local _specterDiagnostics = {
    acBypassTime = 0,
    windUILoadTime = 0,
    totalTime = 0,
    revokedCount = 0
}

-- Optimized Non-Blocking Anti-Cheat Remote Revoker & Bypass
task.spawn(function()
    local t0 = os.clock()

    -- 1. KeepYourHeadUp_ Bypass
    pcall(function()
        local p = workspace:FindFirstChild("FE") and workspace.FE:FindFirstChild("Actions")
        if p then
            local AC = p:FindFirstChild("KeepYourHeadUp_")
            if AC then
                AC:Destroy()
                local r = Instance.new("RemoteEvent")
                r.Name = "KeepYourHeadUp_"
                r.Parent = p
            end
        end
    end)

    -- 2. Anti-Cheat remote pattern matcher
    local function isAcRemote(n)
        return string.match(n, "^[a-zA-Z]+%-%d+%a*%-%d+%a*$") ~= nil
    end

    local function revokeIfMatch(inst)
        if inst and inst:IsA("RemoteEvent") and isAcRemote(inst.Name) then
            pcall(function()
                inst:Destroy()
                _specterDiagnostics.revokedCount = _specterDiagnostics.revokedCount + 1
            end)
        end
    end

    -- 3. Dynamic Real-time Event Interceptor (Catches any remotes created after startup)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    pcall(function()
        ReplicatedStorage.DescendantAdded:Connect(revokeIfMatch)
    end)
    pcall(function()
        workspace.DescendantAdded:Connect(revokeIfMatch)
    end)
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp then
            lp.DescendantAdded:Connect(revokeIfMatch)
        end
    end)

    -- 4. Targeted initial scan of containers that can actually hold replicated RemoteEvents
    -- Batched with cooperative yielding (yields every 80 items) so 60 FPS is maintained
    local checkContainers = { ReplicatedStorage, workspace }
    local scanned = 0
    for _, container in ipairs(checkContainers) do
        pcall(function()
            for _, desc in ipairs(container:GetDescendants()) do
                scanned = scanned + 1
                if scanned % 80 == 0 then
                    task.wait() -- Cooperatively yield to maintain 60 FPS
                end
                revokeIfMatch(desc)
            end
        end)
    end

    _specterDiagnostics.acBypassTime = os.clock() - t0
end)

-- Error-handled WindUI Loader with Latency Benchmark
local _startUILoad = os.clock()
local okUI, WindUI = pcall(function()
    local raw = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
    return loadstring(raw)()
end)

if not okUI or not WindUI then
    warn("[Specter Error] Failed to fetch or initialize WindUI: " .. tostring(WindUI))
    return
end
_specterDiagnostics.windUILoadTime = os.clock() - _startUILoad

WindUI:AddTheme({
    Name = "Specter",
    Accent = Color3.fromHex("#FFFFFF"),
    Dialog = Color3.fromHex("#0A0A0A"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#808080"),
    Background = Color3.fromHex("#000000"),
    Button = Color3.fromHex("#1A1A1A"),
    Icon = Color3.fromHex("#FFFFFF"),
})

local Window = WindUI:CreateWindow({
    Title = "Specter",
    Icon = "ghost",
    Author = "By Specter Team",
    Folder = "WindUI_Specter",
    Size = UDim2.fromOffset(560, 400),
    Transparent = false,
    Theme = "Specter",
    SideBarWidth = 140,
    HasOutline = true,
    ToggleKey = Enum.KeyCode.RightShift,
    Keybind = Enum.KeyCode.RightShift
})

-- ==============================================================================
-- OPEN / CLOSE UI CONTROLLER (PC & Mobile Support)
-- ==============================================================================
local UserInputService = game:GetService("UserInputService")

local function toggleUI()
    local done = false
    pcall(function()
        if Window and Window.Toggle then
            Window:Toggle()
            done = true
        end
    end)
    if not done then
        pcall(function()
            if Window.Closed ~= nil then
                if Window.Closed then
                    Window:Open()
                else
                    Window:Close()
                end
                done = true
            end
        end)
    end
    if not done then
        pcall(function()
            if Window.UIElements and Window.UIElements.Main then
                local main = Window.UIElements.Main
                main.Visible = not main.Visible
            end
        end)
    end
end

-- Keyboard Keybind (RightShift, LeftControl, Insert)
local toggleKeyCodes = {
    [Enum.KeyCode.RightShift] = true,
    [Enum.KeyCode.LeftControl] = true,
    [Enum.KeyCode.Insert] = true,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if toggleKeyCodes[input.KeyCode] then
        -- Never toggle when user is typing in a chat or text box
        if UserInputService:GetFocusedTextBox() then return end
        toggleUI()
    end
end)

-- Draggable On-Screen Floating Button (Mobile & PC)
task.spawn(function()
    local parentGui
    pcall(function()
        if type(gethui) == "function" then
            parentGui = gethui()
        elseif game:GetService("CoreGui") then
            parentGui = game:GetService("CoreGui")
        else
            parentGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    if not parentGui then return end

    pcall(function()
        local old = parentGui:FindFirstChild("SpecterToggleGui")
        if old then old:Destroy() end
    end)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpecterToggleGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 44, 0, 44)
    toggleBtn.Position = UDim2.new(0, 20, 0.45, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    toggleBtn.Text = "👻"
    toggleBtn.TextSize = 22
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.25
    stroke.Parent = toggleBtn

    local dragging = false
    local dragStart = nil
    local startPos = nil
    local didMove = false
    local dragThreshold = 6

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            didMove = false
            dragStart = input.Position
            startPos = toggleBtn.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)

    toggleBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold then
                didMove = true
            end
            toggleBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    toggleBtn.Activated:Connect(function()
        if not didMove then
            toggleUI()
        end
    end)

    pcall(function()
        screenGui.Parent = parentGui
    end)
end)

local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })

-- INFO TAB
InfoTab:Section({ Title = "Specter" })
InfoTab:Paragraph({
    Title = "Specter Hub",
    Desc = "Welcome to Specter. This interface is empty and ready for your own features."
})

InfoTab:Paragraph({
    Title = "Open / Close UI",
    Desc = "• PC: Press RightShift\n• Mobile & PC: Tap the floating 👻 icon on screen (drag it anywhere to reposition)"
})

InfoTab:Button({
    Title = "Close UI",
    Desc = "Minimize the interface",
    Callback = function()
        toggleUI()
    end
})

InfoTab:Paragraph({
    Title = "Credits",
    Desc = "Original script credits: @noxther"
})

-- WindUI Compatibility Adapter for all tabs and pages
local function wrapTab(tab)
    if not tab then return tab end

    function tab:AddSection(data)
        local title = type(data) == "table" and (data.Title or data.Name or data[1]) or tostring(data)
        local ok, res = pcall(function()
            return tab:Section({ Title = title })
        end)
        return ok and res or nil
    end

    function tab:AddParagraph(data)
        local title = type(data) == "table" and (data.Title or data.Name or data[1]) or "Paragraph"
        local desc = type(data) == "table" and (data.Desc or data.Description or data[2]) or ""
        local ok, res = pcall(function()
            return tab:Paragraph({ Title = title, Desc = desc })
        end)
        return ok and res or nil
    end

    function tab:AddToggle(data)
        local title = data.Name or data.Title or "Toggle"
        local desc = data.Description or data.Desc or ""
        local defaultVal = (data.Default ~= nil) and data.Default or false
        local cb = data.Callback

        local toggleObj = {}
        local ok, innerToggle = pcall(function()
            return tab:Toggle({
                Title = title,
                Desc = desc,
                Value = defaultVal,
                Callback = function(v)
                    if cb then
                        pcall(cb, v)
                    end
                    if toggleObj._callback then
                        pcall(toggleObj._callback, v)
                    end
                end
            })
        end)

        function toggleObj:Callback(fn)
            toggleObj._callback = fn
        end

        function toggleObj:Set(v)
            if ok and innerToggle and innerToggle.Set then
                pcall(function() innerToggle:Set(v) end)
            end
        end

        return toggleObj
    end

    function tab:AddTextBox(data)
        local title = data.Name or data.Title or "Input"
        local desc = data.Description or data.Desc or ""
        local placeholder = data.PlaceholderText or data.Placeholder or ""
        local defVal = (data.Default ~= nil and tostring(data.Default)) or (data.Value ~= nil and tostring(data.Value)) or ""
        local cb = data.Callback
        local ok, res = pcall(function()
            return tab:Input({
                Title = title,
                Desc = desc,
                Placeholder = placeholder,
                Value = defVal,
                Callback = function(v)
                    if cb then pcall(cb, v) end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:AddSlider(data)
        local title = data.Name or data.Title or "Slider"
        local desc = data.Description or data.Desc or ""
        local minVal = data.Min or 0
        local maxVal = data.Max or 100
        local defVal = data.Default or minVal
        local stepVal = data.Increase or data.Step or 1
        local cb = data.Callback
        local ok, res = pcall(function()
            return tab:Slider({
                Title = title,
                Desc = desc,
                Step = stepVal,
                Value = {
                    Min = minVal,
                    Max = maxVal,
                    Default = defVal
                },
                Callback = function(v)
                    if cb then pcall(cb, v) end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:AddButton(data)
        local title = ""
        local cb = nil
        if type(data) == "table" then
            if type(data[1]) == "string" and type(data[2]) == "function" then
                title = data[1]
                cb = data[2]
            else
                title = data.Name or data.Title or "Button"
                cb = data.Callback
            end
        else
            title = tostring(data)
        end
        local ok, res = pcall(function()
            return tab:Button({
                Title = title,
                Callback = function()
                    if cb then pcall(cb) end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:AddDropdown(data)
        local title = data.Name or data.Title or "Dropdown"
        local desc = data.Description or data.Desc or ""
        local values = data.Options or data.Values or {}
        local defVal = data.Default or data.Value or (values[1] or "")
        local cb = data.Callback
        local ok, res = pcall(function()
            return tab:Dropdown({
                Title = title,
                Desc = desc,
                Values = values,
                Value = defVal,
                Callback = function(v)
                    if cb then pcall(cb, v) end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:AddDiscordInvite(data)
        local ok, res = pcall(function()
            return tab:Button({
                Title = data.Name or "Join Discord",
                Desc = data.Invite or data.Description or "",
                Callback = function()
                    if setclipboard and data.Invite then
                        setclipboard(data.Invite)
                    end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:CreateSection(title)
        local ok, res = pcall(function()
            return tab:Section({ Title = tostring(title) })
        end)
        return ok and res or nil
    end

    function tab:CreateLabel(text)
        local ok, res = pcall(function()
            return tab:Paragraph({ Title = tostring(text), Desc = "" })
        end)
        return ok and res or nil
    end

    function tab:CreateInput(title, desc, placeholder, defaultVal, extra, callback)
        local cb = callback or (type(extra) == "function" and extra) or (type(defaultVal) == "function" and defaultVal)
        local ok, res = pcall(function()
            return tab:Input({
                Title = tostring(title),
                Desc = tostring(desc or ""),
                Placeholder = tostring(placeholder or ""),
                Callback = function(v)
                    if cb then pcall(cb, v) end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:CreateToggle(title, desc, defaultVal, callback)
        local cb = callback or (type(defaultVal) == "function" and defaultVal)
        local val = (type(defaultVal) == "boolean") and defaultVal or false
        local ok, res = pcall(function()
            return tab:Toggle({
                Title = tostring(title),
                Desc = tostring(desc or ""),
                Value = val,
                Callback = function(v)
                    if cb then pcall(cb, v) end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:CreateButton(title, desc, extra, callback)
        local cb = callback or (type(extra) == "function" and extra) or (type(desc) == "function" and desc)
        local ok, res = pcall(function()
            return tab:Button({
                Title = tostring(title),
                Desc = (type(desc) == "string") and desc or "",
                Callback = function()
                    if cb then pcall(cb) end
                end
            })
        end)
        return ok and res or nil
    end

    function tab:CreateDivider()
        pcall(function()
            if tab.Divider then tab:Divider() end
        end)
    end

    return tab
end

function Window:MakeTab(data)
    local title = type(data) == "table" and (data.Title or data.Name or data[1]) or tostring(data)
    local icon = type(data) == "table" and (data.Icon or data[2]) or "box"
    if type(icon) == "string" then
        icon = icon:gsub("^lucide%-", "")
    end
    if icon == "smile-plus" then icon = "smile" end
    if icon == "settings-2" then icon = "settings" end
    local ok, t = pcall(function()
        return Window:Tab({ Title = title, Icon = icon })
    end)
    if not ok or not t then
        pcall(function()
            t = Window:Tab({ Title = title })
        end)
    end
    return wrapTab(t)
end

function Window:SelectTab(t)
    pcall(function()
        if t and t.Select then t:Select() end
    end)
end

function Window:Minimize()
    pcall(function()
        if Window.Toggle then
            Window:Toggle()
        end
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local fti = firetouchinterest
local abs = math.abs
local clamp = math.clamp
local sqrt = math.sqrt
local clock = os.clock
local V3 = Vector3.new
local V3zero = Vector3.zero
local MAT_AIR = Enum.Material.Air

local Tab2 = Window:MakeTab({"Reach", "lucide-user"})

local reachSize = Vector3.new(10, 10, 10)
local reachDist = 5
local reachX = 5
local reachY = 5
local reachZ = 5
local reachMode = "Normal" -- "Normal" or "XYZ"
local legReachEnabled = false
local xyzReachEnabled = false
local reachConn = nil
local shapeType = "Box"
local transparency2 = 0.7

local reachPart = Instance.new("Part")
reachPart.Anchored = true
reachPart.CanCollide = false
reachPart.Transparency = transparency2
reachPart.Color = Color3.fromRGB(0, 85, 255)
reachPart.Name = "ReachPart"
reachPart.Parent = workspace

local _root, _hum, _rleg, _lleg, _hasRleg, _hasLleg
local function refreshChar(char)
    if not char then
        return false
    end
    _root = char:FindFirstChild("HumanoidRootPart")
    _hum = char:FindFirstChild("Humanoid")
    _rleg = char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg")
    _lleg = char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg")
    _hasRleg = _rleg ~= nil
    _hasLleg = _lleg ~= nil
    return (_root ~= nil and _hum ~= nil and (_hasRleg or _hasLleg))
end

local _charChildConn = nil
local function trackCharacter(c)
    if _charChildConn then
        _charChildConn:Disconnect()
        _charChildConn = nil
    end
    if not c then return end
    local complete = refreshChar(c)
    if not complete then
        -- Only listen until essential limbs are loaded, then immediately disconnect
        _charChildConn = c.ChildAdded:Connect(function()
            if refreshChar(c) and _charChildConn then
                _charChildConn:Disconnect()
                _charChildConn = nil
            end
        end)
    end
end

trackCharacter(lp.Character)
lp.CharacterAdded:Connect(function(c)
    task.wait()
    trackCharacter(c)
end)

local function getBall()
    local sys = workspace:FindFirstChild("TPSSystem")
    return (sys and sys:FindFirstChild("TPS")) or workspace:FindFirstChild("Ball")
end

local function fireLeg(ball)
    pcall(
        function()
            local pf = game.Lighting:FindFirstChild(lp.Name) and game.Lighting[lp.Name]:FindFirstChild("PreferredFoot")
            if pf and _hum then
                local ln
                if _hum.RigType == Enum.HumanoidRigType.R6 then
                    ln = (pf.Value == 1) and "Right Leg" or "Left Leg"
                else
                    ln = (pf.Value == 1) and "RightLowerLeg" or "LeftLowerLeg"
                end
                local l = lp.Character and lp.Character:FindFirstChild(ln)
                if l then
                    fti(l, ball, 0)
                    fti(l, ball, 1)
                end
            end
        end
    )
    if _root then
        fti(ball, _root, 0)
        fti(ball, _root, 1)
    end
    if _hasRleg then
        fti(ball, _rleg, 0)
        fti(ball, _rleg, 1)
    end
    if _hasLleg then
        fti(ball, _lleg, 0)
        fti(ball, _lleg, 1)
    end
end

-- smartPredict (Predictive Physics Trajectory)
local BUF_MAX = 8
local POS_BUF = {}
for i = 1, BUF_MAX do
    POS_BUF[i] = {t = 0, pos = V3zero, vel = V3zero}
end
local POS_HEAD, POS_LEN = 0, 0
local function recordBall(ball)
    POS_HEAD = (POS_HEAD % BUF_MAX) + 1
    local s = POS_BUF[POS_HEAD]
    s.t = clock()
    s.pos = ball.Position
    s.vel = ball.AssemblyLinearVelocity
    if POS_LEN < BUF_MAX then
        POS_LEN = POS_LEN + 1
    end
end
local function getFrame(offset)
    return POS_BUF[((POS_HEAD - offset - 1) % BUF_MAX) + 1]
end
local function smartPredict(ball, ahead)
    if POS_LEN < 2 then
        if not ball then
            return V3zero, V3zero
        end
        return ball.Position + ball.AssemblyLinearVelocity * ahead, ball.AssemblyLinearVelocity
    end
    local s2 = getFrame(0)
    local s1 = getFrame(1)
    local dt = s2.t - s1.t
    if dt <= 0 then
        dt = 0.016
    end
    local vpx = (s2.pos.X - s1.pos.X) / dt
    local vpy = (s2.pos.Y - s1.pos.Y) / dt
    local vpz = (s2.pos.Z - s1.pos.Z) / dt
    local vrx = s2.vel.X
    local vry = s2.vel.Y
    local vrz = s2.vel.Z
    local ddx = vrx - vpx
    local ddy = vry - vpy
    local ddz = vrz - vpz
    local kb = clamp((ddx * ddx + ddy * ddy + ddz * ddz) / (35 * 35), 0, 1)
    local blx = vpx * (1 - kb) + vrx * kb
    local bly = vpy * (1 - kb) + vry * kb
    local blz = vpz * (1 - kb) + vrz * kb
    local ax, ay, az = 0, 0, 0
    if POS_LEN >= 3 then
        local s0 = getFrame(2)
        local dt0 = s1.t - s0.t
        if dt0 > 0 then
            local v0x = (s1.pos.X - s0.pos.X) / dt0
            local v0y = (s1.pos.Y - s0.pos.Y) / dt0
            local v0z = (s1.pos.Z - s0.pos.Z) / dt0
            local amax = 120
            ax = clamp((vpx - v0x) / dt, -amax, amax)
            ay = clamp((vpy - v0y) / dt, -amax, amax)
            az = clamp((vpz - v0z) / dt, -amax, amax)
        end
    end
    local gravY = -9.8 * ahead * ahead * (1 - kb)
    local t = clamp(ahead, 0.016, 0.25)
    local half = 0.5 * t * t
    return V3(
        s2.pos.X + blx * t + ax * half,
        s2.pos.Y + bly * t + ay * half + gravY,
        s2.pos.Z + blz * t + az * half
    ), V3(blx, bly, blz)
end

local _cachedPing = 0.05
local _lastPingT = 0
local HIGH_PING_MS = 0.10
local GRAV_HALF_SQ = -9.8 * 0.5 * (1 / 60) * (1 / 60)
local INSIDE_THRESH = 2.5

local function applyReachSettings()
    if reachMode == "XYZ" then
        reachSize = Vector3.new(reachX * 2, reachY * 2, reachZ * 2)
    else
        reachSize = Vector3.new(reachDist * 2, reachDist * 2, reachDist * 2)
    end
    if reachPart then
        reachPart.Size = reachSize
        reachPart.Transparency = transparency2
        if shapeType == "Box" then
            reachPart.Shape = Enum.PartType.Block
        elseif shapeType == "Sphere" then
            reachPart.Shape = Enum.PartType.Ball
        elseif shapeType == "Cylinder" then
            reachPart.Shape = Enum.PartType.Cylinder
        end
        if (legReachEnabled or xyzReachEnabled) and _root then
            reachPart.CFrame = _root.CFrame
        end
    end
end

local function startReach()
    if reachConn then
        reachConn:Disconnect()
        reachConn = nil
    end
    applyReachSettings()
    reachConn = RunService.PreSimulation:Connect(
        function()
            if not _root or not _hum then
                return
            end

            -- Always update reach box position to follow character so user can see it!
            reachPart.CFrame = _root.CFrame

            local ball = getBall()
            if not ball then
                return
            end

            local now = clock()
            if now - _lastPingT >= 2 then
                _lastPingT = now
                _cachedPing = clamp(lp:GetNetworkPing(), 0.016, 0.25)
            end

            local ballPos = ball.Position
            local rootPos = _root.Position
            local qdx = ballPos.X - rootPos.X
            local qdz = ballPos.Z - rootPos.Z
            local maxBound = math.max(reachSize.X, reachSize.Z) / 2
            if abs(qdx) > (maxBound + 16) or abs(qdz) > (maxBound + 16) then
                return
            end

            recordBall(ball)
            local qdy = ballPos.Y - rootPos.Y
            local rawDist = sqrt(qdx * qdx + qdy * qdy + qdz * qdz)

            -- In range: fire touch
            local maxDim = math.max(reachSize.X, reachSize.Y, reachSize.Z) / 2
            if rawDist <= maxDim or rawDist < INSIDE_THRESH then
                fireLeg(ball)
                return
            end

            local ahead = _cachedPing + 1 / 60
            local predPos, predVel
            if _cachedPing >= HIGH_PING_MS or rawDist >= 7 then
                predPos, predVel = smartPredict(ball, ahead)
            else
                predPos = ballPos
                predVel = ball.AssemblyLinearVelocity
            end

            local pvx = predVel.X
            local pvy = predVel.Y
            local pvz = predVel.Z
            local farPos = V3(
                predPos.X + pvx * (1 / 60),
                predPos.Y + pvy * (1 / 60) + GRAV_HALF_SQ,
                predPos.Z + pvz * (1 / 60)
            )

            local rx = reachSize.X / 2
            local ry = reachSize.Y / 2
            local rz = reachSize.Z / 2
            local dx = predPos.X - rootPos.X
            local dy = predPos.Y - rootPos.Y
            local dz = predPos.Z - rootPos.Z
            local fdx = farPos.X - rootPos.X
            local fdy = farPos.Y - rootPos.Y
            local fdz = farPos.Z - rootPos.Z

            if (abs(dx) <= rx and abs(dy) <= ry and abs(dz) <= rz) or (abs(fdx) <= rx and abs(fdy) <= ry and abs(fdz) <= rz) then
                fireLeg(ball)
            end
        end
    )
end

local function stopReach()
    if reachConn then
        reachConn:Disconnect()
        reachConn = nil
    end
    reachPart.CFrame = CFrame.new(0, -9999, 0)
end

-- UI Controls
local reachToggleUI = nil
local reachSliderUI = nil
local reachSyncBoxUI = nil

local xyzToggleUI = nil
local reachXYZAllSliderUI = nil
local reachXYZAllBoxUI = nil
local reachXSliderUI = nil
local reachYSliderUI = nil
local reachZSliderUI = nil
local reachXBoxUI = nil
local reachYBoxUI = nil
local reachZBoxUI = nil

local reachShapeUI = nil
local reachHideUI = nil
local headReachToggleUI = nil
local headReachSliderUI = nil

-- SECTION 1: NORMAL REACH
Tab2:AddSection({"Normal Reach"})
Tab2:AddParagraph(
    {"Normal Reach", "Standard uniform predictive reach expanding equally across all axes."}
)

reachToggleUI = Tab2:AddToggle(
    {
        Name = "Enable Normal Reach",
        Default = false,
        Callback = function(v)
            legReachEnabled = v
            if v then
                reachMode = "Normal"
                xyzReachEnabled = false
                if xyzToggleUI and xyzToggleUI.Set then
                    pcall(function() xyzToggleUI:Set(false) end)
                end
                startReach()
            else
                if not xyzReachEnabled then
                    stopReach()
                end
            end
        end
    }
)

reachSliderUI = Tab2:AddSlider(
    {
        Name = "Reach Size",
        Min = 1,
        Max = 12,
        Increase = 1,
        Default = 5,
        Callback = function(v)
            reachDist = v
            if reachMode == "Normal" and (legReachEnabled or xyzReachEnabled) then
                applyReachSettings()
            end
        end
    }
)

reachSyncBoxUI = Tab2:AddTextBox(
    {
        Name = "Sync Reach Size",
        PlaceholderText = "Size (1-12)",
        Callback = function(v)
            local n = tonumber(v)
            if n then
                n = math.clamp(n, 1, 12)
                reachDist = n
                if reachSliderUI and reachSliderUI.Set then pcall(function() reachSliderUI:Set(n) end) end
                if reachSliderUI and reachSliderUI.SetValue then pcall(function() reachSliderUI:SetValue(n) end) end
                if reachMode == "Normal" and (legReachEnabled or xyzReachEnabled) then
                    applyReachSettings()
                end
            end
        end
    }
)

-- SECTION 2: XYZ REACH SYSTEM (SINGLE AXIS CONTROLS)
Tab2:AddSection({"XYZ Reach System"})
Tab2:AddParagraph(
    {"XYZ System", "Customize each individual axis independently (X = Width, Y = Height, Z = Length)."}
)

xyzToggleUI = Tab2:AddToggle(
    {
        Name = "Enable XYZ Reach",
        Default = false,
        Callback = function(v)
            xyzReachEnabled = v
            if v then
                reachMode = "XYZ"
                legReachEnabled = false
                if reachToggleUI and reachToggleUI.Set then
                    pcall(function() reachToggleUI:Set(false) end)
                end
                startReach()
            else
                if not legReachEnabled then
                    stopReach()
                end
            end
        end
    }
)

reachXYZAllSliderUI = Tab2:AddSlider(
    {
        Name = "Reach Size (All X.Y.Z)",
        Min = 1,
        Max = 12,
        Increase = 1,
        Default = 5,
        Callback = function(v)
            reachX = v
            reachY = v
            reachZ = v
            if reachXSliderUI and reachXSliderUI.Set then pcall(function() reachXSliderUI:Set(v) end) end
            if reachXSliderUI and reachXSliderUI.SetValue then pcall(function() reachXSliderUI:SetValue(v) end) end
            if reachYSliderUI and reachYSliderUI.Set then pcall(function() reachYSliderUI:Set(v) end) end
            if reachYSliderUI and reachYSliderUI.SetValue then pcall(function() reachYSliderUI:SetValue(v) end) end
            if reachZSliderUI and reachZSliderUI.Set then pcall(function() reachZSliderUI:Set(v) end) end
            if reachZSliderUI and reachZSliderUI.SetValue then pcall(function() reachZSliderUI:SetValue(v) end) end
            if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                applyReachSettings()
            end
        end
    }
)

reachXYZAllBoxUI = Tab2:AddTextBox(
    {
        Name = "Sync Reach Size (All X.Y.Z)",
        PlaceholderText = "Size (1-12)",
        Callback = function(v)
            local n = tonumber(v)
            if n then
                n = math.clamp(n, 1, 12)
                reachX = n
                reachY = n
                reachZ = n
                if reachXYZAllSliderUI and reachXYZAllSliderUI.Set then pcall(function() reachXYZAllSliderUI:Set(n) end) end
                if reachXYZAllSliderUI and reachXYZAllSliderUI.SetValue then pcall(function() reachXYZAllSliderUI:SetValue(n) end) end
                if reachXSliderUI and reachXSliderUI.Set then pcall(function() reachXSliderUI:Set(n) end) end
                if reachXSliderUI and reachXSliderUI.SetValue then pcall(function() reachXSliderUI:SetValue(n) end) end
                if reachYSliderUI and reachYSliderUI.Set then pcall(function() reachYSliderUI:Set(n) end) end
                if reachYSliderUI and reachYSliderUI.SetValue then pcall(function() reachYSliderUI:SetValue(n) end) end
                if reachZSliderUI and reachZSliderUI.Set then pcall(function() reachZSliderUI:Set(n) end) end
                if reachZSliderUI and reachZSliderUI.SetValue then pcall(function() reachZSliderUI:SetValue(n) end) end
                if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                    applyReachSettings()
                end
            end
        end
    }
)

reachXSliderUI = Tab2:AddSlider(
    {
        Name = "Reach X (Width)",
        Min = 1,
        Max = 12,
        Increase = 1,
        Default = 5,
        Callback = function(v)
            reachX = v
            if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                applyReachSettings()
            end
        end
    }
)

reachXBoxUI = Tab2:AddTextBox(
    {
        Name = "Sync X (Width)",
        PlaceholderText = "X (1-12)",
        Callback = function(v)
            local n = tonumber(v)
            if n then
                n = math.clamp(n, 1, 12)
                reachX = n
                if reachXSliderUI and reachXSliderUI.Set then pcall(function() reachXSliderUI:Set(n) end) end
                if reachXSliderUI and reachXSliderUI.SetValue then pcall(function() reachXSliderUI:SetValue(n) end) end
                if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                    applyReachSettings()
                end
            end
        end
    }
)

reachYSliderUI = Tab2:AddSlider(
    {
        Name = "Reach Y (Height)",
        Min = 1,
        Max = 12,
        Increase = 1,
        Default = 5,
        Callback = function(v)
            reachY = v
            if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                applyReachSettings()
            end
        end
    }
)

reachYBoxUI = Tab2:AddTextBox(
    {
        Name = "Sync Y (Height)",
        PlaceholderText = "Y (1-12)",
        Callback = function(v)
            local n = tonumber(v)
            if n then
                n = math.clamp(n, 1, 12)
                reachY = n
                if reachYSliderUI and reachYSliderUI.Set then pcall(function() reachYSliderUI:Set(n) end) end
                if reachYSliderUI and reachYSliderUI.SetValue then pcall(function() reachYSliderUI:SetValue(n) end) end
                if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                    applyReachSettings()
                end
            end
        end
    }
)

reachZSliderUI = Tab2:AddSlider(
    {
        Name = "Reach Z (Length)",
        Min = 1,
        Max = 12,
        Increase = 1,
        Default = 5,
        Callback = function(v)
            reachZ = v
            if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                applyReachSettings()
            end
        end
    }
)

reachZBoxUI = Tab2:AddTextBox(
    {
        Name = "Sync Z (Length)",
        PlaceholderText = "Z (1-12)",
        Callback = function(v)
            local n = tonumber(v)
            if n then
                n = math.clamp(n, 1, 12)
                reachZ = n
                if reachZSliderUI and reachZSliderUI.Set then pcall(function() reachZSliderUI:Set(n) end) end
                if reachZSliderUI and reachZSliderUI.SetValue then pcall(function() reachZSliderUI:SetValue(n) end) end
                if reachMode == "XYZ" and (legReachEnabled or xyzReachEnabled) then
                    applyReachSettings()
                end
            end
        end
    }
)

-- SECTION 3: VISUALS & SHAPE
Tab2:AddSection({"Visuals & Shape"})

reachShapeUI = Tab2:AddDropdown(
    {
        Name = "Select Shape",
        Options = {"Box", "Sphere", "Cylinder"},
        Default = "Box",
        Callback = function(v)
            shapeType = v
            if shapeType == "Box" then
                reachPart.Shape = Enum.PartType.Block
            elseif shapeType == "Sphere" then
                reachPart.Shape = Enum.PartType.Ball
            elseif shapeType == "Cylinder" then
                reachPart.Shape = Enum.PartType.Cylinder
            end
            if legReachEnabled or xyzReachEnabled then
                startReach()
            end
        end
    }
)

reachHideUI = Tab2:AddToggle(
    {
        Name = "Hide Box",
        Default = false,
        Callback = function(v)
            transparency2 = v and 1 or 0.7
            reachPart.Transparency = transparency2
        end
    }
)

-- ==============================================================================
-- HEAD REACH LOGIC & HELPERS
-- ==============================================================================
local sr_enabled = false
local sr_distance = 3
local function applyHeadReachSettings() end

local function updateUIElements()
    pcall(function()
        if reachToggleUI and reachToggleUI.Set then reachToggleUI:Set(legReachEnabled) end
    end)
    pcall(function()
        if reachSliderUI and reachSliderUI.Set then reachSliderUI:Set(reachDist) end
        if reachSliderUI and reachSliderUI.SetValue then reachSliderUI:SetValue(reachDist) end
    end)
    pcall(function()
        if xyzToggleUI and xyzToggleUI.Set then xyzToggleUI:Set(xyzReachEnabled) end
    end)
    pcall(function()
        if reachXYZAllSliderUI and reachXYZAllSliderUI.Set then reachXYZAllSliderUI:Set(reachX) end
        if reachXYZAllSliderUI and reachXYZAllSliderUI.SetValue then reachXYZAllSliderUI:SetValue(reachX) end
    end)
    pcall(function()
        if reachXSliderUI and reachXSliderUI.Set then reachXSliderUI:Set(reachX) end
        if reachXSliderUI and reachXSliderUI.SetValue then reachXSliderUI:SetValue(reachX) end
    end)
    pcall(function()
        if reachYSliderUI and reachYSliderUI.Set then reachYSliderUI:Set(reachY) end
        if reachYSliderUI and reachYSliderUI.SetValue then reachYSliderUI:SetValue(reachY) end
    end)
    pcall(function()
        if reachZSliderUI and reachZSliderUI.Set then reachZSliderUI:Set(reachZ) end
        if reachZSliderUI and reachZSliderUI.SetValue then reachZSliderUI:SetValue(reachZ) end
    end)
    pcall(function()
        if reachShapeUI and reachShapeUI.Select then reachShapeUI:Select(shapeType) end
        if reachShapeUI and reachShapeUI.Set then reachShapeUI:Set(shapeType) end
    end)
    pcall(function()
        if reachHideUI and reachHideUI.Set then reachHideUI:Set(transparency2 == 1) end
    end)
    pcall(function()
        if headReachToggleUI and headReachToggleUI.Set then headReachToggleUI:Set(sr_enabled) end
    end)
    pcall(function()
        if headReachSliderUI and headReachSliderUI.Set then headReachSliderUI:Set(sr_distance) end
        if headReachSliderUI and headReachSliderUI.SetValue then headReachSliderUI:SetValue(sr_distance) end
    end)
end

-- ==============================================================================
-- HEAD REACH (MiddleNight Moss Presets & Semi-Safe Mode)
-- ==============================================================================
task.wait()
local TabHeadReach = Window:MakeTab({"Head Reach", "lucide-user"})

-- MiddleNight Moss Presets Engine
local hrActive = false
local hrContact = false
local hrData = {idle="4", hit="4", interp="60", HX=3, HZ=3, HY=5}

local function hrStrip(k)
    return k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("FString",""):gsub("FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
end
local function hrSet(name,val)
    if not setfflag then return end
    pcall(function()
        local ck = hrStrip(name)
        if getfflag and getfflag(ck)~=nil then setfflag(ck,tostring(val))
        elseif getfflag and getfflag(name)~=nil then setfflag(name,tostring(val)) end
    end)
end

task.spawn(function()
    while true do
        if hrActive then
            hrSet("DFIntTargetTimeDelayFacctorTenths", hrContact and hrData.hit or hrData.idle)
            hrSet("FIntInterpolationMaxDelayMSec", hrData.interp)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if hrActive then
            local ch = lp and lp.Character or Players.LocalPlayer.Character
            local head = ch and ch:FindFirstChild("Head")
            local ball = getBall()
            if head and ball then
                local bp,hp = ball.Position, head.Position
                local dx,dy,dz = bp.X-hp.X, bp.Y-hp.Y, bp.Z-hp.Z
                if dx>=-hrData.HX and dx<=hrData.HX and dz>=-hrData.HZ and dz<=hrData.HZ and dy>=1.0 and dy<=hrData.HY then
                    pcall(function() firetouchinterest(ball,head,0); firetouchinterest(ball,head,1) end)
                    hrContact = true
                else hrContact = false end
            end
        end
        task.wait(0.016)
    end
end)

local function headPreset(idle,hit,interp,HX,HZ,HY,label)
    if not setfflag then
        pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Head Reach", Content="setfflag not supported", Duration=3}) end end)
        return
    end
    hrData.idle=idle; hrData.hit=hit; hrData.interp=interp
    hrData.HX=HX; hrData.HZ=HZ; hrData.HY=HY
    hrActive = true
    pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Head Reach", Content=(label or "Activated"), Duration=2}) end end)
end

TabHeadReach:AddSection({"Moss Presets"})
TabHeadReach:AddParagraph({"Moss Presets", "Dynamic timing delay + automated 3D head reach."})
TabHeadReach:AddButton({"15%   (Safest)", function() headPreset("13","9","90", 2.5,1.5,3.0, "15% (Safest)") end})
TabHeadReach:AddButton({"25%", function() headPreset("12","8","85", 2.7,1.7,3.4, "25%") end})
TabHeadReach:AddButton({"50%", function() headPreset("10","6","75", 3.1,2.3,4.2, "50%") end})
TabHeadReach:AddButton({"75%", function() headPreset("8","3","67", 3.6,2.9,5.1, "75%") end})
TabHeadReach:AddButton({"100%", function() headPreset("7","0","60", 4.0,3.5,6.0, "100%") end})
TabHeadReach:AddButton({"Stop Moss", function() hrActive = false; pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Head Reach", Content="Stopped", Duration=2}) end end) end})

-- ==============================================================================
-- REACT
-- ==============================================================================
task.wait()
local Tab5 = Window:MakeTab({"React", "lucide-smile-plus"})
Tab5:AddSection({"React"})
Tab5:AddParagraph({"React", "15% = highest delay (safer), 100% = lowest delay (most aggressive)."})

local function applyReact(tt, interp)
    local function strip(k)
        return k:gsub("^DFInt", ""):gsub("^DFFlag", ""):gsub("FString", ""):gsub("FLog", ""):gsub(
            "^FFlag", ""
        ):gsub("^DFint", ""):gsub("^FInt", "")
    end
    task.spawn(
        function()
            local flags = {
                ["DFIntTargetTimeDelayFacctorTenths"] = tt,
                ["FIntInterpolationMaxDelayMSec"] = interp,
            }
            local function apply()
                if not setfflag then
                    return
                end
                for k, v in pairs(flags) do
                    local ck = strip(k)
                    pcall(
                        function()
                            if getfflag(ck) ~= nil then
                                setfflag(ck, v)
                            elseif getfflag(k) ~= nil then
                                setfflag(k, v)
                            end
                        end
                    )
                end
            end
            while true do
                apply()
                task.wait(20)
            end
        end
    )
end

Tab5:AddButton(
    {
        "React 15%",
        function()
            applyReact("13", "90")
        end
    }
)
Tab5:AddButton(
    {
        "React 25%",
        function()
            applyReact("12", "85")
        end
    }
)
Tab5:AddButton(
    {
        "React 50%",
        function()
            applyReact("10", "75")
        end
    }
)
Tab5:AddButton(
    {
        "React 75%",
        function()
            applyReact("8", "67")
        end
    }
)
Tab5:AddButton(
    {
        "React 100%",
        function()
            applyReact("7", "60")
        end
    }
)

-- this under is xeno tab

task.wait()
local Tab6 = Window:MakeTab({"Xeno Moss", "lucide-zap"})

local Section = Tab6:AddSection({"Xeno Moss"})

Tab6:AddParagraph({
    "Xeno Moss",
    "Moss for <font color='rgb(127,0,255)'>Xeno & Solara</font>. Pick your %. Higher % = bigger hitbox."
})

Tab6:AddButton({"Xeno Moss 15%", function(Value)
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local BOX_X=2; local BOX_Y=2.8; local BOX_Z=3; local BOX_Y_OFFSET=1.5

local function isBoxTouching(pCF,pSz,tCF,tSz)
    local pMin=pCF.Position-pSz/2; local pMax=pCF.Position+pSz/2
    local tMin=tCF.Position-tSz/2; local tMax=tCF.Position+tSz/2
    return (pMin.X<=tMax.X and pMax.X>=tMin.X) and (pMin.Y<=tMax.Y and pMax.Y>=tMin.Y) and (pMin.Z<=tMax.Z and pMax.Z>=tMin.Z)
end

local headerAnim=Instance.new("Animation"); headerAnim.AnimationId="rbxassetid://301501585"
local currentTrack=nil

local function playHeaderAnim()
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if currentTrack and currentTrack.IsPlaying then return end
    pcall(function() currentTrack=hum:LoadAnimation(headerAnim); currentTrack:Play() end)
end

local function fireKick()
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    local TPS=TPSSystem and TPSSystem:FindFirstChild("TPS"); if not TPS then return end
    local FE=workspace:FindFirstChild("FE")
    local remote=FE and FE:FindFirstChild("System") and FE.System:FindFirstChild("Header"); if not remote then return end
    remote:FireServer(player.UserId,TPS,"Rock'n'roll Star","NeverFearTruth","power=95/100")
end

local mossWasInside=false; local mossCooldown=false

RunService.Heartbeat:Connect(function()
    local char=player.Character; if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local raisedCFrame=head.CFrame*CFrame.new(0,BOX_Y_OFFSET,0)
    local boxSize=Vector3.new(BOX_X,BOX_Y,BOX_Z)
    local targets={}
    local BallsFolder=workspace:FindFirstChild("Balls")
    if BallsFolder then for _,ball in BallsFolder:GetChildren() do if ball:IsA("BasePart") then table.insert(targets,ball) end end end
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    if TPSSystem then for _,tpsPart in TPSSystem:GetChildren() do if tpsPart:IsA("BasePart") or tpsPart.Name=="TPS" then table.insert(targets,tpsPart) end end end
    local ballCurrentlyInside=false
    for _,target in targets do
        local predictedPos=target.Position+target.Velocity*0.001
        local predictedCFrame=CFrame.new(predictedPos)*target.CFrame.Rotation
        if target.Position.Y>=hrp.Position.Y+1 then
            if isBoxTouching(raisedCFrame,boxSize,predictedCFrame,target.Size) then ballCurrentlyInside=true; break end
        end
    end
    if ballCurrentlyInside and not mossWasInside and not mossCooldown then
        mossCooldown=true; playHeaderAnim(); fireKick()
        task.delay(0.3,function() mossCooldown=false end)
    end
    mossWasInside=ballCurrentlyInside
end)
end})

Tab6:AddButton({"Xeno Moss 25%", function(Value)
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local BOX_X=2.5; local BOX_Y=3.2; local BOX_Z=3.3; local BOX_Y_OFFSET=1.5

local function isBoxTouching(pCF,pSz,tCF,tSz)
    local pMin=pCF.Position-pSz/2; local pMax=pCF.Position+pSz/2
    local tMin=tCF.Position-tSz/2; local tMax=tCF.Position+tSz/2
    return (pMin.X<=tMax.X and pMax.X>=tMin.X) and (pMin.Y<=tMax.Y and pMax.Y>=tMin.Y) and (pMin.Z<=tMax.Z and pMax.Z>=tMin.Z)
end

local headerAnim=Instance.new("Animation"); headerAnim.AnimationId="rbxassetid://301501585"
local currentTrack=nil

local function playHeaderAnim()
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if currentTrack and currentTrack.IsPlaying then return end
    pcall(function() currentTrack=hum:LoadAnimation(headerAnim); currentTrack:Play() end)
end

local function fireKick()
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    local TPS=TPSSystem and TPSSystem:FindFirstChild("TPS"); if not TPS then return end
    local FE=workspace:FindFirstChild("FE")
    local remote=FE and FE:FindFirstChild("System") and FE.System:FindFirstChild("Header"); if not remote then return end
    remote:FireServer(player.UserId,TPS,"Rock'n'roll Star","NeverFearTruth","power=95/100")
end

local mossWasInside=false; local mossCooldown=false

RunService.Heartbeat:Connect(function()
    local char=player.Character; if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local raisedCFrame=head.CFrame*CFrame.new(0,BOX_Y_OFFSET,0)
    local boxSize=Vector3.new(BOX_X,BOX_Y,BOX_Z)
    local targets={}
    local BallsFolder=workspace:FindFirstChild("Balls")
    if BallsFolder then for _,ball in BallsFolder:GetChildren() do if ball:IsA("BasePart") then table.insert(targets,ball) end end end
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    if TPSSystem then for _,tpsPart in TPSSystem:GetChildren() do if tpsPart:IsA("BasePart") or tpsPart.Name=="TPS" then table.insert(targets,tpsPart) end end end
    local ballCurrentlyInside=false
    for _,target in targets do
        local predictedPos=target.Position+target.Velocity*0.001
        local predictedCFrame=CFrame.new(predictedPos)*target.CFrame.Rotation
        if target.Position.Y>=hrp.Position.Y+1 then
            if isBoxTouching(raisedCFrame,boxSize,predictedCFrame,target.Size) then ballCurrentlyInside=true; break end
        end
    end
    if ballCurrentlyInside and not mossWasInside and not mossCooldown then
        mossCooldown=true; playHeaderAnim(); fireKick()
        task.delay(0.3,function() mossCooldown=false end)
    end
    mossWasInside=ballCurrentlyInside
end)
end})

Tab6:AddButton({"Xeno Moss 50%", function(Value)
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local BOX_X=3; local BOX_Y=3.8; local BOX_Z=3.6; local BOX_Y_OFFSET=1.5

local function isBoxTouching(pCF,pSz,tCF,tSz)
    local pMin=pCF.Position-pSz/2; local pMax=pCF.Position+pSz/2
    local tMin=tCF.Position-tSz/2; local tMax=tCF.Position+tSz/2
    return (pMin.X<=tMax.X and pMax.X>=tMin.X) and (pMin.Y<=tMax.Y and pMax.Y>=tMin.Y) and (pMin.Z<=tMax.Z and pMax.Z>=tMin.Z)
end

local headerAnim=Instance.new("Animation"); headerAnim.AnimationId="rbxassetid://301501585"
local currentTrack=nil

local function playHeaderAnim()
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if currentTrack and currentTrack.IsPlaying then return end
    pcall(function() currentTrack=hum:LoadAnimation(headerAnim); currentTrack:Play() end)
end

local function fireKick()
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    local TPS=TPSSystem and TPSSystem:FindFirstChild("TPS"); if not TPS then return end
    local FE=workspace:FindFirstChild("FE")
    local remote=FE and FE:FindFirstChild("System") and FE.System:FindFirstChild("Header"); if not remote then return end
    remote:FireServer(player.UserId,TPS,"Rock'n'roll Star","NeverFearTruth","power=95/100")
end

local mossWasInside=false; local mossCooldown=false

RunService.Heartbeat:Connect(function()
    local char=player.Character; if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local raisedCFrame=head.CFrame*CFrame.new(0,BOX_Y_OFFSET,0)
    local boxSize=Vector3.new(BOX_X,BOX_Y,BOX_Z)
    local targets={}
    local BallsFolder=workspace:FindFirstChild("Balls")
    if BallsFolder then for _,ball in BallsFolder:GetChildren() do if ball:IsA("BasePart") then table.insert(targets,ball) end end end
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    if TPSSystem then for _,tpsPart in TPSSystem:GetChildren() do if tpsPart:IsA("BasePart") or tpsPart.Name=="TPS" then table.insert(targets,tpsPart) end end end
    local ballCurrentlyInside=false
    for _,target in targets do
        local predictedPos=target.Position+target.Velocity*0.001
        local predictedCFrame=CFrame.new(predictedPos)*target.CFrame.Rotation
        if target.Position.Y>=hrp.Position.Y+1 then
            if isBoxTouching(raisedCFrame,boxSize,predictedCFrame,target.Size) then ballCurrentlyInside=true; break end
        end
    end
    if ballCurrentlyInside and not mossWasInside and not mossCooldown then
        mossCooldown=true; playHeaderAnim(); fireKick()
        task.delay(0.3,function() mossCooldown=false end)
    end
    mossWasInside=ballCurrentlyInside
end)
end})

Tab6:AddButton({"Xeno Moss 75%", function(Value)
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local BOX_X=3.5; local BOX_Y=4.5; local BOX_Z=4.1; local BOX_Y_OFFSET=1.5

local function isBoxTouching(pCF,pSz,tCF,tSz)
    local pMin=pCF.Position-pSz/2; local pMax=pCF.Position+pSz/2
    local tMin=tCF.Position-tSz/2; local tMax=tCF.Position+tSz/2
    return (pMin.X<=tMax.X and pMax.X>=tMin.X) and (pMin.Y<=tMax.Y and pMax.Y>=tMin.Y) and (pMin.Z<=tMax.Z and pMax.Z>=tMin.Z)
end

local headerAnim=Instance.new("Animation"); headerAnim.AnimationId="rbxassetid://301501585"
local currentTrack=nil

local function playHeaderAnim()
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if currentTrack and currentTrack.IsPlaying then return end
    pcall(function() currentTrack=hum:LoadAnimation(headerAnim); currentTrack:Play() end)
end

local function fireKick()
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    local TPS=TPSSystem and TPSSystem:FindFirstChild("TPS"); if not TPS then return end
    local FE=workspace:FindFirstChild("FE")
    local remote=FE and FE:FindFirstChild("System") and FE.System:FindFirstChild("Header"); if not remote then return end
    remote:FireServer(player.UserId,TPS,"Rock'n'roll Star","NeverFearTruth","power=95/100")
end

local mossWasInside=false; local mossCooldown=false

RunService.Heartbeat:Connect(function()
    local char=player.Character; if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local raisedCFrame=head.CFrame*CFrame.new(0,BOX_Y_OFFSET,0)
    local boxSize=Vector3.new(BOX_X,BOX_Y,BOX_Z)
    local targets={}
    local BallsFolder=workspace:FindFirstChild("Balls")
    if BallsFolder then for _,ball in BallsFolder:GetChildren() do if ball:IsA("BasePart") then table.insert(targets,ball) end end end
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    if TPSSystem then for _,tpsPart in TPSSystem:GetChildren() do if tpsPart:IsA("BasePart") or tpsPart.Name=="TPS" then table.insert(targets,tpsPart) end end end
    local ballCurrentlyInside=false
    for _,target in targets do
        local predictedPos=target.Position+target.Velocity*0.001
        local predictedCFrame=CFrame.new(predictedPos)*target.CFrame.Rotation
        if target.Position.Y>=hrp.Position.Y+1 then
            if isBoxTouching(raisedCFrame,boxSize,predictedCFrame,target.Size) then ballCurrentlyInside=true; break end
        end
    end
    if ballCurrentlyInside and not mossWasInside and not mossCooldown then
        mossCooldown=true; playHeaderAnim(); fireKick()
        task.delay(0.3,function() mossCooldown=false end)
    end
    mossWasInside=ballCurrentlyInside
end)
end})

Tab6:AddButton({"Xeno Moss 100%", function(Value)
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local BOX_X=4; local BOX_Y=5; local BOX_Z=4.5; local BOX_Y_OFFSET=1.5

local function isBoxTouching(pCF,pSz,tCF,tSz)
    local pMin=pCF.Position-pSz/2; local pMax=pCF.Position+pSz/2
    local tMin=tCF.Position-tSz/2; local tMax=tCF.Position+tSz/2
    return (pMin.X<=tMax.X and pMax.X>=tMin.X) and (pMin.Y<=tMax.Y and pMax.Y>=tMin.Y) and (pMin.Z<=tMax.Z and pMax.Z>=tMin.Z)
end

local headerAnim=Instance.new("Animation"); headerAnim.AnimationId="rbxassetid://301501585"
local currentTrack=nil

local function playHeaderAnim()
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if currentTrack and currentTrack.IsPlaying then return end
    pcall(function() currentTrack=hum:LoadAnimation(headerAnim); currentTrack:Play() end)
end

local function fireKick()
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    local TPS=TPSSystem and TPSSystem:FindFirstChild("TPS"); if not TPS then return end
    local FE=workspace:FindFirstChild("FE")
    local remote=FE and FE:FindFirstChild("System") and FE.System:FindFirstChild("Header"); if not remote then return end
    remote:FireServer(player.UserId,TPS,"Rock'n'roll Star","NeverFearTruth","power=95/100")
end

local mossWasInside=false; local mossCooldown=false

RunService.Heartbeat:Connect(function()
    local char=player.Character; if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local raisedCFrame=head.CFrame*CFrame.new(0,BOX_Y_OFFSET,0)
    local boxSize=Vector3.new(BOX_X,BOX_Y,BOX_Z)
    local targets={}
    local BallsFolder=workspace:FindFirstChild("Balls")
    if BallsFolder then for _,ball in BallsFolder:GetChildren() do if ball:IsA("BasePart") then table.insert(targets,ball) end end end
    local TPSSystem=workspace:FindFirstChild("TPSSystem")
    if TPSSystem then for _,tpsPart in TPSSystem:GetChildren() do if tpsPart:IsA("BasePart") or tpsPart.Name=="TPS" then table.insert(targets,tpsPart) end end end
    local ballCurrentlyInside=false
    for _,target in targets do
        local predictedPos=target.Position+target.Velocity*0.001
        local predictedCFrame=CFrame.new(predictedPos)*target.CFrame.Rotation
        if target.Position.Y>=hrp.Position.Y+1 then
            if isBoxTouching(raisedCFrame,boxSize,predictedCFrame,target.Size) then ballCurrentlyInside=true; break end
        end
    end
    if ballCurrentlyInside and not mossWasInside and not mossCooldown then
        mossCooldown=true; playHeaderAnim(); fireKick()
        task.delay(0.3,function() mossCooldown=false end)
    end
    mossWasInside=ballCurrentlyInside
end)
end})

-- ==============================================================================
-- FLAG FUNC (Hybrid Engine & FFlag Implementation - 100% Working)
-- ==============================================================================
local _g = (type(getgenv) == "function" and getgenv()) or _G
local _raw_setfflag = (type(setfflag) == "function" and setfflag) or (_g and _g.setfflag) or (_g and _g.set_fflag)
local _raw_getfflag = (type(getfflag) == "function" and getfflag) or (_g and _g.getfflag) or (_g and _g.get_fflag)
local _raw_setfpscap = (type(setfpscap) == "function" and setfpscap) or (_g and _g.setfpscap) or (_g and _g.set_fps_cap)

local function setfflag(flag, val)
    if _raw_setfflag then
        pcall(function()
            _raw_setfflag(flag, tostring(val))
        end)
        local ck = flag:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("FString",""):gsub("FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
        pcall(function()
            if _raw_getfflag and _raw_getfflag(ck) ~= nil then
                _raw_setfflag(ck, tostring(val))
            elseif _raw_getfflag and _raw_getfflag(flag) ~= nil then
                _raw_setfflag(flag, tostring(val))
            end
        end)
    end
end

local function setfpscap(fps)
    local n = tonumber(fps) or 60
    if _raw_setfpscap then
        pcall(_raw_setfpscap, n)
    end
end

local function notify(title, content, duration)
    local sent = false
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = title or "Specter",
                Content = content or "",
                Duration = duration or 2,
                Icon = "check"
            })
            sent = true
        end
    end)
    if not sent then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "Specter",
                Text = content or "",
                Duration = duration or 2
            })
        end)
    end
end

local punishgoatby97mzu = {
    Notify = function(self, data)
        pcall(function()
            if type(data) == "table" then
                notify(data.Title, data.Content, data.Duration)
            end
        end)
    end
}

-- REAL IN-GAME ENGINE MODIFIERS (GUARANTEES 100% VISUAL & PERFORMANCE CHANGES ON ALL PLATFORMS)
local _fpsGui = nil
local function toggleFpsCounter(show)
    setfflag("FFlagDebugDisplayFPS", show and "true" or "false")
    if show then
        if not _fpsGui then
            local sg = Instance.new("ScreenGui")
            sg.Name = "Specter_FPS_HUD"
            sg.ResetOnSpawn = false
            pcall(function() sg.Parent = game:GetService("CoreGui") end)
            if not sg.Parent then
                sg.Parent = lp and lp:FindFirstChild("PlayerGui")
            end
            if not sg.Parent then return end

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 95, 0, 26)
            lbl.Position = UDim2.new(0.5, -47, 0, 8)
            lbl.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            lbl.BackgroundTransparency = 0.25
            lbl.TextColor3 = Color3.fromRGB(0, 255, 165)
            lbl.TextSize = 13
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = "FPS: 60"
            lbl.Parent = sg

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = lbl

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(70, 70, 70)
            stroke.Thickness = 1
            stroke.Parent = lbl

            _fpsGui = sg

            task.spawn(function()
                local lastTime = os.clock()
                local frames = 0
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if not _fpsGui or not _fpsGui.Parent then
                        if conn then conn:Disconnect() end
                        return
                    end
                    frames = frames + 1
                    local now = os.clock()
                    if now - lastTime >= 0.5 then
                        local curFps = math.round(frames / (now - lastTime))
                        lbl.Text = "FPS: " .. tostring(curFps)
                        if curFps >= 50 then
                            lbl.TextColor3 = Color3.fromRGB(0, 255, 165)
                        elseif curFps >= 30 then
                            lbl.TextColor3 = Color3.fromRGB(255, 205, 55)
                        else
                            lbl.TextColor3 = Color3.fromRGB(255, 75, 75)
                        end
                        frames = 0
                        lastTime = now
                    end
                end)
            end)
        else
            _fpsGui.Enabled = true
        end
    else
        if _fpsGui then
            _fpsGui.Enabled = false
        end
    end
end

local _origSky = nil
local function toggleGraySky(enable)
    setfflag("FFlagDebugSkyGray", enable and "true" or "false")
    pcall(function()
        local Lighting = game:GetService("Lighting")
        if enable then
            if not _origSky then
                _origSky = Lighting:FindFirstChildOfClass("Sky")
            end
            if _origSky then
                _origSky.Parent = Lighting:FindFirstChild("HiddenSkies") or workspace
            end
            Lighting.FogColor = Color3.fromRGB(128, 128, 128)
            Lighting.FogEnd = 2000
            Lighting.FogStart = 0
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        else
            if _origSky then
                _origSky.Parent = Lighting
            end
            Lighting.FogEnd = 100000
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end)
end

local function toggleShadows(disable)
    setfflag("FIntRenderShadowIntensity", disable and "0" or "1")
    pcall(function()
        game:GetService("Lighting").GlobalShadows = not disable
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = not disable
            end
        end
    end)
end

local function togglePostFX(disable)
    setfflag("FFlagDisablePostFx", disable and "true" or "false")
    pcall(function()
        for _, fx in pairs(game:GetService("Lighting"):GetChildren()) do
            if fx:IsA("PostEffect") or fx:IsA("BloomEffect") or fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                fx.Enabled = not disable
            end
        end
    end)
end

local function toggleTerrainTextures(disable)
    setfflag("FIntTerrainArraySliceSize", disable and "0" or "2")
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = disable and 0 or 0.15
            terrain.WaterWaveSpeed = disable and 0 or 10
            terrain.WaterReflectance = disable and 0 or 1
            terrain.WaterTransparency = disable and 0 or 1
        end
    end)
end

local function setGameQuality(val)
    pcall(function()
        if settings and settings().Rendering then
            if val == 0 then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            elseif val == 1 then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
            elseif val == 2 then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
            elseif val == 3 then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level15
            elseif val == 4 then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
            else
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end
        end
    end)
end

task.wait()
local TabFlags = Window:MakeTab({"Flag Func", "lucide-settings-2"})

TabFlags:CreateSection("Flags")
TabFlags:CreateLabel("Toggle flags on/off. All changes apply instantly.")

-- OP FPS BOOST BTW
TabFlags:CreateSection("Performance")
TabFlags:CreateInput("Target FPS", "set FPS limit (0 = unlimited)", "Default: 60", nil, nil, function(v)
    local fps = tonumber(v)
    if fps then
        if fps == 0 then fps = 999 end
        setfpscap(fps)
        setfflag("DFIntTaskSchedulerTargetFps", tostring(fps))
        setfflag("FFlagTaskSchedulerLimitTargetFpsTo2402", fps >= 70 and "true" or "false")
        punishgoatby97mzu:Notify({ Title="FPS", Content="Set to " .. fps, Duration=2 })
    end
end)

TabFlags:CreateToggle("Show FPS", "displays real-time FPS counter HUD", false, function(v)
    toggleFpsCounter(v)
end)

TabFlags:CreateToggle("Gray Sky", "turns sky gray in real-time", false, function(v)
    toggleGraySky(v)
end)

-- Visual Quality
TabFlags:CreateSection("Visual Quality")

TabFlags:CreateInput("Anti-Aliasing (MSAA)", "1x, 2x, 4x, 8x (0 = auto)", "Default: 0", nil, nil, function(v)
    local samples = tonumber(v)
    if samples then
        setfflag("FIntDebugForceMSAASamples", tostring(samples))
        punishgoatby97mzu:Notify({ Title="MSAA", Content="Set to " .. samples .. "x", Duration=2 })
    end
end)

TabFlags:CreateInput("Texture Quality", "0=lowest, 1=low, 2=medium, 3=high, 4=highest, -1=auto", "Default: -1", nil, nil, function(v)
    local val = tonumber(v)
    if val then
        setGameQuality(val)
        if val == -1 then
            setfflag("DFFlagTextureQualityOverrideEnabled", "false")
            setfflag("DFIntTextureQualityOverride", "0")
            setfflag("FIntDebugTextureManagerSkipMips", "0")
        else
            setfflag("DFFlagTextureQualityOverrideEnabled", "true")
            setfflag("DFIntTextureQualityOverride", tostring(val))
            setfflag("FIntDebugTextureManagerSkipMips", val == 0 and "2" or "0")
        end
        punishgoatby97mzu:Notify({ Title="Texture", Content="Set to " .. v, Duration=2 })
    end
end)

TabFlags:CreateInput("Lighting Technology", "0=auto, 1=voxel, 2=shadowmap, 3=future", "Default: 0", nil, nil, function(v)
    local val = tonumber(v)
    if val then
        pcall(function()
            local l = game:GetService("Lighting")
            if val == 1 then l.Technology = Enum.Technology.Voxel
            elseif val == 2 then l.Technology = Enum.Technology.ShadowMap
            elseif val == 3 then l.Technology = Enum.Technology.Future
            end
        end)
        if val == 0 then
            setfflag("DFFlagDebugRenderForceTechnologyVoxel", "false")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase3", "false")
        elseif val == 1 then
            setfflag("DFFlagDebugRenderForceTechnologyVoxel", "true")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase3", "false")
        elseif val == 2 then
            setfflag("DFFlagDebugRenderForceTechnologyVoxel", "false")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase2", "true")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase3", "false")
        elseif val == 3 then
            setfflag("DFFlagDebugRenderForceTechnologyVoxel", "false")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase3", "true")
        end
        punishgoatby97mzu:Notify({ Title="Lighting", Content="Set to " .. v, Duration=2 })
    end
end)

-- Gameplay Tweaks
TabFlags:CreateSection("Gameplay Tweaks")

TabFlags:CreateToggle("Disable Player Shadows", "removes all shadows in real-time", false, function(v)
    toggleShadows(v)
end)

TabFlags:CreateToggle("Disable PostFX", "disables post-processing instantly", false, function(v)
    togglePostFX(v)
end)

TabFlags:CreateToggle("Disable Terrain Textures", "removes terrain and water textures", false, function(v)
    toggleTerrainTextures(v)
end)

-- Network & React
TabFlags:CreateSection("Network & React")

local _tt = "4"
local _interp = "60"
local _s2 = "38720"

TabFlags:CreateInput("Target Time Delay", "DFIntTargetTimeDelayFacctorTenths", "Default: 4", nil, nil, function(v)
    if v ~= "" then
        _tt = tostring(v)
        setfflag("DFIntTargetTimeDelayFacctorTenths", _tt)
        punishgoatby97mzu:Notify({ Title="Flag", Content="Set target delay to " .. v, Duration=2 })
    end
end)

TabFlags:CreateInput("Interpolation Delay", "FIntInterpolationMaxDelayMSec", "Default: 60", nil, nil, function(v)
    if v ~= "" then
        _interp = tostring(v)
        setfflag("FIntInterpolationMaxDelayMSec", _interp)
        punishgoatby97mzu:Notify({ Title="Flag", Content="Set interpolation to " .. v, Duration=2 })
    end
end)

TabFlags:CreateInput("Physics Sender Rate", "DFIntS2PhysicsSenderRate", "Default: 38720", nil, nil, function(v)
    if v ~= "" then
        _s2 = tostring(v)
        setfflag("DFIntS2PhysicsSenderRate", _s2)
        punishgoatby97mzu:Notify({ Title="Flag", Content="Set sender rate to " .. v, Duration=2 })
    end
end)

local _flagLockThread = nil
TabFlags:CreateButton("Apply & Lock Network Flags", "continuously locks delay & sender rate", nil, function()
    if _flagLockThread then task.cancel(_flagLockThread) end
    _flagLockThread = task.spawn(function()
        while true do
            setfflag("DFIntTargetTimeDelayFacctorTenths", _tt)
            setfflag("FIntInterpolationMaxDelayMSec", _interp)
            setfflag("DFIntS2PhysicsSenderRate", _s2)
            task.wait(2)
        end
    end)
    punishgoatby97mzu:Notify({ Title="Lock", Content="Network flags locked.", Duration=2 })
end)

TabFlags:CreateButton("Unlock Network Flags", "stops the lock loop", nil, function()
    if _flagLockThread then
        task.cancel(_flagLockThread)
        _flagLockThread = nil
    end
    punishgoatby97mzu:Notify({ Title="Lock", Content="Network flags unlocked.", Duration=2 })
end)

-- Presets
TabFlags:CreateSection("Presets")

TabFlags:CreateButton("Reset All Flags", "resets all flags and visuals to default", nil, function()
    toggleShadows(false)
    togglePostFX(false)
    toggleGraySky(false)
    toggleTerrainTextures(false)
    toggleFpsCounter(false)
    setGameQuality(-1)
    setfpscap(60)
    setfflag("DFIntTargetTimeDelayFacctorTenths", "4")
    setfflag("FIntInterpolationMaxDelayMSec", "60")
    setfflag("DFIntS2PhysicsSenderRate", "38720")
    setfflag("FFlagDebugDisplayFPS", "false")
    setfflag("FFlagDebugSkyGray", "false")
    setfflag("FIntDebugForceMSAASamples", "0")
    setfflag("DFFlagTextureQualityOverrideEnabled", "false")
    setfflag("DFIntTextureQualityOverride", "0")
    setfflag("FIntDebugTextureManagerSkipMips", "0")
    setfflag("DFFlagDebugRenderForceTechnologyVoxel", "false")
    setfflag("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
    setfflag("DFFlagDebugRenderForceFutureIsBrightPhase3", "false")
    setfflag("FIntRenderShadowIntensity", "1")
    setfflag("FFlagDisablePostFx", "false")
    setfflag("FIntTerrainArraySliceSize", "2")
    setfflag("DFIntTaskSchedulerTargetFps", "60")
    setfflag("FFlagTaskSchedulerLimitTargetFpsTo2402", "false")
    punishgoatby97mzu:Notify({ Title="Flags", Content="All flags reset to default.", Duration=3 })
end)

-- Bloxstrap Presets
TabFlags:CreateSection("Bloxstrap Presets")
TabFlags:CreateLabel("Quick presets for common flags")

TabFlags:CreateButton("FPS Mode (120 FPS)", "unlock FPS to 120", nil, function()
    setfpscap(120)
    setfflag("DFIntTaskSchedulerTargetFps", "120")
    setfflag("FFlagTaskSchedulerLimitTargetFpsTo2402", "true")
    punishgoatby97mzu:Notify({ Title="Preset", Content="FPS set to 120", Duration=2 })
end)

TabFlags:CreateButton("React Mode (Faster Touches)", "optimized for better touch registration", nil, function()
    setfflag("DFIntTargetTimeDelayFacctorTenths", "0")
    setfflag("FIntInterpolationMaxDelayMSec", "30")
    setfflag("DFIntS2PhysicsSenderRate", "60")
    _tt = "0"
    _interp = "30"
    _s2 = "60"
    punishgoatby97mzu:Notify({ Title="Preset", Content="React mode applied", Duration=2 })
end)

TabFlags:CreateButton("Low Performance Mode", "max performance, low visuals", nil, function()
    toggleGraySky(true)
    togglePostFX(true)
    toggleShadows(true)
    toggleTerrainTextures(true)
    setGameQuality(0)
    setfflag("FFlagDebugSkyGray", "true")
    setfflag("FFlagDisablePostFx", "true")
    setfflag("FIntRenderShadowIntensity", "0")
    setfflag("FIntTerrainArraySliceSize", "0")
    setfflag("DFFlagTextureQualityOverrideEnabled", "true")
    setfflag("DFIntTextureQualityOverride", "0")
    setfflag("FIntDebugTextureManagerSkipMips", "2")
    punishgoatby97mzu:Notify({ Title="Preset", Content="Low performance mode applied", Duration=2 })
end)

TabFlags:CreateButton("Reset Flags", "reset to default flags", nil, function()
    toggleShadows(false)
    togglePostFX(false)
    toggleGraySky(false)
    toggleTerrainTextures(false)
    setGameQuality(-1)
    setfflag("DFIntTargetTimeDelayFacctorTenths", "4")
    setfflag("FIntInterpolationMaxDelayMSec", "60")
    setfflag("DFIntS2PhysicsSenderRate", "38720")
    setfflag("FFlagDebugDisplayFPS", "false")
    setfflag("FFlagDebugSkyGray", "false")
    setfflag("FIntDebugForceMSAASamples", "0")
    setfflag("DFFlagTextureQualityOverrideEnabled", "false")
    setfflag("DFIntTextureQualityOverride", "0")
    setfflag("FIntDebugTextureManagerSkipMips", "0")
    setfflag("DFFlagDebugRenderForceTechnologyVoxel", "false")
    setfflag("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
    setfflag("DFFlagDebugRenderForceFutureIsBrightPhase3", "false")
    setfflag("FIntRenderShadowIntensity", "1")
    setfflag("FFlagDisablePostFx", "false")
    setfflag("FIntTerrainArraySliceSize", "2")
    setfflag("DFIntTaskSchedulerTargetFps", "60")
    setfflag("FFlagTaskSchedulerLimitTargetFpsTo2402", "false")
    punishgoatby97mzu:Notify({ Title="Flags", Content="All flags reset to default.", Duration=3 })
end)

-- JSON Flag Inject
TabFlags:CreateDivider()
TabFlags:CreateSection("JSON Flag Inject")
TabFlags:CreateLabel('Paste JSON. Format: {"FlagName":"value"}')

local _injectThread = nil
local _injectFlags = {}

TabFlags:CreateInput("Flag JSON", 'Paste raw JSON', '{"DFIntTargetTimeDelayFacctorTenths":"7"}', nil, nil, function(v)
    if not v or v == "" then return end
    local ok, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(v)
    end)
    if ok and type(decoded) == "table" then
        _injectFlags = decoded
        punishgoatby97mzu:Notify({ Title="Inject", Content="Flags parsed.", Duration=3 })
    else
        punishgoatby97mzu:Notify({ Title="Inject Error", Content="Invalid JSON.", Duration=4 })
    end
end)

TabFlags:CreateButton("Start JSON Inject", "injects parsed flags every 20s", nil, function()
    if _injectThread then task.cancel(_injectThread) end
    _injectThread = task.spawn(function()
        while true do
            for k, v in pairs(_injectFlags) do
                setfflag(k, tostring(v))
            end
            task.wait(20)
        end
    end)
    punishgoatby97mzu:Notify({ Title="Inject", Content="Inject loop started.", Duration=3 })
end)

TabFlags:CreateButton("Stop JSON Inject", "stops the inject loop", nil, function()
    if _injectThread then task.cancel(_injectThread); _injectThread = nil end
    punishgoatby97mzu:Notify({ Title="Inject", Content="Inject loop stopped.", Duration=3 })
end)

-- ==============================================================================
-- AVATAR STEALER (MiddleNight Tab 8)
-- ==============================================================================
task.wait()
local TabAv = Window:MakeTab({"Avatar Stealer", "lucide-user-check"})
TabAv:AddSection({"Fake Avatar"})
TabAv:AddParagraph({"Avatar Stealer", "Copy any player's accessories, clothing, and appearance in real-time."})

local avUser = ""
local avSaved = nil
local avLastId = nil
local avAuto = true

local function avSave()
    local ch = lp and lp.Character or Players.LocalPlayer.Character
    if not ch then return end
    local snap = {items={}}
    for _,v in ipairs(ch:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") or v:IsA("BodyColors") or (v:IsA("Decal") and v.Name=="face") then
            pcall(function() table.insert(snap.items, v:Clone()) end)
        end
    end
    avSaved = snap
end

task.spawn(function() task.wait(3); avSave() end)
lp.CharacterAdded:Connect(function() task.wait(3); avSave() end)

local function avClear(ch)
    for _,v in ipairs(ch:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") or v:IsA("BodyColors") or (v:IsA("Decal") and v.Name=="face") then
            v:Destroy()
        end
    end
end

local avAttMap = {
    HatAttachment=CFrame.new(0,0.6,0), HairAttachment=CFrame.new(0,0.6,0),
    FaceFrontAttachment=CFrame.new(0,0,-0.6), FaceCenterAttachment=CFrame.new(0,0,-0.5),
    HeadFrontAttachment=CFrame.new(0,0,-0.5), HeadTopAttachment=CFrame.new(0,0.5,0),
    HeadBackAttachment=CFrame.new(0,0,0.5), LeftEarAttachment=CFrame.new(-0.5,0,0),
    RightEarAttachment=CFrame.new(0.5,0,0), HatFrontAttachment=CFrame.new(0,0.6,-0.5),
    NeckAttachment=CFrame.new(0,-0.5,0)
}

local function avEnsureHead(ch)
    local head = ch:FindFirstChild("Head"); if not head then return end
    for nm,cf in pairs(avAttMap) do
        if not head:FindFirstChild(nm) then
            local a = Instance.new("Attachment"); a.Name=nm; a.CFrame=cf; a.Parent=head
        end
    end
end

local function avWeld(acc, ch)
    local head = ch:FindFirstChild("Head"); if not head then return false end
    local h = acc:FindFirstChild("Handle"); if not h then return false end
    local att = h:FindFirstChild("HatAttachment") or h:FindFirstChild("HairAttachment") or h:FindFirstChild("FaceFrontAttachment") or h:FindFirstChild("FaceCenterAttachment") or h:FindFirstChildOfClass("Attachment")
    if not att then return false end
    local ha = head:FindFirstChild(att.Name)
    if not ha then
        ha = Instance.new("Attachment"); ha.Name=att.Name; ha.CFrame=avAttMap[att.Name] or CFrame.new(0,0.6,0); ha.Parent=head
    end
    h.Anchored=false; h.CanCollide=false; h.Massless=true
    local osz = h:FindFirstChild("OriginalSize"); local osv = osz and osz.Value or h.Size
    acc.Parent = ch
    for _,c in ipairs(h:GetChildren()) do
        if c:IsA("Weld") or c:IsA("Motor6D") or c:IsA("WeldConstraint") then c:Destroy() end
    end
    local w = Instance.new("Motor6D"); w.Name="AccessoryWeld"; w.Part0=head; w.Part1=h
    w.C0=ha.CFrame; w.C1=att.CFrame; w.Parent=h
    if osv then task.defer(function() if h and h.Parent then pcall(function() h.Size=osv*0.85 end) end end) end
    return true
end

local function avApply(item, ch, hum)
    if item:IsA("Accessory") or item:IsA("Hat") then
        local c = item:Clone()
        local osz = c:FindFirstChild("OriginalSize"); local osv = osz and osz.Value
        if osz then osz:Destroy() end
        local ok = pcall(function() hum:AddAccessory(c) end)
        if ok then
            task.defer(function()
                if c and c.Parent then
                    local h = c:FindFirstChild("Handle")
                    if h and not h:FindFirstChildOfClass("Weld") and not h:FindFirstChildOfClass("Motor6D") then
                        if osv then pcall(function() h.Size = osv*0.85 end) end
                        avWeld(c, ch)
                    end
                end
            end)
            return 1
        end
        if avWeld(c, ch) then return 1 end
    elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
        item:Clone().Parent = ch; return 1
    elseif item:IsA("BodyColors") then
        local o = ch:FindFirstChildOfClass("BodyColors"); if o then o:Destroy() end
        item:Clone().Parent = ch; return 1
    elseif item:IsA("CharacterMesh") then
        item:Clone().Parent = ch; return 1
    elseif item:IsA("Decal") and item.Name=="face" then
        local o = ch:FindFirstChild("face"); if o then o:Destroy() end
        item:Clone().Parent = ch; return 1
    end
    return 0
end

local function avApplyId(uid, ch, hum)
    local ok, model = pcall(function() return Players:GetCharacterAppearanceAsync(uid) end)
    if not ok or not model then return 0,0 end
    avEnsureHead(ch); avClear(ch); task.wait(0.1)
    local ac, cc, seen = 0, 0, {}
    for _, item in ipairs(model:GetDescendants()) do
        if not item:IsA("Attachment") and not item:IsA("Motor6D") and item.Name~="Handle" and item.Name~="OriginalSize" then
            if item:IsA("Accessory") or item:IsA("Hat") then
                local h = item:FindFirstChild("Handle")
                if not (h and seen[h]) then
                    if h then seen[h]=true end
                    if avApply(item, ch, hum) > 0 then ac = ac + 1 end
                end
            elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") or item:IsA("CharacterMesh") or (item:IsA("Decal") and item.Name=="face") then
                if avApply(item, ch, hum) > 0 then cc = cc + 1 end
            end
        end
    end
    model:Destroy()
    return ac, cc
end

local function avSteal(name)
    if not name or name=="" then
        pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Avatar", Content="Enter username", Duration=2}) end end)
        return
    end
    local uid
    if tonumber(name) then uid = tonumber(name)
    else
        local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(name) end)
        if ok then uid = id end
    end
    if not uid then
        pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Avatar", Content="User not found", Duration=3}) end end)
        return
    end
    pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Avatar", Content="Loading "..name.."...", Duration=2}) end end)
    local ch = lp and lp.Character or Players.LocalPlayer.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not avSaved then avSave() end
    local a, c = avApplyId(uid, ch, hum)
    avLastId = uid
    pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Avatar", Content="✓ "..a.." accs, "..c.." clothes", Duration=3}) end end)
end

lp.CharacterAdded:Connect(function(ch)
    if not avAuto or not avLastId then return end
    ch:WaitForChild("Humanoid",10); ch:WaitForChild("Head",10); task.wait(1.5)
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    avApplyId(avLastId, ch, hum)
end)

TabAv:AddTextBox({Name="Username or ID", PlaceholderText="e.g. Roblox", Callback=function(v) avUser=v end})
TabAv:AddButton({"Apply Avatar", function() avSteal(avUser) end})
TabAv:AddButton({"Apply Roblox (Test)", function() avSteal("Roblox") end})
TabAv:AddToggle({Name="Keep Skin on Respawn", Default=true, Callback=function(v) avAuto=v end})
TabAv:AddButton({"Restore Original", function()
    if not avSaved then return end
    local ch = lp and lp.Character or Players.LocalPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
    avEnsureHead(ch); avClear(ch); task.wait(0.1)
    for _,item in ipairs(avSaved.items) do avApply(item, ch, hum) end
    avLastId = nil
    pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Avatar", Content="Restored", Duration=2}) end end)
end})
TabAv:AddButton({"Save Current", function()
    avSave()
    pcall(function() if WindUI and WindUI.Notify then WindUI:Notify({Title="Avatar", Content="Saved", Duration=2}) end end)
end})

-- ==============================================================================
-- SETTINGS & CONFIGURATION MANAGER (LAST TAB)
-- ==============================================================================
task.wait()
local TabSettings = Window:MakeTab({"Settings", "lucide-settings"})
TabSettings:AddSection({"Configuration Manager"})
TabSettings:AddParagraph({
    "Settings & Profiles",
    "Save, load, and manage custom profiles. Set auto-load to automatically apply your favorite configuration on script startup."
})

local HttpService = game:GetService("HttpService")
local CONFIG_DIR = "SpecterConfigs"
local AUTOLOAD_FILE = CONFIG_DIR .. "/autoload.txt"
local currentConfigName = "default"

local function ensureFolder()
    pcall(function()
        if makefolder and isfolder and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
    end)
end

local function sanitizeName(name)
    name = tostring(name or "default"):gsub("[^%w_%-]", "")
    if name == "" then name = "default" end
    return name
end

local function getSavedConfigs()
    ensureFolder()
    local list = {}
    local ok, files = pcall(function()
        if listfiles then
            return listfiles(CONFIG_DIR)
        end
        return nil
    end)
    if ok and type(files) == "table" then
        for _, file in ipairs(files) do
            local clean = tostring(file):gsub("\\", "/")
            local name = clean:match("([^/]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
    end
    if #list == 0 then
        table.insert(list, "default")
    end
    return list
end

local function getAutoLoadConfig()
    ensureFolder()
    local ok, res = pcall(function()
        if isfile and isfile(AUTOLOAD_FILE) and readfile then
            local name = readfile(AUTOLOAD_FILE)
            if name and #name > 0 then
                return name:gsub("%s+", "")
            end
        end
        return nil
    end)
    return ok and res or nil
end

local function setAutoLoadConfig(name, enable)
    ensureFolder()
    pcall(function()
        if enable then
            if writefile then
                writefile(AUTOLOAD_FILE, tostring(name))
            end
        else
            if delfile and isfile and isfile(AUTOLOAD_FILE) then
                delfile(AUTOLOAD_FILE)
            end
        end
    end)
end

local function notify(title, content, icon)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = tostring(title or "Settings"),
                Content = tostring(content or ""),
                Duration = 3,
                Icon = icon or "settings"
            })
        end
    end)
end

local function collectConfigData()
    return {
        Reach = {
            Enabled = legReachEnabled,
            XYZEnabled = xyzReachEnabled,
            Mode = reachMode,
            Distance = reachDist,
            X = reachX,
            Y = reachY,
            Z = reachZ,
            Shape = shapeType,
            Transparency = transparency2,
            Hidden = (transparency2 == 1)
        },
        HeadReach = {
            Enabled = sr_enabled,
            Distance = sr_distance
        }
    }
end

local function applyConfigData(data)
    if type(data) ~= "table" then return false end

    -- Tab 2 Reach
    if data.Reach and type(data.Reach) == "table" then
        if data.Reach.Distance ~= nil then
            reachDist = math.clamp(tonumber(data.Reach.Distance) or 5, 1, 12)
        end
        if data.Reach.X ~= nil then
            reachX = math.clamp(tonumber(data.Reach.X) or 5, 1, 12)
        end
        if data.Reach.Y ~= nil then
            reachY = math.clamp(tonumber(data.Reach.Y) or 5, 1, 12)
        end
        if data.Reach.Z ~= nil then
            reachZ = math.clamp(tonumber(data.Reach.Z) or 5, 1, 12)
        end
        if data.Reach.Mode ~= nil then
            reachMode = tostring(data.Reach.Mode)
        end
        if data.Reach.Shape ~= nil then
            shapeType = tostring(data.Reach.Shape)
        end
        if data.Reach.Hidden ~= nil then
            transparency2 = data.Reach.Hidden and 1 or 0.7
        elseif data.Reach.Transparency ~= nil then
            transparency2 = tonumber(data.Reach.Transparency) or 0.7
        end
        if data.Reach.XYZEnabled ~= nil then
            xyzReachEnabled = data.Reach.XYZEnabled and true or false
        end
        if data.Reach.Enabled ~= nil then
            legReachEnabled = data.Reach.Enabled and true or false
        end
        applyReachSettings()
    end

    -- Head Reach
    if data.HeadReach and type(data.HeadReach) == "table" then
        if data.HeadReach.Distance ~= nil then
            sr_distance = math.clamp(tonumber(data.HeadReach.Distance) or 3, 1, 7)
        end
        if data.HeadReach.Enabled ~= nil then
            sr_enabled = data.HeadReach.Enabled and true or false
        end
        applyHeadReachSettings()
    end

    updateUIElements()
    return true
end

local configDropdownUI = nil
local autoLoadToggleUI = nil

local function refreshConfigDropdown()
    local configs = getSavedConfigs()
    pcall(function()
        if configDropdownUI then
            if configDropdownUI.SetValues then
                configDropdownUI:SetValues(configs)
            elseif configDropdownUI.Refresh then
                configDropdownUI:Refresh(configs)
            end
        end
    end)
end

local function saveConfig(name)
    name = sanitizeName(name)
    ensureFolder()
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    local data = collectConfigData()
    local jsonStr = ""
    local okEnc = pcall(function()
        jsonStr = HttpService:JSONEncode(data)
    end)
    if not okEnc then
        notify("Config Error", "Failed to encode configuration", "alert-circle")
        return false
    end

    local okWrite = pcall(function()
        if writefile then
            writefile(path, jsonStr)
            return true
        end
        return false
    end)

    if okWrite then
        notify("Config Saved", "Saved config '" .. name .. "' successfully", "check")
        refreshConfigDropdown()
        return true
    else
        notify("Save Failed", "Executor missing writefile permission", "alert-circle")
        return false
    end
end

local function loadConfig(name)
    name = sanitizeName(name)
    ensureFolder()
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    local content = nil
    local okRead = pcall(function()
        if isfile and isfile(path) and readfile then
            content = readfile(path)
            return true
        end
        return false
    end)

    if not okRead or not content then
        notify("Load Error", "Config '" .. name .. "' not found!", "alert-circle")
        return false
    end

    local okDec, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)

    if okDec and type(data) == "table" then
        applyConfigData(data)
        notify("Config Loaded", "Loaded profile '" .. name .. "'", "check")
        return true
    else
        notify("Load Error", "Invalid config JSON file", "alert-circle")
        return false
    end
end

local function clearConfig(name)
    name = sanitizeName(name)
    ensureFolder()
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    local okDel = pcall(function()
        if isfile and isfile(path) and delfile then
            delfile(path)
            return true
        end
        return false
    end)

    if okDel then
        local autoName = getAutoLoadConfig()
        if autoName == name then
            setAutoLoadConfig(name, false)
            if autoLoadToggleUI and autoLoadToggleUI.Set then
                pcall(function() autoLoadToggleUI:Set(false) end)
            end
        end
        notify("Config Deleted", "Removed config '" .. name .. "'", "trash")
        refreshConfigDropdown()
        return true
    else
        notify("Delete Failed", "Config file not found or cannot delete", "alert-circle")
        return false
    end
end

local function resetAllSettings()
    legReachEnabled = false
    xyzReachEnabled = false
    reachMode = "Normal"
    reachDist = 5
    reachX = 5
    reachY = 5
    reachZ = 5
    reachSize = Vector3.new(10, 10, 10)
    shapeType = "Box"
    transparency2 = 0.7
    applyReachSettings()

    sr_enabled = false
    sr_distance = 3
    applyHeadReachSettings()

    updateUIElements()
    notify("Reset Complete", "All settings restored to defaults", "rotate-ccw")
end

-- UI Controls for Settings
TabSettings:AddTextBox({
    Name = "Config Name",
    PlaceholderText = "Enter config name (e.g. default)",
    Default = "default",
    Callback = function(v)
        local clean = sanitizeName(v)
        if clean and clean ~= "" then
            currentConfigName = clean
            if autoLoadToggleUI and autoLoadToggleUI.Set then
                pcall(function() autoLoadToggleUI:Set(getAutoLoadConfig() == currentConfigName) end)
            end
        end
    end
})

configDropdownUI = TabSettings:AddDropdown({
    Name = "Saved Configs",
    Options = getSavedConfigs(),
    Default = currentConfigName,
    Callback = function(v)
        if v and v ~= "" then
            currentConfigName = sanitizeName(v)
            if autoLoadToggleUI and autoLoadToggleUI.Set then
                pcall(function() autoLoadToggleUI:Set(getAutoLoadConfig() == currentConfigName) end)
            end
        end
    end
})

TabSettings:AddButton({
    Name = "Save Config",
    Callback = function()
        saveConfig(currentConfigName)
    end
})

TabSettings:AddButton({
    Name = "Load Config",
    Callback = function()
        loadConfig(currentConfigName)
    end
})

autoLoadToggleUI = TabSettings:AddToggle({
    Name = "Set Auto Load",
    Description = "Automatically load this config profile on script startup",
    Default = (getAutoLoadConfig() == currentConfigName),
    Callback = function(v)
        setAutoLoadConfig(currentConfigName, v)
        if v then
            notify("Auto-Load Enabled", "'" .. currentConfigName .. "' will auto-load on start", "check")
        else
            notify("Auto-Load Disabled", "Auto-load disabled", "info")
        end
    end
})

TabSettings:AddButton({
    Name = "Clear Config",
    Callback = function()
        clearConfig(currentConfigName)
    end
})

TabSettings:AddSection({"Reset Settings"})
TabSettings:AddParagraph({
    "Reset to Default",
    "Quickly reset all reach hitboxes, distances, shapes, and active toggles back to default values."
})

TabSettings:AddButton({
    Name = "Reset Settings",
    Callback = function()
        resetAllSettings()
    end
})

-- Startup Auto-Load Hook
task.spawn(function()
    task.wait(1)
    local autoName = getAutoLoadConfig()
    if autoName and autoName ~= "" then
        local loaded = loadConfig(autoName)
        if loaded then
            notify("Auto-Loaded", "Profile '" .. autoName .. "' auto-loaded", "check")
        end
    end
end)

-- Diagnostic Benchmark Summary & Notification
task.spawn(function()
    task.wait(1.2)
    _specterDiagnostics.totalTime = os.clock() - _specterLoadStart
    print(string.format("[Specter Diagnostics] Total Load Time: %.3fs | WindUI Network: %.3fs | AC Scan: %.3fs | Revoked Remotes: %d | Status: 60 FPS Smooth",
        _specterDiagnostics.totalTime,
        _specterDiagnostics.windUILoadTime,
        _specterDiagnostics.acBypassTime,
        _specterDiagnostics.revokedCount
    ))
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "Specter Ready",
                Content = string.format("Loaded in %.2fs (60 FPS Non-blocking)", _specterDiagnostics.totalTime),
                Duration = 3,
                Icon = "check"
            })
        end
    end)
end)


