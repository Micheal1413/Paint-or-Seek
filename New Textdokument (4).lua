-- camo_v2.lua
if _G._camoV2Kill then _G._camoV2Kill() end
task.wait(0.1)

local killed       = false
local texCache     = {}
local texLoading   = {}
local texTypeCache = {}
local loadingSet   = {}

_G._camoV2Kill = function() killed = true end

local plr  = game.Players.LocalPlayer
local rs   = game:GetService("ReplicatedStorage")
local as   = game:GetService("AssetService")
local uis  = game:GetService("UserInputService")
local ts   = game:GetService("TweenService")

local remotes    = rs:WaitForChild("Remotes", 10)
local PaintEvent = remotes and remotes:WaitForChild("PaintEvent", 10)


local PaintAtlas   = require(rs.Modules.PaintAtlas)
local PaintDrawing = require(rs.Modules.PaintDrawing)

local RAY_DIVISOR = 2
local RAY_LENGTH  = 500
local SURF_OFF    = 0.15  -- push ray origin off surface to clear the part itself


local function isHider()
    return plr:GetAttribute("InRound") == true
        and plr:GetAttribute("RoundRole") == "Hider"
end

-- -- Texture cache -------------------------------------------------------------
local function loadTex(id)
    if texCache[id] ~= nil or texLoading[id] then return end
    texLoading[id] = true
    loadingSet[id] = true
    task.spawn(function()
        local ok, img = pcall(as.CreateEditableImageAsync, as, Content.fromUri(id))
        texCache[id]  = (ok and img) or false
        texLoading[id] = nil
        loadingSet[id] = nil
    end)
end

local function getTex(id)
    local v = texCache[id]
    return (v and v ~= false) and v or nil
end

-- ── Texture analysis cache ────────────────────────────────────────────────────
local texInfoCache = {}

local function analyzeTexture(img, id)
    if texInfoCache[id] then return texInfoCache[id] end
    local sz = img.Size
    local opaque, trans, rS, gS, bS, cnt = 0, 0, 0, 0, 0, 0
    for i = 0, 63 do
        local px = Vector2.new(
            math.floor((i%8)/7*(sz.X-1)),
            math.floor(math.floor(i/8)/7*(sz.Y-1)))
        local ok, buf = pcall(img.ReadPixelsBuffer, img, px, Vector2.new(1,1))
        if ok then
            local a = buffer.readu8(buf,3)
            if a > 200 then
                opaque+=1; rS+=buffer.readu8(buf,0)
                gS+=buffer.readu8(buf,1); bS+=buffer.readu8(buf,2); cnt+=1
            else trans+=1 end
        end
    end
    local avgB = cnt>0 and (rS+gS+bS)/(cnt*3) or 128
    local info
    if trans > opaque then
        info = {type = avgB < 64 and "black_overlay" or "white_overlay"}
    else
        info = {type="color", norm=128/math.max(avgB,1)}
    end
    texInfoCache[id] = info
    return info
end


