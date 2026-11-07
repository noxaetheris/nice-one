local punishgoatby97mzu = {
	Instances = {},
	ThemeChangedHooks = {},
	VisualConnections = {},
	CurrentTheme = "cezar",
	-- Fully monochrome palettes (black & white only, no hue).
	Themes = {
		cezar = { -- pure black
			MainBg = Color3.fromRGB(0, 0, 0),
			Stroke = Color3.fromRGB(58, 58, 58),
			Accent = Color3.fromRGB(255, 255, 255),
			Accentpunish = Color3.fromRGB(210, 210, 210),
			Text = Color3.fromRGB(255, 255, 255),
			TextInactive = Color3.fromRGB(150, 150, 150),
			ToggleBgOff = Color3.fromRGB(38, 38, 38),
			ToggleBtnBg = Color3.fromRGB(18, 18, 18),
			ToggleDot = Color3.fromRGB(255, 255, 255),
			SectionTitle = Color3.fromRGB(235, 235, 235),
		},
		Graphite = {
			MainBg = Color3.fromRGB(16, 16, 16),
			Stroke = Color3.fromRGB(72, 72, 72),
			Accent = Color3.fromRGB(240, 240, 240),
			Accentpunish = Color3.fromRGB(195, 195, 195),
			Text = Color3.fromRGB(248, 248, 248),
			TextInactive = Color3.fromRGB(160, 160, 160),
			ToggleBgOff = Color3.fromRGB(52, 52, 52),
			ToggleBtnBg = Color3.fromRGB(28, 28, 28),
			ToggleDot = Color3.fromRGB(255, 255, 255),
			SectionTitle = Color3.fromRGB(225, 225, 225),
		},
		Contrast = {
			MainBg = Color3.fromRGB(0, 0, 0),
			Stroke = Color3.fromRGB(255, 255, 255),
			Accent = Color3.fromRGB(255, 255, 255),
			Accentpunish = Color3.fromRGB(255, 255, 255),
			Text = Color3.fromRGB(255, 255, 255),
			TextInactive = Color3.fromRGB(185, 185, 185),
			ToggleBgOff = Color3.fromRGB(30, 30, 30),
			ToggleBtnBg = Color3.fromRGB(0, 0, 0),
			ToggleDot = Color3.fromRGB(255, 255, 255),
			SectionTitle = Color3.fromRGB(255, 255, 255),
		},
		Paper = { -- light monochrome
			MainBg = Color3.fromRGB(245, 245, 245),
			Stroke = Color3.fromRGB(190, 190, 190),
			Accent = Color3.fromRGB(20, 20, 20),
			Accentpunish = Color3.fromRGB(70, 70, 70),
			Text = Color3.fromRGB(15, 15, 15),
			TextInactive = Color3.fromRGB(110, 110, 110),
			ToggleBgOff = Color3.fromRGB(210, 210, 210),
			ToggleBtnBg = Color3.fromRGB(230, 230, 230),
			ToggleDot = Color3.fromRGB(255, 255, 255),
			SectionTitle = Color3.fromRGB(30, 30, 30),
		},
	},
}
 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Accepts any Roblox asset reference: 12345, "12345", "rbxassetid://12345",
-- "rbxthumb://..." / "http(s)://..." URLs, or an already-built image string.
function punishgoatby97mzu:ResolveAsset(Asset)
	if Asset == nil or Asset == "" then
		return ""
	end
	if typeof(Asset) == "number" then
		return "rbxassetid://" .. tostring(math.floor(Asset))
	end
	local str = tostring(Asset)
	if str:match("^%d+$") then
		return "rbxassetid://" .. str
	end
	return str
end

-- Pool of Roblox decal/image assets. Every tab pulls one of these at random on
-- each execution and shows it as a badge next to the tab name.
punishgoatby97mzu.AssetPool = {
	9596344302,
	6955134006,
	83867600773185,
	130043073827131,
	72164665440799,
	94849782041283,
	4953666740,
	7061193672,
	15710160835,
	15325715933,
	7052240858,
}

local assetRng = Random.new(tick() * 1000)
function punishgoatby97mzu:RandomAsset()
	local pool = punishgoatby97mzu.AssetPool
	if #pool == 0 then
		return ""
	end
	return punishgoatby97mzu:ResolveAsset(pool[assetRng:NextInteger(1, #pool)])
end

-- ============================================================
-- 2D DECAL SUPPORT (rbxasset / rbxassetid / decal ids)
-- Roblox ImageLabels only accept *Image* assets. A raw Decal id
-- has to be unwrapped first, so it is fetched once and cached.
-- ============================================================
punishgoatby97mzu.DecalCache = {}

function punishgoatby97mzu:ResolveDecalSync(Asset)
	local base = punishgoatby97mzu:ResolveAsset(Asset)
	if base == "" then
		return ""
	end
	if punishgoatby97mzu.DecalCache[base] then
		return punishgoatby97mzu.DecalCache[base]
	end
	-- rbxasset:// (local content), rbxthumb://, http(s):// are already 2D textures
	if not base:match("^rbxassetid://%d+$") then
		punishgoatby97mzu.DecalCache[base] = base
		return base
	end
	local ok, objects = pcall(function()
		return game:GetObjects(base)
	end)
	if ok and typeof(objects) == "table" and objects[1] then
		local inst = objects[1]
		local texture = (inst:IsA("Decal") or inst:IsA("Texture")) and inst.Texture
			or (inst:IsA("ImageLabel") and inst.Image)
			or nil
		if texture and texture ~= "" then
			punishgoatby97mzu.DecalCache[base] = texture
			return texture
		end
	end
	punishgoatby97mzu.DecalCache[base] = base
	return base
end

-- Assigns any decal/image reference to an ImageLabel without ever freezing
-- the UI thread: the direct id shows instantly, the unwrapped decal replaces
-- it as soon as the fetch resolves.
function punishgoatby97mzu:ApplyDecal(ImageInst, Asset)
	if not ImageInst then
		return
	end
	local base = punishgoatby97mzu:ResolveAsset(Asset)
	ImageInst.Image = base
	if base == "" or not base:match("^rbxassetid://%d+$") then
		return
	end
	task.spawn(function()
		local resolved = punishgoatby97mzu:ResolveDecalSync(base)
		if ImageInst.Parent and resolved ~= base then
			ImageInst.Image = resolved
		end
		pcall(function()
			game:GetService("ContentProvider"):PreloadAsync({ ImageInst })
		end)
	end)
end

-- Feathers an image on every side AND every corner.
-- A single UIGradient can only fade along one axis, which is why the decals
-- still looked like squares. Here we nest two CanvasGroups: the outer one
-- fades left/right, the inner one fades top/bottom. Each CanvasGroup renders
-- its children to its own texture, so the two alpha ramps multiply and the
-- result is a soft round vignette that keeps the artwork fully visible in the
-- middle while dissolving into the panel at the edges and corners.
--   hoist = true  -> the wrapper inherits the image's Name/Visible so any
--                    existing Main:FindFirstChild(name) lookups keep working.
function punishgoatby97mzu:AddEdgeFade(ImageInst, Feather, hoist)
	if not ImageInst then
		return
	end
	local parent = ImageInst.Parent
	if not parent then
		return
	end
	if parent:IsA("CanvasGroup") and parent.Name:sub(1, 8) == "EdgeFade" then
		return parent.Parent
	end

	local feather = math.clamp(Feather or 0.38, 0.06, 0.48)
	local function ramp(rotation)
		local g = Instance.new("UIGradient")
		g.Rotation = rotation
		g.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(feather * 0.35, 0.72),
			NumberSequenceKeypoint.new(feather * 0.7, 0.26),
			NumberSequenceKeypoint.new(feather, 0),
			NumberSequenceKeypoint.new(1 - feather, 0),
			NumberSequenceKeypoint.new(1 - feather * 0.7, 0.26),
			NumberSequenceKeypoint.new(1 - feather * 0.35, 0.72),
			NumberSequenceKeypoint.new(1, 1),
		})
		return g
	end

	local outer = Instance.new("CanvasGroup")
	outer.Name = hoist and ImageInst.Name or ("EdgeFadeX_" .. ImageInst.Name)
	outer.BackgroundTransparency = 1
	outer.BorderSizePixel = 0
	outer.AnchorPoint = ImageInst.AnchorPoint
	outer.Position = ImageInst.Position
	outer.Size = ImageInst.Size
	outer.ZIndex = ImageInst.ZIndex
	outer.LayoutOrder = ImageInst.LayoutOrder
	if hoist then
		outer.Visible = ImageInst.Visible
	end
	ramp(0).Parent = outer

	local inner = Instance.new("CanvasGroup", outer)
	inner.Name = "EdgeFadeY"
	inner.BackgroundTransparency = 1
	inner.BorderSizePixel = 0
	inner.Size = UDim2.new(1, 0, 1, 0)
	ramp(90).Parent = inner

	if hoist then
		ImageInst.Name = ImageInst.Name .. "Image"
		ImageInst.Visible = true
	end
	ImageInst.AnchorPoint = Vector2.new(0, 0)
	ImageInst.Position = UDim2.new(0, 0, 0, 0)
	ImageInst.Size = UDim2.new(1, 0, 1, 0)
	ImageInst.Parent = inner
	outer.Parent = parent
	return outer
end

-- Vivid per-tab colours. These stay constant across the monochrome themes so
-- the rail always reads as colourful.
punishgoatby97mzu.TabPalette = {
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(232, 232, 232),
	Color3.fromRGB(210, 210, 210),
	Color3.fromRGB(188, 188, 188),
	Color3.fromRGB(245, 245, 245),
	Color3.fromRGB(200, 200, 200),
	Color3.fromRGB(222, 222, 222),
	Color3.fromRGB(170, 170, 170),
}
punishgoatby97mzu.ColorfulTabs = false
punishgoatby97mzu.DecalsEnabled = true
punishgoatby97mzu.DecalShuffle = true
punishgoatby97mzu.NotificationsEnabled = true

function punishgoatby97mzu:TabColor(index)
	local pool = punishgoatby97mzu.TabPalette
	return pool[((index - 1) % #pool) + 1]
end

-- ============================================================
-- ENVIRONMENT PROBE (executor / fps / ping / friends / player)
-- ============================================================
local RunService = game:GetService("RunService")
local Stats = game:FindService("Stats")

punishgoatby97mzu.Live = { FPS = 60, Ping = 0, FriendsInServer = 0, FriendsOnline = 0, FriendsOffline = 0, FriendsTotal = 0, Players = 0 }

function punishgoatby97mzu:GetExecutor()
	local name, version
	if identifyexecutor then
		local ok, a, b = pcall(identifyexecutor)
		if ok then
			name, version = a, b
		end
	end
	if not name and getexecutorname then
		local ok, a = pcall(getexecutorname)
		if ok then
			name = a
		end
	end
	if not name then
		name = (syn and "Synapse")
			or (KRNL_LOADED and "Krnl")
			or (fluxus and "Fluxus")
			or (is_sirhurt_closure and "SirHurt")
			or (secure_load and "Sentinel")
			or (getgenv and "Unknown Executor")
			or "Roblox Studio"
	end
	local level = "Unknown"
	if getgenv and hookfunction and getrawmetatable then
		level = "Full"
	elseif getgenv then
		level = "Partial"
	end
	return tostring(name), (version and tostring(version) or ""), level
end

function punishgoatby97mzu:CountFriends()
	local inServer, online, total = 0, 0, 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local ok, isFriend = pcall(function()
				return LocalPlayer:IsFriendsWith(plr.UserId)
			end)
			if ok and isFriend then
				inServer = inServer + 1
			end
		end
	end
	local ok, pages = pcall(function()
		return Players:GetFriendsAsync(LocalPlayer.UserId)
	end)
	if ok and pages then
		while true do
			for _, friend in ipairs(pages:GetCurrentPage()) do
				total = total + 1
				if friend.IsOnline then
					online = online + 1
				end
			end
			if pages.IsFinished then
				break
			end
			local advanced = pcall(function()
				pages:AdvanceToNextPageAsync()
			end)
			if not advanced then
				break
			end
		end
	end
	return inServer, online, math.max(total - online, 0), total
end

-- Single shared heartbeat: every HUD element reads from punishgoatby97mzu.Live.
task.spawn(function()
	local frames, clock = 0, os.clock()
	RunService.RenderStepped:Connect(function()
		frames = frames + 1
		if os.clock() - clock >= 0.5 then
			punishgoatby97mzu.Live.FPS = math.floor(frames / (os.clock() - clock) + 0.5)
			frames, clock = 0, os.clock()
		end
	end)
	while true do
		local ping = 0
		if Stats then
			local ok, value = pcall(function()
				return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			if ok then
				ping = value
			end
		end
		if ping == 0 then
			local ok, value = pcall(function()
				return LocalPlayer:GetNetworkPing() * 1000
			end)
			if ok then
				ping = value
			end
		end
		punishgoatby97mzu.Live.Ping = math.floor(ping + 0.5)
		punishgoatby97mzu.Live.Players = #Players:GetPlayers()
		task.wait(1)
	end
end)

task.spawn(function()
	while true do
		local inServer, online, offline, total = punishgoatby97mzu:CountFriends()
		punishgoatby97mzu.Live.FriendsInServer = inServer
		punishgoatby97mzu.Live.FriendsOnline = online
		punishgoatby97mzu.Live.FriendsOffline = offline
		punishgoatby97mzu.Live.FriendsTotal = total
		task.wait(20)
	end
end)
 

 
function punishgoatby97mzu:ApplyThemeObj(Inst, Prop, ThemeType)
	table.insert(self.Instances, { Inst = Inst, Prop = Prop, Type = ThemeType })
	local palette = self.Themes[self.CurrentTheme]
	Inst[Prop] = palette[ThemeType]
	return Inst
end
 
function punishgoatby97mzu:ChangeTheme(ThemeName)
	local palette = self.Themes[ThemeName]
	if not palette then
		return false
	end
	self.CurrentTheme = ThemeName
	for _, obj in pairs(self.Instances) do
		if obj.Inst and obj.Inst.Parent then
			TweenService:Create(obj.Inst, TweenInfo.new(0.3), { [obj.Prop] = palette[obj.Type] }):Play()
		end
	end
 
	for _, hook in pairs(self.ThemeChangedHooks) do
		if hook.Inst and hook.Inst.Parent then
			hook.Func(ThemeName)
		end
	end
	return true
end
 
local NotifUI = Instance.new("ScreenGui")
NotifUI.Name = "cezarNotifUI"
NotifUI.ResetOnSpawn = false
NotifUI.IgnoreGuiInset = true
-- Set the highest DisplayOrder so notification cards never get covered by the game's HUD
NotifUI.DisplayOrder = 99999
NotifUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
 
local NotifContainer = Instance.new("Frame", NotifUI)
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 260, 1, -20)
NotifContainer.Position = UDim2.new(1, -20, 0, 10)
NotifContainer.AnchorPoint = Vector2.new(1, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 1000
 
local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)
 
-- Hard cap so a fast-dragged slider can never stack dozens of cards.
local MAX_NOTIFS = 3

function punishgoatby97mzu:Notify(Data)
	if not punishgoatby97mzu.NotificationsEnabled then
		return
	end
	local TitleStr = Data.Title or "Notification"
	local ContentStr = Data.Content or "Description here"
	local Duration = Data.Duration or 3

	local live = {}
	for _, child in ipairs(NotifContainer:GetChildren()) do
		if child:IsA("Frame") then
			table.insert(live, child)
		end
	end
	for i = 1, #live - (MAX_NOTIFS - 1) do
		live[i]:Destroy()
	end

	local NCard = Instance.new("Frame", NotifContainer)
	NCard.Size = UDim2.new(1, 0, 0, 60)
	NCard.Position = UDim2.new(1, 300, 0, 0)
	NCard.BackgroundTransparency = 0.15
	NCard.ClipsDescendants = true
	NCard.ZIndex = 1001
	Instance.new("UICorner", NCard).CornerRadius = UDim.new(0, 8)
	punishgoatby97mzu:ApplyThemeObj(NCard, "BackgroundColor3", "ToggleBtnBg")
 
	local NStroke = Instance.new("UIStroke", NCard)
	NStroke.Thickness = 1
	NStroke.Transparency = 0.5
	punishgoatby97mzu:ApplyThemeObj(NStroke, "Color", "Stroke")
 
	local NIcon = Instance.new("ImageLabel", NCard)
	NIcon.Size = UDim2.new(0, 24, 0, 24)
	NIcon.Position = UDim2.new(0, 15, 0.5, -12)
	NIcon.BackgroundTransparency = 1
	NIcon.Image = "rbxassetid://10709771426"
	NIcon.ZIndex = 1002
	punishgoatby97mzu:ApplyThemeObj(NIcon, "ImageColor3", "Accent")
 
	local NTitle = Instance.new("TextLabel", NCard)
	NTitle.Size = UDim2.new(1, -55, 0, 18)
	NTitle.Position = UDim2.new(0, 50, 0, 10)
	NTitle.BackgroundTransparency = 1
	NTitle.Text = TitleStr
	NTitle.Font = Enum.Font.GothamBold
	NTitle.TextSize = 13
	NTitle.TextXAlignment = Enum.TextXAlignment.Left
	NTitle.ZIndex = 1002
	punishgoatby97mzu:ApplyThemeObj(NTitle, "TextColor3", "Text")
 
	local NDesc = Instance.new("TextLabel", NCard)
	NDesc.Size = UDim2.new(1, -55, 1, -30)
	NDesc.Position = UDim2.new(0, 50, 0, 28)
	NDesc.BackgroundTransparency = 1
	NDesc.Text = ContentStr
	NDesc.Font = Enum.Font.Gotham
	NDesc.TextSize = 11
	NDesc.TextWrapped = true
	NDesc.TextYAlignment = Enum.TextYAlignment.Top
	NDesc.TextXAlignment = Enum.TextXAlignment.Left
	NDesc.ZIndex = 1002
	punishgoatby97mzu:ApplyThemeObj(NDesc, "TextColor3", "TextInactive")
 
	local NBarBg = Instance.new("Frame", NCard)
	NBarBg.Size = UDim2.new(1, 0, 0, 3)
	NBarBg.Position = UDim2.new(0, 0, 1, -3)
	NBarBg.BorderSizePixel = 0
	NBarBg.ZIndex = 1002
	punishgoatby97mzu:ApplyThemeObj(NBarBg, "BackgroundColor3", "MainBg")
 
	local NBarFill = Instance.new("Frame", NBarBg)
	NBarFill.Size = UDim2.new(1, 0, 1, 0)
	NBarFill.BorderSizePixel = 0
	NBarFill.ZIndex = 1002
	punishgoatby97mzu:ApplyThemeObj(NBarFill, "BackgroundColor3", "Accent")
 
	TweenService:Create(
		NCard,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0, 0, 0, 0) }
	):Play()
	TweenService:Create(NBarFill, TweenInfo.new(Duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
		:Play()
 
	task.delay(Duration, function()
		local OutAnim = TweenService:Create(
			NCard,
			TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 300, 0, 0) }
		)
		OutAnim:Play()
		OutAnim.Completed:Wait()
		NCard:Destroy()
	end)
end
 
-- This is the "brain" that stores UI state for as long as the script is running
local UI_Session = {
    Pos = UDim2.new(0.5, 0, 0.5, 0), -- Default ke tengah
    Size = UDim2.new(0, 700, 0, 450), -- Default ukuran
}
local VisualConnections = {}
 function punishgoatby97mzu:CreateWindow(TitleText)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- Se já existir uma instância antiga, destrói
    local oldUI = PlayerGui:FindFirstChild("cezarUI")
    if oldUI then
        oldUI:Destroy()
    end

    local Window = { Tabs = {}, SelectCloseFuncs = {}, DropdownCloseFuncs = {}, CurrentTab = nil }
 
    local punishgoatUI = Instance.new("ScreenGui")
    punishgoatUI.Name = "cezarUI"
    punishgoatUI.ResetOnSpawn = false
    punishgoatUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    punishgoatUI.IgnoreGuiInset = true
    punishgoatUI.DisplayOrder = 99999 
    punishgoatUI.Parent = PlayerGui

    -- Glass backplate: game HUD elements remain visible underneath the UI.
    local Backplate = Instance.new("Frame")
    Backplate.Name = "CezarOverlayBackplate"
    Backplate.Size = UDim2.new(0, 556, 0, 356)
    Backplate.AnchorPoint = Vector2.new(0.5, 0)
    -- currentPos is calculated just below, so use a valid placeholder first.
    Backplate.Position = UDim2.new(0.5, 0, 0.5, 0)
    Backplate.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Backplate.BackgroundTransparency = 0.5
    Backplate.BorderSizePixel = 0
    Backplate.ZIndex = 1
    Backplate.Parent = punishgoatUI
    Instance.new("UICorner", Backplate).CornerRadius = UDim.new(0, 16)
 
    local Main = Instance.new("Frame")
    local currentSize = UDim2.new(0, 548, 0, 348)
 
    local Camera = workspace.CurrentCamera
    local Viewport = Camera and Camera.ViewportSize or Vector2.new(1000, 1000)
    local scaleX = Viewport.X / 760
    local scaleY = Viewport.Y / 420
    local initialScale = math.clamp(math.min(scaleX, scaleY, 1), 0.4, 1)
    local initialYOffset = (Viewport.Y / 2) - (348 * initialScale / 2)
    local currentPos = UDim2.new(0.5, 0, 0, initialYOffset)
    Backplate.Position = currentPos
 
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 548, 0, 348)
    Main.AnchorPoint = Vector2.new(0.5, 0) 
    Main.Position = currentPos
    Main.BackgroundTransparency = 0.08
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false -- floating tab dock lives outside the main panel
    Main.ZIndex = 10
    Main.Parent = punishgoatUI
    punishgoatby97mzu:ApplyThemeObj(Main, "BackgroundColor3", "MainBg")
    local MainGradient = Instance.new("UIGradient", Main)
    MainGradient.Rotation = 135
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 12)),
    })
    MainGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.45),
    })
    table.insert(punishgoatby97mzu.ThemeChangedHooks, {
        Inst = Main,
        Func = function(themeName)
            local palette = punishgoatby97mzu.Themes[themeName]
            MainGradient.Color = ColorSequence.new(palette.MainBg, palette.ToggleBtnBg)
        end,
    })
 
	local MainScale = Instance.new("UIScale")
	MainScale.Name = "cezarAutoScaler"
	MainScale.Parent = Main
	local BackplateScale = Instance.new("UIScale")
	BackplateScale.Name = "CezarOverlayScale"
	BackplateScale.Parent = Backplate
 
	local function ScaleUI()
            local Camera = workspace.CurrentCamera
            if not Camera then
                return
            end
            local Viewport = Camera.ViewportSize
 
