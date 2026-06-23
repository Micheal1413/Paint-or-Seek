if _G.camoKill then _G.camoKill() end

local killed = false
_G.camoKill = function()
    killed = true
end

local plr = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

local PaintEvent = rs.Remotes.PaintEvent
local PaintAtlas = require(rs.Modules.PaintAtlas)
local PaintDrawing = require(rs.Modules.PaintDrawing)

local GRID = 20
local RAY_LENGTH = 200
local SURFACE_OFFSET = 0.05

local FACE_NORMALS = {
    [Enum.NormalId.Front] = Vector3.new(0, 0, -1),
    [Enum.NormalId.Back] = Vector3.new(0, 0, 1),
    [Enum.NormalId.Right] = Vector3.new(1, 0, 0),
    [Enum.NormalId.Left] = Vector3.new(-1, 0, 0),
    [Enum.NormalId.Top] = Vector3.new(0, 1, 0),
    [Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
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

                    if img then
                        canvases[part][faceEnum] = {
                            image = img,
                            size = img.Size
                        }
                    end
                end
            end
        end
    end

    return canvases
end

local function uvToWorld(part, faceEnum, u, v)
    local s = part.Size
    local cf = part.CFrame

    local hx, hy, hz = s.X * .5, s.Y * .5, s.Z * .5
    local lx, ly, lz

    if faceEnum == Enum.NormalId.Front then
        lx = (0.5 - u) * s.X
        ly = (0.5 - v) * s.Y
        lz = -hz
    elseif faceEnum == Enum.NormalId.Back then
        lx = (u - 0.5) * s.X
        ly = (0.5 - v) * s.Y
        lz = hz
    elseif faceEnum == Enum.NormalId.Right then
        lx = hx
        ly = (0.5 - v) * s.Y
        lz = (0.5 - u) * s.Z
    elseif faceEnum == Enum.NormalId.Left then
        lx = -hx
        ly = (0.5 - v) * s.Y
        lz = (u - 0.5) * s.Z
    elseif faceEnum == Enum.NormalId.Top then
        lx = (v - 0.5) * s.X
        ly = hy
        lz = (0.5 - u) * s.Z
    elseif faceEnum == Enum.NormalId.Bottom then
        lx = (0.5 - v) * s.X
        ly = -hy
        lz = (0.5 - u) * s.Z
    end

    return cf:PointToWorldSpace(Vector3.new(lx, ly, lz))
end

local excludeCache = nil
local excludeBuiltAt = 0

local function buildExclude(character)
    local now = os.clock()

    if excludeCache and (now - excludeBuiltAt) < 2 then
        excludeCache[1] = character
        return excludeCache
    end

    local t = {character}

    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and (
            inst.Transparency >= 1 or
            inst.Size.Magnitude < 0.5 or
            inst.Name == "Weld"
        ) then
            table.insert(t, inst)
        end
    end

    excludeCache = t
    excludeBuiltAt = now

    return t
end

local function camoFace(canvas, part, faceEnum, rayParams)
    local img = canvas.image
    local imgSize = canvas.size

    local tileW = imgSize.X / GRID
    local tileH = imgSize.Y / GRID

    local localNormal = FACE_NORMALS[faceEnum]
    local worldNormal = part.CFrame:VectorToWorldSpace(localNormal)

    local shootDir = -worldNormal

    local painted = 0
    local colorSamples = {}

    for gy = 0, GRID - 1 do
        for gx = 0, GRID - 1 do
            local u = (gx + 0.5) / GRID
            local v = (gy + 0.5) / GRID

            local wp = uvToWorld(part, faceEnum, u, v) + worldNormal * SURFACE_OFFSET

            local result = workspace:Raycast(wp, shootDir * RAY_LENGTH, rayParams)

            if result and result.Instance:IsA("BasePart")
                and result.Instance.Transparency < 0.9
                and result.Instance.Size.Magnitude >= 0.5
                and result.Instance.Name ~= "Weld" then

                local color = result.Instance.Color

                local px = Vector2.new(
                    math.floor(gx * tileW),
                    math.floor(gy * tileH)
                )

                local ps = Vector2.new(
                    math.min(math.ceil((gx + 1) * tileW) - px.X, imgSize.X - px.X),
                    math.min(math.ceil((gy + 1) * tileH) - px.Y, imgSize.Y - px.Y)
                )

                if ps.X > 0 and ps.Y > 0 then
                    pcall(PaintDrawing.FillImageArea, img, px, ps, color)
                    table.insert(colorSamples, color)
                    painted += 1
                end
            end
        end
    end

    return painted, colorSamples
end

local function autoCamouflage()
    local character = plr.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local canvases = getCanvases(character)

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = buildExclude(character)

    local total, painted = 0, 0
    local partColors = {}

    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and PaintAtlas.IsPaintablePart(part) then
            local pc = canvases[part]

            if pc then
                local allSamples = {}

                for faceEnum, canvas in pairs(pc) do
                    total += 1
                    local p, samples = camoFace(canvas, part, faceEnum, rayParams)
                    painted += p

                    for _, c in ipairs(samples) do
                        table.insert(allSamples, c)
                    end
                end

                if #allSamples > 0 then
                    local r, g, b = 0, 0, 0

                    for _, c in ipairs(allSamples) do
                        r += c.R
                        g += c.G
                        b += c.B
                    end

                    local n = #allSamples
                    partColors[part.Name] = Color3.new(r/n, g/n, b/n)
                end
            end
        end
    end

    for partName, color in pairs(partColors) do
        pcall(function()
            PaintEvent:FireServer({
                kind = "fillPart",
                targetUserId = plr.UserId,
                partName = partName,
                color = color,
            })
        end)
    end
end

local function sampleAndFill()
    local camera = workspace.CurrentCamera
    local mousePos = uis:GetMouseLocation()

    local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude

    local char = plr.Character
    if char then
        rp.FilterDescendantsInstances = {char}
    end

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rp)
    if not result then return end

    local color = result.Instance.Color
    if not char then return end

    local canvases = getCanvases(char)

    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and PaintAtlas.IsPaintablePart(part) then
            local pc = canvases[part]

            if pc then
                for _, canvas in pairs(pc) do
                    pcall(PaintDrawing.FillImageArea, canvas.image, Vector2.zero, canvas.size, color)
                end
            end

            pcall(function()
                PaintEvent:FireServer({
                    kind = "fillPart",
                    targetUserId = plr.UserId,
                    partName = part.Name,
                    color = color,
                })
            end)
        end
    end
end

local conn = uis.InputBegan:Connect(function(input, gpe)
    if killed then return end
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.E then
        sampleAndFill()
    elseif input.KeyCode == Enum.KeyCode.T then
        autoCamouflage()
    end
end)

task.spawn(function()
    while not killed do
        task.wait(0.5)
    end
    conn:Disconnect()
    excludeCache = nil
end)