-- Sample a texture pixel and return the final blended Color3
-- We use a WEAK texture influence (TEX_INFLUENCE) so the result stays close to
-- partColor (which is what the game's own eyedropper returns) while still
-- showing the texture pattern for visual camouflage accuracy.
local TEX_INFLUENCE = 0.35  -- how much texture shifts color vs staying at partColor

local function sampleTex(img, id, u, v, partColor, texChild)
    local sz = img.Size
    local px = Vector2.new(
        math.clamp(math.floor(u*sz.X), 0, sz.X-1),
        math.clamp(math.floor(v*sz.Y), 0, sz.Y-1))
    local ok, buf = pcall(img.ReadPixelsBuffer, img, px, Vector2.new(1,1))
    if not ok then return partColor end
    local r = buffer.readu8(buf,0)/255
    local g = buffer.readu8(buf,1)/255
    local b = buffer.readu8(buf,2)/255
    local a = buffer.readu8(buf,3)/255
    local texTrans = (texChild and texChild:IsA("Texture")) and texChild.Transparency or 0
    local info = analyzeTexture(img, id)

    if info.type == "black_overlay" or info.type == "white_overlay" then
        -- Pattern overlays: darken/brighten by a small amount
        if a < 0.05 then return partColor end
        local influence = TEX_INFLUENCE * a * (1 - texTrans)
        if info.type == "black_overlay" then
            -- Darken toward black
            return Color3.new(
                math.clamp(partColor.R * (1 - influence * 0.7), 0, 1),
                math.clamp(partColor.G * (1 - influence * 0.7), 0, 1),
                math.clamp(partColor.B * (1 - influence * 0.7), 0, 1))
        else
            -- Brighten slightly
            return Color3.new(
                math.min(partColor.R * (1 + influence * 0.2), 1),
                math.min(partColor.G * (1 + influence * 0.2), 1),
                math.min(partColor.B * (1 + influence * 0.2), 1))
        end
    end

    -- Opaque color texture: lerp from partColor toward texRGB by TEX_INFLUENCE
    -- This keeps us close to partColor (eyedropper accuracy) while showing pattern
    local texColor = Color3.new(r, g, b)
    local strength = TEX_INFLUENCE * (1 - texTrans)
    return Color3.new(
        math.clamp(partColor.R + (texColor.R - partColor.R) * strength, 0, 1),
        math.clamp(partColor.G + (texColor.G - partColor.G) * strength, 0, 1),
        math.clamp(partColor.B + (texColor.B - partColor.B) * strength, 0, 1))
end

local function getSurfaceColor(part)
    local sc = part:GetAttribute("SampleColor")
    if typeof(sc) == "Color3" then return sc end
    return part.Color
end




-- -- Surface helpers -----------------------------------------------------------
local function faceFromNormal(part, worldNormal)
    local ln = part.CFrame:VectorToObjectSpace(worldNormal)
    local ax, ay, az = math.abs(ln.X), math.abs(ln.Y), math.abs(ln.Z)
    if     ax >= ay and ax >= az then return ln.X > 0 and "Right"  or "Left"
    elseif ay >= ax and ay >= az then return ln.Y > 0 and "Top"    or "Bottom"
    else                              return ln.Z > 0 and "Back"   or "Front" end
end

-- Returns textures/decals on a face as a list: {{id, child}, ...}
-- Only returns textures matching the hit face (strict), or one fallback
local function getTexLayers(part, hitFaceName)
    local layers = {}
    local fallback = nil
    local seen = {}  -- deduplicate by texture ID
    for _, c in ipairs(part:GetChildren()) do
        if (c:IsA("Texture") or c:IsA("Decal")) and c.Texture ~= "" then
            local face = tostring(c.Face):match("NormalId%.(.+)") or ""
            local id = c.Texture
            if face == hitFaceName and not seen[id] then
                seen[id] = true
                table.insert(layers, {id, c})
            elseif not fallback and not seen[id] then
                fallback = {id, c}
            end
        end
    end
    -- Only use fallback if NO face-matched textures found
    if #layers == 0 and fallback then table.insert(layers, fallback) end
    if #layers == 0 and part:IsA("MeshPart") and part.TextureID ~= "" then
        table.insert(layers, {part.TextureID, nil})
    end
    if #layers == 0 then
        local sa = part:FindFirstChildOfClass("SurfaceAppearance")
        if sa then
            local id = tostring(sa.ColorMapContent):match("(rbxassetid://%d+)")
            if id then table.insert(layers, {id, nil}) end
        end
    end
    return layers
end

-- Legacy single-tex helper for hitUV
local function getTexId(part, hitFaceName)
    local layers = getTexLayers(part, hitFaceName)
    if layers[1] then return layers[1][1], layers[1][2] end
    return nil, nil

end

-- Exact UV math from PaintDrawing.GetNormalizedUV
-- Front:  u=1-(lx/sx+.5)  v=1-(ly/sy+.5)

-- Front:  u=1-(lx/sx+.5)  v=1-(ly/sy+.5)
-- Back:   u=lx/sx+.5      v=1-(ly/sy+.5)
-- Right:  u=1-(lz/sz+.5)  v=1-(ly/sy+.5)
-- Left:   u=lz/sz+.5      v=1-(ly/sy+.5)
-- Top:    u=1-(lz/sz+.5)  v=lx/sx+.5
-- Bottom: u=1-(lz/sz+.5)  v=1-(lx/sx+.5)
local function getUV(part, hitPos, faceEnum)
    local lp = part.CFrame:PointToObjectSpace(hitPos)
    local sz = part.Size
    local lx = lp.X/sz.X + 0.5
    local ly = lp.Y/sz.Y + 0.5
    local lz = lp.Z/sz.Z + 0.5
    if     faceEnum == Enum.NormalId.Front  then return 1-lx, 1-ly
    elseif faceEnum == Enum.NormalId.Back   then return   lx, 1-ly
    elseif faceEnum == Enum.NormalId.Right  then return 1-lz, 1-ly
    elseif faceEnum == Enum.NormalId.Left   then return   lz, 1-ly
    elseif faceEnum == Enum.NormalId.Top    then return 1-lz,   lx
    elseif faceEnum == Enum.NormalId.Bottom then return 1-lz, 1-lx
    end
    return 0.5, 0.5
end

-- Same UV but with tiling for Texture children
local function hitUV(part, hitPos, faceEnum, texChild)
    local u, v = getUV(part, hitPos, faceEnum)
    if texChild and texChild:IsA("Texture") then
        local sz = part.Size
        local su, sv = texChild.StudsPerTileU, texChild.StudsPerTileV
        if su > 0 and sv > 0 then
            local fw, fh
            if faceEnum == Enum.NormalId.Front or faceEnum == Enum.NormalId.Back then
                fw, fh = sz.X, sz.Y
            elseif faceEnum == Enum.NormalId.Right or faceEnum == Enum.NormalId.Left then
                fw, fh = sz.Z, sz.Y
            else
                fw, fh = sz.X, sz.Z
            end
            u = (u * fw / su) % 1
            v = (v * fh / sv) % 1
        end
    end
    return math.clamp(u, 0, 1), math.clamp(v, 0, 1)
end

-- -- Face definitions ----------------------------------------------------------
local FACES = {
    {name="Front",  ln=Vector3.new( 0, 0,-1), faceEnum=Enum.NormalId.Front },
    {name="Back",   ln=Vector3.new( 0, 0, 1), faceEnum=Enum.NormalId.Back  },
    {name="Right",  ln=Vector3.new( 1, 0, 0), faceEnum=Enum.NormalId.Right },
    {name="Left",   ln=Vector3.new(-1, 0, 0), faceEnum=Enum.NormalId.Left  },
    {name="Top",    ln=Vector3.new( 0, 1, 0), faceEnum=Enum.NormalId.Top   },
    {name="Bottom", ln=Vector3.new( 0,-1, 0), faceEnum=Enum.NormalId.Bottom},
}

-- Convert canvas pixel (px,py) → world ray origin
-- PaintImage has 1px bleed: Size=(1,2,1,2) Position=(0,-1,0,-1)
-- So face pixels are 1..(W-2), not 0..(W-1)
-- Correct UV: u = (px - 1 + 0.5) / (imgW - 2)  i.e. bleed-compensated
local function pixelRay(part, face, px, py, imgW, imgH)
    local u = (px - 1 + 0.5) / (imgW - 2)
    local v = (py - 1 + 0.5) / (imgH - 2)
    u = math.clamp(u, -1/imgW, 1 + 1/imgW)
    v = math.clamp(v, -1/imgH, 1 + 1/imgH)
    local sz = part.Size
    local fe = face.faceEnum
    local ln = face.ln


    -- Invert GetNormalizedUV to get local position from UV
    local lx, ly, lz
    if fe == Enum.NormalId.Front then
        lx = (1-u - 0.5) * sz.X
        ly = (1-v - 0.5) * sz.Y
        lz = -sz.Z * 0.5
    elseif fe == Enum.NormalId.Back then
        lx = (u - 0.5) * sz.X
        ly = (1-v - 0.5) * sz.Y
        lz = sz.Z * 0.5
    elseif fe == Enum.NormalId.Right then
        lx = sz.X * 0.5
        ly = (1-v - 0.5) * sz.Y
        lz = (1-u - 0.5) * sz.Z
    elseif fe == Enum.NormalId.Left then
        lx = -sz.X * 0.5
        ly = (1-v - 0.5) * sz.Y
        lz = (u - 0.5) * sz.Z
    elseif fe == Enum.NormalId.Top then
        lx = (v - 0.5) * sz.X
        ly = sz.Y * 0.5
        lz = (1-u - 0.5) * sz.Z
    elseif fe == Enum.NormalId.Bottom then
        lx = (1-v - 0.5) * sz.X
        ly = -sz.Y * 0.5
        lz = (1-u - 0.5) * sz.Z
    end

    local wn  = part.CFrame:VectorToWorldSpace(ln)
    local org = part.CFrame:PointToWorldSpace(Vector3.new(lx, ly, lz)) + wn * SURF_OFF
    return org, -wn
end

-- -- Canvas access -------------------------------------------------------------
local function getCanvases(char)
    local out = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and PaintAtlas.IsPaintablePart(part) then
            local pd = {}
            for _, face in ipairs(FACES) do
                local sg  = part:FindFirstChild("PaintCanvas_"..face.name)
                local lbl = sg and sg:FindFirstChild("PaintImage")
                if lbl then
                    local ok, img = pcall(function() return lbl.ImageContent.Object end)
                    if ok and img then
                        pd[face.name] = {img=img, sz=img.Size, face=face}
                    end
                end
            end
            if next(pd) then out[part] = pd end
        end
    end
    return out
end

-- -- Prewarm -------------------------------------------------------------------
local function prewarm(char, rp)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dirs = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(0,-1,0), Vector3.new(0,1,0),
        Vector3.new(1,0,1).Unit, Vector3.new(-1,0,1).Unit,
        Vector3.new(1,0,-1).Unit, Vector3.new(-1,0,-1).Unit,
    }
    for _, d in ipairs(dirs) do
        local r = workspace:Raycast(hrp.Position, d * 120, rp)
        if r and r.Instance then
            local fn = faceFromNormal(r.Instance, r.Normal)
            local id = getTexId(r.Instance, fn)
            if id then loadTex(id) end
        end
    end
