if _G.camoKill then _G.camoKill() end
local killed = false
_G.camoKill = function() killed = true end

local plr = game.Players.LocalPlayer
local rs  = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local ts  = game:GetService("TweenService")
local gs  = game:GetService("GuiService")

local PaintEvent   = rs.Remotes.PaintEvent
local PaintAtlas   = require(rs.Modules.PaintAtlas)
local PaintDrawing = require(rs.Modules.PaintDrawing)

local GRID = 20
local RAY_LENGTH = 200
local SURFACE_OFFSET = 0.05

-- Platform detection: Small=phone/tablet, Medium=PC, Large=TV
local isTouchDevice = uis.TouchEnabled and not uis.KeyboardEnabled
local function getDS()
    local ok, ds = pcall(function() return gs.ViewportDisplaySize end)
    if ok then return ds end
    return isTouchDevice and Enum.DisplaySize.Small or Enum.DisplaySize.Medium
end
local DS    = getDS()
local SMALL = DS == Enum.DisplaySize.Small
local LARGE = DS == Enum.DisplaySize.Large

local BTN_H    = SMALL and 44 or 32
local CLOSE_SZ = SMALL and 30 or 24
local PILL_W   = SMALL and 110 or 90
local PILL_H   = SMALL and 40  or 32
local HEADER_H = 36
local BTN1_Y   = 68
local BTN2_Y   = BTN1_Y + BTN_H + 8
local FRAME_H  = BTN2_Y + BTN_H + 10
local FRAME_W  = 210

local FRAME_SIZE = UDim2.new(0, FRAME_W, 0, FRAME_H)
local PILL_SIZE  = UDim2.new(0, PILL_W, 0, PILL_H)
local PANEL_POS  = UDim2.new(0, 16, 0.5, -math.floor(FRAME_H / 2))
local EXPAND_UP  = math.floor(FRAME_H * 0.37)
local NOTIF_W    = 260
local NOTIF_OFF  = -(NOTIF_W / 2)

local playerGui = plr:WaitForChild("PlayerGui")
do local e = playerGui:FindFirstChild("CamoGui"); if e then e:Destroy() end end

local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "CamoGui"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ScreenInsets   = Enum.ScreenInsets.CoreUISafeInsets
screenGui.Parent         = playerGui

local uiScale = Instance.new("UIScale")
uiScale.Scale  = 1.0
uiScale.Parent = screenGui

-- On viewport resize: scale down if window shrinks, clamp panel back on screen
local BASE_W = 1280
local function onViewportChanged()
    local vp  = workspace.CurrentCamera.ViewportSize
    local max = LARGE and 1.25 or 1.0
    uiScale.Scale = math.clamp(vp.X / BASE_W, 0.45, max)
    task.defer(function()
        local s   = uiScale.Scale
        local target = (frame ~= nil and frame.Visible) and frame or miniPill
        if not target or not target.Visible then return end
        local ap = target.AbsolutePosition
        local as = target.AbsoluteSize
        local clampedX = math.clamp(ap.X, 0, math.max(0, vp.X - as.X))
        local clampedY = math.clamp(ap.Y, 0, math.max(0, vp.Y - as.Y))
        if clampedX ~= ap.X or clampedY ~= ap.Y then
            local newPos = UDim2.new(0, math.floor(clampedX / s), 0, math.floor(clampedY / s))
            ts:Create(target, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = newPos}):Play()
            if target == frame then
                local fp = newPos
                miniPill.Position = UDim2.new(fp.X.Scale, fp.X.Offset, fp.Y.Scale, fp.Y.Offset + EXPAND_UP)
            end
        end
    end)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged)
onViewportChanged()

local function sPx()
    local vp = workspace.CurrentCamera.ViewportSize
    return math.max(1, math.floor(math.min(vp.X, vp.Y) / 700))
end