local maxWidth = 548 + 210
local maxHeight = 348 + 80
 
            local scaleX = Viewport.X / maxWidth
            local scaleY = Viewport.Y / maxHeight
 
            local finalScale = math.min(scaleX, scaleY, 1)
 
            -- Clamp the minimum scale to 0.38 so it still fits on short phone screens
            local userScale = punishgoatby97mzu.UserScale or 1
            MainScale.Scale = math.clamp(finalScale, 0.38, 1) * userScale
            BackplateScale.Scale = MainScale.Scale
        end
	punishgoatby97mzu.UserScale = punishgoatby97mzu.UserScale or 1
	Window.ApplyScale = ScaleUI
 
	ScaleUI()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ScaleUI)
 
 
	local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 12)
 
    -- No outline at all: the old thick border read as an ugly grey frame.
 
	local TopBar = Instance.new("Frame", Main)
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 34)
	TopBar.BackgroundTransparency = 1
	TopBar.ZIndex = 50

    -- Full-width spectrum hairline: the only splash of colour on the shell.
    local TopAccent = Instance.new("Frame", TopBar)
    TopAccent.Name = "TopAccent"
    TopAccent.Size = UDim2.new(1, 30, 0, 2)
    TopAccent.Position = UDim2.new(0, -15, 1, -1)
    TopAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopAccent.BorderSizePixel = 0
    TopAccent.ZIndex = 52
    local TopAccentGradient = Instance.new("UIGradient", TopAccent)
    TopAccentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, punishgoatby97mzu:TabColor(1)),
        ColorSequenceKeypoint.new(0.25, punishgoatby97mzu:TabColor(3)),
        ColorSequenceKeypoint.new(0.5, punishgoatby97mzu:TabColor(4)),
        ColorSequenceKeypoint.new(0.75, punishgoatby97mzu:TabColor(5)),
        ColorSequenceKeypoint.new(1, punishgoatby97mzu:TabColor(7)),
    })
    TopAccentGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.35),
    })
    task.spawn(function()
        while TopAccent.Parent do
            TweenService:Create(TopAccentGradient, TweenInfo.new(6, Enum.EasingStyle.Linear), { Offset = Vector2.new(1, 0) }):Play()
            task.wait(6)
            TopAccentGradient.Offset = Vector2.new(-1, 0)
            TweenService:Create(TopAccentGradient, TweenInfo.new(6, Enum.EasingStyle.Linear), { Offset = Vector2.new(0, 0) }):Play()
            task.wait(6)
        end
    end)
 
	local TopBarPadding = Instance.new("UIPadding", TopBar)
	TopBarPadding.PaddingLeft = UDim.new(0, 15)
	TopBarPadding.PaddingRight = UDim.new(0, 15)
 
	local Title = Instance.new("TextLabel", TopBar)
	Title.Name = "Title"
    Title.Size = UDim2.new(0.5, 0, 0, 15)
    Title.Position = UDim2.new(0, 12, 0, 5)
	Title.BackgroundTransparency = 1
Title.Text = TitleText or "punishment hub"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.ZIndex = 51
	punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")

    local Subtitle = Instance.new("TextLabel", TopBar)
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0.45, 0, 0, 11)
    Subtitle.Position = UDim2.new(0, 12, 0, 19)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "CONTROL CENTER  •  ONLINE"
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextSize = 8
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 52
    punishgoatby97mzu:ApplyThemeObj(Subtitle, "TextColor3", "Accentpunish")

    -- Live executor / fps / ping readout in the title bar.
    task.spawn(function()
        local execName, execVersion = punishgoatby97mzu:GetExecutor()
        local label = execName .. (execVersion ~= "" and (" " .. execVersion) or "")
        while Subtitle.Parent do
            Subtitle.Text = string.format(
                "%s  •  %d FPS  •  %dms",
                string.upper(label),
                punishgoatby97mzu.Live.FPS,
                punishgoatby97mzu.Live.Ping
            )
            task.wait(1)
        end
    end)
 
	local dragging, dragInput, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	TopBar.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			Main.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			Backplate.Position = Main.Position
			currentPos = Main.Position -- 🔥 TIMPA: Simpan posisi terbaru setiap kali UI digeser
		end
	end)
 
	local ControlContainer = Instance.new("Frame", TopBar)
	ControlContainer.Name = "ControlContainer"
	ControlContainer.Size = UDim2.new(0.5, 0, 1, 0)
	ControlContainer.AnchorPoint = Vector2.new(1, 0)
	ControlContainer.Position = UDim2.new(1, 0, 0, 0)
	ControlContainer.BackgroundTransparency = 1
	ControlContainer.ZIndex = 51
 
	local ControlLayout = Instance.new("UIListLayout", ControlContainer)
	ControlLayout.FillDirection = Enum.FillDirection.Horizontal
	ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ControlLayout.Padding = UDim.new(0, 10)
	ControlLayout.SortOrder = Enum.SortOrder.LayoutOrder
 
	local MinimizeBtn = Instance.new("ImageButton", ControlContainer)
	MinimizeBtn.Size = UDim2.new(0, 18, 0, 18)
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.LayoutOrder = 2
	MinimizeBtn.Image = "rbxassetid://10734896206"
	MinimizeBtn.ZIndex = 51
	punishgoatby97mzu:ApplyThemeObj(MinimizeBtn, "ImageColor3", "Text")

 
	local CloseBtn = Instance.new("ImageButton", ControlContainer)
	CloseBtn.Size = UDim2.new(0, 18, 0, 18)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.LayoutOrder = 4
	CloseBtn.Image = "rbxassetid://10747384394"
	CloseBtn.ZIndex = 51
	punishgoatby97mzu:ApplyThemeObj(CloseBtn, "ImageColor3", "Text")
 
	local function ApplyHover(btn, hoverColor)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), { ImageColor3 = hoverColor }):Play()
		end)
		btn.MouseLeave:Connect(function()
			local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
			TweenService:Create(btn, TweenInfo.new(0.2), { ImageColor3 = palette.Text }):Play()
		end)
	end
	ApplyHover(MinimizeBtn, Color3.fromRGB(171, 171, 171))
	ApplyHover(CloseBtn, Color3.fromRGB(114, 114, 114))
 
	local ProfileCard
 
    local isMinimized = false
    local isMaximized = false
	local preMinSize = Main.Size
	local preMinPos = Main.Position
	local isMinTweening = false
 
MinimizeBtn.MouseButton1Click:Connect(function()
    if isMinTweening then return end
    isMinTweening = true
    isMinimized = not isMinimized

    if ProfileCard then
        ProfileCard.Visible = not isMinimized
    end

    -- Hide the body immediately so nothing is left floating while the frame shrinks.
    local bodyNames = { "TabDock", "ContentContainer", "ResizeGrip", "RailStatus", "RailSettingsBtn", "SettingsPanel", "DecalWatermark" }
    local body = {}
    for _, name in ipairs(bodyNames) do
        local inst = Main:FindFirstChild(name)
        if inst then
            table.insert(body, inst)
        end
    end
    if isMinimized then
        for _, inst in ipairs(body) do
            inst.Visible = false
        end
    end

    local info = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local targetHeight = isMinimized and 34 or currentSize.Y.Offset
    local targetWidth = currentSize.X.Offset

    TweenService:Create(Main, info, {
        Size = UDim2.new(currentSize.X.Scale, targetWidth, 0, targetHeight),
    }):Play()

    -- The backplate is a separate frame: shrink it too, otherwise the old glass
    -- panel stays behind the collapsed bar and looks like a hole on screen.
    TweenService:Create(Backplate, info, {
        Size = UDim2.new(0, targetWidth + 8, 0, targetHeight + 8),
    }):Play()

    task.delay(0.35, function()
        if not isMinimized then
            for _, inst in ipairs(body) do
                if inst.Name ~= "SettingsPanel" then
                    inst.Visible = true
                end
            end
        end
        isMinTweening = false
    end)
end)

 
	local ModalOverlay = Instance.new("Frame", Main)
	ModalOverlay.Size = UDim2.new(1, 0, 1, 0)
	ModalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ModalOverlay.BackgroundTransparency = 1
	ModalOverlay.Visible = false
	ModalOverlay.ZIndex = 998
 
	local ModalBox = Instance.new("Frame", ModalOverlay)
	ModalBox.Size = UDim2.new(0, 300, 0, 150)
	ModalBox.AnchorPoint = Vector2.new(0.5, 0.5)
	ModalBox.Position = UDim2.new(0.5, 0, 0.5, 20)
	ModalBox.BackgroundTransparency = 1
	ModalBox.ZIndex = 999
	Instance.new("UICorner", ModalBox).CornerRadius = UDim.new(0, 10)
	punishgoatby97mzu:ApplyThemeObj(ModalBox, "BackgroundColor3", "MainBg")
 
	local ModalStroke = Instance.new("UIStroke", ModalBox)
	ModalStroke.Thickness = 1
	ModalStroke.Transparency = 1
	punishgoatby97mzu:ApplyThemeObj(ModalStroke, "Color", "Stroke")
 
	local ModalTitle = Instance.new("TextLabel", ModalBox)
	ModalTitle.Size = UDim2.new(1, 0, 0, 40)
	ModalTitle.BackgroundTransparency = 1