end
-- -- Paint one face ------------------------------------------------------------
local function paintFace(part, cd, rp)
    local img  = cd.img
    local imgW = cd.sz.X
    local imgH = cd.sz.Y
    local face = cd.face

    local gridW = math.max(1, math.ceil(imgW / RAY_DIVISOR))
    local gridH = math.max(1, math.ceil(imgH / RAY_DIVISOR))
    local tileW = imgW / gridW
    local tileH = imgH / gridH

    local totalPx = imgW * imgH
    local buf     = buffer.create(totalPx * 4)
    local pc      = part.Color
    local pr = math.floor(pc.R*255+.5)
    local pg = math.floor(pc.G*255+.5)
    local pb = math.floor(pc.B*255+.5)
    for i = 0, totalPx-1 do
        local o = i*4
        buffer.writeu8(buf,o,pr); buffer.writeu8(buf,o+1,pg)
        buffer.writeu8(buf,o+2,pb); buffer.writeu8(buf,o+3,255)
    end

    local rSum,gSum,bSum,rCnt = 0,0,0,0

    for gy = 0, gridH-1 do
        for gx = 0, gridW-1 do
            local cpx = math.floor((gx+0.5)*tileW)
            local cpy = math.floor((gy+0.5)*tileH)
            local org, dir = pixelRay(part, face, cpx, cpy, imgW, imgH)

            local r,g,b     = pr,pg,pb
            local remaining = RAY_LENGTH
            local rayOrg    = org

            for _ = 1, 6 do
                local res = workspace:Raycast(rayOrg, dir*remaining, rp)
                if not res then break end

                local hit  = res.Instance
                local dist = (res.Position-rayOrg).Magnitude
                local isChar = hit.Parent and (
                    hit.Parent:FindFirstChildOfClass("Humanoid") or
                    (hit.Parent.Parent and hit.Parent.Parent:FindFirstChildOfClass("Humanoid")))

                -- Skip: character parts, or hits within 0.3 studs (self-surface noise)
                if dist < 0.3 or isChar then
                    remaining = remaining - dist - 0.05
                    rayOrg    = res.Position + dir*0.05
                    if remaining < 0.5 then break end
                    continue
                end

                if hit.Transparency < 0.85 then
                    local baseColor = getSurfaceColor(hit)
                    local finalColor = baseColor
                    local hitFace = faceFromNormal(hit, res.Normal)
                    local fe = Enum.NormalId[hitFace]

                    -- Sample and composite ALL texture layers bottom→top
                    local layers = getTexLayers(hit, hitFace)
                    for _, layer in ipairs(layers) do
                        local tid, tc = layer[1], layer[2]
                        local timg = getTex(tid)
                        if timg then
                            if fe then
                                local tu, tv = hitUV(hit, res.Position, fe, tc)
                                finalColor = sampleTex(timg, tid, tu, tv, finalColor, tc)
                            end
                        else
                            loadTex(tid)
                        end
                    end

                    r = math.clamp(math.floor(finalColor.R*255+.5), 0, 255)
                    g = math.clamp(math.floor(finalColor.G*255+.5), 0, 255)
                    b = math.clamp(math.floor(finalColor.B*255+.5), 0, 255)
                    rSum+=r; gSum+=g; bSum+=b; rCnt+=1
                end
                break
            end



            local px0 = math.floor(gx*tileW)
            local py0 = math.floor(gy*tileH)
            local px1 = math.min(math.floor((gx+1)*tileW), imgW)
            local py1 = math.min(math.floor((gy+1)*tileH), imgH)
            for py2 = py0, py1-1 do
                for px2 = px0, px1-1 do
                    local o = (py2*imgW+px2)*4
                    buffer.writeu8(buf,o,r); buffer.writeu8(buf,o+1,g)
                    buffer.writeu8(buf,o+2,b); buffer.writeu8(buf,o+3,255)
                end
            end
        end
    end

    pcall(img.WritePixelsBuffer, img, Vector2.zero, cd.sz, buf)
    return rCnt>0 and math.floor(rSum/rCnt) or pr,
           rCnt>0 and math.floor(gSum/rCnt) or pg,
           rCnt>0 and math.floor(bSum/rCnt) or pb
