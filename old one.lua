-- wild ass anticheat still somehow works (credits twistz my baby)

task.spawn(function()

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
    return string.match(n,"^[a-zA-Z]+%-%d+%a*%-%d+%a*$")~=nil
end

local function b(o)
    -- pcall prevents the script from crashing when touching locked game services
    pcall(function()
    for _,c in pairs(o:GetChildren()) do
        if c:IsA("RemoteEvent") and a(c.Name) then
            c:Destroy()
        end
        b(c) -- Recursive call
    end
end)
end

b(game)
end)


-- this is hub loader
local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealTwistzz/Ui-Libs/refs/heads/main/Redz%20Hub/source.lua"))()
local Window = redzlib:MakeWindow({
Title = "Ascend - https://discord.gg/grtaeN2qG",
SubTitle = "Paid Version",
SaveFolder = "Punishment"
})

Window:AddMinimizeButton({
Button = { Image = "rbxassetid://114654649471766", BackgroundTransparency = 1 },
Corner = { CornerRadius = UDim.new(35, 1) },
})

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.End then
        Window:Minimize()
    end
end)

local Tab1 = Window:MakeTab({"Home", "lucide-home"})

Tab1:AddDiscordInvite({
Name = "Join our Discord",
Description = "Join server",
Logo = "rbxassetid://114654649471766",
Invite = "https://discord.gg/grtaeN2qG",
})
redzlib:SetScale(600)

Window:SelectTab(Tab1)

local Section = Tab1:AddSection({"Credits"})

local Paragraph = Tab1:AddParagraph({"Credits", "Script is made by :\\n@kimidev\\n@savv"})

local Section = Tab1:AddSection({"Updates"})

local Paragraph = Tab1:AddParagraph({"Updates", "soon..."})

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer
local fti        = firetouchinterest
local abs        = math.abs
local clamp      = math.clamp
local sqrt       = math.sqrt
local clock      = os.clock
local V3         = Vector3.new
local V3zero     = Vector3.zero
local MAT_AIR    = Enum.Material.Air

local Tab2 = Window:MakeTab({"Reach", "lucide-user"})
Tab2:AddSection({"Reach [Method 1]"})
Tab2:AddParagraph({"Reach [Method 1]","NOT<font color='rgb(0, 255, 34)'> Xeno & Solara</font> Support"})

-- METHOD 1 (original simple fti with ue own fut )
local e = false
local d = 1
local c