ModalTitle.Text = "Exit punishment hub?"
	ModalTitle.Font = Enum.Font.GothamBold
	ModalTitle.TextSize = 16
	ModalTitle.TextTransparency = 1
	ModalTitle.ZIndex = 999
	punishgoatby97mzu:ApplyThemeObj(ModalTitle, "TextColor3", "Text")
 
	local ModalDesc = Instance.new("TextLabel", ModalBox)
	ModalDesc.Size = UDim2.new(1, -40, 0, 40)
	ModalDesc.Position = UDim2.new(0, 20, 0, 40)
	ModalDesc.BackgroundTransparency = 1
	ModalDesc.Text = "Are you sure you want to exit? You will need to re-execute the script."
	ModalDesc.TextWrapped = true
	ModalDesc.Font = Enum.Font.Gotham
	ModalDesc.TextSize = 12
	ModalDesc.TextTransparency = 1
	ModalDesc.ZIndex = 999
	punishgoatby97mzu:ApplyThemeObj(ModalDesc, "TextColor3", "TextInactive")
 
	local CancelBtn = Instance.new("TextButton", ModalBox)
	CancelBtn.Size = UDim2.new(0, 110, 0, 36)
	CancelBtn.Position = UDim2.new(0, 30, 1, -50)
	CancelBtn.Text = "Cancel"
	CancelBtn.Font = Enum.Font.GothamMedium
	CancelBtn.TextSize = 13
	CancelBtn.AutoButtonColor = false
	CancelBtn.BackgroundTransparency = 1
	CancelBtn.TextTransparency = 1
	CancelBtn.ZIndex = 999
	Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 6)
	punishgoatby97mzu:ApplyThemeObj(CancelBtn, "BackgroundColor3", "ToggleBgOff")
	punishgoatby97mzu:ApplyThemeObj(CancelBtn, "TextColor3", "Text")
 
	local ConfirmBtn = Instance.new("TextButton", ModalBox)
	ConfirmBtn.Size = UDim2.new(0, 110, 0, 36)
	ConfirmBtn.Position = UDim2.new(1, -140, 1, -50)
	ConfirmBtn.Text = "Yes, Exit"
	ConfirmBtn.Font = Enum.Font.GothamMedium
	ConfirmBtn.TextSize = 13
	ConfirmBtn.AutoButtonColor = false
	ConfirmBtn.BackgroundTransparency = 1
	ConfirmBtn.TextTransparency = 1
	ConfirmBtn.ZIndex = 999
	Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 6)
	punishgoatby97mzu:ApplyThemeObj(ConfirmBtn, "BackgroundColor3", "Accent")
	ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
 
	CloseBtn.MouseButton1Click:Connect(function()
		ModalOverlay.Visible = true
		TweenService:Create(ModalOverlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.5 }):Play()
		TweenService:Create(
			ModalBox,
			TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0 }
		):Play()
		TweenService:Create(ModalStroke, TweenInfo.new(0.3), { Transparency = 0.5 }):Play()
		TweenService:Create(ModalTitle, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		TweenService:Create(ModalDesc, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
		TweenService:Create(CancelBtn, TweenInfo.new(0.3), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
		TweenService:Create(ConfirmBtn, TweenInfo.new(0.3), { BackgroundTransparency = 0.2, TextTransparency = 0 })
			:Play()
	end)
 
	CancelBtn.MouseButton1Click:Connect(function()
		TweenService:Create(ModalOverlay, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(
			ModalBox,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{ Position = UDim2.new(0.5, 0, 0.5, 20), BackgroundTransparency = 1 }
		):Play()
		TweenService:Create(ModalStroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
		TweenService:Create(ModalTitle, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		TweenService:Create(ModalDesc, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		TweenService:Create(CancelBtn, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		TweenService:Create(ConfirmBtn, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		task.wait(0.3)
		ModalOverlay.Visible = false
	end)
 
	ConfirmBtn.MouseButton1Click:Connect(function()
		TweenService:Create(
			Main,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{ Size = UDim2.new(0, 0, 0, 0) }
		):Play()
		if FloatingBtn then
			TweenService:Create(FloatingBtn, TweenInfo.new(0.3), { Size = UDim2.new(0, 0, 0, 0) }):Play()
		end
		task.wait(0.3)
		punishgoatUI:Destroy()
	end)
 
local ResizeGrip = Instance.new("ImageButton", Main)
ResizeGrip.Name = "ResizeGrip"
ResizeGrip.Size = UDim2.new(0, 20, 0, 20)
ResizeGrip.Position = UDim2.new(1, 0, 1, 0)
ResizeGrip.AnchorPoint = Vector2.new(1, 1)
ResizeGrip.BackgroundTransparency = 1
ResizeGrip.Image = "rbxassetid://83865456239149"
ResizeGrip.ZIndex = 100
	local resizing, rDragStart, startSize
	ResizeGrip.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if isMinimized or isMaximized then
				return
			end
			resizing = true
			rDragStart = input.Position
			startSize = Main.Size
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if
			resizing
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local delta = input.Position - rDragStart
local newX = math.clamp(startSize.X.Offset + delta.X, 430, 900)
local newY = math.clamp(startSize.Y.Offset + delta.Y, 290, 640)
			Main.Size = UDim2.new(0, newX, 0, newY)
			Backplate.Size = UDim2.new(0, newX + 8, 0, newY + 8)
			currentSize = Main.Size
		end
	end)
 
	-- ============================================================
	-- FLOATING LEFT RAIL
	--   1. live status card (above the tabs)
	--   2. settings launcher
	--   3. floating tab list
	--   4. profile chip (bottom)
	-- ============================================================
	local RAIL_W = 158
	local RAIL_X = -166

	local RailStatus = Instance.new("Frame", Main)
	RailStatus.Name = "RailStatus"
	RailStatus.Size = UDim2.new(0, RAIL_W, 0, 104)
	RailStatus.Position = UDim2.new(0, RAIL_X, 0, 0)
	RailStatus.BackgroundTransparency = 0.3
	RailStatus.BorderSizePixel = 0
	RailStatus.ZIndex = 22
	Instance.new("UICorner", RailStatus).CornerRadius = UDim.new(0, 12)
	punishgoatby97mzu:ApplyThemeObj(RailStatus, "BackgroundColor3", "ToggleBtnBg")

	local StatusGlow = Instance.new("Frame", RailStatus)
	StatusGlow.Name = "Glow"
	StatusGlow.Size = UDim2.new(1, 0, 0, 3)
	StatusGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	StatusGlow.BorderSizePixel = 0
	StatusGlow.ZIndex = 24
	Instance.new("UICorner", StatusGlow).CornerRadius = UDim.new(1, 0)
	local StatusGlowGradient = Instance.new("UIGradient", StatusGlow)
	StatusGlowGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, punishgoatby97mzu:TabColor(5)),
		ColorSequenceKeypoint.new(0.5, punishgoatby97mzu:TabColor(6)),
		ColorSequenceKeypoint.new(1, punishgoatby97mzu:TabColor(8)),
	})

	local StatusAvatar = Instance.new("ImageLabel", RailStatus)
	StatusAvatar.Size = UDim2.new(0, 28, 0, 28)
	StatusAvatar.Position = UDim2.new(0, 9, 0, 11)
	StatusAvatar.BackgroundTransparency = 0.8
	StatusAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
	StatusAvatar.ZIndex = 24
	Instance.new("UICorner", StatusAvatar).CornerRadius = UDim.new(1, 0)
	punishgoatby97mzu:ApplyThemeObj(StatusAvatar, "BackgroundColor3", "ToggleBgOff")

	local StatusName = Instance.new("TextLabel", RailStatus)
	StatusName.Size = UDim2.new(1, -46, 0, 13)
	StatusName.Position = UDim2.new(0, 44, 0, 12)
	StatusName.BackgroundTransparency = 1
	StatusName.Text = LocalPlayer.DisplayName
	StatusName.Font = Enum.Font.GothamBold
	StatusName.TextSize = 12
	StatusName.TextXAlignment = Enum.TextXAlignment.Left
	StatusName.TextTruncate = Enum.TextTruncate.AtEnd
	StatusName.ZIndex = 24
	punishgoatby97mzu:ApplyThemeObj(StatusName, "TextColor3", "Text")

	local StatusUser = Instance.new("TextLabel", RailStatus)
	StatusUser.Size = UDim2.new(1, -46, 0, 11)
	StatusUser.Position = UDim2.new(0, 44, 0, 26)
	StatusUser.BackgroundTransparency = 1
	StatusUser.Text = "@" .. LocalPlayer.Name
	StatusUser.Font = Enum.Font.GothamMedium
	StatusUser.TextSize = 9
	StatusUser.TextXAlignment = Enum.TextXAlignment.Left
	StatusUser.TextTruncate = Enum.TextTruncate.AtEnd
	StatusUser.ZIndex = 24
	punishgoatby97mzu:ApplyThemeObj(StatusUser, "TextColor3", "TextInactive")

	local StatusExec = Instance.new("TextLabel", RailStatus)
	StatusExec.Size = UDim2.new(1, -18, 0, 12)
	StatusExec.Position = UDim2.new(0, 9, 0, 44)
	StatusExec.BackgroundTransparency = 1
	StatusExec.Text = "EXECUTOR • detecting..."
	StatusExec.Font = Enum.Font.GothamBold
	StatusExec.TextSize = 8
	StatusExec.TextXAlignment = Enum.TextXAlignment.Left
	StatusExec.TextTruncate = Enum.TextTruncate.AtEnd
	StatusExec.ZIndex = 24
	StatusExec.TextColor3 = punishgoatby97mzu:TabColor(4)

	-- 2 x 2 live metric chips
	local function makeChip(index, col, row, label, color)
		local chipW = (RAIL_W - 18 - 6) / 2
		local Chip = Instance.new("Frame", RailStatus)
		Chip.Size = UDim2.new(0, chipW, 0, 18)
		Chip.Position = UDim2.new(0, 9 + col * (chipW + 6), 0, 60 + row * 22)
		Chip.BackgroundColor3 = color
		Chip.BackgroundTransparency = 0.86
		Chip.BorderSizePixel = 0
		Chip.ZIndex = 24
		Instance.new("UICorner", Chip).CornerRadius = UDim.new(0, 6)

		local Key = Instance.new("TextLabel", Chip)
		Key.Size = UDim2.new(0.55, 0, 1, 0)
		Key.Position = UDim2.new(0, 6, 0, 0)
		Key.BackgroundTransparency = 1
		Key.Text = label
		Key.Font = Enum.Font.GothamBold
		Key.TextSize = 8
		Key.TextXAlignment = Enum.TextXAlignment.Left
		Key.TextColor3 = color
		Key.ZIndex = 25

		local Value = Instance.new("TextLabel", Chip)
		Value.Size = UDim2.new(0.45, -6, 1, 0)
		Value.Position = UDim2.new(0.55, 0, 0, 0)
		Value.BackgroundTransparency = 1
		Value.Text = "--"
		Value.Font = Enum.Font.GothamBold
		Value.TextSize = 9
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.ZIndex = 25
		punishgoatby97mzu:ApplyThemeObj(Value, "TextColor3", "Text")
		return Value
	end

	local ChipFPS = makeChip(1, 0, 0, "FPS", punishgoatby97mzu:TabColor(4))
	local ChipPing = makeChip(2, 1, 0, "PING", punishgoatby97mzu:TabColor(5))
	local ChipFriends = makeChip(3, 0, 1, "FRND", punishgoatby97mzu:TabColor(8))
	local ChipPlayers = makeChip(4, 1, 1, "PLRS", punishgoatby97mzu:TabColor(2))

	task.spawn(function()
		local execName, execVersion, execLevel = punishgoatby97mzu:GetExecutor()
		StatusExec.Text = string.upper(execName)
			.. (execVersion ~= "" and (" " .. execVersion) or "")
			.. "  •  "
			.. string.upper(execLevel)
		while RailStatus.Parent do
			local live = punishgoatby97mzu.Live
			ChipFPS.Text = tostring(live.FPS)
			ChipPing.Text = live.Ping .. "ms"
			ChipFriends.Text = tostring(live.Friends)
			ChipPlayers.Text = tostring(live.Players)
			task.wait(0.5)
		end
	end)

	-- Settings launcher, directly under the status card and above the tabs.
	local SettingsBtn = Instance.new("TextButton", Main)
	SettingsBtn.Name = "RailSettingsBtn"
	SettingsBtn.Size = UDim2.new(0, RAIL_W, 0, 26)
	SettingsBtn.Position = UDim2.new(0, RAIL_X, 0, 110)
	SettingsBtn.BackgroundTransparency = 0.35
	SettingsBtn.AutoButtonColor = false
	SettingsBtn.Text = ""
	SettingsBtn.ZIndex = 22
	Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 8)
	punishgoatby97mzu:ApplyThemeObj(SettingsBtn, "BackgroundColor3", "ToggleBtnBg")

	local SettingsIcon = Instance.new("ImageLabel", SettingsBtn)
	SettingsIcon.Size = UDim2.new(0, 13, 0, 13)
	SettingsIcon.Position = UDim2.new(0, 9, 0.5, -6)
	SettingsIcon.BackgroundTransparency = 1
	SettingsIcon.Image = "rbxassetid://10734950309"
	SettingsIcon.ZIndex = 23
	SettingsIcon.ImageColor3 = punishgoatby97mzu:TabColor(6)

	local SettingsText = Instance.new("TextLabel", SettingsBtn)
	SettingsText.Size = UDim2.new(1, -30, 1, 0)
	SettingsText.Position = UDim2.new(0, 28, 0, 0)
	SettingsText.BackgroundTransparency = 1
	SettingsText.Text = "Settings & keybind"
	SettingsText.Font = Enum.Font.GothamMedium
	SettingsText.TextSize = 11
	SettingsText.TextXAlignment = Enum.TextXAlignment.Left
	SettingsText.ZIndex = 23
	punishgoatby97mzu:ApplyThemeObj(SettingsText, "TextColor3", "Text")

	SettingsBtn.MouseEnter:Connect(function()
		TweenService:Create(SettingsBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
	end)
	SettingsBtn.MouseLeave:Connect(function()
		TweenService:Create(SettingsBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.35 }):Play()
	end)

	-- Floating tab dock: sits OUTSIDE the main panel and drags with it.
	local TabDock = Instance.new("Frame", Main)
	TabDock.Name = "TabDock"
	TabDock.Size = UDim2.new(0, RAIL_W, 1, -200)
	TabDock.Position = UDim2.new(0, RAIL_X, 0, 142)
	TabDock.BackgroundTransparency = 1
	TabDock.ZIndex = 20

	local Sidebar = Instance.new("ScrollingFrame", TabDock)
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(1, 0, 1, 0)
	Sidebar.Position = UDim2.new(0, 0, 0, 0)
	Sidebar.BackgroundTransparency = 1
	Sidebar.BorderSizePixel = 0
	Sidebar.ScrollBarThickness = 0
	Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
	Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
 
	local SidebarPadding = Instance.new("UIPadding", Sidebar)
	SidebarPadding.PaddingTop = UDim.new(0, 2)
	SidebarPadding.PaddingBottom = UDim.new(0, 8)
	SidebarPadding.PaddingLeft = UDim.new(0, 2)
	SidebarPadding.PaddingRight = UDim.new(0, 2)

	local SidebarHeader = Instance.new("Frame", Sidebar)
	SidebarHeader.Name = "SidebarHeader"
	SidebarHeader.Size = UDim2.new(1, 0, 0, 16)
	SidebarHeader.BackgroundTransparency = 1
	SidebarHeader.LayoutOrder = -1
	local SidebarHeaderText = Instance.new("TextLabel", SidebarHeader)
	SidebarHeaderText.Size = UDim2.new(1, 0, 1, 0)
	SidebarHeaderText.BackgroundTransparency = 1
	SidebarHeaderText.Text = " TABS"
	SidebarHeaderText.Font = Enum.Font.GothamBold
	SidebarHeaderText.TextSize = 8
	SidebarHeaderText.TextXAlignment = Enum.TextXAlignment.Left
	SidebarHeaderText.ZIndex = 5
	punishgoatby97mzu:ApplyThemeObj(SidebarHeaderText, "TextColor3", "TextInactive")
 
	local SidebarLayout = Instance.new("UIListLayout", Sidebar)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 4)
 
	ProfileCard = Instance.new("Frame", Main)
	ProfileCard.Name = "RailProfile"
	ProfileCard.Size = UDim2.new(0, RAIL_W, 0, 40)
	ProfileCard.Position = UDim2.new(0, RAIL_X, 1, -46)
	ProfileCard.BackgroundTransparency = 0.35
	ProfileCard.ZIndex = 22
	Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 10)
	punishgoatby97mzu:ApplyThemeObj(ProfileCard, "BackgroundColor3", "ToggleBtnBg")
 
	local AvatarImg = Instance.new("ImageLabel", ProfileCard)
	AvatarImg.Size = UDim2.new(0, 24, 0, 24)
	AvatarImg.Position = UDim2.new(0, 8, 0.5, -12)
	AvatarImg.BackgroundTransparency = 1
	AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
	AvatarImg.ZIndex = 23
	Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)
 
	local PlayerName = Instance.new("TextLabel", ProfileCard)
	PlayerName.Size = UDim2.new(1, -46, 0, 12)
	PlayerName.Position = UDim2.new(0, 38, 0, 8)
	PlayerName.BackgroundTransparency = 1
	PlayerName.Text = LocalPlayer.Name
	PlayerName.Font = Enum.Font.GothamBold
	PlayerName.TextSize = 11
	PlayerName.TextXAlignment = Enum.TextXAlignment.Left
	PlayerName.TextTruncate = Enum.TextTruncate.AtEnd
	PlayerName.ZIndex = 23
	punishgoatby97mzu:ApplyThemeObj(PlayerName, "TextColor3", "Text")
 
	local f = Instance.new("TextLabel", ProfileCard)
	f.Size = UDim2.new(1, -46, 0, 11)
	f.Position = UDim2.new(0, 38, 0, 21)
	f.BackgroundTransparency = 1
	f.Text = "punishment hub • UID " .. tostring(LocalPlayer.UserId)
	f.Font = Enum.Font.GothamMedium
	f.TextSize = 8
	f.TextXAlignment = Enum.TextXAlignment.Left
	f.TextTruncate = Enum.TextTruncate.AtEnd
	f.ZIndex = 23
	punishgoatby97mzu:ApplyThemeObj(f, "TextColor3", "Accentpunish")
 
	-- ============================================================
	-- SETTINGS PANEL (keybind + every UI preference)
	-- ============================================================
	Window.ToggleKey = Enum.KeyCode.RightShift

	function Window:RefreshTabColors()
		local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
		for _, tab in pairs(Window.Tabs) do
			local color = punishgoatby97mzu.ColorfulTabs and tab.Color or palette.Accent
			tab.Indicator.BackgroundColor3 = color
			tab.PillStroke.Color = punishgoatby97mzu.ColorfulTabs and color or palette.Stroke
			if Window.CurrentTab == tab then
				tab.Icon.ImageColor3 = color
			end
		end
	end

	function Window:RefreshDecals()
		for _, tab in pairs(Window.Tabs) do
			tab.DecalBadge.Visible = punishgoatby97mzu.DecalsEnabled
			for _, d in ipairs(tab.Page:GetDescendants()) do
				if d:IsA("ImageLabel") and d.Name == "SectionDecal" then
					d.Visible = punishgoatby97mzu.DecalsEnabled
				end
			end
		end
	end

	local SettingsPanel = Instance.new("Frame", Main)
	SettingsPanel.Name = "SettingsPanel"
	SettingsPanel.Size = UDim2.new(1, -20, 1, -46)
	SettingsPanel.Position = UDim2.new(0, 10, 0, 40)
	SettingsPanel.BackgroundTransparency = 0.05
	SettingsPanel.BorderSizePixel = 0
	SettingsPanel.Visible = false
	SettingsPanel.ClipsDescendants = true
	SettingsPanel.ZIndex = 300
	Instance.new("UICorner", SettingsPanel).CornerRadius = UDim.new(0, 10)
	punishgoatby97mzu:ApplyThemeObj(SettingsPanel, "BackgroundColor3", "MainBg")

	local SPHeader = Instance.new("TextLabel", SettingsPanel)
	SPHeader.Size = UDim2.new(1, -60, 0, 30)
	SPHeader.Position = UDim2.new(0, 14, 0, 6)
	SPHeader.BackgroundTransparency = 1
	SPHeader.Text = "Interface settings"
	SPHeader.Font = Enum.Font.GothamBold
	SPHeader.TextSize = 14
	SPHeader.TextXAlignment = Enum.TextXAlignment.Left
	SPHeader.ZIndex = 302
	punishgoatby97mzu:ApplyThemeObj(SPHeader, "TextColor3", "Text")

	local SPClose = Instance.new("TextButton", SettingsPanel)
	SPClose.Size = UDim2.new(0, 24, 0, 24)
	SPClose.Position = UDim2.new(1, -32, 0, 9)
	SPClose.BackgroundTransparency = 1
	SPClose.Text = "✕"
	SPClose.Font = Enum.Font.GothamBold
	SPClose.TextSize = 13
	SPClose.AutoButtonColor = false
	SPClose.ZIndex = 302
	punishgoatby97mzu:ApplyThemeObj(SPClose, "TextColor3", "TextInactive")

	local SPList = Instance.new("ScrollingFrame", SettingsPanel)
	SPList.Size = UDim2.new(1, -20, 1, -46)
	SPList.Position = UDim2.new(0, 10, 0, 38)
	SPList.BackgroundTransparency = 1
	SPList.BorderSizePixel = 0
	SPList.ScrollBarThickness = 2
	SPList.CanvasSize = UDim2.new(0, 0, 0, 0)
	SPList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SPList.ZIndex = 302
	punishgoatby97mzu:ApplyThemeObj(SPList, "ScrollBarImageColor3", "Stroke")

	local SPLayout = Instance.new("UIListLayout", SPList)
	SPLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SPLayout.Padding = UDim.new(0, 6)

	local spOrder = 0
	local function spRow(height)
		spOrder = spOrder + 1
		local Row = Instance.new("Frame", SPList)
		Row.Size = UDim2.new(1, -4, 0, height)
		Row.BackgroundTransparency = 0.45
		Row.BorderSizePixel = 0
		Row.LayoutOrder = spOrder
		Row.ZIndex = 303
		Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
		punishgoatby97mzu:ApplyThemeObj(Row, "BackgroundColor3", "ToggleBtnBg")
		return Row
	end

	local function spLabel(Parent, text, size, font, key, x, y, w)
		local Label = Instance.new("TextLabel", Parent)
		Label.Size = UDim2.new(1, w or -110, 0, 14)
		Label.Position = UDim2.new(0, x or 12, 0, y or 0)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.Font = font
		Label.TextSize = size
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTruncate = Enum.TextTruncate.AtEnd
		Label.ZIndex = 304
		punishgoatby97mzu:ApplyThemeObj(Label, "TextColor3", key)
		return Label
	end

	local function spSection(text)
		spOrder = spOrder + 1
		local Head = Instance.new("TextLabel", SPList)
		Head.Size = UDim2.new(1, -4, 0, 18)
		Head.BackgroundTransparency = 1
		Head.Text = string.upper(text)
		Head.Font = Enum.Font.GothamBold
		Head.TextSize = 9
		Head.TextXAlignment = Enum.TextXAlignment.Left
		Head.LayoutOrder = spOrder
		Head.ZIndex = 303
		punishgoatby97mzu:ApplyThemeObj(Head, "TextColor3", "TextInactive")
		return Head
	end

	local function spToggle(text, desc, default, callback)
		local Row = spRow(desc and 44 or 34)
		spLabel(Row, text, 12, Enum.Font.GothamMedium, "Text", 12, desc and 8 or 10)
		if desc then
			spLabel(Row, desc, 9, Enum.Font.Gotham, "TextInactive", 12, 24)
		end

		local Track = Instance.new("TextButton", Row)
		Track.Size = UDim2.new(0, 34, 0, 16)
		Track.AnchorPoint = Vector2.new(1, 0.5)
		Track.Position = UDim2.new(1, -12, 0.5, 0)
		Track.Text = ""
		Track.AutoButtonColor = false
		Track.BorderSizePixel = 0
		Track.ZIndex = 305
		Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

		local Dot = Instance.new("Frame", Track)
		Dot.Size = UDim2.new(0, 12, 0, 12)
		Dot.Position = UDim2.new(0, 2, 0.5, -6)
		Dot.BorderSizePixel = 0
		Dot.ZIndex = 306
		Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
		punishgoatby97mzu:ApplyThemeObj(Dot, "BackgroundColor3", "ToggleDot")

		local state = default and true or false
		local function paint(animate)
			local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
			local target = state and punishgoatby97mzu:TabColor(4) or palette.ToggleBgOff
			local pos = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
			if animate then
				TweenService:Create(Track, TweenInfo.new(0.18), { BackgroundColor3 = target }):Play()
				TweenService:Create(Dot, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = pos }):Play()
			else
				Track.BackgroundColor3 = target
				Dot.Position = pos
			end
		end
		paint(false)

		Track.MouseButton1Click:Connect(function()
			state = not state
			paint(true)
			callback(state)
		end)
		return Row
	end

	local function spSlider(text, min, max, default, suffix, callback)
		local Row = spRow(44)
		spLabel(Row, text, 12, Enum.Font.GothamMedium, "Text", 12, 8)

		local Value = Instance.new("TextLabel", Row)
		Value.Size = UDim2.new(0, 60, 0, 14)
		Value.AnchorPoint = Vector2.new(1, 0)
		Value.Position = UDim2.new(1, -12, 0, 8)
		Value.BackgroundTransparency = 1
		Value.Font = Enum.Font.GothamBold
		Value.TextSize = 11
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.ZIndex = 305
		Value.TextColor3 = punishgoatby97mzu:TabColor(5)

		local Track = Instance.new("TextButton", Row)
		Track.Size = UDim2.new(1, -24, 0, 5)
		Track.Position = UDim2.new(0, 12, 0, 30)
		Track.Text = ""
		Track.AutoButtonColor = false
		Track.BorderSizePixel = 0
		Track.BackgroundTransparency = 0.4
		Track.ZIndex = 305
		Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
		punishgoatby97mzu:ApplyThemeObj(Track, "BackgroundColor3", "ToggleBgOff")

		local Fill = Instance.new("Frame", Track)
		Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		Fill.BorderSizePixel = 0
		Fill.BackgroundColor3 = punishgoatby97mzu:TabColor(5)
		Fill.ZIndex = 306
		Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

		local Knob = Instance.new("Frame", Track)
		Knob.Size = UDim2.new(0, 10, 0, 10)
		Knob.AnchorPoint = Vector2.new(0.5, 0.5)
		Knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
		Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Knob.BorderSizePixel = 0
		Knob.ZIndex = 307
		Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

		local function setFromAlpha(alpha)
			alpha = math.clamp(alpha, 0, 1)
			local value = min + (max - min) * alpha
			Fill.Size = UDim2.new(alpha, 0, 1, 0)
			Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
			Value.Text = string.format("%.2f", value):gsub("%.?0+$", "") .. (suffix or "")
			callback(value)
		end
		Value.Text = string.format("%.2f", default):gsub("%.?0+$", "") .. (suffix or "")

		local dragging = false
		local function update(input)
			setFromAlpha((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X)
		end
		Track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				update(input)
			end
		end)
		Track.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
		return Row
	end

	local function spAction(text, desc, color, callback)
		local Row = spRow(desc and 44 or 34)
		spLabel(Row, text, 12, Enum.Font.GothamMedium, "Text", 12, desc and 8 or 10)
		if desc then
			spLabel(Row, desc, 9, Enum.Font.Gotham, "TextInactive", 12, 24)
		end

		local Btn = Instance.new("TextButton", Row)
		Btn.Size = UDim2.new(0, 62, 0, 22)
		Btn.AnchorPoint = Vector2.new(1, 0.5)
		Btn.Position = UDim2.new(1, -12, 0.5, 0)
		Btn.BackgroundColor3 = color
		Btn.BackgroundTransparency = 0.78
		Btn.Text = "Run"
		Btn.Font = Enum.Font.GothamBold
		Btn.TextSize = 10
		Btn.TextColor3 = color
		Btn.AutoButtonColor = false
		Btn.ZIndex = 305
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		Btn.MouseButton1Click:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.4 }):Play()
			task.delay(0.1, function()
				TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.78 }):Play()
			end)
			callback()
		end)
		return Btn
	end

	-- ---------- keybind row ----------
	spSection("Access")
	local KeyRow = spRow(44)
	spLabel(KeyRow, "Open / close keybind", 12, Enum.Font.GothamMedium, "Text", 12, 8)
	local KeyHint = spLabel(KeyRow, "Click the key, then press any key", 9, Enum.Font.Gotham, "TextInactive", 12, 24)

	local KeyBtn = Instance.new("TextButton", KeyRow)
	KeyBtn.Size = UDim2.new(0, 78, 0, 24)
	KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
	KeyBtn.Position = UDim2.new(1, -12, 0.5, 0)
	KeyBtn.BackgroundColor3 = punishgoatby97mzu:TabColor(6)
	KeyBtn.BackgroundTransparency = 0.78
	KeyBtn.Text = Window.ToggleKey.Name
	KeyBtn.Font = Enum.Font.GothamBold
	KeyBtn.TextSize = 11
	KeyBtn.TextColor3 = punishgoatby97mzu:TabColor(6)
	KeyBtn.AutoButtonColor = false
	KeyBtn.ZIndex = 305
	Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)

	local listeningForKey = false
	KeyBtn.MouseButton1Click:Connect(function()
		listeningForKey = true
		KeyBtn.Text = "..."
		KeyHint.Text = "Press any key (Esc cancels)"
	end)

	local uiHidden = false
	function Window:SetVisible(state)
		uiHidden = not state
		punishgoatUI.Enabled = state
	end
	function Window:Toggle()
		Window:SetVisible(uiHidden)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if listeningForKey then
			listeningForKey = false
			if input.KeyCode ~= Enum.KeyCode.Escape then
				Window.ToggleKey = input.KeyCode
			end
			KeyBtn.Text = Window.ToggleKey.Name
			KeyHint.Text = "Click the key, then press any key"
			return
		end
		if gameProcessed then
			return
		end
		if input.KeyCode == Window.ToggleKey then
			Window:Toggle()
		end
	end)

	-- ---------- appearance ----------
	spSection("Appearance")
	local ThemeRow = spRow(56)
	spLabel(ThemeRow, "Theme", 12, Enum.Font.GothamMedium, "Text", 12, 8)
	local ThemeOrder = { "cezar", "Graphite", "Contrast", "Paper" }
	local themeChips = {}
	for i, tName in ipairs(ThemeOrder) do
		local chipW = 0.25
		local chip = Instance.new("TextButton", ThemeRow)
		chip.Size = UDim2.new(chipW, -14, 0, 20)
		chip.Position = UDim2.new(chipW * (i - 1), 12, 0, 28)
		chip.Text = tName
		chip.Font = Enum.Font.GothamMedium
		chip.TextSize = 10
		chip.AutoButtonColor = false
		chip.BackgroundColor3 = punishgoatby97mzu:TabColor(i)
		chip.BackgroundTransparency = (tName == punishgoatby97mzu.CurrentTheme) and 0.55 or 0.88
		chip.TextColor3 = punishgoatby97mzu:TabColor(i)
		chip.ZIndex = 305
		Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 6)
		themeChips[tName] = chip

		chip.MouseButton1Click:Connect(function()
			punishgoatby97mzu:ChangeTheme(tName)
			for name, other in pairs(themeChips) do
				TweenService:Create(other, TweenInfo.new(0.18), {
					BackgroundTransparency = (name == tName) and 0.55 or 0.88,
				}):Play()
			end
			Window:RefreshTabColors()
			local palette = punishgoatby97mzu.Themes[tName]
			for _, tabData in pairs(Window.Tabs) do
				if tabData.Page.Visible then
					TweenService:Create(tabData.TitleLabel, TweenInfo.new(0.3), { TextColor3 = palette.Text }):Play()
				end
			end
		end)
	end

	spToggle("Colourful tabs", "Give every tab its own accent colour.", punishgoatby97mzu.ColorfulTabs, function(state)
		punishgoatby97mzu.ColorfulTabs = state
		Window:RefreshTabColors()
	end)

	spSlider("Interface scale", 0.6, 1.4, 1, "x", function(value)
		punishgoatby97mzu.UserScale = value
		if Window.ApplyScale then
			Window.ApplyScale()
		end
	end)

	spSlider("Panel opacity", 0, 0.85, 0.08, "", function(value)
		Main.BackgroundTransparency = value
		Backplate.BackgroundTransparency = math.clamp(value + 0.4, 0, 1)
	end)

	spSlider("Backdrop dim", 0, 1, 0.5, "", function(value)
		Backplate.BackgroundTransparency = value
	end)

	spSlider("Corner rounding", 0, 20, 12, "px", function(value)
		MainCorner.CornerRadius = UDim.new(0, math.floor(value))
	end)

	-- ---------- decals ----------
	spSection("2D decals")
	spToggle("Tab decal badges", "Show an rbxasset / decal image on every tab.", punishgoatby97mzu.DecalsEnabled, function(state)
		punishgoatby97mzu.DecalsEnabled = state
		Window:RefreshDecals()
	end)
	spToggle("Shuffle decals", "Rotate each tab badge through the asset pool.", punishgoatby97mzu.DecalShuffle, function(state)
		punishgoatby97mzu.DecalShuffle = state
	end)
	local WatermarkToggleRow = spToggle("Decal watermark", "Large decal behind the panel content.", true, function(state)
		local wm = Main:FindFirstChild("DecalWatermark")
		if wm then
			wm.Visible = state
		end
	end)
	spAction("Reshuffle now", "Pull a fresh decal for every tab.", punishgoatby97mzu:TabColor(3), function()
		for _, tab in pairs(Window.Tabs) do
			punishgoatby97mzu:ApplyDecal(tab.DecalBadge, punishgoatby97mzu:RandomAsset())
		end
	end)

	-- ---------- behaviour ----------
	spSection("Behaviour")
	spToggle("Notifications", "Show the toast cards in the corner.", punishgoatby97mzu.NotificationsEnabled, function(state)
		punishgoatby97mzu.NotificationsEnabled = state
	end)
	spAction("Recentre window", "Snap the panel back to the middle.", punishgoatby97mzu:TabColor(5), function()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1000, 1000)
		local pos = UDim2.new(0.5, 0, 0, (vp.Y / 2) - (Main.AbsoluteSize.Y / 2))
		TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = pos }):Play()
		TweenService:Create(Backplate, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = pos }):Play()
		currentPos = pos
	end)
	spAction("Reset size", "Return to the compact default size.", punishgoatby97mzu:TabColor(1), function()
		Main.Size = UDim2.new(0, 548, 0, 348)
		Backplate.Size = UDim2.new(0, 556, 0, 356)
		currentSize = Main.Size
	end)
	spAction("Copy job id", "Puts the server job id on your clipboard.", punishgoatby97mzu:TabColor(7), function()
		if setclipboard then
			pcall(setclipboard, game.JobId)
		end
		punishgoatby97mzu:Notify({ Title = "punishment hub", Content = "Job id copied", Duration = 2 })
	end)

	local function setSettingsOpen(open)
		if open then
			SettingsPanel.Visible = true
			SettingsPanel.BackgroundTransparency = 1
			SettingsPanel.Position = UDim2.new(0, 10, 0, 52)
			TweenService:Create(SettingsPanel, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.05,
				Position = UDim2.new(0, 10, 0, 40),
			}):Play()
		else
			local out = TweenService:Create(SettingsPanel, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 52),
			})
			out:Play()
			out.Completed:Connect(function()
				SettingsPanel.Visible = false
			end)
		end
	end

	function Window:CloseSettings()
		if SettingsPanel.Visible then
			setSettingsOpen(false)
		end
	end

	SettingsBtn.MouseButton1Click:Connect(function()
		setSettingsOpen(not SettingsPanel.Visible)
	end)
	SPClose.MouseButton1Click:Connect(function()
		setSettingsOpen(false)
	end)
 
	local ContentContainer = Instance.new("Frame", Main)
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, 0, 1, -34)
	ContentContainer.Position = UDim2.new(0, 0, 0, 34)

	-- Giant decal watermark behind the content of the big center panel.
	local Watermark = Instance.new("ImageLabel", Main)
	Watermark.Name = "DecalWatermark"
	Watermark.AnchorPoint = Vector2.new(0.5, 0.5)
	Watermark.Position = UDim2.new(0.5, 0, 0.55, 0)
	Watermark.Size = UDim2.new(0, 190, 0, 190)
	Watermark.BackgroundTransparency = 1
	Watermark.ImageTransparency = 0.92
	Watermark.ScaleType = Enum.ScaleType.Fit
	Watermark.ZIndex = 2
	Watermark.Visible = false
	punishgoatby97mzu:ApplyDecal(Watermark, punishgoatby97mzu:RandomAsset())
	punishgoatby97mzu:ApplyThemeObj(Watermark, "ImageColor3", "Text")
	-- Soft vignette so the big background decal melts into the panel.
	punishgoatby97mzu:AddEdgeFade(Watermark, 0.42, true)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.BorderSizePixel = 0
	ContentContainer.ClipsDescendants = true
 
	-- CreateTab(name, icon, decal)
	--   decal accepts anything ResolveAsset understands: a number, an id string,
	--   "rbxassetid://", "rbxasset://textures/...", "rbxthumb://" or a raw Decal id.
	function Window:CreateTab(TabName, IconID, DecalAsset)
		local tabIndex = #Window.Tabs + 1
		local tabColor = punishgoatby97mzu:TabColor(tabIndex)

		local TabBtn = Instance.new("TextButton", Sidebar)
		TabBtn.Name = "TabBtn_" .. TabName
		TabBtn.Size = UDim2.new(1, 0, 0, 34)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.BackgroundColor3 = tabColor
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 9)

		local TabPillBg = Instance.new("Frame", TabBtn)
		TabPillBg.Name = "PillBg"
		TabPillBg.Size = UDim2.new(1, 0, 1, 0)
		TabPillBg.BackgroundTransparency = 0.4
		TabPillBg.BorderSizePixel = 0
		TabPillBg.ZIndex = -1
		Instance.new("UICorner", TabPillBg).CornerRadius = UDim.new(0, 9)
		punishgoatby97mzu:ApplyThemeObj(TabPillBg, "BackgroundColor3", "ToggleBtnBg")
		local TabPillStroke = Instance.new("UIStroke", TabPillBg)
		TabPillStroke.Thickness = 1
		TabPillStroke.Transparency = 0.75
		TabPillStroke.Color = punishgoatby97mzu.ColorfulTabs and tabColor
			or punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Stroke

		local TabScale = Instance.new("UIScale", TabBtn)
		TabScale.Scale = 1
		TabBtn.MouseEnter:Connect(function()
			TweenService:Create(TabScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.03 }):Play()
			TweenService:Create(TabPillStroke, TweenInfo.new(0.18), { Transparency = 0.3 }):Play()
		end)
		TabBtn.MouseLeave:Connect(function()
			TweenService:Create(TabScale, TweenInfo.new(0.18), { Scale = 1 }):Play()
			TweenService:Create(TabPillStroke, TweenInfo.new(0.18), { Transparency = 0.75 }):Play()
		end)

		-- 2D decal badge for this tab: explicit asset if given, otherwise pooled.
		local DecalBadge = Instance.new("ImageLabel", TabBtn)
		DecalBadge.Name = "DecalBadge"
		DecalBadge.Size = UDim2.new(0, 18, 0, 18)
		DecalBadge.AnchorPoint = Vector2.new(1, 0.5)
		DecalBadge.Position = UDim2.new(1, -7, 0.5, 0)
		DecalBadge.BackgroundTransparency = 1
		DecalBadge.ScaleType = Enum.ScaleType.Fit
		DecalBadge.ImageTransparency = 0.1
		DecalBadge.Visible = punishgoatby97mzu.DecalsEnabled
		DecalBadge.ZIndex = 3
		punishgoatby97mzu:ApplyDecal(DecalBadge, DecalAsset or punishgoatby97mzu:RandomAsset())
		punishgoatby97mzu:AddEdgeFade(DecalBadge, 0.3)
 
		local Indicator = Instance.new("Frame", TabBtn)
		Indicator.Name = "Indicator"
		Indicator.Size = UDim2.new(0, 3, 0, 14)
		Indicator.AnchorPoint = Vector2.new(0, 0.5)
		Indicator.Position = UDim2.new(0, 3, 0.5, 0)
		Indicator.BackgroundTransparency = 1
		Indicator.BorderSizePixel = 0
		Indicator.BackgroundColor3 = punishgoatby97mzu.ColorfulTabs and tabColor
			or punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Accent
		Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
 
		local Icon = Instance.new("ImageLabel", TabBtn)
		Icon.Name = "Icon"
		Icon.Size = UDim2.new(0, 14, 0, 14)
		Icon.AnchorPoint = Vector2.new(0, 0.5)
		Icon.Position = UDim2.new(0, 12, 0.5, 0)
		Icon.BackgroundTransparency = 1
		Icon.Image = punishgoatby97mzu:ResolveAsset(IconID)
		punishgoatby97mzu:ApplyThemeObj(Icon, "ImageColor3", "TextInactive")
		local IconScale = Instance.new("UIScale", Icon)
		IconScale.Scale = 1
 
		local TitleLabel = Instance.new("TextLabel", TabBtn)
		TitleLabel.Name = "TitleLabel"
		TitleLabel.Size = UDim2.new(1, -58, 1, 0)
		TitleLabel.Position = UDim2.new(0, 33, 0, 0)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Text = TabName
		TitleLabel.Font = Enum.Font.GothamMedium
		TitleLabel.TextSize = 12
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		punishgoatby97mzu:ApplyThemeObj(TitleLabel, "TextColor3", "TextInactive")
 
		local Page = Instance.new("ScrollingFrame", ContentContainer)
		Page.Name = "Page_" .. TabName
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.Position = UDim2.new(0, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 2
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		-- Use Roblox's built-in AutomaticCanvasSize so scroll height adapts to dropdown content automatically
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		punishgoatby97mzu:ApplyThemeObj(Page, "ScrollBarImageColor3", "Stroke")
 
		local PagePadding = Instance.new("UIPadding", Page)
		PagePadding.PaddingTop = UDim.new(0, 15)
		PagePadding.PaddingBottom = UDim.new(0, 15)
		PagePadding.PaddingLeft = UDim.new(0, 15)
		PagePadding.PaddingRight = UDim.new(0, 15)
 
		local PageLayout = Instance.new("UIListLayout", Page)
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 8)
 
		task.spawn(function()
			while TabBtn.Parent do
				task.wait(6 + math.random() * 2)
				if not TabBtn.Parent then
					break
				end
				-- Explicit decals stay put; only pooled badges shuffle, and only
				-- while both the decal layer and shuffling are switched on.
				if punishgoatby97mzu.DecalShuffle and punishgoatby97mzu.DecalsEnabled and not DecalAsset then
					local nextImg = punishgoatby97mzu:RandomAsset()
					TweenService:Create(DecalBadge, TweenInfo.new(0.25), { ImageTransparency = 1 }):Play()
					task.wait(0.25)
					punishgoatby97mzu:ApplyDecal(DecalBadge, nextImg)
					TweenService:Create(DecalBadge, TweenInfo.new(0.25), { ImageTransparency = 0.1 }):Play()
					if Window.CurrentTab and Window.CurrentTab.DecalBadge == DecalBadge then
						punishgoatby97mzu:ApplyDecal(Watermark, nextImg)
					end
				end
			end
		end)

		local TabData = {
			Color = tabColor,
			DecalBadge = DecalBadge,
			PillBg = TabPillBg,
			PillStroke = TabPillStroke,
			Button = TabBtn,
			Indicator = Indicator,
			Icon = Icon,
			IconScale = IconScale,
			TitleLabel = TitleLabel,
			Page = Page,
		}
		table.insert(Window.Tabs, TabData)
 
		TabBtn.MouseButton1Click:Connect(function()
			-- Any tab click dismisses the settings & keybind overlay so the two
			-- surfaces never sit on top of each other.
			if Window.CloseSettings then
				Window:CloseSettings()
			end
			if Window.CurrentTab == TabData then
				return
			end
			local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
			local activeColor = punishgoatby97mzu.ColorfulTabs and tabColor or palette.Accent
			Watermark.Image = DecalBadge.Image
			TweenService:Create(TabScale, TweenInfo.new(0.12), { Scale = 0.94 }):Play()
			task.delay(0.12, function()
				TweenService:Create(TabScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			end)

			-- Snap the previous page off instantly: cross-fading two scrolling
			-- pages is what caused the long "two tabs on screen" overlap.
			for _, v in pairs(Window.Tabs) do
				TweenService:Create(v.Button, TweenInfo.new(0.14), { BackgroundTransparency = 0.98 }):Play()
				TweenService:Create(v.Indicator, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
				TweenService:Create(v.Icon, TweenInfo.new(0.14), { ImageColor3 = palette.TextInactive }):Play()
				TweenService:Create(v.TitleLabel, TweenInfo.new(0.14), { TextColor3 = palette.TextInactive }):Play()
				TweenService:Create(v.IconScale, TweenInfo.new(0.14, Enum.EasingStyle.Quint), { Scale = 0.9 }):Play()
				if v ~= TabData then
					v.Page.Visible = false
					v.Page.Position = UDim2.new(0, 0, 0, 0)
				end
			end

			Window.CurrentTab = TabData
			Page.Visible = true
			Page.Position = UDim2.new(0.05, 0, 0, 0)
			Page.CanvasPosition = Vector2.new(0, 0)
			TweenService:Create(
				Page,
				TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0) }
			):Play()

			TweenService:Create(TabBtn, TweenInfo.new(0.16, Enum.EasingStyle.Quart), { BackgroundTransparency = 0.86 }):Play()
			Indicator.BackgroundColor3 = activeColor
			TweenService:Create(Indicator, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0,
				Size = UDim2.new(0, 3, 0, 18),
			}):Play()
			TweenService:Create(Icon, TweenInfo.new(0.16, Enum.EasingStyle.Quart), { ImageColor3 = activeColor }):Play()
			TweenService:Create(IconScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.1 }):Play()
			TweenService:Create(TitleLabel, TweenInfo.new(0.16, Enum.EasingStyle.Quart), { TextColor3 = palette.Text }):Play()

			task.delay(0.18, function()
				if Window.CurrentTab == TabData then
					TweenService:Create(IconScale, TweenInfo.new(0.14, Enum.EasingStyle.Quart), { Scale = 1 }):Play()
				end
			end)
			for _, closeFunc in pairs(Window.SelectCloseFuncs) do
				closeFunc()
			end
		end)
 
		if #Window.Tabs == 1 then
			Window.CurrentTab = TabData
			Page.Visible = true
			Page.Position = UDim2.new(0, 0, 0, 0)
			TabBtn.BackgroundTransparency = 0.86
			Indicator.BackgroundTransparency = 0
			local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
			Icon.ImageColor3 = punishgoatby97mzu.ColorfulTabs and tabColor or palette.Accent
			TitleLabel.TextColor3 = palette.Text
			punishgoatby97mzu:ApplyDecal(Watermark, DecalBadge.Image)
		end
 
		local Tab = {}
		function Tab:CreateSection(SectionName, SectionDecal)
			local SectionLabel = Instance.new("Frame", Page)
			SectionLabel.Size = UDim2.new(1, 0, 0, 30)
			SectionLabel.BackgroundTransparency = 1

			-- Small decal sitting directly beside the section name instead of a
			-- floating square in the middle of the page.
			local SectionIcon = Instance.new("ImageLabel", SectionLabel)
			SectionIcon.Name = "SectionDecal"
			SectionIcon.Size = UDim2.new(0, 14, 0, 14)
			SectionIcon.AnchorPoint = Vector2.new(0, 0.5)
			SectionIcon.Position = UDim2.new(0, 5, 0.5, 0)
			SectionIcon.BackgroundTransparency = 1
			SectionIcon.ScaleType = Enum.ScaleType.Fit
			SectionIcon.ImageTransparency = 0.15
			SectionIcon.Visible = punishgoatby97mzu.DecalsEnabled
			punishgoatby97mzu:ApplyThemeObj(SectionIcon, "ImageColor3", "Text")
			punishgoatby97mzu:ApplyDecal(SectionIcon, SectionDecal or punishgoatby97mzu:RandomAsset())
			punishgoatby97mzu:AddEdgeFade(SectionIcon, 0.3)

			local Title = Instance.new("TextLabel", SectionLabel)
			Title.Size = UDim2.new(1, -27, 1, 0)
			Title.Position = UDim2.new(0, 23, 0, 0)
			Title.BackgroundTransparency = 1
			Title.Text = SectionName
			Title.Font = Enum.Font.GothamBold
			Title.TextSize = 14
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "SectionTitle")
 
			Instance.new("UIPadding", SectionLabel).PaddingTop = UDim.new(0, 15)
		end

		-- ==========================================================
		-- Dashboard components (home-screen style cards)
		-- ==========================================================
		local function styleCard(Frame, Radius)
			Frame.BackgroundTransparency = 0.05
			Frame.BorderSizePixel = 0
			punishgoatby97mzu:ApplyThemeObj(Frame, "BackgroundColor3", "ToggleBtnBg")
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, Radius or 12)
			local stroke = Instance.new("UIStroke", Frame)
			stroke.Thickness = 1
			stroke.Transparency = 0.6
			punishgoatby97mzu:ApplyThemeObj(stroke, "Color", "Stroke")
			return Frame
		end

		local function makeText(Parent, Text, Size, Font, ThemeKey)
			local label = Instance.new("TextLabel", Parent)
			label.BackgroundTransparency = 1
			label.Text = Text
			label.Font = Font
			label.TextSize = Size
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			punishgoatby97mzu:ApplyThemeObj(label, "TextColor3", ThemeKey)
			return label
		end

		-- Big profile row: avatar + greeting, like a home header.
		function Tab:CreateProfileCard(Greeting, Subtitle, ImageAsset)
			local Card = styleCard(Instance.new("Frame", Page), 14)
			Card.Size = UDim2.new(1, 0, 0, 74)

			local Avatar = Instance.new("ImageLabel", Card)
			Avatar.Size = UDim2.new(0, 52, 0, 52)
			Avatar.Position = UDim2.new(0, 12, 0.5, 0)
			Avatar.AnchorPoint = Vector2.new(0, 0.5)
			Avatar.BackgroundTransparency = 0.85
			Avatar.Image = punishgoatby97mzu:ResolveAsset(
				ImageAsset
					or ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150")
			)
			punishgoatby97mzu:ApplyThemeObj(Avatar, "BackgroundColor3", "ToggleBgOff")
			Instance.new("UICorner", Avatar).CornerRadius = UDim.new(0, 10)

			local Title = makeText(Card, Greeting or ("Hello, " .. LocalPlayer.Name), 17, Enum.Font.GothamBold, "Text")
			Title.Size = UDim2.new(1, -84, 0, 22)
			Title.Position = UDim2.new(0, 76, 0, 16)

			local Sub = makeText(Card, Subtitle or LocalPlayer.DisplayName, 12, Enum.Font.Gotham, "TextInactive")
			Sub.Size = UDim2.new(1, -84, 0, 16)
			Sub.Position = UDim2.new(0, 76, 0, 38)
			return Card
		end

		-- Card holding a grid of small stat tiles: {{ Label, Value, Callback }, ... }
		local function buildStatCard(Parent, Title, Desc, Stats, Accent)
			local Card = styleCard(Instance.new("Frame", Parent), 12)
			Card.Size = UDim2.new(1, 0, 0, 0)
			Card.AutomaticSize = Enum.AutomaticSize.Y

			local pad = Instance.new("UIPadding", Card)
			pad.PaddingTop = UDim.new(0, 12)
			pad.PaddingBottom = UDim.new(0, 12)
			pad.PaddingLeft = UDim.new(0, 12)
			pad.PaddingRight = UDim.new(0, 12)

			local list = Instance.new("UIListLayout", Card)
			list.SortOrder = Enum.SortOrder.LayoutOrder
			list.Padding = UDim.new(0, 6)

			local head = makeText(Card, Title, 15, Enum.Font.GothamBold, Accent and "Accent" or "Text")
			head.Size = UDim2.new(1, 0, 0, 20)
			head.LayoutOrder = 1

			if Desc and Desc ~= "" then
				local sub = makeText(Card, Desc, 11, Enum.Font.Gotham, "TextInactive")
				sub.Size = UDim2.new(1, 0, 0, 14)
				sub.TextTruncate = Enum.TextTruncate.None
				sub.TextWrapped = true
				sub.AutomaticSize = Enum.AutomaticSize.Y
				sub.LayoutOrder = 2
			end

			if Stats and #Stats > 0 then
				local Grid = Instance.new("Frame", Card)
				Grid.BackgroundTransparency = 1
				Grid.Size = UDim2.new(1, 0, 0, 0)
				Grid.AutomaticSize = Enum.AutomaticSize.Y
				Grid.LayoutOrder = 3

				local grid = Instance.new("UIGridLayout", Grid)
				grid.CellSize = UDim2.new(0.5, -4, 0, 44)
				grid.CellPadding = UDim2.new(0, 8, 0, 8)
				grid.SortOrder = Enum.SortOrder.LayoutOrder

				for i, stat in ipairs(Stats) do
					local Tile = Instance.new("TextButton", Grid)
					Tile.Text = ""
					Tile.AutoButtonColor = false
					Tile.LayoutOrder = i
					styleCard(Tile, 8)
					Tile.BackgroundTransparency = 0.25
					punishgoatby97mzu:ApplyThemeObj(Tile, "BackgroundColor3", "ToggleBgOff")

					local l = makeText(Tile, tostring(stat[1]), 12, Enum.Font.GothamBold, "Text")
					l.Size = UDim2.new(1, -16, 0, 14)
					l.Position = UDim2.new(0, 8, 0, 7)

					local function readValue()
						if type(stat[2]) ~= "function" then
							return tostring(stat[2])
						end
						local ok, value = pcall(stat[2])
						return ok and tostring(value) or "Unavailable"
					end
					local v = makeText(Tile, readValue(), 11, Enum.Font.Gotham, "TextInactive")
					v.Size = UDim2.new(1, -16, 0, 13)
					v.Position = UDim2.new(0, 8, 0, 23)
					if type(stat[2]) == "function" then
						task.spawn(function()
							while v.Parent do
								v.Text = readValue()
								task.wait(1)
							end
						end)
					end

					local hoverInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					Tile.MouseEnter:Connect(function()
						TweenService:Create(Tile, hoverInfo, { BackgroundTransparency = 0.05 }):Play()
					end)
					Tile.MouseLeave:Connect(function()
						TweenService:Create(Tile, hoverInfo, { BackgroundTransparency = 0.25 }):Play()
					end)
					if stat[3] then
						Tile.MouseButton1Click:Connect(function()
							stat[3]()
						end)
					end
				end
			end
			return Card
		end

		function Tab:CreateStatCard(Title, Desc, Stats, Accent)
			return buildStatCard(Page, Title, Desc, Stats, Accent)
		end

		-- Two side-by-side columns, each accepting stat cards.
		function Tab:CreateSplit(LeftWeight)
			local Holder = Instance.new("Frame", Page)
			Holder.BackgroundTransparency = 1
			Holder.Size = UDim2.new(1, 0, 0, 0)
			Holder.AutomaticSize = Enum.AutomaticSize.Y

			local row = Instance.new("UIListLayout", Holder)
			row.FillDirection = Enum.FillDirection.Horizontal
			row.Padding = UDim.new(0, 10)
			row.SortOrder = Enum.SortOrder.LayoutOrder

			local weight = LeftWeight or 0.55
			local function column(width, order)
				local Col = Instance.new("Frame", Holder)
				Col.BackgroundTransparency = 1
				Col.Size = UDim2.new(width, -5, 0, 0)
				Col.AutomaticSize = Enum.AutomaticSize.Y
				Col.LayoutOrder = order
				local l = Instance.new("UIListLayout", Col)
				l.Padding = UDim.new(0, 10)
				l.SortOrder = Enum.SortOrder.LayoutOrder
				return {
					Frame = Col,
					CreateStatCard = function(_, Title, Desc, Stats, Accent)
						return buildStatCard(Col, Title, Desc, Stats, Accent)
					end,
				}
			end

			return column(weight, 1), column(1 - weight, 2)
		end

		-- Wide call-to-action banner (the Discord-style row at the bottom).
		function Tab:CreateBanner(Title, Desc, Callback)
			local Card = Instance.new("TextButton", Page)
			Card.Text = ""
			Card.AutoButtonColor = false
			Card.Size = UDim2.new(1, 0, 0, 62)
			styleCard(Card, 12)

			local Bar = Instance.new("Frame", Card)
			Bar.Size = UDim2.new(0, 3, 1, -20)
			Bar.Position = UDim2.new(0, 12, 0.5, 0)
			Bar.AnchorPoint = Vector2.new(0, 0.5)
			Bar.BorderSizePixel = 0
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(Bar, "BackgroundColor3", "Accent")

			local t = makeText(Card, Title, 15, Enum.Font.GothamBold, "Text")
			t.Size = UDim2.new(1, -40, 0, 20)
			t.Position = UDim2.new(0, 26, 0, 13)

			local d = makeText(Card, Desc or "", 11, Enum.Font.Gotham, "TextInactive")
			d.Size = UDim2.new(1, -40, 0, 16)
			d.Position = UDim2.new(0, 26, 0, 33)

			local bannerInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			Card.MouseEnter:Connect(function()
				TweenService:Create(Card, bannerInfo, { BackgroundTransparency = 0 }):Play()
				TweenService:Create(Bar, bannerInfo, { Size = UDim2.new(0, 3, 1, -8) }):Play()
			end)
			Card.MouseLeave:Connect(function()
				TweenService:Create(Card, bannerInfo, { BackgroundTransparency = 0.05 }):Play()
				TweenService:Create(Bar, bannerInfo, { Size = UDim2.new(0, 3, 1, -20) }):Play()
			end)
			if Callback then
				Card.MouseButton1Click:Connect(Callback)
			end
			return Card
		end

 
		-- Thin horizontal separator to break up long lists of components.
		function Tab:CreateDivider()
			local DividerHolder = Instance.new("Frame", Page)
			DividerHolder.Size = UDim2.new(1, 0, 0, 9)
			DividerHolder.BackgroundTransparency = 1
 
			local Line = Instance.new("Frame", DividerHolder)
			Line.Size = UDim2.new(1, 0, 0, 1)
			Line.Position = UDim2.new(0, 0, 0.5, 0)
			Line.AnchorPoint = Vector2.new(0, 0.5)
			Line.BorderSizePixel = 0
			Line.BackgroundTransparency = 0.7
			punishgoatby97mzu:ApplyThemeObj(Line, "BackgroundColor3", "Stroke")
		end
 
		-- Same idea as CreateDivider, but accepts an optional centered label
		-- (e.g. AddLine("Advanced"), or just AddLine() for a plain line).
		function Tab:AddLine(Text)
			local LineHolder = Instance.new("Frame", Page)
			LineHolder.Size = UDim2.new(1, 0, 0, 9)
			LineHolder.BackgroundTransparency = 1
 
			if Text and Text ~= "" then
				local LeftLine = Instance.new("Frame", LineHolder)
				LeftLine.AnchorPoint = Vector2.new(0, 0.5)
				LeftLine.Position = UDim2.new(0, 0, 0.5, 0)
				LeftLine.Size = UDim2.new(0.4, 0, 0, 1)
				LeftLine.BorderSizePixel = 0
				LeftLine.BackgroundTransparency = 0.7
				punishgoatby97mzu:ApplyThemeObj(LeftLine, "BackgroundColor3", "Stroke")
 
				local Label = Instance.new("TextLabel", LineHolder)
				Label.AnchorPoint = Vector2.new(0.5, 0.5)
				Label.Position = UDim2.new(0.5, 0, 0.5, 0)
				Label.Size = UDim2.new(0, 0, 0, 14)
				Label.AutomaticSize = Enum.AutomaticSize.X
				Label.BackgroundTransparency = 1
				Label.Text = Text
				Label.Font = Enum.Font.GothamMedium
				Label.TextSize = 11
				punishgoatby97mzu:ApplyThemeObj(Label, "TextColor3", "TextInactive")
 
				local RightLine = Instance.new("Frame", LineHolder)
				RightLine.AnchorPoint = Vector2.new(1, 0.5)
				RightLine.Position = UDim2.new(1, 0, 0.5, 0)
				RightLine.Size = UDim2.new(0.4, 0, 0, 1)
				RightLine.BorderSizePixel = 0
				RightLine.BackgroundTransparency = 0.7
				punishgoatby97mzu:ApplyThemeObj(RightLine, "BackgroundColor3", "Stroke")
			else
				local Line = Instance.new("Frame", LineHolder)
				Line.Size = UDim2.new(1, 0, 0, 1)
				Line.Position = UDim2.new(0, 0, 0.5, 0)
				Line.AnchorPoint = Vector2.new(0, 0.5)
				Line.BorderSizePixel = 0
				Line.BackgroundTransparency = 0.7
				punishgoatby97mzu:ApplyThemeObj(Line, "BackgroundColor3", "Stroke")
			end
		end
 
		-- Live search box. Calls Callback(query) on every keystroke; the caller decides
		-- what to filter (component list, dropdown options, etc). Returns a handle with
		-- :Set(text) so the search text can be cleared/updated from outside too.
		function Tab:CreateSearchBar(Placeholder, Callback)
			local CallbackFunc = Callback or function() end
 
			local SearchContainer = Instance.new("Frame", Page)
			SearchContainer.Size = UDim2.new(1, 0, 0, 36)
			SearchContainer.BackgroundTransparency = 0.55
			Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(SearchContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local SearchStroke = Instance.new("UIStroke", SearchContainer)
			SearchStroke.Thickness = 1
			SearchStroke.Transparency = 0.85
			SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			punishgoatby97mzu:ApplyThemeObj(SearchStroke, "Color", "Stroke")
 
			local Icon = Instance.new("ImageLabel", SearchContainer)
			Icon.Size = UDim2.new(0, 16, 0, 16)
			Icon.AnchorPoint = Vector2.new(0, 0.5)
			Icon.Position = UDim2.new(0, 12, 0.5, 0)
			Icon.BackgroundTransparency = 1
			Icon.Image = "rbxassetid://10709791245" -- magnifying glass icon
			punishgoatby97mzu:ApplyThemeObj(Icon, "ImageColor3", "TextInactive")
 
			local Input = Instance.new("TextBox", SearchContainer)
			Input.Size = UDim2.new(1, -70, 1, 0)
			Input.Position = UDim2.new(0, 36, 0, 0)
			Input.BackgroundTransparency = 1
			Input.PlaceholderText = Placeholder or "Search..."
			Input.Text = ""
			Input.ClearTextOnFocus = false
			Input.Font = Enum.Font.Gotham
			Input.TextSize = 13
			Input.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Input, "TextColor3", "Text")
			punishgoatby97mzu:ApplyThemeObj(Input, "PlaceholderColor3", "TextInactive")
 
			local ClearBtn = Instance.new("TextButton", SearchContainer)
			ClearBtn.Size = UDim2.new(0, 24, 0, 24)
			ClearBtn.AnchorPoint = Vector2.new(1, 0.5)
			ClearBtn.Position = UDim2.new(1, -8, 0.5, 0)
			ClearBtn.BackgroundTransparency = 1
			ClearBtn.Text = "X"
			ClearBtn.Font = Enum.Font.GothamBold
			ClearBtn.TextSize = 12
			ClearBtn.AutoButtonColor = false
			ClearBtn.Visible = false
			punishgoatby97mzu:ApplyThemeObj(ClearBtn, "TextColor3", "TextInactive")
 
			Input.Focused:Connect(function()
				TweenService:Create(SearchStroke, TweenInfo.new(0.2), {
					Color = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Accent,
					Transparency = 0.5,
				}):Play()
			end)
			Input.FocusLost:Connect(function()
				TweenService:Create(SearchStroke, TweenInfo.new(0.2), {
					Color = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Stroke,
					Transparency = 0.85,
				}):Play()
			end)
 
			-- [FIX] React on every keystroke (GetPropertyChangedSignal), not just FocusLost,
			-- so filtering feels instant instead of only firing once the box loses focus.
			Input:GetPropertyChangedSignal("Text"):Connect(function()
				ClearBtn.Visible = Input.Text ~= ""
				CallbackFunc(Input.Text)
			end)
 
			ClearBtn.MouseButton1Click:Connect(function()
				Input.Text = ""
				Input:CaptureFocus()
			end)
 
			local SearchBar = {}
			function SearchBar:Set(text)
				Input.Text = text or ""
			end
			function SearchBar:Get()
				return Input.Text
			end
			return SearchBar
		end
 
		function Tab:CreateThemeDropdown(DropdownName)
			local Expanded = false
 
			local DropdownContainer = Instance.new("Frame", Page)
			DropdownContainer.Size = UDim2.new(1, 0, 0, 36)
			DropdownContainer.BackgroundTransparency = 0.55
			DropdownContainer.ClipsDescendants = true
			Instance.new("UICorner", DropdownContainer).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(DropdownContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local ContainerStroke = Instance.new("UIStroke", DropdownContainer)
			ContainerStroke.Thickness = 1
			ContainerStroke.Transparency = 0.85
			ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			punishgoatby97mzu:ApplyThemeObj(ContainerStroke, "Color", "Stroke")
 
			local Header = Instance.new("TextButton", DropdownContainer)
			Header.Size = UDim2.new(1, 0, 0, 36)
			Header.BackgroundTransparency = 1
			Header.AutoButtonColor = false
			Header.Text = ""
 
			local Title = Instance.new("TextLabel", Header)
			Title.Size = UDim2.new(1, -60, 1, 0)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.Text = DropdownName or "Select Theme"
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			local Arrow = Instance.new("ImageLabel", Header)
			Arrow.Size = UDim2.new(0, 16, 0, 16)
			Arrow.AnchorPoint = Vector2.new(1, 0.5)
			Arrow.Position = UDim2.new(1, -15, 0.5, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Image = "rbxassetid://10709790948"
			punishgoatby97mzu:ApplyThemeObj(Arrow, "ImageColor3", "TextInactive")
 
			local ContentArea = Instance.new("Frame", DropdownContainer)
			ContentArea.Size = UDim2.new(1, 0, 0, 0)
			ContentArea.Position = UDim2.new(0, 0, 0, 36)
			ContentArea.BackgroundTransparency = 1
 
			local ContentPadding = Instance.new("UIPadding", ContentArea)
			ContentPadding.PaddingTop = UDim.new(0, 8)
			ContentPadding.PaddingBottom = UDim.new(0, 12)
			ContentPadding.PaddingLeft = UDim.new(0, 12)
			ContentPadding.PaddingRight = UDim.new(0, 12)
 
			local ContentLayout = Instance.new("UIListLayout", ContentArea)
			ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ContentLayout.Padding = UDim.new(0, 4)
 
			local function ToggleDropdown()
				Expanded = not Expanded
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
 
				if Expanded then
					local TargetHeight = 36 + 20 + ContentLayout.AbsoluteContentSize.Y
					TweenService:Create(
						DropdownContainer,
						TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, TargetHeight) }
					):Play()
					TweenService
						:Create(ContainerStroke, TweenInfo.new(0.3), { Color = palette.Accent, Transparency = 0.5 })
						:Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), { ImageColor3 = palette.Accent, Rotation = 180 })
						:Play()
					TweenService:Create(Title, TweenInfo.new(0.3), { TextColor3 = palette.Accent }):Play()
				else
					TweenService:Create(
						DropdownContainer,
						TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, 36) }
					):Play()
					TweenService
						:Create(ContainerStroke, TweenInfo.new(0.3), { Color = palette.Stroke, Transparency = 0.85 })
						:Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), { ImageColor3 = palette.TextInactive, Rotation = 0 })
						:Play()
					TweenService:Create(Title, TweenInfo.new(0.3), { TextColor3 = palette.Text }):Play()
				end
			end
 
			Header.MouseButton1Click:Connect(ToggleDropdown)
 
			local ThemeOrder =
				{ "cezar", "Graphite", "Contrast", "Paper" }
			for _, tName in ipairs(ThemeOrder) do
				local tBtn = Instance.new("TextButton", ContentArea)
				tBtn.Size = UDim2.new(1, 0, 0, 30)
				tBtn.BackgroundTransparency = 1
				tBtn.Text = tName
				tBtn.Font = Enum.Font.GothamMedium
				tBtn.TextSize = 12
				tBtn.AutoButtonColor = false
				Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)
				punishgoatby97mzu:ApplyThemeObj(tBtn, "BackgroundColor3", "ToggleBgOff")
				punishgoatby97mzu:ApplyThemeObj(tBtn, "TextColor3", "TextInactive")
 
				tBtn.MouseEnter:Connect(function()
					TweenService:Create(tBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
				end)
				tBtn.MouseLeave:Connect(function()
					TweenService:Create(tBtn, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
				end)
 
				tBtn.MouseButton1Click:Connect(function()
					punishgoatby97mzu:ChangeTheme(tName)
 
					for _, tabData in pairs(Window.Tabs) do
						if tabData.Page.Visible then
							local palette = punishgoatby97mzu.Themes[tName]
							TweenService:Create(tabData.Icon, TweenInfo.new(0.3), { ImageColor3 = palette.Accent })
								:Play()
							TweenService:Create(tabData.TitleLabel, TweenInfo.new(0.3), { TextColor3 = palette.Text })
								:Play()
						end
					end
 
					ToggleDropdown()
				end)
			end
		end
 
		function Tab:CreateChangelog(TitleText, ContentText)
			local Expanded = false
 
			local LogContainer = Instance.new("TextButton", Page)
			LogContainer.Size = UDim2.new(1, 0, 0, 36)
			LogContainer.BackgroundTransparency = 0.55
			LogContainer.AutoButtonColor = false
			LogContainer.Text = ""
			LogContainer.ClipsDescendants = true
			Instance.new("UICorner", LogContainer).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(LogContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local LogStroke = Instance.new("UIStroke", LogContainer)
			LogStroke.Thickness = 1
			LogStroke.Transparency = 0.85
			LogStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			punishgoatby97mzu:ApplyThemeObj(LogStroke, "Color", "Stroke")
 
			local Header = Instance.new("Frame", LogContainer)
			Header.Size = UDim2.new(1, 0, 0, 36)
			Header.BackgroundTransparency = 1
 
			local Title = Instance.new("TextLabel", Header)
			Title.Size = UDim2.new(1, -40, 1, 0)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.Text = TitleText
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			local Arrow = Instance.new("ImageLabel", Header)
			Arrow.Size = UDim2.new(0, 16, 0, 16)
			Arrow.AnchorPoint = Vector2.new(1, 0.5)
			Arrow.Position = UDim2.new(1, -15, 0.5, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Image = "rbxassetid://10709790948"
			punishgoatby97mzu:ApplyThemeObj(Arrow, "ImageColor3", "TextInactive")
 
			local ContentArea = Instance.new("Frame", LogContainer)
			ContentArea.Size = UDim2.new(1, 0, 0, 0)
			ContentArea.Position = UDim2.new(0, 0, 0, 36)
			ContentArea.BackgroundTransparency = 1
 
			local ContentPadding = Instance.new("UIPadding", ContentArea)
			ContentPadding.PaddingTop = UDim.new(0, 5)
			ContentPadding.PaddingBottom = UDim.new(0, 10)
			ContentPadding.PaddingLeft = UDim.new(0, 15)
			ContentPadding.PaddingRight = UDim.new(0, 15)
 
			local ContentLayout = Instance.new("UIListLayout", ContentArea)
			ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ContentLayout.Padding = UDim.new(0, 6)
 
			local lines = {}
			for s in string.gmatch(ContentText, "[^\r\n]+") do
				table.insert(lines, s)
			end
 
			for _, lineText in ipairs(lines) do
				local LogCard = Instance.new("Frame", ContentArea)
				LogCard.Size = UDim2.new(1, 0, 0, 26)
				LogCard.BackgroundTransparency = 0.5
				Instance.new("UICorner", LogCard).CornerRadius = UDim.new(0, 4)
				punishgoatby97mzu:ApplyThemeObj(LogCard, "BackgroundColor3", "ToggleBgOff")
 
				local CardStroke = Instance.new("UIStroke", LogCard)
				CardStroke.Thickness = 1
				CardStroke.Transparency = 0.8
				punishgoatby97mzu:ApplyThemeObj(CardStroke, "Color", "Stroke")
 
				local LogLineText = Instance.new("TextLabel", LogCard)
				LogLineText.Size = UDim2.new(1, -20, 1, 0)
				LogLineText.Position = UDim2.new(0, 10, 0, 0)
				LogLineText.BackgroundTransparency = 1
				LogLineText.Text = lineText
				LogLineText.Font = Enum.Font.GothamMedium
				LogLineText.TextSize = 11
				LogLineText.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(LogLineText, "TextColor3", "TextInactive")
			end
 
			local function ToggleLog()
				Expanded = not Expanded
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
 
				if Expanded then
					local TargetHeight = 36 + 15 + ContentLayout.AbsoluteContentSize.Y
					TweenService:Create(
						LogContainer,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, TargetHeight) }
					):Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), { Rotation = 180, ImageColor3 = palette.Accent })
						:Play()
					TweenService:Create(LogStroke, TweenInfo.new(0.3), { Color = palette.Accent, Transparency = 0.5 })
						:Play()
				else
					TweenService:Create(
						LogContainer,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, 36) }
					):Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), { Rotation = 0, ImageColor3 = palette.TextInactive })
						:Play()
					TweenService:Create(LogStroke, TweenInfo.new(0.3), { Color = palette.Stroke, Transparency = 0.85 })
						:Play()
				end
			end
 
			LogContainer.MouseButton1Click:Connect(ToggleLog)
			ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if Expanded then
					local TargetHeight = 36 + 15 + ContentLayout.AbsoluteContentSize.Y
					TweenService:Create(
						LogContainer,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine),
						{ Size = UDim2.new(1, 0, 0, TargetHeight) }
					):Play()
				end
			end)
		end
 
		function Tab:CreateToggle(ToggleName, Description, Default, Callback)
			local State = Default or false
			local CallbackFunc = Callback or function() end
			local HasDesc = type(Description) == "string" and Description ~= ""
 
			local ToggleBtn = Instance.new("TextButton", Page)
			ToggleBtn.Active = false
			ToggleBtn.Size = UDim2.new(1, 0, 0, HasDesc and 52 or 36)
			ToggleBtn.AutoButtonColor = false
			ToggleBtn.Text = ""
			ToggleBtn.BackgroundTransparency = 0.2
			Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(ToggleBtn, "BackgroundColor3", "ToggleBtnBg")
 
			local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
			ToggleStroke.Thickness = 1
			ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 
			ToggleStroke.Color = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Stroke
			ToggleStroke.Transparency = 0.85
 
			local function UpdateStrokeVisual(isActive, themeName)
				local palette = punishgoatby97mzu.Themes[themeName or punishgoatby97mzu.CurrentTheme]
				if isActive then
					TweenService:Create(
						ToggleStroke,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint),
						{ Color = palette.Accent, Transparency = 0.85 }
					):Play()
				else
					TweenService:Create(
						ToggleStroke,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint),
						{ Color = palette.Stroke, Transparency = 0.88 }
					):Play()
				end
			end
 
			UpdateStrokeVisual(State, punishgoatby97mzu.CurrentTheme)
			table.insert(punishgoatby97mzu.ThemeChangedHooks, {
				Inst = ToggleBtn,
				Func = function(tName)
					UpdateStrokeVisual(State, tName)
				end,
			})
 
			local Title = Instance.new("TextLabel", ToggleBtn)
			Title.Size = UDim2.new(1, -60, 0, 16)
			Title.Position = UDim2.new(0, 15, 0, HasDesc and 10 or 10)
			if not HasDesc then
				Title.Size = UDim2.new(1, -60, 1, 0)
				Title.Position = UDim2.new(0, 15, 0, 0)
			end
			Title.BackgroundTransparency = 1
			Title.Text = ToggleName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			if HasDesc then
				local DescLabel = Instance.new("TextLabel", ToggleBtn)
				DescLabel.Size = UDim2.new(1, -60, 0, 14)
				DescLabel.Position = UDim2.new(0, 15, 0, 26)
				DescLabel.BackgroundTransparency = 1
				DescLabel.Text = Description
				DescLabel.Font = Enum.Font.Gotham
				DescLabel.TextSize = 11
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(DescLabel, "TextColor3", "TextInactive")
			end
 
			local SwitchBg = Instance.new("Frame", ToggleBtn)
			SwitchBg.Size = UDim2.new(0, 36, 0, 18)
			SwitchBg.AnchorPoint = Vector2.new(1, 0.5)
			SwitchBg.Position = UDim2.new(1, -15, 0.5, 0)
			Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(SwitchBg, "BackgroundColor3", State and "Accent" or "ToggleBgOff")
 
			local Dot = Instance.new("Frame", SwitchBg)
			Dot.Size = UDim2.new(0, 14, 0, 14)
			Dot.AnchorPoint = Vector2.new(0, 0.5)
			Dot.Position = UDim2.new(0, State and 20 or 2, 0.5, 0)
			Dot.ZIndex = 2
			Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(Dot, "BackgroundColor3", "ToggleDot")
 
			ToggleBtn.MouseButton1Click:Connect(function()
				State = not State
				CallbackFunc(State)
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
 
				UpdateStrokeVisual(State)
 
				if State then
					TweenService
						:Create(
							Dot,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint),
							{ Position = UDim2.new(0, 20, 0.5, 0) }
						)
						:Play()
					TweenService
						:Create(
							SwitchBg,
							TweenInfo.new(0.3, Enum.EasingStyle.Quint),
							{ BackgroundColor3 = palette.Accent }
						)
						:Play()
				else
					TweenService
						:Create(Dot, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Position = UDim2.new(0, 2, 0.5, 0) })
						:Play()
					TweenService:Create(
						SwitchBg,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint),
						{ BackgroundColor3 = palette.ToggleBgOff }
					):Play()
				end
 
				for _, obj in pairs(punishgoatby97mzu.Instances) do
					if obj.Inst == SwitchBg then
						obj.Type = State and "Accent" or "ToggleBgOff"
					end
				end
			end)
		end
 
		function Tab:CreateButton(ButtonName, Description, IconID, Callback)
			local CallbackFunc = Callback or function() end
			local HasDesc = type(Description) == "string" and Description ~= ""
 
			local ButtonContainer = Instance.new("TextButton", Page)
			ButtonContainer.Active = false -- 🔥 TAMBAHKAN BARIS INI
			ButtonContainer.Size = UDim2.new(1, 0, 0, HasDesc and 52 or 36)
			ButtonContainer.BackgroundTransparency = 0.55
			ButtonContainer.AutoButtonColor = false
			ButtonContainer.Text = ""
			Instance.new("UICorner", ButtonContainer).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(ButtonContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local BtnStroke = Instance.new("UIStroke", ButtonContainer)
			BtnStroke.Thickness = 1
			BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			BtnStroke.Color = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Stroke
			BtnStroke.Transparency = 0.85
 
			local function UpdateBtnStrokeVisual(isActive, themeName)
				local palette = punishgoatby97mzu.Themes[themeName or punishgoatby97mzu.CurrentTheme]
				if isActive then
					TweenService:Create(
						BtnStroke,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint),
						{ Color = palette.Accent, Transparency = 0.5 }
					):Play()
				else
					TweenService:Create(
						BtnStroke,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine),
						{ Color = palette.Stroke, Transparency = 0.85 }
					):Play()
				end
			end
 
			UpdateBtnStrokeVisual(false, punishgoatby97mzu.CurrentTheme)
			table.insert(punishgoatby97mzu.ThemeChangedHooks, {
				Inst = ButtonContainer,
				Func = function(tName)
					UpdateBtnStrokeVisual(false, tName)
				end,
			})
 
			local Title = Instance.new("TextLabel", ButtonContainer)
			Title.Size = UDim2.new(1, -60, 0, 16)
			Title.Position = UDim2.new(0, 15, 0, HasDesc and 10 or 10)
			if not HasDesc then
				Title.Size = UDim2.new(1, -60, 1, 0)
				Title.Position = UDim2.new(0, 15, 0, 0)
			end
			Title.BackgroundTransparency = 1
			Title.Text = ButtonName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			if HasDesc then
				local DescLabel = Instance.new("TextLabel", ButtonContainer)
				DescLabel.Size = UDim2.new(1, -60, 0, 14)
				DescLabel.Position = UDim2.new(0, 15, 0, 26)
				DescLabel.BackgroundTransparency = 1
				DescLabel.Text = Description
				DescLabel.Font = Enum.Font.Gotham
				DescLabel.TextSize = 11
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(DescLabel, "TextColor3", "TextInactive")
			end
 
			local ActionKey = Instance.new("Frame", ButtonContainer)
			ActionKey.Size = UDim2.new(0, 30, 0, 30)
			ActionKey.AnchorPoint = Vector2.new(1, 0.5)
			ActionKey.Position = UDim2.new(1, -3, 0.5, 0)
			Instance.new("UICorner", ActionKey).CornerRadius = UDim.new(0, 6)
			punishgoatby97mzu:ApplyThemeObj(ActionKey, "BackgroundColor3", "ToggleBgOff")
 
			local KeyStroke = Instance.new("UIStroke", ActionKey)
			KeyStroke.Thickness = 1
			KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			KeyStroke.Color = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Stroke
			KeyStroke.Transparency = 0.7
 
			local Icon = Instance.new("ImageLabel", ActionKey)
			Icon.Size = UDim2.new(0, 18, 0, 18)
			Icon.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			Icon.BackgroundTransparency = 1
			Icon.Image = IconID or "rbxassetid://10734933056"
			punishgoatby97mzu:ApplyThemeObj(Icon, "ImageColor3", "TextInactive")
 
			ButtonContainer.MouseEnter:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(ActionKey, TweenInfo.new(0.2), {
					BackgroundColor3 = Color3.fromRGB(
						math.clamp(palette.ToggleBgOff.R * 255 + 12, 0, 255),
						math.clamp(palette.ToggleBgOff.G * 255 + 12, 0, 255),
						math.clamp(palette.ToggleBgOff.B * 255 + 12, 0, 255)
					),
				}):Play()
				TweenService:Create(KeyStroke, TweenInfo.new(0.2), { Color = palette.Accent, Transparency = 0.4 })
					:Play()
				TweenService:Create(Icon, TweenInfo.new(0.2), { ImageColor3 = palette.Text }):Play()
			end)
 
			ButtonContainer.MouseLeave:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(ActionKey, TweenInfo.new(0.2), { BackgroundColor3 = palette.ToggleBgOff }):Play()
				TweenService:Create(KeyStroke, TweenInfo.new(0.2), { Color = palette.Stroke, Transparency = 0.7 })
					:Play()
				TweenService:Create(Icon, TweenInfo.new(0.2), { ImageColor3 = palette.TextInactive }):Play()
			end)
 
			ButtonContainer.MouseButton1Click:Connect(function()
				CallbackFunc()
			end)
 
			ButtonContainer.MouseButton1Down:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService
					:Create(ActionKey, TweenInfo.new(0.05, Enum.EasingStyle.Sine), { Size = UDim2.new(0, 26, 0, 26) })
					:Play()
				TweenService:Create(
					Icon,
					TweenInfo.new(0.05, Enum.EasingStyle.Sine),
					{ Size = UDim2.new(0, 14, 0, 14), ImageColor3 = palette.Accent }
				):Play()
				TweenService:Create(
					KeyStroke,
					TweenInfo.new(0.05, Enum.EasingStyle.Sine),
					{ Color = palette.Accent, Transparency = 0.2 }
				):Play()
				UpdateBtnStrokeVisual(true)
			end)
 
			local function ResetButtonAnim()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(
					ActionKey,
					TweenInfo.new(0.3, Enum.EasingStyle.Bounce),
					{ Size = UDim2.new(0, 30, 0, 30), BackgroundColor3 = palette.ToggleBgOff }
				):Play()
				TweenService:Create(
					Icon,
					TweenInfo.new(0.3, Enum.EasingStyle.Bounce),
					{ Size = UDim2.new(0, 18, 0, 18), ImageColor3 = palette.TextInactive }
				):Play()
				TweenService:Create(
					KeyStroke,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine),
					{ Color = palette.Stroke, Transparency = 0.7 }
				):Play()
				UpdateBtnStrokeVisual(false)
			end
 
			ButtonContainer.MouseButton1Up:Connect(ResetButtonAnim)
		end
 
		function Tab:CreateSlider(SliderName, Min, Max, Default, Callback)
			local CallbackFunc = Callback or function() end
			local Value = math.clamp(Default or Min, Min, Max)
 
			local SliderContainer = Instance.new("TextButton", Page)
			SliderContainer.Active = false
			SliderContainer.Size = UDim2.new(1, 0, 0, 42)
			SliderContainer.BackgroundTransparency = 0.55
			SliderContainer.AutoButtonColor = false
			SliderContainer.Text = ""
			Instance.new("UICorner", SliderContainer).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(SliderContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local SliderStroke = Instance.new("UIStroke", SliderContainer)
			SliderStroke.Thickness = 1
			SliderStroke.Transparency = 0.85
			SliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			punishgoatby97mzu:ApplyThemeObj(SliderStroke, "Color", "Stroke")
 
			local Title = Instance.new("TextLabel", SliderContainer)
			Title.Size = UDim2.new(1, -100, 0, 20)
			Title.Position = UDim2.new(0, 15, 0, 5)
			Title.BackgroundTransparency = 1
			Title.Text = SliderName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			local ValueCard = Instance.new("Frame", SliderContainer)
			ValueCard.Size = UDim2.new(0, 35, 0, 20)
			ValueCard.AnchorPoint = Vector2.new(1, 0)
			ValueCard.Position = UDim2.new(1, -15, 0, 5)
			ValueCard.BackgroundTransparency = 0.5
			ValueCard.BorderSizePixel = 0
			Instance.new("UICorner", ValueCard).CornerRadius = UDim.new(0, 4)
			punishgoatby97mzu:ApplyThemeObj(ValueCard, "BackgroundColor3", "ToggleBgOff")
 
			local CardStroke = Instance.new("UIStroke", ValueCard)
			CardStroke.Thickness = 1
			CardStroke.Transparency = 0.8
			punishgoatby97mzu:ApplyThemeObj(CardStroke, "Color", "Stroke")
 
			local ValueInput = Instance.new("TextBox", ValueCard)
			ValueInput.Size = UDim2.new(1, 0, 1, 0)
			ValueInput.BackgroundTransparency = 1
			ValueInput.Text = tostring(Value)
			ValueInput.Font = Enum.Font.GothamMedium
			ValueInput.TextSize = 12
			ValueInput.ClearTextOnFocus = false
			punishgoatby97mzu:ApplyThemeObj(ValueInput, "TextColor3", "Text")
 
			local SliderBg = Instance.new("Frame", SliderContainer)
			SliderBg.Size = UDim2.new(1, -30, 0, 4)
			SliderBg.AnchorPoint = Vector2.new(0.5, 1)
			SliderBg.Position = UDim2.new(0.5, 0, 1, -8)
			SliderBg.BorderSizePixel = 0
			Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(SliderBg, "BackgroundColor3", "ToggleBgOff")
 
			local SliderFill = Instance.new("Frame", SliderBg)
			local SizeScale = (Value - Min) / (Max - Min)
			SliderFill.Size = UDim2.new(SizeScale, 0, 1, 0)
			SliderFill.BorderSizePixel = 0
			Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(SliderFill, "BackgroundColor3", "Accent")
 
			local Dot = Instance.new("Frame", SliderFill)
			Dot.Size = UDim2.new(0, 12, 0, 12)
			Dot.AnchorPoint = Vector2.new(1, 0.5)
			Dot.Position = UDim2.new(1, 6, 0.5, 0)
			Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(Dot, "BackgroundColor3", "ToggleDot")
 
			local DotStroke = Instance.new("UIStroke", Dot)
			DotStroke.Thickness = 1
			punishgoatby97mzu:ApplyThemeObj(DotStroke, "Color", "Stroke")
 
			local Dragging = false
			local function UpdateSlider(Input)
				local Percent =
					math.clamp((Input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
				Value = math.floor(Min + ((Max - Min) * Percent))
				ValueInput.Text = tostring(Value)
				TweenService
					:Create(
						SliderFill,
						TweenInfo.new(0.05, Enum.EasingStyle.Sine),
						{ Size = UDim2.new(Percent, 0, 1, 0) }
					)
					:Play()
				CallbackFunc(Value)
			end
 
			SliderContainer.InputBegan:Connect(function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					Dragging = true
					UpdateSlider(Input)
					TweenService
						:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 16, 0, 16) })
						:Play()
				end
			end)
 
			UserInputService.InputChanged:Connect(function(Input)
				if
					Dragging
					and (
						Input.UserInputType == Enum.UserInputType.MouseMovement
						or Input.UserInputType == Enum.UserInputType.Touch
					)
				then
					UpdateSlider(Input)
				end
			end)
 
			UserInputService.InputEnded:Connect(function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					if Dragging then
						Dragging = false
						TweenService
							:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 12, 0, 12) })
							:Play()
					end
				end
			end)
 
			SliderContainer.MouseEnter:Connect(function()
				if not Dragging then
					TweenService
						:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 16, 0, 16) })
						:Play()
				end
			end)
			SliderContainer.MouseLeave:Connect(function()
				if not Dragging then
					TweenService
						:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 12, 0, 12) })
						:Play()
				end
			end)
 
			ValueInput.FocusLost:Connect(function()
				local Num = tonumber(ValueInput.Text)
				if Num then
					Value = math.clamp(math.floor(Num), Min, Max)
					local NewScale = (Value - Min) / (Max - Min)
					TweenService:Create(
						SliderFill,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint),
						{ Size = UDim2.new(NewScale, 0, 1, 0) }
					):Play()
					CallbackFunc(Value)
				end
				ValueInput.Text = tostring(Value)
			end)
		end
 