local function showNotif(text, color)
    local notif = Instance.new("Frame")
    notif.Size               = UDim2.new(0, NOTIF_W, 0, SMALL and 52 or 48)
    notif.Position           = UDim2.new(0.5, NOTIF_OFF, 0, -(SMALL and 72 or 60))
    notif.BackgroundColor3   = Color3.fromRGB(18, 18, 18)
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel    = 0
    notif.ZIndex             = 10
    notif.Parent             = screenGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)
    local nstroke = Instance.new("UIStroke", notif)
    nstroke.Color = color; nstroke.Thickness = 1.5; nstroke.Transparency = 0.3
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8); dot.Position = UDim2.new(0, 14, 0.5, -4)
    dot.BackgroundColor3 = color; dot.BorderSizePixel = 0; dot.ZIndex = 11
    dot.Parent = notif
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local ntxt = Instance.new("TextLabel")
    ntxt.Size = UDim2.new(1, -34, 1, 0); ntxt.Position = UDim2.new(0, 28, 0, 0)
    ntxt.BackgroundTransparency = 1; ntxt.Text = text
    ntxt.TextColor3 = Color3.fromRGB(230, 230, 230)
    ntxt.TextSize = 13; ntxt.Font = Enum.Font.GothamSemibold
    ntxt.TextXAlignment = Enum.TextXAlignment.Left; ntxt.ZIndex = 11
    ntxt.Parent = notif
    ts:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, NOTIF_OFF, 0, 14)
    }):Play()
    task.delay(2.5, function()
        ts:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, NOTIF_OFF, 0, -(SMALL and 72 or 60))
        }):Play()
        task.delay(0.35, function() if notif and notif.Parent then notif:Destroy() end end)
    end)
end

miniPill = Instance.new("TextButton")
miniPill.Size                   = PILL_SIZE
miniPill.Position               = UDim2.new(PANEL_POS.X.Scale, PANEL_POS.X.Offset, PANEL_POS.Y.Scale, PANEL_POS.Y.Offset + EXPAND_UP)
miniPill.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
miniPill.BackgroundTransparency = 0.15
miniPill.BorderSizePixel        = 0
miniPill.Text                   = "🎨 Camo"
miniPill.TextColor3             = Color3.fromRGB(220, 220, 220)
miniPill.TextSize               = SMALL and 13 or 12
miniPill.Font                   = Enum.Font.GothamBold
miniPill.AutoButtonColor        = false
miniPill.Visible                = false
miniPill.Parent                 = screenGui
Instance.new("UICorner", miniPill).CornerRadius = UDim.new(0, 20)
local miniStroke = Instance.new("UIStroke", miniPill)
miniStroke.Color = Color3.fromRGB(90,90,90); miniStroke.Thickness = sPx(); miniStroke.Transparency = 0.5

frame = Instance.new("Frame")
frame.Size                   = FRAME_SIZE
frame.Position               = PANEL_POS
frame.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel        = 0
frame.ClipsDescendants       = true
frame.Parent                 = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(90,90,90); stroke.Thickness = sPx(); stroke.Transparency = 0.6

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundTransparency = 1; header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -(CLOSE_SZ + 14), 1, 0); title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1; title.Text = "🎨 Camo"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.TextSize = SMALL and 15 or 14; title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size     = UDim2.new(0, CLOSE_SZ, 0, CLOSE_SZ)
closeBtn.Position = UDim2.new(1, -(CLOSE_SZ + 6), 0, math.floor((HEADER_H - CLOSE_SZ) / 2))
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel  = 0; closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = SMALL and 20 or 16; closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false; closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local divider = Instance.new("Frame")
divider.Name = "divider"; divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, HEADER_H)
divider.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
divider.BackgroundTransparency = 0.6; divider.BorderSizePixel = 0; divider.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 18); statusLabel.Position = UDim2.new(0, 12, 0, 42)
statusLabel.BackgroundTransparency = 1; statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
statusLabel.TextSize = SMALL and 12 or 11; statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left; statusLabel.Parent = frame

local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(130, 130, 130)
end