local Toggle1 = Tab2:AddToggle({
Name = "Enable / Disable Reach",
Default = false,
Callback = function(v)
e = v
if not v and c then c:Disconnect(); c = nil; return end
    if c then c:Disconnect() end
        c = RunService.RenderStepped:Connect(function()
        local p = game.Players.LocalPlayer
        local ch = p and p.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local h = ch and ch:FindFirstChild("Humanoid")
        if not (ch and hrp and h) then return end
            local t = workspace:FindFirstChild("TPSSystem")
            t = t and t:FindFirstChild("TPS")
            if not t then return end
                if (hrp.Position - t.Position).Magnitude > d then return end
                    local pf = game.Lighting:FindFirstChild(p.Name)
                    pf = pf and pf:FindFirstChild("PreferredFoot")
                    if not pf then return end
                        local ln
                        if h.RigType == Enum.HumanoidRigType.R6 then
                            ln = (pf.Value == 1) and "Right Leg" or "Left Leg"
                        else
                            ln = (pf.Value == 1) and "RightLowerLeg" or "LeftLowerLeg"
                        end
                        local l = ch:FindFirstChild(ln)
                        if l then fti(l, t, 0); fti(l, t, 1) end
                        end)
                    end
                    })

                    Tab2:AddTextBox({
                    Name = "Reach Size",
                    Description = "",
                    PlaceholderText = "Size",
                    Callback = function(v)
                    d = tonumber(v) or d
                    if c then c:Disconnect(); c = nil end
                        if not e then return end
                            c = RunService.RenderStepped:Connect(function()
                            local p = game.Players.LocalPlayer
                            local ch = p and p.Character
                            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                            local h = ch and ch:FindFirstChild("Humanoid")
                            if not (ch and hrp and h) then return end
                                local t = workspace:FindFirstChild("TPSSystem")
                                t = t and t:FindFirstChild("TPS")
                                if not t then return end
                                    if (hrp.Position - t.Position).Magnitude > d then return end
                                        local pf = game.Lighting:FindFirstChild(p.Name)
                                        pf = pf and pf:FindFirstChild("PreferredFoot")
                                        if not pf then return end
                                            local ln = (h.RigType == Enum.HumanoidRigType.R6)
                                            and ((pf.Value == 1) and "Right Leg" or "Left Leg")
                                            or ((pf.Value == 1) and "RightLowerLeg" or "LeftLowerLeg")
                                            local l = ch:FindFirstChild(ln)
                                            if l then fti(l, t, 0); fti(l, t, 1) end
                                            end)
                                        end
                                        })

                                        -- METHOD 2 (visual box + op presimulatiin)
                                        Tab2:AddSection({"Reach [Method 2]"})
                                        Tab2:AddParagraph({"Reach [Method 2]","NOT <font color='rgb(127,0,255)'>Xeno & Solara</font> Support"})

                                        local reachSize      = Vector3.new(5,5,5)
                                        local legReachEnabled = false
                                        local reachConn      = nil
                                        local shapeType      = "Box"
                                        local transparency2  = 0.7

                                        local reachPart = Instance.new("Part")
                                        reachPart.Anchored = true; reachPart.CanCollide = false
                                        reachPart.Transparency = transparency2; reachPart.Color = Color3.fromRGB(0,85,255)
                                        reachPart.Name = "ReachPart"; reachPart.Parent = workspace

                                        -- op fti logic
                                        local _root, _hum, _rleg, _lleg, _hasRleg, _hasLleg
                                        local function refreshChar2(char)
                                            if not char then return end
                                                _root    = char:FindFirstChild("HumanoidRootPart")
                                                _hum     = char:FindFirstChild("Humanoid")
                                                _rleg    = char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg")
                                                _lleg    = char:FindFirstChild("LeftLowerLeg")  or char:FindFirstChild("Left Leg")
                                                _hasRleg = _rleg ~= nil; _hasLleg = _lleg ~= nil
                                            end
                                            refreshChar2(lp.Character)
                                            lp.CharacterAdded:Connect(function(c) task.wait(); refreshChar2(c); c.ChildAdded:Connect(function() refreshChar2(c) end) end)

                                            local function getBall()
                                                local sys = workspace:FindFirstChild("TPSSystem")
                                                return (sys and sys:FindFirstChild("TPS")) or workspace:FindFirstChild("Ball")
                                            end

                                            local function fireLeg(ball)
                                                if _root  then fti(ball,_root,0);  fti(ball,_root,1)  end
                                                    if _hasRleg then fti(ball,_rleg,0); fti(ball,_rleg,1) end
                                                        if _hasLleg then fti(ball,_lleg,0); fti(ball,_lleg,1) end
                                                        end

                                                        -- smartPredict
                                                        local BUF_MAX = 8
                                                        local POS_BUF = {}
                                                        for i=1,BUF_MAX do POS_BUF[i]={t=0,pos=V3zero,vel=V3zero} end
                                                            local POS_HEAD, POS_LEN = 0, 0
                                                            local function recordBall(ball)
                                                                POS_HEAD=(POS_HEAD%BUF_MAX)+1
                                                                local s=POS_BUF[POS_HEAD]; s.t=clock(); s.pos=ball.Position; s.vel=ball.AssemblyLinearVelocity
                                                                if POS_LEN<BUF_MAX then POS_LEN=POS_LEN+1 end
                                                                end
                                                                local function getFrame(offset) return POS_BUF[((POS_HEAD-offset-1)%BUF_MAX)+1] end
                                                                    local function smartPredict(ball, ahead)
                                                                        if POS_LEN<2 then
                                                                            if not ball then return V3zero,V3zero end
                                                                                return ball.Position+ball.AssemblyLinearVelocity*ahead, ball.AssemblyLinearVelocity
                                                                            end
                                                                            local s2=getFrame(0); local s1=getFrame(1)
                                                                            local dt=s2.t-s1.t; if dt<=0 then dt=0.016 end
                                                                            local vpx=(s2.pos.X-s1.pos.X)/dt; local vpy=(s2.pos.Y-s1.pos.Y)/dt; local vpz=(s2.pos.Z-s1.pos.Z)/dt
                                                                            local vrx=s2.vel.X; local vry=s2.vel.Y; local vrz=s2.vel.Z
                                                                            local ddx=vrx-vpx; local ddy=vry-vpy; local ddz=vrz-vpz
                                                                            local kb=clamp((ddx*ddx+ddy*ddy+ddz*ddz)/(35*35),0,1)
                                                                            local blx=vpx*(1-kb)+vrx*kb; local bly=vpy*(1-kb)+vry*kb; local blz=vpz*(1-kb)+vrz*kb
                                                                            local ax,ay,az=0,0,0
                                                                            if POS_LEN>=3 then
                                                                                local s0=getFrame(2); local dt0=s1.t-s0.t
                                                                                if dt0>0 then
                                                                                    local v0x=(s1.pos.X-s0.pos.X)/dt0; local v0y=(s1.pos.Y-s0.pos.Y)/dt0; local v0z=(s1.pos.Z-s0.pos.Z)/dt0
                                                                                    local amax=120
                                                                                    ax=clamp((vpx-v0x)/dt,-amax,amax); ay=clamp((vpy-v0y)/dt,-amax,amax); az=clamp((vpz-v0z)/dt,-amax,amax)
                                                                                end
                                                                            end
                                                                            local gravY=-9.8*ahead*ahead*(1-kb); local t=clamp(ahead,0.016,0.25); local half=0.5*t*t
                                                                            return V3(s2.pos.X+blx*t+ax*half, s2.pos.Y+bly*t+ay*half+gravY, s2.pos.Z+blz*t+az*half), V3(blx,bly,blz)
                                                                        end

                                                                        local _cachedPing = 0.05
                                                                        local _lastPingT  = 0
                                                                        local HIGH_PING_MS = 0.10
                                                                        local GRAV_HALF_SQ = -9.8*0.5*(1/60)*(1/60)
                                                                        local INSIDE_THRESH = 2.5

                                                                        local function startReach2()
                                                                            if reachConn then reachConn:Disconnect() end
                                                                                reachPart.Size = reachSize
                                                                                reachConn = RunService.PreSimulation:Connect(function()
                                                                                if not _root or not _hum then return end
                                                                                    local ball = getBall(); if not ball then return end
                                                                                    local now = clock()
                                                                                    if now-_lastPingT>=2 then _lastPingT=now; _cachedPing=clamp(lp:GetNetworkPing(),0.016,0.25) end
                                                                                        local ballPos = ball.Position
                                                                                        local rootPos = _root.Position
                                                                                        local qdx=ballPos.X-rootPos.X; local qdz=ballPos.Z-rootPos.Z
                                                                                        if abs(qdx)>16 or abs(qdz)>16 then return end
                                                                                            recordBall(ball)
                                                                                            local qdy=ballPos.Y-rootPos.Y
                                                                                            local rawDist=sqrt(qdx*qdx+qdy*qdy+qdz*qdz)
                                                                                            local ahead=_cachedPing+1/60
                                                                                            local predPos,predVel
                                                                                            if _cachedPing>=HIGH_PING_MS or rawDist>=7 then
                                                                                                predPos,predVel=smartPredict(ball,ahead)
                                                                                            else
                                                                                                predPos=ballPos; predVel=ball.AssemblyLinearVelocity
                                                                                            end
                                                                                            local pvx=predVel.X; local pvy=predVel.Y; local pvz=predVel.Z
                                                                                            local farPos=V3(predPos.X+pvx*(1/60), predPos.Y+pvy*(1/60)+GRAV_HALF_SQ, predPos.Z+pvz*(1/60))
                                                                                            local rx=reachSize.X/2; local ry=reachSize.Y/2; local rz=reachSize.Z/2
                                                                                            local dx=predPos.X-rootPos.X; local dy=predPos.Y-rootPos.Y; local dz=predPos.Z-rootPos.Z
                                                                                            local fdx=farPos.X-rootPos.X;  local fdy=farPos.Y-rootPos.Y;  local fdz=farPos.Z-rootPos.Z
                                                                                            if rawDist<INSIDE_THRESH then fireLeg(ball) end
                                                                                                if (abs(dx)<=rx and abs(dy)<=ry and abs(dz)<=rz) or (abs(fdx)<=rx and abs(fdy)<=ry and abs(fdz)<=rz) then
                                                                                                    fireLeg(ball)
                                                                                                end
                                                                                                reachPart.CFrame = _root.CFrame
                                                                                            end)
                                                                                        end

                                                                                        local function stopReach2()
                                                                                            if reachConn then reachConn:Disconnect(); reachConn=nil end
                                                                                                reachPart.CFrame = CFrame.new(0,-9999,0)
                                                                                            end

                                                                                            Tab2:AddDropdown({
                                                                                            Name = "Select Shape",
                                                                                            Options = {"Box","Sphere","Cylinder"},
                                                                                            Default = "Box",
                                                                                            Callback = function(v)
                                                                                            shapeType = v
                                                                                            if shapeType=="Box" then reachPart.Shape=Enum.PartType.Block
                                                                                            elseif shapeType=="Sphere" then reachPart.Shape=Enum.PartType.Ball
                                                                                            elseif shapeType=="Cylinder" then reachPart.Shape=Enum.PartType.Cylinder end
                                                                                                if legReachEnabled then startReach2() end
                                                                                                end
                                                                                                })

                                                                                                Tab2:AddToggle({
                                                                                                Name = "Enable Reach",
                                                                                                Default = false,
                                                                                                Callback = function(v)
                                                                                                legReachEnabled = v
                                                                                                if v then startReach2() else stopReach2() end
                                                                                                end
                                                                                                })

                                                                                                Tab2:AddSlider({Name="Reach X", Min=1, Max=50, Increase=1, Default=5, Callback=function(v) reachSize=Vector3.new(v,reachSize.Y,reachSize.Z); reachPart.Size=reachSize; if legReachEnabled then startReach2() end end})
                                                                                                Tab2:AddSlider({Name="Reach Y", Min=1, Max=50, Increase=1, Default=5, Callback=function(v) reachSize=Vector3.new(reachSize.X,v,reachSize.Z); reachPart.Size=reachSize; if legReachEnabled then startReach2() end end})
                                                                                                Tab2:AddSlider({Name="Reach Z", Min=1, Max=50, Increase=1, Default=5, Callback=function(v) reachSize=Vector3.new(reachSize.X,reachSize.Y,v); reachPart.Size=reachSize; if legReachEnabled then startReach2() end end})

                                                                                                Tab2:AddTextBox({
                                                                                                Name = "Sync Reach X Y Z",
                                                                                                PlaceholderText = "Size",
                                                                                                Callback = function(v)
                                                                                                local n=tonumber(v); if n then reachSize=Vector3.new(n,n,n); reachPart.Size=reachSize; if legReachEnabled then startReach2() end end
                                                                                            end
                                                                                            })

                                                                                            Tab2:AddToggle({
                                                                                            Name = "Hide Box",
                                                                                            Default = false,
                                                                                            Callback = function(v)
                                                                                            transparency2 = v and 1 or 0.7
                                                                                            reachPart.Transparency = transparency2
                                                                                        end
                                                                                        })
                                                                                        local Tab3 = Window:MakeTab({"Xeno & Solara Reach", "lucide-code"})

                                                                                        local Section = Tab3:AddSection({"Xeno & Solara Reach"})




                                                                                        local Players = game:GetService("Players")
                                                                                        local RunService = game:GetService("RunService")
                                                                                        local player = Players.LocalPlayer




                                                                                        local reachEnabled = false
                                                                                        local shouldReEnable = false
                                                                                        local selectedLegName = "Right Leg"
                                                                                        local reachDistance = 10
                                                                                        local currentConnection = nil
                                                                                        local storedHip = nil




                                                                                        local function enableReach()
                                                                                            if reachEnabled then return end
                                                                                                reachEnabled = true
                                                                                                shouldReEnable = true

                                                                                                local character = player.Character or player.CharacterAdded:Wait()
                                                                                                local hrp = character:WaitForChild("HumanoidRootPart")
                                                                                                local leg = character:WaitForChild(selectedLegName)


                                                                                                if character:FindFirstChild("Right Leg") then
                                                                                                    character["Right Leg"].Transparency = 1
                                                                                                end
                                                                                                if character:FindFirstChild("Left Leg") then
                                                                                                    character["Left Leg"].Transparency = 1
                                                                                                end


                                                                                                storedHip = character:FindFirstChild(
                                                                                                selectedLegName == "Right Leg" and "Right Hip" or "Left Hip",
                                                                                                true
                                                                                                )
                                                                                                if storedHip then
                                                                                                    storedHip.Enabled = false
                                                                                                end

                                                                                                currentConnection = RunService.RenderStepped:Connect(function()
                                                                                                local TPSSystem = workspace:FindFirstChild("TPSSystem")
                                                                                                local TPS = TPSSystem and TPSSystem:FindFirstChild("TPS")
                                                                                                if not TPS or not hrp or not leg then return end

                                                                                                    local direction = TPS.Position - hrp.Position
                                                                                                    local distance = direction.Magnitude

                                                                                                    if distance <= reachDistance then
                                                                                                        leg.CFrame = TPS.CFrame
                                                                                                    else
                                                                                                        leg.CFrame = CFrame.new(hrp.Position + direction.Unit * reachDistance)
                                                                                                    end
                                                                                                end)
                                                                                            end




                                                                                            local function disableReach()
                                                                                                reachEnabled = false
                                                                                                shouldReEnable = false

                                                                                                if currentConnection then
                                                                                                    currentConnection:Disconnect()
                                                                                                    currentConnection = nil
                                                                                                end

                                                                                                local character = player.Character
                                                                                                if character then
                                                                                                    if character:FindFirstChild("Right Leg") then
                                                                                                        character["Right Leg"].Transparency = 0
                                                                                                    end
                                                                                                    if character:FindFirstChild("Left Leg") then
                                                                                                        character["Left Leg"].Transparency = 0
                                                                                                    end
                                                                                                end

                                                                                                if storedHip then
                                                                                                    storedHip.Enabled = true
                                                                                                    storedHip = nil
                                                                                                end
                                                                                            end




                                                                                            player.CharacterAdded:Connect(function()
                                                                                            reachEnabled = false
                                                                                            storedHip = nil

                                                                                            if currentConnection then
                                                                                                currentConnection:Disconnect()
                                                                                                currentConnection = nil
                                                                                            end

                                                                                            if shouldReEnable then
                                                                                                task.wait(0.25)

                                                                                                local character = player.Character or player.CharacterAdded:Wait()
                                                                                                local humanoid = character:WaitForChild("Humanoid")

                                                                                                if humanoid.RigType == Enum.HumanoidRigType.R6 then
                                                                                                    local character = player.Character or player.CharacterAdded:Wait()
                                                                                                    local humanoid = character:WaitForChild("Humanoid")
                                                                                                    character["Right Leg"].Transparency = 1
                                                                                                    character["Left Leg"].Transparency = 1

                                                                                                    character["Left Leg"].Massless = true
                                                                                                    local LeftLegM = Instance.new("Part", character)
                                                                                                    LeftLegM.Name = "Left Leg"
                                                                                                    LeftLegM.CanCollide = false
                                                                                                    LeftLegM.Color = character["Left Leg"].Color
                                                                                                    LeftLegM.Size = Vector3.new(1,2,1)
                                                                                                    LeftLegM.Locked = true
                                                                                                    LeftLegM.Position = character["Left Leg"].Position

                                                                                                    local Attachment = Instance.new("Attachment", LeftLegM)
                                                                                                    Attachment.Name = "LeftFootAttachment"
                                                                                                    Attachment.Position = Vector3.new(0,-1,0)

                                                                                                    local MotorHip = Instance.new("Motor6D", character.Torso)
                                                                                                    MotorHip.Name = "Fake Left Hip"
                                                                                                    MotorHip.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                                                                                                    MotorHip.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                                                                                                    MotorHip.MaxVelocity = 0.1
                                                                                                    MotorHip.Part0 = character.Torso
                                                                                                    MotorHip.Part1 = LeftLegM

                                                                                                    character["Right Leg"].Massless = true
                                                                                                    local RightLegM = Instance.new("Part", character)
                                                                                                    RightLegM.Name = "Right Leg"
                                                                                                    RightLegM.CanCollide = false
                                                                                                    RightLegM.Color = character["Right Leg"].Color
                                                                                                    RightLegM.Size = Vector3.new(1,2,1)
                                                                                                    RightLegM.Locked = true
                                                                                                    RightLegM.Position = character["Right Leg"].Position

                                                                                                    local Attachment2 = Instance.new("Attachment", RightLegM)
                                                                                                    Attachment2.Name = "RightFootAttachment"
                                                                                                    Attachment2.Position = Vector3.new(0,-1,0)

                                                                                                    local MotorHip2 = Instance.new("Motor6D", character.Torso)
                                                                                                    MotorHip2.Name = "Fake Right Hip"
                                                                                                    MotorHip2.C0 = CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0)
                                                                                                    MotorHip2.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0)
                                                                                                    MotorHip2.MaxVelocity = 0.1
                                                                                                    MotorHip2.Part0 = character.Torso
                                                                                                    MotorHip2.Part1 = RightLegM

                                                                                                end

                                                                                                enableReach()
                                                                                            end
                                                                                        end)


                                                                                        local Toggle1 = Tab3:AddToggle({
                                                                                        Name = "Enable / Disable Reach",
                                                                                        Description = "Best <font color='rgb(127,0,255)'>Reach Method </font> Provided ",
                                                                                        Default = false
                                                                                        })
                                                                                        Toggle1:Callback(function(value)
                                                                                        if value then
                                                                                            enableReach()
                                                                                        else
                                                                                            disableReach()
                                                                                        end
                                                                                    end)

                                                                                    Tab3:AddSlider({
                                                                                    Name = "Reach Size",
                                                                                    Min = 1,
                                                                                    Max = 25,
                                                                                    Increase = 1,
                                                                                    Default = 16,
                                                                                    Callback = function(value)
                                                                                    reachDistance = value
                                                                                end
                                                                                })
                                                                                Tab3:AddButton({"Fake Legs", function(Value)
                                                                                local character = player.Character or player.CharacterAdded:Wait()
                                                                                local humanoid = character:WaitForChild("Humanoid")

                                                                                if humanoid.RigType == Enum.HumanoidRigType.R6 then

                                                                                    character["Right Leg"].Transparency = 1
                                                                                    character["Left Leg"].Transparency = 1


                                                                                    character["Left Leg"].Massless = true
                                                                                    local LeftLegM = Instance.new("Part", character)
                                                                                    LeftLegM.Name = "Left Leg"
                                                                                    LeftLegM.CanCollide = false
                                                                                    LeftLegM.Color = character["Left Leg"].Color
                                                                                    LeftLegM.Size = Vector3.new(1, 2, 1)
                                                                                    LeftLegM.Locked = true
                                                                                    LeftLegM.Position = character["Left Leg"].Position

                                                                                    local LeftAttachment = Instance.new("Attachment", LeftLegM)
                                                                                    LeftAttachment.Name = "LeftFootAttachment"
                                                                                    LeftAttachment.Position = Vector3.new(0, -1, 0)

                                                                                    local LeftMotor = Instance.new("Motor6D", character.Torso)
                                                                                    LeftMotor.Name = "Fake Left Hip"
                                                                                    LeftMotor.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                                                                                    LeftMotor.C1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                                                                                    LeftMotor.MaxVelocity = 0.1
                                                                                    LeftMotor.Part0 = character.Torso
                                                                                    LeftMotor.Part1 = LeftLegM


                                                                                    character["Right Leg"].Massless = true
                                                                                    local RightLegM = Instance.new("Part", character)
                                                                                    RightLegM.Name = "Right Leg"
                                                                                    RightLegM.CanCollide = false
                                                                                    RightLegM.Color = character["Right Leg"].Color
                                                                                    RightLegM.Size = Vector3.new(1, 2, 1)
                                                                                    RightLegM.Locked = true
                                                                                    RightLegM.Position = character["Right Leg"].Position

                                                                                    local RightAttachment = Instance.new("Attachment", RightLegM)
                                                                                    RightAttachment.Name = "RightFootAttachment"
                                                                                    RightAttachment.Position = Vector3.new(0, -1, 0)

                                                                                    local RightMotor = Instance.new("Motor6D", character.Torso)
                                                                                    RightMotor.Name = "Fake Right Hip"
                                                                                    RightMotor.C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
                                                                                    RightMotor.C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
                                                                                    RightMotor.MaxVelocity = 0.1
                                                                                    RightMotor.Part0 = character.Torso
                                                                                    RightMotor.Part1 = RightLegM
                                                                                end
                                                                            end})





                                                                            local Tab5 = Window:MakeTab({"React", "lucide-smile-plus"})
                                                                            Tab5:AddSection({"React"})
                                                                            Tab5:AddParagraph({"React","15% = highest delay (safer), 100% = lowest delay (most aggressive)."})

                                                                            local function applyReact(tt, interp)
                                                                                local function strip(k)
                                                                                    return k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("FString",""):gsub("FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
                                                                                end
                                                                                task.spawn(function()
                                                                                local flags = {
                                                                                ["DFIntTargetTimeDelayFacctorTenths"] = tt,
                                                                                ["FIntInterpolationMaxDelayMSec"] = interp,
                                                                                }
                                                                                local function apply()
                                                                                    if not setfflag then return end
                                                                                        for k,v in pairs(flags) do
                                                                                            local ck = strip(k)
                                                                                            pcall(function()
                                                                                            if getfflag(ck)~=nil then setfflag(ck,v) elseif getfflag(k)~=nil then setfflag(k,v) end
                                                                                            end)
                                                                                        end
                                                                                    end
                                                                                    while true do apply() task.wait(20) end
                                                                                    end)
                                                                                end

                                                                                Tab5:AddButton({"React 15%",  function() applyReact("13","90") end})
                                                                                Tab5:AddButton({"React 25%",  function() applyReact("12","85") end})
                                                                                Tab5:AddButton({"React 50%",  function() applyReact("10","75") end})
                                                                                Tab5:AddButton({"React 75%",  function() applyReact("8","67")  end})
                                                                                Tab5:AddButton({"React 100%", function() applyReact("7","60")  end})



                                                                                -- this under is xeno tab

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
                                                                                                                        local Tab6 = Window:MakeTab({"Flag Func", "lucide-settings-2"})
                                                                                                                        Tab6:AddSection({"Flag Override"})

                                                                                                                        local _flags = {tt="4", interp="60", s2="38720"}
                                                                                                                        local _thread = nil

                                                                                                                        local function strip(k)
                                                                                                                            return k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("FString",""):gsub("FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
                                                                                                                        end

                                                                                                                        local function apply()
                                                                                                                            if not setfflag then return end
                                                                                                                                for raw,val in pairs({
                                                                                                                                    ["DFIntTargetTimeDelayFacctorTenths"] = _flags.tt,
                                                                                                                                    ["FIntInterpolationMaxDelayMSec"]     = _flags.interp,
                                                                                                                                    ["DFIntS2PhysicsSenderRate"]          = _flags.s2,
                                                                                                                                    }) do
                                                                                                                                    local ck = strip(raw)
                                                                                                                                    pcall(function()
                                                                                                                                    if getfflag(ck)~=nil then setfflag(ck,val)
                                                                                                                                    elseif getfflag(raw)~=nil then setfflag(raw,val) end
                                                                                                                                    end)
                                                                                                                                end
                                                                                                                            end

                                                                                                                            Tab6:AddTextBox({
                                                                                                                            Name = "TargetTimeDelay",
                                                                                                                            Description = "DFIntTargetTimeDelayFacctorTenths",
                                                                                                                            PlaceholderText = "e.g. 4",
                                                                                                                            Callback = function(v)
                                                                                                                            if v and v ~= "" then _flags.tt = v end
                                                                                                                            end
                                                                                                                            })

                                                                                                                            Tab6:AddTextBox({
                                                                                                                            Name = "Interpolation",
                                                                                                                            Description = "FIntInterpolationMaxDelayMSec",
                                                                                                                            PlaceholderText = "e.g. 60",
                                                                                                                            Callback = function(v)
                                                                                                                            if v and v ~= "" then _flags.interp = v end
                                                                                                                            end
                                                                                                                            })

                                                                                                                            Tab6:AddTextBox({
                                                                                                                            Name = "PhysicsSenderRate",
                                                                                                                            Description = "DFIntS2PhysicsSenderRate",
                                                                                                                            PlaceholderText = "e.g. 38720",
                                                                                                                            Callback = function(v)
                                                                                                                            if v and v ~= "" then _flags.s2 = v end
                                                                                                                            end
                                                                                                                            })

                                                                                                                            Tab6:AddButton({"Apply & Lock", function()
                                                                                                                            if _thread then task.cancel(_thread) end
                                                                                                                                _thread = task.spawn(function()
                                                                                                                                while true do apply() task.wait(2) end
                                                                                                                                end)
                                                                                                                            end})

                                                                                                                            Tab6:AddButton({"Unlock", function()
                                                                                                                            if _thread then task.cancel(_thread); _thread = nil end
                                                                                                                            end})

                                                                                                                            Tab6:AddSection({"Flag Inject"})
                                                                                                                            Tab6:AddParagraph({"Flag Inject","Paste your JSON flags below. Supports any amount. Format: {\\\"FlagName\\\":\\\"value\\\"}"})

                                                                                                                            local _injectThread = nil
                                                                                                                            local _injectFlags  = {}

                                                                                                                            Tab6:AddTextBox({
                                                                                                                            Name = "Flag JSON",
                                                                                                                            Description = "Paste full JSON here",
                                                                                                                            PlaceholderText = '{"DFIntTargetTimeDelayFacctorTenths":"7","FIntInterpolationMaxDelayMSec":"60"}',
                                                                                                                            Callback = function(v)
                                                                                                                            if not v or v == "" then return end
                                                                                                                                local ok, decoded = pcall(function()
                                                                                                                                return game:GetService("HttpService"):JSONDecode(v)
                                                                                                                            end)
                                                                                                                            if ok and type(decoded) == "table" then
                                                                                                                                _injectFlags = decoded
                                                                                                                            end
                                                                                                                        end
                                                                                                                        })

                                                                                                                        Tab6:AddButton({"Inject & Lock All", function()
                                                                                                                        if _injectThread then task.cancel(_injectThread) end
                                                                                                                            _injectThread = task.spawn(function()
                                                                                                                            while true do
                                                                                                                                if setfflag then
                                                                                                                                    for k, v in pairs(_injectFlags) do
                                                                                                                                        local ck = strip(k)
                                                                                                                                        pcall(function()
                                                                                                                                        if getfflag(ck) ~= nil then setfflag(ck, tostring(v))
                                                                                                                                        elseif getfflag(k) ~= nil then setfflag(k, tostring(v)) end
                                                                                                                                        end)
                                                                                                                                    end
                                                                                                                                end
                                                                                                                                task.wait(10)
                                                                                                                            end
                                                                                                                        end)
                                                                                                                    end})

                                                                                                                    Tab6:AddButton({"Stop Inject", function()
                                                                                                                    if _injectThread then task.cancel(_injectThread); _injectThread = nil end
                                                                                                                    end})

                                                                                                                    local Tab7 = Window:MakeTab({"FreeWill", "lucide-user"})

                                                                                                                    Tab7:AddSection({"Freewill Auto-Kick"})

                                                                                                                    local Camera = workspace.CurrentCamera
                                                                                                                    local freewillLoop = nil
                                                                                                                    local REACH = 5
                                                                                                                    local HEIGHT = 3.1

                                                                                                                    local function getFreewillBall()
                                                                                                                        local tps = workspace:FindFirstChild("TPSSystem")
                                                                                                                        return tps and tps:FindFirstChild("TPS") or workspace:FindFirstChild("Ball")
                                                                                                                    end

                                                                                                                    local function directionalKick(hrp, ball)
                                                                                                                        local lookDir = Camera.CFrame.LookVector
                                                                                                                        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookDir.X, 0, lookDir.Z))

                                                                                                                        for i = 1, 25 do
                                                                                                                            firetouchinterest(hrp, ball, 0)
                                                                                                                            firetouchinterest(hrp, ball, 1)
                                                                                                                        end
                                                                                                                    end

                                                                                                                    local function setFreewillState(state)
                                                                                                                        if state then
                                                                                                                            freewillLoop = RunService.Heartbeat:Connect(function()
                                                                                                                            local char = lp.Character
                                                                                                                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                                                                                                            local ball = getFreewillBall()

                                                                                                                            if hrp and ball then
                                                                                                                                hrp.AssemblyLinearVelocity = Vector3.zero

                                                                                                                                local camLook = Camera.CFrame.LookVector
                                                                                                                                hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0, HEIGHT, 0), ball.Position + Vector3.new(camLook.X, HEIGHT, camLook.Z))

                                                                                                                                if (hrp.Position - ball.Position).Magnitude <= REACH then
                                                                                                                                    directionalKick(hrp, ball)
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end)
                                                                                                                    else
                                                                                                                        if freewillLoop then freewillLoop:Disconnect() end
                                                                                                                            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                                                                                                                                lp.Character.HumanoidRootPart.Anchored = false
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end

                                                                                                                    Tab7:AddToggle({
                                                                                                                    Name = "Enable Freewill",
                                                                                                                    Default = false,
                                                                                                                    Callback = function(state)
                                                                                                                    setFreewillState(state)
                                                                                                                end
                                                                                                                })