end


-- -- Exclude list + running flag (must be before autoCamo) --------------------
local running = false

local function buildExclude(char)
    local t = {char}
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and (inst.Transparency >= 0.95 or inst.Size.Magnitude < 0.2) then
            t[#t+1] = inst
        end
    end
    return t
end

-- -- Auto camo -----------------------------------------------------------------
local function autoCamo(setStatus, notif)
    if running then notif("Still painting...", Color3.fromRGB(255,150,50)); return end

    if not isHider() then
        local role = plr:GetAttribute("RoundRole") or ""
        local msg  = plr:GetAttribute("InRound") and ("You are "..role) or "Not in a round"
        notif(msg, Color3.fromRGB(200,100,40))
        setStatus(msg, Color3.fromRGB(200,100,40))
        return
    end


    running = true
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        notif("No character!", Color3.fromRGB(200,60,60))
        running = false; return
    end

    setStatus("Building scene...", Color3.fromRGB(255,200,60))

    local rp = RaycastParams.new()
    rp.FilterType                 = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = buildExclude(char)

    prewarm(char, rp)
    setStatus("Loading textures...", Color3.fromRGB(255,200,60))
    local deadline = os.clock() + 5
    repeat task.wait(0.05) until next(loadingSet) == nil or os.clock() > deadline

    local canvases = getCanvases(char)
    local total, done = 0, 0
    for _, pd in pairs(canvases) do for _ in pairs(pd) do total += 1 end end

    if total == 0 then
        notif("No canvases — are you Hider in a round?", Color3.fromRGB(200,60,60))
        running = false; return
    end

    setStatus("Painting 0/"..total.."...", Color3.fromRGB(100,200,120))
    setStatus("Painting 0/"..total.."...", Color3.fromRGB(100,200,120))

    for part, pd in pairs(canvases) do
        if killed then break end
        for _, cd in pairs(pd) do
            if killed then break end
            paintFace(part, cd, rp)
            done += 1
            setStatus(string.format("Painting %d/%d...", done, total), Color3.fromRGB(100,200,120))
            if done % 4 == 0 then task.wait() end
        end
        -- Server sync removed: fillPart sets part.Color = avgColor which
        -- re-tints our per-pixel canvas via LightInfluence=1 → wrong colors
    end

    running = false
    setStatus(string.format("Done! %d faces painted", done), Color3.fromRGB(80,220,120))
    notif("Camo applied! "..done.." faces", Color3.fromRGB(50,180,80))
end

-- -- Sample & fill -------------------------------------------------------------
local function sampleFill(setStatus, notif)
    if not isHider() then

        notif("Must be Hider to paint", Color3.fromRGB(200,100,40)); return
    end

    local cam = workspace.CurrentCamera
    local mp  = uis:GetMouseLocation()
    local ray = cam:ViewportPointToRay(mp.X, mp.Y)
    local rp  = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local char = plr.Character
    if char then rp.FilterDescendantsInstances = {char} end

    local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
    if not res then notif("No surface hit!", Color3.fromRGB(200,60,60)); return end

    local color = getSurfaceColor(res.Instance)

    if not char then return end
    local canvases = getCanvases(char)
    for part, pd in pairs(canvases) do
        for _, cd in pairs(pd) do
            pcall(PaintDrawing.FillImageArea, cd.img, Vector2.zero, cd.sz, color)
        end
        pcall(function()
            PaintEvent:FireServer({kind="fillPart", targetUserId=plr.UserId,
                partName=part.Name, color=color})
        end)
    end

    notif(string.format("RGB(%d,%d,%d)",
        math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
        Color3.fromRGB(40,120,200))
    setStatus("Sampled & filled", Color3.fromRGB(80,180,255))
end



-- -- UI ------------------------------------------------------------------------
local pg = plr:WaitForChild("PlayerGui")
do local e = pg:FindFirstChild("CamoGui2"); if e then e:Destroy() end end

local sg = Instance.new("ScreenGui")
sg.Name="CamoGui2"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
sg.Parent=pg

local function notif(text, color)
    local f = Instance.new("Frame")
    f.Size=UDim2.new(0,270,0,44); f.Position=UDim2.new(0.5,-135,0,-56)
    f.BackgroundColor3=Color3.fromRGB(18,18,18); f.BackgroundTransparency=0.1
    f.BorderSizePixel=0; f.ZIndex=20; f.Parent=sg
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    local st=Instance.new("UIStroke",f); st.Color=color; st.Thickness=1.5; st.Transparency=0.3
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,12,0.5,-3.5)
    dot.BackgroundColor3=color; dot.BorderSizePixel=0; dot.ZIndex=21; dot.Parent=f
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local tl=Instance.new("TextLabel")
    tl.Size=UDim2.new(1,-28,1,0); tl.Position=UDim2.new(0,26,0,0)
    tl.BackgroundTransparency=1; tl.Text=text
    tl.TextColor3=Color3.fromRGB(225,225,225); tl.TextSize=12
    tl.Font=Enum.Font.GothamSemibold
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=21; tl.Parent=f
    ts:Create(f, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-135,0,12)}):Play()
    task.delay(3, function()
        ts:Create(f, TweenInfo.new(0.25), {Position=UDim2.new(0.5,-135,0,-56)}):Play()
        task.delay(0.3, function() if f.Parent then f:Destroy() end end)
    end)