local function makeButton(label, keybind, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, BTN_H); btn.Position = UDim2.new(0, 8, 0, posY)
    btn.BackgroundColor3 = color; btn.BorderSizePixel = 0; btn.Text = ""
    btn.AutoButtonColor = false; btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel")
    lbl.Size = SMALL and UDim2.new(1, -12, 1, 0) or UDim2.new(1, -46, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = SMALL and 13 or 12; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = btn
    if not SMALL then
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 32, 0, 20); badge.Position = UDim2.new(1, -38, 0.5, -10)
        badge.BackgroundColor3 = Color3.fromRGB(0,0,0); badge.BackgroundTransparency = 0.5
        badge.Text = keybind; badge.TextColor3 = Color3.fromRGB(200, 200, 200)
        badge.TextSize = 10; badge.Font = Enum.Font.GothamBold; badge.Parent = btn
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)
    end
    local orig = color
    local hover = color:Lerp(Color3.fromRGB(255,255,255), 0.12)
    local pressed = color:Lerp(Color3.fromRGB(0,0,0), 0.15)
    btn.MouseEnter:Connect(function()       btn.BackgroundColor3 = hover   end)
    btn.MouseLeave:Connect(function()       btn.BackgroundColor3 = orig    end)
    btn.MouseButton1Down:Connect(function() btn.BackgroundColor3 = pressed end)
    btn.MouseButton1Up:Connect(function()   btn.BackgroundColor3 = orig    end)
    return btn
end

local sampleBtn = makeButton("Sample & Fill", "[E]", BTN1_Y, Color3.fromRGB(40, 120, 200))
local camoBtn   = makeButton("Auto Camo",     "[T]", BTN2_Y, Color3.fromRGB(50, 160, 80))

local animating = false

local function closeUI()
    if animating then return end
    animating = true
    local tweens = {}
    for _, obj in ipairs(frame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            table.insert(tweens, ts:Create(obj, TweenInfo.new(0.18), {TextTransparency=1}))
        elseif obj:IsA("TextButton") and obj ~= closeBtn then
            table.insert(tweens, ts:Create(obj, TweenInfo.new(0.18), {BackgroundTransparency=1, TextTransparency=1}))
        elseif obj:IsA("Frame") and obj ~= frame then
            table.insert(tweens, ts:Create(obj, TweenInfo.new(0.18), {BackgroundTransparency=1}))
        end
    end
    table.insert(tweens, ts:Create(closeBtn, TweenInfo.new(0.18), {BackgroundTransparency=1, TextTransparency=1}))
    table.insert(tweens, ts:Create(frame,    TweenInfo.new(0.18), {BackgroundTransparency=1}))
    table.insert(tweens, ts:Create(stroke,   TweenInfo.new(0.18), {Transparency=1}))
    for _, t in ipairs(tweens) do t:Play() end
    task.delay(0.2, function()
        frame.Visible = false
        frame.BackgroundTransparency = 0.15; stroke.Transparency = 0.6
        closeBtn.BackgroundTransparency = 0; closeBtn.TextTransparency = 0
        for _, obj in ipairs(frame:GetDescendants()) do
            if obj:IsA("TextLabel") then obj.TextTransparency = 0
            elseif obj:IsA("TextButton") and obj ~= closeBtn then
                obj.BackgroundTransparency = 0; obj.TextTransparency = 0
            elseif obj:IsA("Frame") and obj ~= frame then
                obj.BackgroundTransparency = obj.Name == "divider" and 0.6 or 1
            end
        end
        local fp = frame.Position
        miniPill.Position = UDim2.new(fp.X.Scale, fp.X.Offset, fp.Y.Scale, fp.Y.Offset + EXPAND_UP)
        miniPill.BackgroundTransparency = 1; miniPill.TextTransparency = 1
        miniPill.Visible = true
        ts:Create(miniPill, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.15, TextTransparency = 0
        }):Play()
        animating = false
    end)
end

local function openUI()
    if animating then return end
    animating = true
    local pillPos = miniPill.Position
    frame.Position = pillPos; frame.Size = PILL_SIZE
    frame.BackgroundTransparency = 0.15; frame.Visible = true
    miniPill.Visible = false
    ts:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size     = FRAME_SIZE,
        Position = UDim2.new(pillPos.X.Scale, pillPos.X.Offset, pillPos.Y.Scale, pillPos.Y.Offset - EXPAND_UP),
    }):Play()
    task.delay(0.3, function() animating = false end)
    local hint = SMALL and "Tap Sample or Auto Camo below" or "Press [E] to sample · [T] for auto camo"
    showNotif(hint, Color3.fromRGB(80, 180, 255))
end

closeBtn.MouseButton1Click:Connect(closeUI); closeBtn.TouchTap:Connect(closeUI)
miniPill.MouseButton1Click:Connect(openUI);  miniPill.TouchTap:Connect(openUI)

local dragging, dragStart, dragStartPos
local function beginDrag(target, input)
    dragging = target; dragStart = input.Position; dragStartPos = target.Position