function Tab:CreateImageParagraph(Title, Desc, Image)
    local Container = Instance.new("Frame", Page)
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BackgroundTransparency = 0.55
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
    punishgoatby97mzu:ApplyThemeObj(Container, "BackgroundColor3", "ToggleBtnBg")

    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.85
    punishgoatby97mzu:ApplyThemeObj(Stroke, "Color", "Stroke")

    local Padding = Instance.new("UIPadding", Container)
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)

    local Top = Instance.new("Frame", Container)
    Top.Size = UDim2.new(1, 0, 0, 40)
    Top.BackgroundTransparency = 1

    local ImageLabel = Instance.new("ImageLabel", Top)
    ImageLabel.Size = UDim2.new(0, 36, 0, 36)
    ImageLabel.Position = UDim2.new(0, 0, 0.5, -16)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Image = Image or ""

    local Corner = Instance.new("UICorner", ImageLabel)
    Corner.CornerRadius = UDim.new(0, 5)

    local TitleLbl = Instance.new("TextLabel", Top)
    TitleLbl.Position = UDim2.new(0, 42, 0, 5)
    TitleLbl.Size = UDim2.new(1, -42, 0, 16)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = Title or ""
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.RichText = true
    punishgoatby97mzu:ApplyThemeObj(TitleLbl, "TextColor3", "Text")

    local DescLbl = Instance.new("TextLabel", Top)
    DescLbl.Position = UDim2.new(0, 42, 0, 19)
    DescLbl.Size = UDim2.new(1, -42, 0, 14)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = Desc or ""
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextSize = 13.4
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.RichText = true
    punishgoatby97mzu:ApplyThemeObj(DescLbl, "TextColor3", "TextInactive")

    local Obj = {}

    function Obj:SetTitle(NewTitle)
        TitleLbl.Text = NewTitle
    end

    function Obj:SetDescription(NewDesc)
        DescLbl.Text = NewDesc
    end

    function Obj:SetImage(NewImage)
        ImageLabel.Image = NewImage
    end

    return Obj