end

local W, H = 200, 130
local panel = Instance.new("Frame")
panel.Size=UDim2.new(0,W,0,H); panel.Position=UDim2.new(0,14,0.5,-H/2)
panel.BackgroundColor3=Color3.fromRGB(15,15,15); panel.BackgroundTransparency=0.1
panel.BorderSizePixel=0; panel.Parent=sg
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,10)
local ps=Instance.new("UIStroke",panel)
ps.Color=Color3.fromRGB(80,80,80); ps.Thickness=1; ps.Transparency=0.5

local ttl=Instance.new("TextLabel")
ttl.Size=UDim2.new(1,-8,0,26); ttl.Position=UDim2.new(0,10,0,4)
ttl.BackgroundTransparency=1; ttl.Text="🎨 Camo v2"
ttl.TextColor3=Color3.fromRGB(220,220,220); ttl.TextSize=13
ttl.Font=Enum.Font.GothamBold
ttl.TextXAlignment=Enum.TextXAlignment.Left; ttl.Parent=panel

local statusLbl=Instance.new("TextLabel")
statusLbl.Size=UDim2.new(1,-10,0,14); statusLbl.Position=UDim2.new(0,10,0,28)
statusLbl.BackgroundTransparency=1; statusLbl.Text="Waiting for round..."
statusLbl.TextColor3=Color3.fromRGB(110,110,110); statusLbl.TextSize=10
statusLbl.Font=Enum.Font.Gotham
statusLbl.TextXAlignment=Enum.TextXAlignment.Left
statusLbl.TextTruncate=Enum.TextTruncate.AtEnd; statusLbl.Parent=panel