end
frame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        beginDrag(frame, i) end end)
miniPill.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        beginDrag(miniPill, i) end end)
uis.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dragStart
        dragging.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + d.X,
                                      dragStartPos.Y.Scale, dragStartPos.Y.Offset + d.Y)
    end end)
uis.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = nil end end)

local FACE_NORMALS = {
    [Enum.NormalId.Front]  = Vector3.new(0, 0, -1), [Enum.NormalId.Back]   = Vector3.new(0, 0,  1),
    [Enum.NormalId.Right]  = Vector3.new(1, 0,  0), [Enum.NormalId.Left]   = Vector3.new(-1, 0, 0),
    [Enum.NormalId.Top]    = Vector3.new(0, 1,  0), [Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
}

local function getCanvases(char)
    local canvases = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and PaintAtlas.IsPaintablePart(part) then
            canvases[part] = {}
            for faceEnum in pairs(FACE_NORMALS) do
                local sg = part:FindFirstChild("PaintCanvas_" .. faceEnum.Name)
                if sg then
                    local lbl = sg:FindFirstChild("PaintImage")
                    local img = lbl and lbl.ImageContent and lbl.ImageContent.Object
                    if img then canvases[part][faceEnum] = {image=img, size=img.Size} end
                end
            end
        end
    end
    return canvases
end

local function uvToWorld(part, faceEnum, u, v)
    local s=part.Size; local cf=part.CFrame
    local hx,hy,hz = s.X*.5, s.Y*.5, s.Z*.5
    local lx,ly,lz
    if      faceEnum==Enum.NormalId.Front  then lx=(0.5-u)*s.X; ly=(0.5-v)*s.Y; lz=-hz
    elseif  faceEnum==Enum.NormalId.Back   then lx=(u-0.5)*s.X; ly=(0.5-v)*s.Y; lz= hz
    elseif  faceEnum==Enum.NormalId.Right  then lx= hx;         ly=(0.5-v)*s.Y; lz=(0.5-u)*s.Z
    elseif  faceEnum==Enum.NormalId.Left   then lx=-hx;         ly=(0.5-v)*s.Y; lz=(u-0.5)*s.Z
    elseif  faceEnum==Enum.NormalId.Top    then lx=(v-0.5)*s.X; ly= hy;         lz=(0.5-u)*s.Z
    elseif  faceEnum==Enum.NormalId.Bottom then lx=(0.5-v)*s.X; ly=-hy;         lz=(0.5-u)*s.Z
    end
    return cf:PointToWorldSpace(Vector3.new(lx,ly,lz))
end

local excludeCache, excludeBuiltAt = nil, 0
local function buildExclude(character)
    local now = os.clock()
    if excludeCache and (now-excludeBuiltAt)<2 then excludeCache[1]=character; return excludeCache end
    local t = {character}
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and (inst.Transparency>=1 or inst.Size.Magnitude<0.5 or inst.Name=="Weld") then
            table.insert(t, inst) end end
    excludeCache=t; excludeBuiltAt=now; return t
end

local function camoFace(canvas, part, faceEnum, rayParams)
    local img=canvas.image; local imgSize=canvas.size
    local tileW=imgSize.X/GRID; local tileH=imgSize.Y/GRID
    local worldNormal=part.CFrame:VectorToWorldSpace(FACE_NORMALS[faceEnum])
    local shootDir=-worldNormal; local painted=0; local colorSamples={}
    for gy=0,GRID-1 do for gx=0,GRID-1 do
        local u=(gx+0.5)/GRID; local v=(gy+0.5)/GRID
        local wp=uvToWorld(part,faceEnum,u,v)+worldNormal*SURFACE_OFFSET
        local result=workspace:Raycast(wp, shootDir*RAY_LENGTH, rayParams)
        if result and result.Instance:IsA("BasePart")
            and result.Instance.Transparency<0.9
            and result.Instance.Size.Magnitude>=0.5
            and result.Instance.Name~="Weld" then
            local color=result.Instance.Color
            local px=Vector2.new(math.floor(gx*tileW),math.floor(gy*tileH))
            local ps=Vector2.new(
                math.min(math.ceil((gx+1)*tileW)-px.X, imgSize.X-px.X),
                math.min(math.ceil((gy+1)*tileH)-px.Y, imgSize.Y-px.Y))
            if ps.X>0 and ps.Y>0 then
                pcall(PaintDrawing.FillImageArea, img, px, ps, color)
                table.insert(colorSamples,color); painted+=1 end
        end
    end end
    return painted, colorSamples
end

local function autoCamouflage()
    local character=plr.Character; if not character then return end
    if not character:FindFirstChild("HumanoidRootPart") then return end
    setStatus("Scanning...", Color3.fromRGB(255,200,60))
    showNotif("Scanning environment...", Color3.fromRGB(255,200,60))
    local canvases=getCanvases(character)
    local rayParams=RaycastParams.new()
    rayParams.FilterType=Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances=buildExclude(character)
    local total,painted,partColors=0,0,{}
    for _,part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and PaintAtlas.IsPaintablePart(part) then
            local pc=canvases[part]
            if pc then
                local allSamples={}
                for faceEnum,canvas in pairs(pc) do
                    total+=1
                    local p,samples=camoFace(canvas,part,faceEnum,rayParams)
                    painted+=p
                    for _,c in ipairs(samples) do table.insert(allSamples,c) end
                end
                if #allSamples>0 then
                    local r,g,b=0,0,0
                    for _,c in ipairs(allSamples) do r+=c.R;g+=c.G;b+=c.B end
                    local n=#allSamples
                    partColors[part.Name]=Color3.new(r/n,g/n,b/n)
                end
            end
        end
    end
    for partName,color in pairs(partColors) do
        pcall(function()
            PaintEvent:FireServer({kind="fillPart",targetUserId=plr.UserId,partName=partName,color=color})
        end)
    end
    local pct=total>0 and math.floor((painted/total)*100) or 0
    setStatus("Camo: "..pct.."% covered", Color3.fromRGB(80,200,120))
    showNotif("Auto camo applied! "..pct.."% covered", Color3.fromRGB(50,160,80))
end

local function sampleAndFill()
    local camera=workspace.CurrentCamera
    local mousePos=uis:GetMouseLocation()
    local unitRay=camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
    local char=plr.Character
    if char then rp.FilterDescendantsInstances={char} end
    local result=workspace:Raycast(unitRay.Origin, unitRay.Direction*1000, rp)
    if not result then
        setStatus("No surface hit", Color3.fromRGB(200,80,80))
        showNotif("No surface found!", Color3.fromRGB(200,80,80)); return
    end
    local color=result.Instance.Color
    if not char then return end
    local canvases=getCanvases(char)
    for _,part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and PaintAtlas.IsPaintablePart(part) then
            local pc=canvases[part]
            if pc then
                for _,canvas in pairs(pc) do
                    pcall(PaintDrawing.FillImageArea, canvas.image, Vector2.zero, canvas.size, color)
                end
            end
            pcall(function()
                PaintEvent:FireServer({kind="fillPart",targetUserId=plr.UserId,partName=part.Name,color=color})
            end)
        end
    end
    local r,g,b=math.floor(color.R*255),math.floor(color.G*255),math.floor(color.B*255)
    setStatus(string.format("Filled (%d, %d, %d)",r,g,b), Color3.fromRGB(80,180,255))
    showNotif(string.format("Sampled RGB (%d, %d, %d)",r,g,b), Color3.fromRGB(40,120,200))
end

sampleBtn.MouseButton1Click:Connect(sampleAndFill); sampleBtn.TouchTap:Connect(sampleAndFill)
camoBtn.MouseButton1Click:Connect(autoCamouflage);  camoBtn.TouchTap:Connect(autoCamouflage)

local inputConn = uis.InputBegan:Connect(function(input, gpe)
    if killed or gpe then return end
    if input.KeyCode == Enum.KeyCode.E then sampleAndFill()
    elseif input.KeyCode == Enum.KeyCode.T then autoCamouflage() end
end)

task.delay(0.5, function()
    local hint = SMALL and "Tap Sample or Auto Camo" or "Press [E] to sample · [T] for auto camo"
    showNotif(hint, Color3.fromRGB(80, 180, 255))
end)

task.spawn(function()
    while not killed do task.wait(0.5) end
    inputConn:Disconnect(); excludeCache = nil
    if screenGui and screenGui.Parent then screenGui:Destroy() end
end)