end

		function Tab:CreateInput(InputName, Description, Placeholder, ExtraIcon, ExtraCallback, TextCallback)
			if type(ExtraIcon) == "function" then
				TextCallback = ExtraIcon
				ExtraIcon = nil
				ExtraCallback = nil
			end
 
			local CallbackFunc = TextCallback or function() end
			local HasDesc = type(Description) == "string" and Description ~= ""
 
			local InputContainer = Instance.new("TextButton", Page)
			InputContainer.Active = false
			InputContainer.Size = UDim2.new(1, 0, 0, HasDesc and 52 or 36)
			InputContainer.BackgroundTransparency = 0.55
			InputContainer.AutoButtonColor = false
			InputContainer.Text = ""
			Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(InputContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local InputStroke = Instance.new("UIStroke", InputContainer)
			InputStroke.Thickness = 1
			InputStroke.Transparency = 0.85
			InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			punishgoatby97mzu:ApplyThemeObj(InputStroke, "Color", "Stroke")
 
			local Title = Instance.new("TextLabel", InputContainer)
			Title.Size = UDim2.new(1, ExtraIcon and -200 or -170, 0, 16)
			Title.Position = UDim2.new(0, 15, 0, HasDesc and 10 or 10)
			if not HasDesc then
				Title.Size = UDim2.new(1, ExtraIcon and -200 or -170, 1, 0)
				Title.Position = UDim2.new(0, 15, 0, 0)
			end
			Title.BackgroundTransparency = 1
			Title.Text = InputName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			if HasDesc then
				local DescLabel = Instance.new("TextLabel", InputContainer)
				DescLabel.Size = UDim2.new(1, ExtraIcon and -200 or -170, 0, 14)
				DescLabel.Position = UDim2.new(0, 15, 0, 26)
				DescLabel.BackgroundTransparency = 1
				DescLabel.Text = Description
				DescLabel.Font = Enum.Font.Gotham
				DescLabel.TextSize = 11
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(DescLabel, "TextColor3", "TextInactive")
			end
 
			local TextBoxCard = Instance.new("Frame", InputContainer)
			TextBoxCard.Size = UDim2.new(0, ExtraIcon and 180 or 150, 0, 26)
			TextBoxCard.AnchorPoint = Vector2.new(1, 0.5)
			TextBoxCard.Position = UDim2.new(1, -10, 0.5, 0)
			TextBoxCard.BackgroundTransparency = 0.5
			Instance.new("UICorner", TextBoxCard).CornerRadius = UDim.new(0, 6)
			punishgoatby97mzu:ApplyThemeObj(TextBoxCard, "BackgroundColor3", "ToggleBgOff")
 
			local CardStroke = Instance.new("UIStroke", TextBoxCard)
			CardStroke.Thickness = 1
			CardStroke.Transparency = 0.7
			punishgoatby97mzu:ApplyThemeObj(CardStroke, "Color", "Stroke")
 
			local TextBox = Instance.new("TextBox", TextBoxCard)
			TextBox.Size = UDim2.new(1, ExtraIcon and -36 or -16, 1, 0)
			TextBox.Position = UDim2.new(0, 8, 0, 0)
			TextBox.BackgroundTransparency = 1
			TextBox.Text = ""
			TextBox.PlaceholderText = Placeholder or "Type here..."
			TextBox.Font = Enum.Font.GothamMedium
			TextBox.TextSize = 11
			TextBox.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.ClearTextOnFocus = false
			TextBox.ClipsDescendants = true
			punishgoatby97mzu:ApplyThemeObj(TextBox, "TextColor3", "Text")
			punishgoatby97mzu:ApplyThemeObj(TextBox, "PlaceholderColor3", "TextInactive")
 
			TextBox.Focused:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(CardStroke, TweenInfo.new(0.3), { Color = palette.Accent, Transparency = 0.3 })
					:Play()
			end)
 
			TextBox.FocusLost:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(CardStroke, TweenInfo.new(0.3), { Color = palette.Stroke, Transparency = 0.7 })
					:Play()
				CallbackFunc(TextBox.Text)
			end)
			-- [FIX FOCUSLOST BUG] Save instantly so the value registers even before pressing Enter!
			TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				CallbackFunc(TextBox.Text)
			end)
 
			if ExtraIcon then
				local ExtraBtn = Instance.new("ImageButton", TextBoxCard)
				ExtraBtn.Size = UDim2.new(0, 20, 0, 20)
				ExtraBtn.Position = UDim2.new(1, -4, 0.5, 0)
				ExtraBtn.AnchorPoint = Vector2.new(1, 0.5)
				ExtraBtn.BackgroundTransparency = 1
				ExtraBtn.Image = ExtraIcon
				punishgoatby97mzu:ApplyThemeObj(ExtraBtn, "ImageColor3", "Accent")
 
				ExtraBtn.MouseButton1Click:Connect(function()
					TweenService:Create(ExtraBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 16, 0, 16) }):Play()
					task.wait(0.1)
					TweenService:Create(ExtraBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 20, 0, 20) }):Play()
					if ExtraCallback then
						ExtraCallback(TextBox.Text)
					end
				end)
			end
		end
 
		-- CreateDropdown builds a collapsible group of controls. Scripts written
		-- for option-picker style dropdowns pass (name, desc, {options}, callback),
		-- so in that case we transparently hand off to CreateSelect.
		function Tab:CreateDropdown(DropdownName, Description, Options, Callback)
			if type(Options) == "table" then
				return Tab:CreateSelect(DropdownName, Description, Options, nil, Callback)
			end
			if type(Description) == "table" then
				return Tab:CreateSelect(DropdownName, nil, Description, nil, Options)
			end
			local Expanded = false
 
			local DropdownContainer = Instance.new("Frame", Page)
			DropdownContainer.Name = "Dropdown_" .. DropdownName
			DropdownContainer.Size = UDim2.new(1, 0, 0, 36)
			DropdownContainer.BackgroundTransparency = 0.55
			DropdownContainer.ClipsDescendants = true
			Instance.new("UICorner", DropdownContainer).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(DropdownContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local ContainerStroke = Instance.new("UIStroke", DropdownContainer)
			ContainerStroke.Thickness = 1
			ContainerStroke.Transparency = 0.85
			ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			punishgoatby97mzu:ApplyThemeObj(ContainerStroke, "Color", "Stroke")
 
			local Header = Instance.new("TextButton", DropdownContainer)
			Header.Active = false
			Header.Size = UDim2.new(1, 0, 0, 36)
			Header.BackgroundTransparency = 1
			Header.AutoButtonColor = false
			Header.Text = ""
 
			local Title = Instance.new("TextLabel", Header)
			Title.Size = UDim2.new(1, -60, 1, 0)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.Text = DropdownName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			local Arrow = Instance.new("ImageLabel", Header)
			Arrow.Size = UDim2.new(0, 16, 0, 16)
			Arrow.AnchorPoint = Vector2.new(1, 0.5)
			Arrow.Position = UDim2.new(1, -15, 0.5, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Image = "rbxassetid://10709791523"
			punishgoatby97mzu:ApplyThemeObj(Arrow, "ImageColor3", "TextInactive")
 
			local ContentArea = Instance.new("Frame", DropdownContainer)
			ContentArea.Size = UDim2.new(1, 0, 0, 0)
			ContentArea.Position = UDim2.new(0, 0, 0, 36)
			ContentArea.BackgroundTransparency = 1
 
			local ContentPadding = Instance.new("UIPadding", ContentArea)
			ContentPadding.PaddingTop = UDim.new(0, 8)
			ContentPadding.PaddingBottom = UDim.new(0, 2)
			ContentPadding.PaddingLeft = UDim.new(0, 12)
			ContentPadding.PaddingRight = UDim.new(0, 12)
 
			local ContentLayout = Instance.new("UIListLayout", ContentArea)
			ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ContentLayout.Padding = UDim.new(0, 6)
 
			local function ToggleDropdown()
				Expanded = not Expanded
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
 
				if Expanded then
					local TargetHeight = 36 + 16 + ContentLayout.AbsoluteContentSize.Y
					TweenService:Create(
						DropdownContainer,
						TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, TargetHeight) }
					):Play()
					TweenService
						:Create(ContainerStroke, TweenInfo.new(0.3), { Color = palette.Accent, Transparency = 0.5 })
						:Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), { ImageColor3 = palette.Accent, Rotation = 180 })
						:Play()
					TweenService:Create(Title, TweenInfo.new(0.3), { TextColor3 = palette.Accent }):Play()
				else
					TweenService:Create(
						DropdownContainer,
						TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = UDim2.new(1, 0, 0, 36) }
					):Play()
					TweenService
						:Create(ContainerStroke, TweenInfo.new(0.3), { Color = palette.Stroke, Transparency = 0.85 })
						:Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), { ImageColor3 = palette.TextInactive, Rotation = 0 })
						:Play()
					TweenService:Create(Title, TweenInfo.new(0.3), { TextColor3 = palette.Text }):Play()
				end
			end
 
			Header.MouseButton1Click:Connect(ToggleDropdown)
 
			local function ForceCloseDropdown()
				if Expanded then
					Expanded = false
					local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
					TweenService:Create(DropdownContainer, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 36) }):Play()
					TweenService
						:Create(ContainerStroke, TweenInfo.new(0.2), { Color = palette.Stroke, Transparency = 0.85 })
						:Play()
					TweenService:Create(Arrow, TweenInfo.new(0.2), { ImageColor3 = palette.TextInactive, Rotation = 0 })
						:Play()
					TweenService:Create(Title, TweenInfo.new(0.2), { TextColor3 = palette.Text }):Play()
				end
			end
			table.insert(Window.DropdownCloseFuncs, ForceCloseDropdown)
 
			ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if Expanded then
					local TargetHeight = 36 + 16 + ContentLayout.AbsoluteContentSize.Y
					TweenService:Create(
						DropdownContainer,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine),
						{ Size = UDim2.new(1, 0, 0, TargetHeight) }
					):Play()
				end
			end)
 
			local DropdownObj = {}
			function DropdownObj:CreateToggle(...)
				local oldPage = Page
				Page = ContentArea
				Tab.CreateToggle(Tab, ...)
				Page = oldPage
			end
			function DropdownObj:CreateButton(...)
				local oldPage = Page
				Page = ContentArea
				Tab.CreateButton(Tab, ...)
				Page = oldPage
			end
			function DropdownObj:CreateSlider(...)
				local oldPage = Page
				Page = ContentArea
				Tab.CreateSlider(Tab, ...)
				Page = oldPage
			end
			function DropdownObj:CreateInput(...)
				local oldPage = Page
				Page = ContentArea
				Tab.CreateInput(Tab, ...)
				Page = oldPage
			end
			function DropdownObj:CreateSelect(...)
				local oldPage = Page
				Page = ContentArea
				Tab.CreateSelect(Tab, ...)
				Page = oldPage
			end
			return DropdownObj
		end
 
		function Tab:CreateSelect(SelectName, Description, Options, Default, Callback)
			local CallbackFunc = Callback or function() end
			local OptionsList = Options or {}
			local Expanded = false
			local HasDesc = type(Description) == "string" and Description ~= ""
 
			local SelectedItems = {}
			if type(Default) == "table" then
				for _, v in pairs(Default) do
					table.insert(SelectedItems, v)
				end
			elseif type(Default) == "string" and Default ~= "None" and Default ~= "" then
				table.insert(SelectedItems, Default)
			end
 
			local TriggerBtn = Instance.new("TextButton", Page)
			TriggerBtn.Active = false
			TriggerBtn.Size = UDim2.new(1, 0, 0, HasDesc and 52 or 36)
			TriggerBtn.BackgroundTransparency = 0.55
			TriggerBtn.AutoButtonColor = false
			TriggerBtn.Text = ""
			Instance.new("UICorner", TriggerBtn).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(TriggerBtn, "BackgroundColor3", "ToggleBtnBg")
 
			local TriggerStroke = Instance.new("UIStroke", TriggerBtn)
			TriggerStroke.Thickness = 1
			TriggerStroke.Transparency = 0.85
			TriggerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			punishgoatby97mzu:ApplyThemeObj(TriggerStroke, "Color", "Stroke")
 
			local Title = Instance.new("TextLabel", TriggerBtn)
			Title.Size = UDim2.new(0.5, -15, 0, 16)
			Title.Position = UDim2.new(0, 15, 0, HasDesc and 10 or 10)
			if not HasDesc then
				Title.Size = UDim2.new(0.5, -15, 1, 0)
				Title.Position = UDim2.new(0, 15, 0, 0)
			end
			Title.BackgroundTransparency = 1
			Title.Text = SelectName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			if HasDesc then
				local DescLabel = Instance.new("TextLabel", TriggerBtn)
				DescLabel.Size = UDim2.new(0.5, -15, 0, 14)
				DescLabel.Position = UDim2.new(0, 15, 0, 26)
				DescLabel.BackgroundTransparency = 1
				DescLabel.Text = Description
				DescLabel.Font = Enum.Font.Gotham
				DescLabel.TextSize = 11
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(DescLabel, "TextColor3", "TextInactive")
			end
 
			local SelectedText = Instance.new("TextLabel", TriggerBtn)
			SelectedText.Size = UDim2.new(0.5, -35, 1, 0)
			SelectedText.Position = UDim2.new(0.5, 0, 0, 0)
			SelectedText.BackgroundTransparency = 1
			SelectedText.Font = Enum.Font.GothamMedium
			SelectedText.TextSize = 12
			SelectedText.TextXAlignment = Enum.TextXAlignment.Right
			punishgoatby97mzu:ApplyThemeObj(SelectedText, "TextColor3", "TextInactive")
 
			local Arrow = Instance.new("ImageLabel", TriggerBtn)
			Arrow.Size = UDim2.new(0, 16, 0, 16)
			Arrow.AnchorPoint = Vector2.new(1, 0.5)
			Arrow.Position = UDim2.new(1, -15, 0.5, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Image = "rbxassetid://10709790948"
			punishgoatby97mzu:ApplyThemeObj(Arrow, "ImageColor3", "TextInactive")
 
			local function UpdateTriggerText()
				-- If empty OR only "Any" / "All" is selected, automatically display "--"
				if #SelectedItems == 0 or (#SelectedItems == 1 and (SelectedItems[1] == "Any" or SelectedItems[1] == "All")) then
					SelectedText.Text = "--"
				elseif #SelectedItems == 1 then
					SelectedText.Text = SelectedItems[1]
				else
					SelectedText.Text = tostring(#SelectedItems) .. " Selected"
				end
			end
			UpdateTriggerText()
 
			local ContainerParent = ContentContainer
 
			local CloseArea = Instance.new("TextButton", ContainerParent)
			CloseArea.Size = UDim2.new(1, 0, 1, 0)
			CloseArea.BackgroundTransparency = 1
			CloseArea.Text = ""
			CloseArea.ZIndex = 9
			CloseArea.Visible = false
 
			local SidePanel = Instance.new("Frame", ContainerParent)
			SidePanel.Name = "SidePanel_" .. SelectName
			SidePanel.Size = UDim2.new(0.55, -10, 1, -10)
			SidePanel.Position = UDim2.new(1, 10, 0, 5)
			SidePanel.BackgroundTransparency = 0.05
			SidePanel.ZIndex = 10
			Instance.new("UICorner", SidePanel).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(SidePanel, "BackgroundColor3", "ToggleBgOff")
 
			local PanelStroke = Instance.new("UIStroke", SidePanel)
			PanelStroke.Thickness = 1
			PanelStroke.Transparency = 0.85
			punishgoatby97mzu:ApplyThemeObj(PanelStroke, "Color", "Stroke")
 
			local SearchContainer = Instance.new("Frame", SidePanel)
			SearchContainer.Size = UDim2.new(1, -20, 0, 30)
			SearchContainer.Position = UDim2.new(0, 10, 0, 10)
			SearchContainer.BackgroundTransparency = 0.5
			SearchContainer.ZIndex = 11
			Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 6)
			punishgoatby97mzu:ApplyThemeObj(SearchContainer, "BackgroundColor3", "ToggleBtnBg")
 
			local SearchStroke = Instance.new("UIStroke", SearchContainer)
			SearchStroke.Thickness = 1
			SearchStroke.Transparency = 0.8
			punishgoatby97mzu:ApplyThemeObj(SearchStroke, "Color", "Stroke")
 
			local SearchIcon = Instance.new("ImageLabel", SearchContainer)
			SearchIcon.Size = UDim2.new(0, 14, 0, 14)
			SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
			SearchIcon.Position = UDim2.new(0, 10, 0.5, 0)
			SearchIcon.BackgroundTransparency = 1
			SearchIcon.Image = "rbxassetid://10709761217"
			SearchIcon.ZIndex = 11
			punishgoatby97mzu:ApplyThemeObj(SearchIcon, "ImageColor3", "TextInactive")
 
			local SearchInput = Instance.new("TextBox", SearchContainer)
			SearchInput.Size = UDim2.new(1, -34, 1, 0)
			SearchInput.Position = UDim2.new(0, 30, 0, 0)
			SearchInput.BackgroundTransparency = 1
			SearchInput.Text = ""
			SearchInput.PlaceholderText = "Search..."
			SearchInput.Font = Enum.Font.GothamMedium
			SearchInput.TextSize = 12
			SearchInput.TextXAlignment = Enum.TextXAlignment.Left
			SearchInput.ZIndex = 11
			SearchInput.ClearTextOnFocus = false
			punishgoatby97mzu:ApplyThemeObj(SearchInput, "TextColor3", "Text")
			punishgoatby97mzu:ApplyThemeObj(SearchInput, "PlaceholderColor3", "TextInactive")
 
			SearchInput.Focused:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(SearchStroke, TweenInfo.new(0.3), { Color = palette.Accent, Transparency = 0.3 })
					:Play()
			end)
 
			SearchInput.FocusLost:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(SearchStroke, TweenInfo.new(0.3), { Color = palette.Stroke, Transparency = 0.8 })
					:Play()
			end)
 
		local ItemList = Instance.new("ScrollingFrame", SidePanel)
		ItemList.Size = UDim2.new(1, 0, 1, -55)
		ItemList.Position = UDim2.new(0, 10, 0, 50)
		ItemList.BackgroundTransparency = 1
		ItemList.BorderSizePixel = 0
		ItemList.ScrollBarThickness = 2
		ItemList.ZIndex = 11
 
		-- Use Roblox's built-in AutomaticCanvasSize so the search list doesn't lag while scrolling
		ItemList.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ItemList.CanvasSize = UDim2.new(0, 0, 0, 0)
		punishgoatby97mzu:ApplyThemeObj(ItemList, "ScrollBarImageColor3", "Stroke")
 
		local ListPadding = Instance.new("UIPadding", ItemList)
		ListPadding.PaddingLeft = UDim.new(0, 1)
		ListPadding.PaddingRight = UDim.new(0, 20)
		ListPadding.PaddingTop = UDim.new(0, 5)
 
		ListPadding.PaddingBottom = UDim.new(0, 5)
 
		local ListLayout = Instance.new("UIListLayout", ItemList)
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 6)
 
			local OptionButtons = {}
 
			local function ClosePanel()
				Expanded = false
				CloseArea.Visible = false
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(
					SidePanel,
					TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Position = UDim2.new(1, 10, 0, 5) }
				):Play()
				TweenService:Create(Arrow, TweenInfo.new(0.3), { Rotation = 0, ImageColor3 = palette.TextInactive })
					:Play()
				TweenService:Create(TriggerStroke, TweenInfo.new(0.3), { Transparency = 0.85, Color = palette.Stroke })
					:Play()
			end
 
			table.insert(Window.SelectCloseFuncs, ClosePanel)
			CloseArea.MouseButton1Click:Connect(ClosePanel)
 
			local function RefreshOptions()
				for _, btn in pairs(OptionButtons) do
					btn:Destroy()
				end
				table.clear(OptionButtons)
 
				local FilterText = string.lower(SearchInput.Text)
 
				for _, opt in ipairs(OptionsList) do
					if FilterText == "" or string.find(string.lower(opt), FilterText) then
						local OptBtn = Instance.new("TextButton", ItemList)
						OptBtn.Active = false
						OptBtn.Size = UDim2.new(1, 0, 0, 32)
						OptBtn.BackgroundTransparency = 0.95
						OptBtn.AutoButtonColor = false
						OptBtn.Text = ""
						OptBtn.ZIndex = 12
						Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6)
						punishgoatby97mzu:ApplyThemeObj(OptBtn, "BackgroundColor3", "ToggleBtnBg")
 
						local OptStroke = Instance.new("UIStroke", OptBtn)
						OptStroke.Thickness = 1
						OptStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 
						local Indicator = Instance.new("Frame", OptBtn)
						local isSelected = table.find(SelectedItems, opt) ~= nil
						Indicator.Size = UDim2.new(0, 3, 0, isSelected and 16 or 0)
						Indicator.AnchorPoint = Vector2.new(0, 0.5)
						Indicator.Position = UDim2.new(0, 4, 0.5, 0)
						Indicator.BorderSizePixel = 0
						Indicator.ZIndex = 12
						Indicator.BackgroundTransparency = 0
						Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
						punishgoatby97mzu:ApplyThemeObj(Indicator, "BackgroundColor3", "Accent")
 
						local ItemTitle = Instance.new("TextLabel", OptBtn)
						ItemTitle.Size = UDim2.new(1, -30, 1, 0)
						ItemTitle.Position = UDim2.new(0, 15, 0, 0)
						ItemTitle.BackgroundTransparency = 1
						ItemTitle.Text = opt
						ItemTitle.Font = Enum.Font.GothamMedium
						ItemTitle.TextSize = 12
						ItemTitle.TextXAlignment = Enum.TextXAlignment.Left
						ItemTitle.ZIndex = 12
 
						if isSelected then
							OptStroke.Transparency = 0.95
							punishgoatby97mzu:ApplyThemeObj(OptStroke, "Color", "Accent")
							punishgoatby97mzu:ApplyThemeObj(ItemTitle, "TextColor3", "Accent")
							OptBtn.BackgroundTransparency = 0.55
						else
							OptStroke.Transparency = 0.85
							punishgoatby97mzu:ApplyThemeObj(OptStroke, "Color", "Stroke")
							punishgoatby97mzu:ApplyThemeObj(ItemTitle, "TextColor3", "Text")
							OptBtn.BackgroundTransparency = 0.95
						end
 
						OptBtn.MouseButton1Click:Connect(function()
							local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
							local idx = table.find(SelectedItems, opt)
 
							if idx then
								table.remove(SelectedItems, idx)
								TweenService:Create(
									Indicator,
									TweenInfo.new(0.3, Enum.EasingStyle.Quint),
									{ Size = UDim2.new(0, 3, 0, 0) }
								):Play()
								TweenService
									:Create(
										OptStroke,
										TweenInfo.new(0.3),
										{ Transparency = 0.85, Color = palette.Stroke }
									)
									:Play()
								TweenService:Create(ItemTitle, TweenInfo.new(0.3), { TextColor3 = palette.Text }):Play()
								TweenService:Create(OptBtn, TweenInfo.new(0.3), { BackgroundTransparency = 0.95 })
									:Play()
							else
								table.insert(SelectedItems, opt)
								TweenService:Create(
									Indicator,
									TweenInfo.new(0.3, Enum.EasingStyle.Quint),
									{ Size = UDim2.new(0, 3, 0, 16) }
								):Play()
								TweenService
									:Create(
										OptStroke,
										TweenInfo.new(0.3),
										{ Transparency = 0.95, Color = palette.Accent }
									)
									:Play()
								TweenService:Create(ItemTitle, TweenInfo.new(0.3), { TextColor3 = palette.Accent })
									:Play()
								TweenService:Create(OptBtn, TweenInfo.new(0.3), { BackgroundTransparency = 0.55 })
									:Play()
							end
 
							UpdateTriggerText()
							CallbackFunc(SelectedItems)
						end)
 
						table.insert(OptionButtons, OptBtn)
					end
				end
			end
 
			RefreshOptions()
 
			SearchInput:GetPropertyChangedSignal("Text"):Connect(RefreshOptions)
 
			TriggerBtn.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
 
				if Expanded then
					CloseArea.Visible = true
					TweenService:Create(
						SidePanel,
						TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.45, 5, 0, 5) }
					):Play()
					TweenService:Create(Arrow, TweenInfo.new(0.3), { Rotation = 90, ImageColor3 = palette.Accent })
						:Play()
					TweenService
						:Create(TriggerStroke, TweenInfo.new(0.3), { Transparency = 0.5, Color = palette.Accent })
						:Play()
				else
					ClosePanel()
				end
			end)
 
			local SelectObj = {}
			
			-- New internal function to force a selection change from outside the library
			local function SetSelection(newSelection)
				SelectedItems = {}
				if type(newSelection) == "table" then
					for _, v in pairs(newSelection) do
						table.insert(SelectedItems, v)
					end
				elseif type(newSelection) == "string" and newSelection ~= "None" and newSelection ~= "" then
					table.insert(SelectedItems, newSelection)
				end
				UpdateTriggerText()
				RefreshOptions()
				pcall(function() CallbackFunc(SelectedItems) end)
			end
 
			-- Expose the Set function so it can be called from the main script
			function SelectObj:Set(newSelection)
				SetSelection(newSelection)
			end
 
			function SelectObj:SetValue(newSelection)
				SetSelection(newSelection)
			end
 
			-- Update the Refresh function to support auto-cleaning stale data
			function SelectObj:Refresh(NewOptions, KeepSelection)
                OptionsList = NewOptions or {}
                
                if KeepSelection == false then
                    SelectedItems = {}
                else
                    -- [SMART AUTO-CLEAN & UPGRADE SYNC]
                    local validSet = {}
                    for _, opt in ipairs(OptionsList) do
                        validSet[opt] = true
                    end
                    
                    for i = #SelectedItems, 1, -1 do
                        local item = SelectedItems[i]
                        if item ~= "Any" and item ~= "All" and not validSet[item] then
                            -- MAIN FIX: check whether this is just a level-up/mutation change, NOT actually removed
                            local baseItem = item:match("^(.-)%s*%[Lvl") or item:match("^(.-)%s*%[Lv") or item:match("^(.-)%s*%(") or item
                            
                            local foundEvolution = false
                            for _, opt in ipairs(OptionsList) do
                                local baseOpt = opt:match("^(.-)%s*%[Lvl") or opt:match("^(.-)%s*%[Lv") or opt:match("^(.-)%s*%(") or opt
                                
                                -- If the base name matches (e.g. Passionfruit) but the level differs
                                if baseItem:lower() == baseOpt:lower() then
                                    -- Automatically move the selection to the new level name!
                                    SelectedItems[i] = opt
                                    foundEvolution = true
                                    break
                                end
                            end
                            
                            -- Only deselect once the base name is truly gone (actually removed from the field)
                            if not foundEvolution then
                                table.remove(SelectedItems, i)
                            end
                        end
                    end
                end
                
                UpdateTriggerText()
                RefreshOptions()
            end
			
			return SelectObj
		end
 
		function Tab:CreateKeybind(KeybindName, Description, DefaultKey, Callback)
			local CallbackFunc = Callback or function() end
			local CurrentKey = DefaultKey or Enum.KeyCode.Unknown
			local HasDesc = type(Description) == "string" and Description ~= ""
			local Listening = false
 
			local KeybindBtn = Instance.new("Frame", Page)
			KeybindBtn.Size = UDim2.new(1, 0, 0, HasDesc and 52 or 36)
			KeybindBtn.BackgroundTransparency = 0.2
			Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(KeybindBtn, "BackgroundColor3", "ToggleBtnBg")
 
			local KeybindStroke = Instance.new("UIStroke", KeybindBtn)
			KeybindStroke.Thickness = 1
			KeybindStroke.Transparency = 0.85
			punishgoatby97mzu:ApplyThemeObj(KeybindStroke, "Color", "Stroke")
 
			local Title = Instance.new("TextLabel", KeybindBtn)
			Title.Size = UDim2.new(1, -110, 0, 16)
			Title.Position = UDim2.new(0, 15, 0, HasDesc and 10 or 10)
			if not HasDesc then
				Title.Size = UDim2.new(1, -110, 1, 0)
				Title.Position = UDim2.new(0, 15, 0, 0)
			end
			Title.BackgroundTransparency = 1
			Title.Text = KeybindName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			if HasDesc then
				local DescLabel = Instance.new("TextLabel", KeybindBtn)
				DescLabel.Size = UDim2.new(1, -110, 0, 14)
				DescLabel.Position = UDim2.new(0, 15, 0, 26)
				DescLabel.BackgroundTransparency = 1
				DescLabel.Text = Description
				DescLabel.Font = Enum.Font.Gotham
				DescLabel.TextSize = 11
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(DescLabel, "TextColor3", "TextInactive")
			end
 
			local KeyBtn = Instance.new("TextButton", KeybindBtn)
			KeyBtn.Size = UDim2.new(0, 80, 0, 26)
			KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
			KeyBtn.Position = UDim2.new(1, -12, 0.5, 0)
			KeyBtn.AutoButtonColor = false
			KeyBtn.Font = Enum.Font.GothamBold
			KeyBtn.TextSize = 12
			Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)
			punishgoatby97mzu:ApplyThemeObj(KeyBtn, "BackgroundColor3", "ToggleBgOff")
			punishgoatby97mzu:ApplyThemeObj(KeyBtn, "TextColor3", "Text")
 
			local function KeyName()
				return (CurrentKey and CurrentKey ~= Enum.KeyCode.Unknown) and CurrentKey.Name or "None"
			end
			KeyBtn.Text = KeyName()
 
			local captureConn
			KeyBtn.MouseButton1Click:Connect(function()
				if Listening then
					return
				end
				Listening = true
				KeyBtn.Text = "..."
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				TweenService:Create(KeybindStroke, TweenInfo.new(0.2), { Color = palette.Accent, Transparency = 0.5 })
					:Play()
 
				-- One-shot listener: grabs the very next key press, then disconnects itself.
				captureConn = UserInputService.InputBegan:Connect(function(input, gpe)
					if gpe then
						return
					end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode ~= Enum.KeyCode.Escape then
							CurrentKey = input.KeyCode
						end
						Listening = false
						KeyBtn.Text = KeyName()
						TweenService:Create(
							KeybindStroke,
							TweenInfo.new(0.2),
							{ Color = palette.Stroke, Transparency = 0.85 }
						):Play()
						if captureConn then
							captureConn:Disconnect()
							captureConn = nil
						end
					end
				end)
			end)
 
			-- Fires the callback whenever the bound key is pressed (ignored while rebinding).
			UserInputService.InputBegan:Connect(function(input, gpe)
				if gpe or Listening then
					return
				end
				if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CurrentKey then
					CallbackFunc(CurrentKey)
				end
			end)
 
			local KeybindObj = {}
			function KeybindObj:Set(keyCode)
				CurrentKey = keyCode
				KeyBtn.Text = KeyName()
			end
			function KeybindObj:Get()
				return CurrentKey
			end
			return KeybindObj
		end
 
		-- Static one-liner, e.g. hints, warnings, small info text. Returns a handle
		-- with :Set(text) so it can be updated later (e.g. live status text).
		-- ==========================================================
		-- Friends chat: online player list + live chat log + sender
		-- ==========================================================
		function Tab:CreateFriendChat(Height)
			local Card = styleCard(Instance.new("Frame", Page), 14)
			Card.Size = UDim2.new(1, 0, 0, Height or 260)
			Card.ClipsDescendants = true

			local Header = makeText(Card, "FRIENDS CHAT", 10, Enum.Font.GothamBold, "Accentpunish")
			Header.Size = UDim2.new(1, -24, 0, 14)
			Header.Position = UDim2.new(0, 12, 0, 10)

			-- left: online players
			local ListFrame = Instance.new("ScrollingFrame", Card)
			ListFrame.Size = UDim2.new(0, 128, 1, -66)
			ListFrame.Position = UDim2.new(0, 12, 0, 32)
			ListFrame.BackgroundTransparency = 1
			ListFrame.BorderSizePixel = 0
			ListFrame.ScrollBarThickness = 2
			ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			punishgoatby97mzu:ApplyThemeObj(ListFrame, "ScrollBarImageColor3", "Stroke")
			local ListLayout = Instance.new("UIListLayout", ListFrame)
			ListLayout.Padding = UDim.new(0, 4)

			local Selected = nil
			local SelectedLabel

			local ChatLog = Instance.new("ScrollingFrame", Card)
			ChatLog.Size = UDim2.new(1, -160, 1, -100)
			ChatLog.Position = UDim2.new(0, 150, 0, 50)
			ChatLog.BackgroundTransparency = 1
			ChatLog.BorderSizePixel = 0
			ChatLog.ScrollBarThickness = 2
			ChatLog.CanvasSize = UDim2.new(0, 0, 0, 0)
			ChatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
			punishgoatby97mzu:ApplyThemeObj(ChatLog, "ScrollBarImageColor3", "Stroke")
			local LogLayout = Instance.new("UIListLayout", ChatLog)
			LogLayout.Padding = UDim.new(0, 4)

			SelectedLabel = makeText(Card, "select a player -->", 10, Enum.Font.GothamMedium, "TextInactive")
			SelectedLabel.Size = UDim2.new(1, -160, 0, 14)
			SelectedLabel.Position = UDim2.new(0, 150, 0, 32)

			local function pushLine(who, msg, isMe)
				local Line = Instance.new("TextLabel", ChatLog)
				Line.Size = UDim2.new(1, -6, 0, 0)
				Line.AutomaticSize = Enum.AutomaticSize.Y
				Line.BackgroundTransparency = 1
				Line.Font = Enum.Font.Gotham
				Line.TextSize = 11
				Line.TextWrapped = true
				Line.TextXAlignment = Enum.TextXAlignment.Left
				Line.Text = who .. ": " .. msg
				punishgoatby97mzu:ApplyThemeObj(Line, "TextColor3", isMe and "Text" or "TextInactive")
				task.defer(function()
					ChatLog.CanvasPosition = Vector2.new(0, math.max(0, ChatLog.AbsoluteCanvasSize.Y))
				end)
			end

			local Box = Instance.new("TextBox", Card)
			Box.Size = UDim2.new(1, -230, 0, 30)
			Box.Position = UDim2.new(0, 150, 1, -40)
			Box.BackgroundTransparency = 0.25
			Box.Text = ""
			Box.PlaceholderText = "message your friend..."
			Box.Font = Enum.Font.Gotham
			Box.TextSize = 11
			Box.ClearTextOnFocus = false
			Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(Box, "BackgroundColor3", "ToggleBgOff")
			punishgoatby97mzu:ApplyThemeObj(Box, "TextColor3", "Text")
			punishgoatby97mzu:ApplyThemeObj(Box, "PlaceholderColor3", "TextInactive")
			local BoxPad = Instance.new("UIPadding", Box)
			BoxPad.PaddingLeft = UDim.new(0, 10)
			BoxPad.PaddingRight = UDim.new(0, 10)

			local SendBtn = Instance.new("TextButton", Card)
			SendBtn.Size = UDim2.new(0, 64, 0, 30)
			SendBtn.AnchorPoint = Vector2.new(1, 0)
			SendBtn.Position = UDim2.new(1, -12, 1, -40)
			SendBtn.Text = "Send"
			SendBtn.Font = Enum.Font.GothamBold
			SendBtn.TextSize = 11
			SendBtn.AutoButtonColor = false
			SendBtn.BackgroundTransparency = 0.15
			Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(SendBtn, "BackgroundColor3", "Accent")
			punishgoatby97mzu:ApplyThemeObj(SendBtn, "TextColor3", "ToggleBtnBg")

			local function send()
				local msg = Box.Text
				if msg == "" then
					return
				end
				Box.Text = ""
				pushLine("You", msg, true)
				local prefix = Selected and ("@" .. Selected.Name .. " ") or ""
				local ok = pcall(function()
					local TextChatService = game:GetService("TextChatService")
					local channels = TextChatService:FindFirstChild("TextChannels")
					local general = channels and (channels:FindFirstChild("RBXGeneral") or channels:FindFirstChildWhichIsA("TextChannel"))
					if general then
						general:SendAsync(prefix .. msg)
					else
						error("legacy")
					end
				end)
				if not ok then
					pcall(function()
						game:GetService("ReplicatedStorage")
							.DefaultChatSystemChatEvents
							.SayMessageRequest:FireServer(prefix .. msg, "All")
					end)
				end
			end
			SendBtn.MouseButton1Click:Connect(send)
			Box.FocusLost:Connect(function(enter)
				if enter then
					send()
				end
			end)

			local function addPlayerRow(plr)
				if plr == LocalPlayer then
					return
				end
				local Row = Instance.new("TextButton", ListFrame)
				Row.Name = "Friend_" .. plr.Name
				Row.Size = UDim2.new(1, -4, 0, 30)
				Row.Text = ""
				Row.AutoButtonColor = false
				Row.BackgroundTransparency = 0.35
				Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
				punishgoatby97mzu:ApplyThemeObj(Row, "BackgroundColor3", "ToggleBgOff")

				local Head = Instance.new("ImageLabel", Row)
				Head.Size = UDim2.new(0, 22, 0, 22)
				Head.Position = UDim2.new(0, 4, 0.5, 0)
				Head.AnchorPoint = Vector2.new(0, 0.5)
				Head.BackgroundTransparency = 1
				Head.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=48&h=48"
				Instance.new("UICorner", Head).CornerRadius = UDim.new(1, 0)

				local Name = makeText(Row, plr.DisplayName, 11, Enum.Font.GothamMedium, "Text")
				Name.Size = UDim2.new(1, -34, 1, 0)
				Name.Position = UDim2.new(0, 32, 0, 0)

				Row.MouseButton1Click:Connect(function()
					Selected = plr
					SelectedLabel.Text = "chatting with " .. plr.DisplayName
					for _, other in ipairs(ListFrame:GetChildren()) do
						if other:IsA("TextButton") then
							TweenService:Create(other, TweenInfo.new(0.15), { BackgroundTransparency = 0.35 }):Play()
						end
					end
					TweenService:Create(Row, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
				end)

				plr.AncestryChanged:Connect(function()
					if not plr:IsDescendantOf(Players) then
						Row:Destroy()
					end
				end)
			end

			for _, plr in ipairs(Players:GetPlayers()) do
				addPlayerRow(plr)
			end
			Players.PlayerAdded:Connect(addPlayerRow)

			for _, plr in ipairs(Players:GetPlayers()) do
				plr.Chatted:Connect(function(msg)
					if (not Selected) or Selected == plr then
						pushLine(plr.DisplayName, msg, false)
					end
				end)
			end
			Players.PlayerAdded:Connect(function(plr)
				plr.Chatted:Connect(function(msg)
					if (not Selected) or Selected == plr then
						pushLine(plr.DisplayName, msg, false)
					end
				end)
			end)

			return {
				Push = pushLine,
				GetSelected = function()
					return Selected
				end,
			}
		end

		function Tab:CreateLabel(Text)
			local LabelHolder = Instance.new("Frame", Page)
			LabelHolder.Size = UDim2.new(1, 0, 0, 0)
			LabelHolder.AutomaticSize = Enum.AutomaticSize.Y
			LabelHolder.BackgroundTransparency = 1
 
			local TextLbl = Instance.new("TextLabel", LabelHolder)
			TextLbl.Size = UDim2.new(1, 0, 0, 0)
			TextLbl.AutomaticSize = Enum.AutomaticSize.Y
			TextLbl.BackgroundTransparency = 1
			TextLbl.Text = Text or ""
			TextLbl.Font = Enum.Font.Gotham
			TextLbl.TextSize = 12
			TextLbl.TextWrapped = true
			TextLbl.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(TextLbl, "TextColor3", "TextInactive")
 
			local LabelObj = {}
			function LabelObj:Set(newText)
				TextLbl.Text = newText
			end
			return LabelObj
		end
 
		-- Boxed title + body text, for longer explanations/warnings that a one-line
		-- Label wouldn't fit nicely.
		function Tab:CreateParagraph(Title, Content)
			local Container = Instance.new("Frame", Page)
			Container.Size = UDim2.new(1, 0, 0, 0)
			Container.AutomaticSize = Enum.AutomaticSize.Y
			Container.BackgroundTransparency = 0.55
			Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(Container, "BackgroundColor3", "ToggleBtnBg")
 
			local Stroke = Instance.new("UIStroke", Container)
			Stroke.Thickness = 1
			Stroke.Transparency = 0.85
			punishgoatby97mzu:ApplyThemeObj(Stroke, "Color", "Stroke")
 
			local Padding = Instance.new("UIPadding", Container)
			Padding.PaddingTop = UDim.new(0, 10)
			Padding.PaddingBottom = UDim.new(0, 10)
			Padding.PaddingLeft = UDim.new(0, 12)
			Padding.PaddingRight = UDim.new(0, 12)
 
			local Layout = Instance.new("UIListLayout", Container)
			Layout.SortOrder = Enum.SortOrder.LayoutOrder
			Layout.Padding = UDim.new(0, 4)
 
			local TitleLbl = Instance.new("TextLabel", Container)
			TitleLbl.Size = UDim2.new(1, 0, 0, 16)
			TitleLbl.BackgroundTransparency = 1
			TitleLbl.Text = Title or ""
			TitleLbl.Font = Enum.Font.GothamBold
			TitleLbl.TextSize = 13
			TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(TitleLbl, "TextColor3", "Text")
 
			local ContentLbl = Instance.new("TextLabel", Container)
			ContentLbl.Size = UDim2.new(1, 0, 0, 0)
			ContentLbl.AutomaticSize = Enum.AutomaticSize.Y
			ContentLbl.BackgroundTransparency = 1
			ContentLbl.Text = Content or ""
			ContentLbl.Font = Enum.Font.Gotham
			ContentLbl.TextSize = 12
			ContentLbl.TextWrapped = true
			ContentLbl.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(ContentLbl, "TextColor3", "TextInactive")
 
			local ParagraphObj = {}
			function ParagraphObj:Set(newContent)
				ContentLbl.Text = newContent
			end
			return ParagraphObj
		end
 
		-- Progress/stat bar with a :Set(value, max?) handle — good for things like
		-- Cash/Sec, farm progress, or a session counter shown right inside a tab.
		function Tab:CreateProgressBar(BarName, Max, Default)
			local MaxValue = Max or 100
			local Value = math.clamp(Default or 0, 0, MaxValue)
 
			local Container = Instance.new("Frame", Page)
			Container.Size = UDim2.new(1, 0, 0, 46)
			Container.BackgroundTransparency = 0.55
			Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(Container, "BackgroundColor3", "ToggleBtnBg")
 
			local Stroke = Instance.new("UIStroke", Container)
			Stroke.Thickness = 1
			Stroke.Transparency = 0.85
			punishgoatby97mzu:ApplyThemeObj(Stroke, "Color", "Stroke")
 
			local Title = Instance.new("TextLabel", Container)
			Title.Size = UDim2.new(1, -80, 0, 18)
			Title.Position = UDim2.new(0, 15, 0, 6)
			Title.BackgroundTransparency = 1
			Title.Text = BarName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			local ValueLabel = Instance.new("TextLabel", Container)
			ValueLabel.Size = UDim2.new(0, 65, 0, 18)
			ValueLabel.AnchorPoint = Vector2.new(1, 0)
			ValueLabel.Position = UDim2.new(1, -15, 0, 6)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(Value) .. "/" .. tostring(MaxValue)
			ValueLabel.Font = Enum.Font.GothamMedium
			ValueLabel.TextSize = 12
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			punishgoatby97mzu:ApplyThemeObj(ValueLabel, "TextColor3", "TextInactive")
 
			local BarBg = Instance.new("Frame", Container)
			BarBg.Size = UDim2.new(1, -30, 0, 6)
			BarBg.Position = UDim2.new(0, 15, 1, -14)
			BarBg.BorderSizePixel = 0
			Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(BarBg, "BackgroundColor3", "ToggleBgOff")
 
			local BarFill = Instance.new("Frame", BarBg)
			BarFill.Size = UDim2.new(MaxValue > 0 and (Value / MaxValue) or 0, 0, 1, 0)
			BarFill.BorderSizePixel = 0
			Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
			punishgoatby97mzu:ApplyThemeObj(BarFill, "BackgroundColor3", "Accent")
 
			local BarObj = {}
			function BarObj:Set(value, max)
				if max then
					MaxValue = max
				end
				Value = math.clamp(value, 0, MaxValue)
				ValueLabel.Text = tostring(Value) .. "/" .. tostring(MaxValue)
				TweenService:Create(BarFill, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
					Size = UDim2.new(MaxValue > 0 and (Value / MaxValue) or 0, 0, 1, 0),
				}):Play()
			end
			function BarObj:Get()
				return Value, MaxValue
			end
			return BarObj
		end
 
		-- Scrollable-friendly history/list block (e.g. "last brainrots found"). Caps
		-- itself at MaxRows so it can't grow forever like an unbounded log would.
		function Tab:CreateTable(TableName, MaxRows)
			MaxRows = MaxRows or 20
 
			if TableName and TableName ~= "" then
				local TitleLabel = Instance.new("TextLabel", Page)
				TitleLabel.Size = UDim2.new(1, 0, 0, 20)
				TitleLabel.BackgroundTransparency = 1
				TitleLabel.Text = TableName
				TitleLabel.Font = Enum.Font.GothamBold
				TitleLabel.TextSize = 13
				TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(TitleLabel, "TextColor3", "SectionTitle")
			end
 
			local ListFrame = Instance.new("Frame", Page)
			ListFrame.Size = UDim2.new(1, 0, 0, 0)
			ListFrame.AutomaticSize = Enum.AutomaticSize.Y
			ListFrame.BackgroundTransparency = 1
 
			local ListLayout = Instance.new("UIListLayout", ListFrame)
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 4)
 
			local Rows = {}
			local OrderCounter = 0
 
			local TableObj = {}
			function TableObj:AddRow(text)
				local Row = Instance.new("Frame", ListFrame)
				Row.Size = UDim2.new(1, 0, 0, 26)
				Row.BackgroundTransparency = 0.5
				OrderCounter = OrderCounter - 1
				Row.LayoutOrder = OrderCounter -- newest row always sorts first
				Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)
				punishgoatby97mzu:ApplyThemeObj(Row, "BackgroundColor3", "ToggleBgOff")
 
				local RowStroke = Instance.new("UIStroke", Row)
				RowStroke.Thickness = 1
				RowStroke.Transparency = 0.8
				punishgoatby97mzu:ApplyThemeObj(RowStroke, "Color", "Stroke")
 
				local RowText = Instance.new("TextLabel", Row)
				RowText.Size = UDim2.new(1, -20, 1, 0)
				RowText.Position = UDim2.new(0, 10, 0, 0)
				RowText.BackgroundTransparency = 1
				RowText.Text = text
				RowText.Font = Enum.Font.GothamMedium
				RowText.TextSize = 11
				RowText.TextXAlignment = Enum.TextXAlignment.Left
				RowText.TextTruncate = Enum.TextTruncate.AtEnd
				punishgoatby97mzu:ApplyThemeObj(RowText, "TextColor3", "TextInactive")
 
				table.insert(Rows, 1, Row)
 
				-- [Cap] never let the history grow forever — trim the oldest row past MaxRows.
				if #Rows > MaxRows then
					local oldest = table.remove(Rows)
					oldest:Destroy()
				end
			end
 
			function TableObj:Clear()
				for _, row in ipairs(Rows) do
					row:Destroy()
				end
				Rows = {}
			end
 
			return TableObj
		end
 
		-- Two-step "arm then confirm" button for dangerous actions (e.g. reset config).
		-- First click arms it (turns red, shows ConfirmText for 3s); a second click
		-- within that window fires the callback. Avoids building a full modal/overlay.
		function Tab:CreateConfirmButton(ButtonName, Description, ConfirmText, Callback)
			local CallbackFunc = Callback or function() end
			local HasDesc = type(Description) == "string" and Description ~= ""
			local Armed = false
			local resetTask
 
			local Btn = Instance.new("TextButton", Page)
			Btn.Size = UDim2.new(1, 0, 0, HasDesc and 52 or 36)
			Btn.AutoButtonColor = false
			Btn.Text = ""
			Btn.BackgroundTransparency = 0.2
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
			punishgoatby97mzu:ApplyThemeObj(Btn, "BackgroundColor3", "ToggleBtnBg")
 
			local BtnStroke = Instance.new("UIStroke", Btn)
			BtnStroke.Thickness = 1
			BtnStroke.Transparency = 0.85
			punishgoatby97mzu:ApplyThemeObj(BtnStroke, "Color", "Stroke")
 
			local Title = Instance.new("TextLabel", Btn)
			Title.Size = UDim2.new(1, -20, 0, 16)
			Title.Position = UDim2.new(0, 15, 0, HasDesc and 10 or 10)
			if not HasDesc then
				Title.Size = UDim2.new(1, -20, 1, 0)
				Title.Position = UDim2.new(0, 15, 0, 0)
			end
			Title.BackgroundTransparency = 1
			Title.Text = ButtonName
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			punishgoatby97mzu:ApplyThemeObj(Title, "TextColor3", "Text")
 
			if HasDesc then
				local DescLabel = Instance.new("TextLabel", Btn)
				DescLabel.Size = UDim2.new(1, -20, 0, 14)
				DescLabel.Position = UDim2.new(0, 15, 0, 26)
				DescLabel.BackgroundTransparency = 1
				DescLabel.Text = Description
				DescLabel.Font = Enum.Font.Gotham
				DescLabel.TextSize = 11
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				punishgoatby97mzu:ApplyThemeObj(DescLabel, "TextColor3", "TextInactive")
			end
 
			Btn.MouseButton1Click:Connect(function()
				local palette = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme]
				if not Armed then
					Armed = true
					Title.Text = ConfirmText or "Click again to confirm"
					TweenService:Create(
						BtnStroke,
						TweenInfo.new(0.2),
						{ Color = Color3.fromRGB(129, 129, 129), Transparency = 0.4 }
					):Play()
 
					if resetTask then
						task.cancel(resetTask)
					end
					resetTask = task.delay(3, function()
						Armed = false
						Title.Text = ButtonName
						TweenService:Create(
							BtnStroke,
							TweenInfo.new(0.2),
							{ Color = punishgoatby97mzu.Themes[punishgoatby97mzu.CurrentTheme].Stroke, Transparency = 0.85 }
						):Play()
					end)
				else
					Armed = false
					if resetTask then
						task.cancel(resetTask)
					end
					Title.Text = ButtonName
					TweenService:Create(BtnStroke, TweenInfo.new(0.2), { Color = palette.Stroke, Transparency = 0.85 })
						:Play()
					CallbackFunc()
				end
			end)
		end
 
		return Tab
	end
 
	-- One-liner: a ready-made friends chat tab.
	function Window:CreateChatTab(TabName, IconID, Height)
		local ChatTab = Window:CreateTab(TabName or "Friends", IconID)
		ChatTab:CreateSection("Friends")
		ChatTab:CreateFriendChat(Height)
		return ChatTab
	end

	return Window