local function setStatus(txt, col)
    statusLbl.Text=txt; statusLbl.TextColor3=col or Color3.fromRGB(110,110,110)
end

local function makeBtn(label, key, y, col)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-12,0,30); b.Position=UDim2.new(0,6,0,y)
    b.BackgroundColor3=col; b.BorderSizePixel=0; b.Text=""
    b.AutoButtonColor=false; b.Parent=panel
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-38,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=Color3.fromRGB(255,255,255); l.TextSize=11
    l.Font=Enum.Font.GothamSemibold
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=b
    local k=Instance.new("TextLabel")
    k.Size=UDim2.new(0,26,0,16); k.Position=UDim2.new(1,-32,0.5,-8)
    k.BackgroundColor3=Color3.fromRGB(0,0,0); k.BackgroundTransparency=0.5
    k.Text=key; k.TextColor3=Color3.fromRGB(180,180,180)
    k.TextSize=9; k.Font=Enum.Font.GothamBold; k.Parent=b
    Instance.new("UICorner",k).CornerRadius=UDim.new(0,4)
    local h=col:Lerp(Color3.new(1,1,1),.12)
    local p=col:Lerp(Color3.new(0,0,0),.15)
    b.MouseEnter:Connect(function()    b.BackgroundColor3=h   end)
    b.MouseLeave:Connect(function()    b.BackgroundColor3=col end)
    b.MouseButton1Down:Connect(function() b.BackgroundColor3=p   end)
    b.MouseButton1Up:Connect(function()   b.BackgroundColor3=col end)
    return b