end
 
-- ==========================================
-- [🔮] IN-GAME DYNAMIC PREDICTION HUD (DRAGGABLE, RESIZABLE & AUTO-WRAPPING)
-- ==========================================
 
local PredictHUD_UI = nil
local PredictHUD = nil
 
function punishgoatby97mzu:UpdatePredictHUD(brainrot, rarity, mutation, cps)
	-- If the toggle is off, pass nil/false as the first argument to hide the HUD
	if not brainrot then
		if PredictHUD then
			PredictHUD.Visible = false
		end
		return
	end
	
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create a dedicated ScreenGui with max DisplayOrder (2147483647) so it's always above gamepass/inventory UI
	if not PredictHUD_UI then
		PredictHUD_UI = Instance.new("ScreenGui")
		PredictHUD_UI.Name = "punishgoatPredictHUD_UI"
		PredictHUD_UI.ResetOnSpawn = false
		PredictHUD_UI.IgnoreGuiInset = true
		PredictHUD_UI.DisplayOrder = 2147483647 -- Limit maksimum 32-bit integer Roblox
		PredictHUD_UI.Parent = PlayerGui
	end
	
	-- Create the HUD Frame if it doesn't exist yet
	if not PredictHUD then
		PredictHUD = Instance.new("Frame")
		PredictHUD.Name = "PredictHUD"
		-- Slightly taller (125) to fit the new Cash/Sec row
		PredictHUD.Size = UDim2.new(0, 210, 0, 125) 
		PredictHUD.Position = UDim2.new(0.02, 0, 0.22, 0) -- Pas di bawah floating button kiri
		PredictHUD.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		PredictHUD.BackgroundTransparency = 0.15
		PredictHUD.BorderSizePixel = 0
		PredictHUD.ZIndex = 400
		PredictHUD.Active = true
		PredictHUD.ClipsDescendants = true -- Agar resize memotong elemen dengan rapi
		PredictHUD.Parent = PredictHUD_UI
		
		local Corner = Instance.new("UICorner", PredictHUD)
		Corner.CornerRadius = UDim.new(0, 8)
		
		local Stroke = Instance.new("UIStroke", PredictHUD)
		Stroke.Thickness = 1
		Stroke.Color = Color3.fromRGB(121, 121, 121)
		Stroke.Transparency = 0.5
		
		local Title = Instance.new("TextLabel", PredictHUD)
		Title.Name = "HUD_Title"
		Title.Size = UDim2.new(1, 0, 0, 20)
		Title.BackgroundTransparency = 1
	Title.Text = "🔮 CEZAR OVERLAY"
		Title.Font = Enum.Font.GothamBold
		Title.TextSize = 11
		Title.TextColor3 = Color3.fromRGB(51, 51, 51) -- punishgoat Red Accent
		Title.ZIndex = 401
		
		local Layout = Instance.new("UIListLayout", PredictHUD)
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 4)
		
		local Padding = Instance.new("UIPadding", PredictHUD)
		Padding.PaddingLeft = UDim.new(0, 12)
		Padding.PaddingRight = UDim.new(0, 12)
		Padding.PaddingTop = UDim.new(0, 8)
		Padding.PaddingBottom = UDim.new(0, 8)
		
		local L_Brainrot = Instance.new("TextLabel", PredictHUD)
		L_Brainrot.Name = "L_Brainrot"
		L_Brainrot.Size = UDim2.new(1, -12, 0, 18) -- Sisakan sedikit padding kanan agar tidak menabrak grip
		L_Brainrot.BackgroundTransparency = 1
		L_Brainrot.Font = Enum.Font.GothamMedium
		L_Brainrot.TextSize = 11
		L_Brainrot.TextColor3 = Color3.fromRGB(210, 210, 210)
		L_Brainrot.TextXAlignment = Enum.TextXAlignment.Left
		L_Brainrot.RichText = true
		L_Brainrot.TextWrapped = true -- AKTIFKAN TEXT WRAP AGAR TULISAN PANJANG TURUN KE BAWAH
		L_Brainrot.AutomaticSize = Enum.AutomaticSize.Y -- TINGGI OTOMATIS MENYESUAIKAN JIKA WRAP
		L_Brainrot.ZIndex = 401
		
		local L_Rarity = Instance.new("TextLabel", PredictHUD)
		L_Rarity.Name = "L_Rarity"
		L_Rarity.Size = UDim2.new(1, -12, 0, 18)
		L_Rarity.BackgroundTransparency = 1
		L_Rarity.Font = Enum.Font.GothamMedium
		L_Rarity.TextSize = 11
		L_Rarity.TextColor3 = Color3.fromRGB(210, 210, 210)
		L_Rarity.TextXAlignment = Enum.TextXAlignment.Left
		L_Rarity.RichText = true
		L_Rarity.TextWrapped = true
		L_Rarity.AutomaticSize = Enum.AutomaticSize.Y
		L_Rarity.ZIndex = 401
		
		local L_Mutation = Instance.new("TextLabel", PredictHUD)
		L_Mutation.Name = "L_Mutation"
		L_Mutation.Size = UDim2.new(1, -12, 0, 18)
		L_Mutation.BackgroundTransparency = 1
		L_Mutation.Font = Enum.Font.GothamMedium
		L_Mutation.TextSize = 11
		L_Mutation.TextColor3 = Color3.fromRGB(210, 210, 210)
		L_Mutation.TextXAlignment = Enum.TextXAlignment.Left
		L_Mutation.RichText = true
		L_Mutation.TextWrapped = true
		L_Mutation.AutomaticSize = Enum.AutomaticSize.Y
		L_Mutation.ZIndex = 401
 
		-- Add a new Label for Cash Per Second (CPS)
		local L_CPS = Instance.new("TextLabel", PredictHUD)
		L_CPS.Name = "L_CPS"
		L_CPS.Size = UDim2.new(1, -12, 0, 18)
		L_CPS.BackgroundTransparency = 1
		L_CPS.Font = Enum.Font.GothamMedium
		L_CPS.TextSize = 11
		L_CPS.TextColor3 = Color3.fromRGB(210, 210, 210)
		L_CPS.TextXAlignment = Enum.TextXAlignment.Left
		L_CPS.RichText = true
		L_CPS.TextWrapped = true
		L_CPS.AutomaticSize = Enum.AutomaticSize.Y
		L_CPS.ZIndex = 401
 
		-- Smooth drag-and-drop feature
		local draggingHUD, dragInputHUD, dragStartHUD, startPosHUD
		PredictHUD.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingHUD = true
				dragStartHUD = input.Position
				startPosHUD = PredictHUD.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						draggingHUD = false
					end
				end)
			end
		end)
		PredictHUD.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInputHUD = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInputHUD and draggingHUD then
				local delta = input.Position - dragStartHUD
				PredictHUD.Position = UDim2.new(
					startPosHUD.X.Scale,
					startPosHUD.X.Offset + delta.X,
					startPosHUD.Y.Scale,
					startPosHUD.Y.Offset + delta.Y
				)
			end
		end)
 
		-- RESIZE GRIP: bottom-right resize handle
		local ResizeGrip = Instance.new("TextButton", PredictHUD)
		ResizeGrip.Name = "ResizeGrip"
		ResizeGrip.Size = UDim2.new(0, 15, 0, 15)
		ResizeGrip.Position = UDim2.new(1, 0, 1, 0)
		ResizeGrip.AnchorPoint = Vector2.new(1, 1)
		ResizeGrip.BackgroundTransparency = 1
		ResizeGrip.Text = "◢"
		ResizeGrip.Font = Enum.Font.GothamBold
		ResizeGrip.TextSize = 10
		ResizeGrip.TextColor3 = Color3.fromRGB(121, 121, 121)
		ResizeGrip.ZIndex = 402
 
		local resizingHUD, rDragStartHUD, startSizeHUD
		ResizeGrip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizingHUD = true
				rDragStartHUD = input.Position
				startSizeHUD = PredictHUD.Size
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizingHUD = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if resizingHUD and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - rDragStartHUD
				local newX = math.clamp(startSizeHUD.X.Offset + delta.X, 180, 500)
				local newY = math.clamp(startSizeHUD.Y.Offset + delta.Y, 95, 300)
				PredictHUD.Size = UDim2.new(0, newX, 0, newY)
			end
		end)
	end
	
	-- Update text
	PredictHUD.Visible = true
	PredictHUD.L_Brainrot.Text = "<b>BRAINROT:</b> " .. tostring(brainrot):upper()
	PredictHUD.L_Rarity.Text = "<b>RARITY:</b> " .. tostring(rarity):upper()
	PredictHUD.L_Mutation.Text = "<b>MUTATION:</b> " .. tostring(mutation):upper()
	-- Display the latest estimated Cash Per Second
	PredictHUD.L_CPS.Text = "<b>CASH/SEC:</b> " .. tostring(cps or "N/A"):upper()