end

local sBtn = makeBtn("Sample & Fill", "[E]", 50,  Color3.fromRGB(35,110,190))
local cBtn = makeBtn("Texture Camo",  "[T]", 86,  Color3.fromRGB(40,150,70))

local drag, ds, dp
panel.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true; ds=i.Position; dp=panel.Position end end)
uis.InputChanged:Connect(function(i)
    if not drag then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-ds
        panel.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y) end end)
uis.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=false end end)

local function doSample() sampleFill(setStatus, notif) end
local function doCamo()   task.spawn(autoCamo, setStatus, notif) end

sBtn.MouseButton1Click:Connect(doSample); sBtn.TouchTap:Connect(doSample)
cBtn.MouseButton1Click:Connect(doCamo);  cBtn.TouchTap:Connect(doCamo)

local ic = uis.InputBegan:Connect(function(i, gpe)
    if killed or gpe then return end
    if i.KeyCode==Enum.KeyCode.E then doSample()
    elseif i.KeyCode==Enum.KeyCode.T then doCamo() end
end)

local function updateStatus()
    if killed then return end
    if isHider() then
        setStatus("Hider — ready!", Color3.fromRGB(80,200,120))
    elseif plr:GetAttribute("InRound") then
        setStatus("Seeker — camo locked", Color3.fromRGB(200,100,40))
    else
        setStatus("Waiting for round...", Color3.fromRGB(110,110,110))
    end
end
plr:GetAttributeChangedSignal("RoundRole"):Connect(updateStatus)
plr:GetAttributeChangedSignal("InRound"):Connect(updateStatus)
updateStatus()

notif("Camo v2 · [E] sample · [T] auto camo", Color3.fromRGB(80,180,255))

task.spawn(function()
    while not killed do task.wait(0.5) end
    ic:Disconnect()
    for _, img in pairs(texCache) do
        if img and img ~= false then pcall(function() img:Destroy() end) end
    end
    texCache = {}; texTypeCache = {}
    if sg.Parent then sg:Destroy() end
end)