end
 
-- ==========================================
-- [⚡] DYNAMIC VISUAL ENGINE (EXTREME POTATO MODE) - LOW-END & ANTI-CRASH
-- ==========================================
function punishgoatby97mzu:SetPotatoMode(state)
    task.spawn(function()
        local Lighting = game:GetService("Lighting")
        local Workspace = game:GetService("Workspace")
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
 
        if state then
            if self.VisualConnections.Potato then self.VisualConnections.Potato:Disconnect() end
 
            -- [BUG FIX] Build a "protected" check (characters + camera) so Potato Mode only
            -- strips the map/props, not the player's own avatar or viewmodel.
            -- With StreamingEnabled, DescendantAdded fires for every part that streams in,
            -- including character parts respawning — without this guard those get flattened too.
            local function IsProtected(obj)
                local camera = Workspace.CurrentCamera
                if camera and obj:IsDescendantOf(camera) then
                    return true
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character and obj:IsDescendantOf(player.Character) then
                        return true
                    end
                end
                return false
            end
 
            -- 1. Aggressively disable global lighting
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.Brightness = 2 -- Slightly raised so the map isn't pitch black once it's stripped down
            Lighting.FogEnd = 9e9
 
            -- [FIX CRASH]: every Terrain property change must be wrapped in its own pcall!
            if Terrain then
                pcall(function() Terrain.WaterWaveSize = 0 end)
                pcall(function() Terrain.WaterWaveSpeed = 0 end)
                pcall(function() Terrain.WaterReflectance = 0 end)
                pcall(function() Terrain.WaterTransparency = 0 end)
                pcall(function() Terrain.Decoration = false end)
            end
 
            -- 2. Core function that strips down every visual (extreme low-end mode)
            local function AnnihilateVisuals(obj)
                if IsProtected(obj) then return end
                pcall(function()
                    if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                        -- Flatten the material (remove reflections)
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Reflectance = 0
                        obj.CastShadow = false
                        
                        -- [TARGET: BRAINROT & MAP TEXTURES]: strip the original 3D model appearance
                        if obj:IsA("MeshPart") then
                            obj.TextureID = "" 
                        end
                    elseif obj:IsA("SpecialMesh") then
                        obj.TextureId = "" 
                    elseif obj:IsA("SurfaceAppearance") then
                        -- Destroy Roblox's built-in HD/PBR texture system
                        obj:Destroy() 
                    elseif obj:IsA("Decal") or obj:IsA("Texture") then
                        obj.Transparency = 1 
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Highlight") then
                        -- Disable ALL VFX including Highlight/Outline
                        obj.Enabled = false 
                    elseif obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") then
                        obj.Enabled = false 
                    elseif obj:IsA("Light") then
                        -- Disable PointLight/SpotLight so the GPU skips lighting calculations
                        obj.Enabled = false 
                    end
                end)
            end
 
            -- 3. Run an O(N) chunked pass across the whole map (freeze-free)
            local allObjects = Workspace:GetDescendants()
            for i, obj in ipairs(allObjects) do
                AnnihilateVisuals(obj)
                -- Yield every 500 objects so the frame rate doesn't drop during the forced re-render
                if i % 500 == 0 then task.wait() end 
            end
 
            for _, obj in ipairs(Lighting:GetChildren()) do
                AnnihilateVisuals(obj)
            end
 
            -- 4. Real-time O(1) guard (auto-strips new Brainrot/VFX the moment they spawn)
            self.VisualConnections.Potato = Workspace.DescendantAdded:Connect(function(obj)
                AnnihilateVisuals(obj)
            end)
 
        else
            -- DISABLE POTATO MODE
            if self.VisualConnections.Potato then 
                self.VisualConnections.Potato:Disconnect() 
                self.VisualConnections.Potato = nil 
            end
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end
 
function punishgoatby97mzu:SetRTXMode(state)
    -- [FIX]: wrapped in task.spawn
    task.spawn(function()
        local Lighting = game:GetService("Lighting")
        local Workspace = game:GetService("Workspace")
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
 
        if state then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
            Lighting.GlobalShadows = true
            Lighting.ShadowSoftness = 0.2
            Lighting.Brightness = 3
            Lighting.EnvironmentDiffuseScale = 1.2
            Lighting.EnvironmentSpecularScale = 1.5 
            
            Lighting.Ambient = Color3.fromRGB(143, 143, 143) 
            Lighting.OutdoorAmbient = Color3.fromRGB(189, 189, 189) 
            Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
            Lighting.ColorShift_Top = Color3.fromRGB(245, 245, 245)
 
            if Terrain then
                Terrain.WaterWaveSize = 0.8
                Terrain.WaterWaveSpeed = 10
                Terrain.WaterReflectance = 1
                Terrain.WaterTransparency = 0.6
                Terrain.Decoration = true
            end
 
            for _, effect in ipairs(Lighting:GetChildren()) do
                if (effect:IsA("PostEffect") or effect:IsA("Atmosphere")) and effect.Name:match("punishgoat") then
                    effect:Destroy()
                end
            end
 
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "punishgoatColor"
            cc.Brightness = 0.05
            cc.Contrast = 0.15 
            cc.Saturation = 0.65 
            cc.TintColor = Color3.fromRGB(249, 249, 249) 
            cc.Parent = Lighting
 
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "punishgoatBloom"
            bloom.Intensity = 0.5
            bloom.Size = 40
            bloom.Threshold = 2
            bloom.Parent = Lighting
 
            local sun = Instance.new("SunRaysEffect")
            sun.Name = "punishgoatSunRays"
            sun.Intensity = 0.25
            sun.Spread = 0.75
            sun.Parent = Lighting
 
            local atmos = Instance.new("Atmosphere")
            atmos.Name = "punishgoatAtmosphere"
            atmos.Density = 0.25
            atmos.Offset = 0.25
            atmos.Color = Color3.fromRGB(176, 176, 176)
            atmos.Decay = Color3.fromRGB(205, 205, 205)
            atmos.Glare = 0.2
            atmos.Haze = 0.4
            atmos.Parent = Lighting
            
            local dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "punishgoatDOF"
            dof.FarIntensity = 0.25
            dof.FocusDistance = 25
            dof.InFocusRadius = 40
            dof.NearIntensity = 0
            dof.Parent = Lighting
        else
            for _, effect in ipairs(Lighting:GetChildren()) do
                if (effect:IsA("PostEffect") or effect:IsA("Atmosphere")) and effect.Name:match("punishgoat") then
                    effect:Destroy()
                end
            end
        end
    end)
end

return punishgoatby97mzu
