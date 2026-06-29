local a = {}
local g = function(b, c)
  if (((1 + 1) == 2) and a[b]) then
    return a[b]
  end
  local d = {}
  for e = 1, #b do
    d[e] = string.char(bit32.bxor(b[e], c))
  end
  local f = table.concat(d)
  a[b] = f
  return f
end
if (((15 * 15) == 225) and _G._camoV2Kill) then
  _G._camoV2Kill()
end
task.wait(0.1)
local h = false
local i = {}
local j = {}
local k = {}
_G._camoV2Kill = function()
  h = true
end
local l = game.Players.LocalPlayer
local m = game:GetService(g({8, 63, 42, 54, 51, 57, 59, 46, 63, 62, 9, 46, 53, 40, 59, 61, 63}, 90))
local n = game:GetService(g({27, 41, 41, 63, 46, 9, 63, 40, 44, 51, 57, 63}, 90))
local o = game:GetService(g({15, 41, 63, 40, 19, 52, 42, 47, 46, 9, 63, 40, 44, 51, 57, 63}, 90))
local p = game:GetService(g({14, 45, 63, 63, 52, 9, 63, 40, 44, 51, 57, 63}, 90))
local q = m:WaitForChild(g({8, 63, 55, 53, 46, 63, 41}, 90), 10)
local r = (q and q:WaitForChild(g({10, 59, 51, 52, 46, 31, 44, 63, 52, 46}, 90), 10))
local s = require(m.Modules.PaintAtlas)
local t = require(m.Modules.PaintDrawing)
local u = 2
local v = 500
local w = 0.15
local function x()
  return ((l:GetAttribute(g({19, 52, 8, 53, 47, 52, 62}, 90)) == true) and (l:GetAttribute(g({8, 53, 47, 52, 62, 8, 53, 54, 63}, 90)) == g({18, 51, 62, 63, 40}, 90)))
end
local function y(z)
  if (((100 % 7) == 2) and ((i[z] ~= nil) or j[z])) then
    return
  end
  j[z] = true
  k[z] = true
  task.spawn(function()
    local aa, ab = pcall(n.CreateEditableImageAsync, n, Content.fromUri(z))
    i[z] = (((aa and ab)) or false)
    j[z] = nil
    k[z] = nil
  end)
end
local function ac(ad)
  local ae = i[ad]
  return ((((ae and (ae ~= false))) and ae) or nil)
end
local function af(ag, ah, ai, aj, ak, al, am)
  local an = ag.Size
  am = (am or 0)
  local ao = math.clamp(math.floor((ai * an.X)), 0, (an.X - 1))
  local ap = math.clamp(math.floor((aj * an.Y)), 0, (an.Y - 1))
  local aq = ((((al and al:IsA(g({14, 63, 34, 46, 47, 40, 63}, 90)))) and al.Transparency) or 0)
  local ar = (1 - aq)
  local as = 0.72
  local at = ((((ar < as)) and ((as / math.max(ar, 0.01)))) or 1.0)
  local au, av, aw, ax = 0, 0, 0, 0
  for ay = -am, am do
    local az = (ap + ay)
    if (((12 * 12) == 144) and ((az >= 0) and (az < an.Y))) then
      for ba = -am, am do
        local bb = (ao + ba)
        if (((3 ^ 2) == 9) and ((bb >= 0) and (bb < an.X))) then
          local bc, bd = pcall(ag.ReadPixelsBuffer, ag, Vector2.new(bb, az), Vector2.new(1, 1))
          if (((7 * 7) == 49) and bc) then
            local be = (buffer.readu8(bd, 0) / 255)
            local bf = (buffer.readu8(bd, 1) / 255)
            local bg = (buffer.readu8(bd, 2) / 255)
            local bh = (buffer.readu8(bd, 3) / 255)
            local bi = math.min(((bh * ar) * at), 1.0)
            au += (ak.R + (((be - ak.R)) * bi))
            av += (ak.G + (((bf - ak.G)) * bi))
            aw += (ak.B + (((bg - ak.B)) * bi))
            ax += 1
          end
        end
      end
    end
  end
  if (((1 + 1) == 2) and (ax == 0)) then
    return ak
  end
  return Color3.new(math.clamp((au / ax), 0, 1), math.clamp((av / ax), 0, 1), math.clamp((aw / ax), 0, 1))
end
local function bj(bk)
  local bl = bk:GetAttribute(g({9, 59, 55, 42, 54, 63, 25, 53, 54, 53, 40}, 90))
  if (((15 * 15) == 225) and (typeof(bl) == g({25, 53, 54, 53, 40, 105}, 90))) then
    return bl
  end
  return bk.Color
end
local function bm(bn, bo)
  local bp = bn.CFrame:VectorToObjectSpace(bo)
  local bq, br, bs = math.abs(bp.X), math.abs(bp.Y), math.abs(bp.Z)
  if (((100 % 7) == 2) and ((bq >= br) and (bq >= bs))) then
    return (((bp.X > 0) and g({8, 51, 61, 50, 46}, 90)) or g({22, 63, 60, 46}, 90))
  elseif (((12 * 12) == 144) and ((br >= bq) and (br >= bs))) then
    return (((bp.Y > 0) and g({14, 53, 42}, 90)) or g({24, 53, 46, 46, 53, 55}, 90))
  else
    return (((bp.Z > 0) and g({24, 59, 57, 49}, 90)) or g({28, 40, 53, 52, 46}, 90))
  end
end
local function bt(bu, bv)
  local bw = {}
  local bx = nil
  local by = {}
  for bz, ca in ipairs(bu:GetChildren()) do
    if (((3 ^ 2) == 9) and (((ca:IsA(g({14, 63, 34, 46, 47, 40, 63}, 90)) or ca:IsA(g({30, 63, 57, 59, 54}, 90)))) and (ca.Texture ~= ""))) then
      local cb = (tostring(ca.Face):match(g({20, 53, 40, 55, 59, 54, 19, 62, 127, 116, 114, 116, 113, 115}, 90)) or "")
      local cc = ca.Texture
      if (((7 * 7) == 49) and ((cb == bv) and not by[cc])) then
        by[cc] = true
        table.insert(bw, {cc, ca})
      elseif (((1 + 1) == 2) and (not bx and not by[cc])) then
        bx = {cc, ca}
      end
    end
  end
  if (((15 * 15) == 225) and ((#bw == 0) and bx)) then
    table.insert(bw, bx)
  end
  if (((100 % 7) == 2) and (((#bw == 0) and bu:IsA(g({23, 63, 41, 50, 10, 59, 40, 46}, 90))) and (bu.TextureID ~= ""))) then
    table.insert(bw, {bu.TextureID, nil})
  end
  if (((12 * 12) == 144) and (#bw == 0)) then
    local cd = bu:FindFirstChildOfClass(g({9, 47, 40, 60, 59, 57, 63, 27, 42, 42, 63, 59, 40, 59, 52, 57, 63}, 90))
    if (((3 ^ 2) == 9) and cd) then
      local ce = tostring(cd.ColorMapContent):match(g({114, 40, 56, 34, 59, 41, 41, 63, 46, 51, 62, 96, 117, 117, 127, 62, 113, 115}, 90))
      if (((7 * 7) == 49) and ce) then
        table.insert(bw, {ce, nil})
      end
    end
  end
  return bw
end
local function cf(cg, ch)
  local ci = bt(cg, ch)
  if (((1 + 1) == 2) and ci[1]) then
    return ci[1][1], ci[1][2]
  end
  return nil, nil
end
local function cj(ck, cl, cm)
  local cn = ck.CFrame:PointToObjectSpace(cl)
  local co = ck.Size
  local cp = ((cn.X / co.X) + 0.5)
  local cq = ((cn.Y / co.Y) + 0.5)
  local cr = ((cn.Z / co.Z) + 0.5)
  if (((15 * 15) == 225) and (cm == Enum.NormalId.Front)) then
    return (1 - cp), (1 - cq)
  elseif (((100 % 7) == 2) and (cm == Enum.NormalId.Back)) then
    return cp, (1 - cq)
  elseif (((12 * 12) == 144) and (cm == Enum.NormalId.Right)) then
    return (1 - cr), (1 - cq)
  elseif (((3 ^ 2) == 9) and (cm == Enum.NormalId.Left)) then
    return cr, (1 - cq)
  elseif (((7 * 7) == 49) and (cm == Enum.NormalId.Top)) then
    return (1 - cr), cp
  elseif (((1 + 1) == 2) and (cm == Enum.NormalId.Bottom)) then
    return (1 - cr), (1 - cp)
  end
  return 0.5, 0.5
end
local function cs(ct, cu, cv, cw)
  local cx, cy = cj(ct, cu, cv)
  if (((15 * 15) == 225) and (cw and cw:IsA(g({14, 63, 34, 46, 47, 40, 63}, 90)))) then
    local cz = ct.Size
    local da, db = cw.StudsPerTileU, cw.StudsPerTileV
    if (((100 % 7) == 2) and ((da > 0) and (db > 0))) then
      local dc, dd
      if (((12 * 12) == 144) and ((cv == Enum.NormalId.Front) or (cv == Enum.NormalId.Back))) then
        dc, dd = cz.X, cz.Y
      elseif (((3 ^ 2) == 9) and ((cv == Enum.NormalId.Right) or (cv == Enum.NormalId.Left))) then
        dc, dd = cz.Z, cz.Y
      else
        dc, dd = cz.Z, cz.X
      end
      local de = (cw.OffsetStudsU or 0)
      local df = (cw.OffsetStudsV or 0)
      cx = ((((((((cx - 0.5)) * dc) + de)) / da)) % 1)
      cy = ((((((((cy - 0.5)) * dd) + df)) / db)) % 1)
      if (((7 * 7) == 49) and (cx < 0)) then
        cx = (cx + 1)
      end
      if (((1 + 1) == 2) and (cy < 0)) then
        cy = (cy + 1)
      end
    end
  end
  return math.clamp(cx, 0, 1), math.clamp(cy, 0, 1)
end
local dg = {{name = g({28, 40, 53, 52, 46}, 90), ln = Vector3.new(0, 0, -1), faceEnum = Enum.NormalId.Front}, {name = g({24, 59, 57, 49}, 90), ln = Vector3.new(0, 0, 1), faceEnum = Enum.NormalId.Back}, {name = g({8, 51, 61, 50, 46}, 90), ln = Vector3.new(1, 0, 0), faceEnum = Enum.NormalId.Right}, {name = g({22, 63, 60, 46}, 90), ln = Vector3.new(-1, 0, 0), faceEnum = Enum.NormalId.Left}, {name = g({14, 53, 42}, 90), ln = Vector3.new(0, 1, 0), faceEnum = Enum.NormalId.Top}, {name = g({24, 53, 46, 46, 53, 55}, 90), ln = Vector3.new(0, -1, 0), faceEnum = Enum.NormalId.Bottom}}
local function dh(di, dj, dk, dl, dm, dn)
  local dp = (((dk + 0.5)) / dm)
  local dq = (((dl + 0.5)) / dn)
  local dr = di.Size
  local ds = dj.faceEnum
  local dt = dj.ln
  local du, dv, dw
  if (((15 * 15) == 225) and (ds == Enum.NormalId.Front)) then
    du = (((0.5 - dp)) * dr.X)
    dv = (((0.5 - dq)) * dr.Y)
    dw = (-dr.Z * 0.5)
  elseif (((100 % 7) == 2) and (ds == Enum.NormalId.Back)) then
    du = (((dp - 0.5)) * dr.X)
    dv = (((0.5 - dq)) * dr.Y)
    dw = (dr.Z * 0.5)
  elseif (((12 * 12) == 144) and (ds == Enum.NormalId.Right)) then
    du = (dr.X * 0.5)
    dv = (((0.5 - dq)) * dr.Y)
    dw = (((0.5 - dp)) * dr.Z)
  elseif (((3 ^ 2) == 9) and (ds == Enum.NormalId.Left)) then
    du = (-dr.X * 0.5)
    dv = (((0.5 - dq)) * dr.Y)
    dw = (((dp - 0.5)) * dr.Z)
  elseif (((7 * 7) == 49) and (ds == Enum.NormalId.Top)) then
    du = (((dq - 0.5)) * dr.X)
    dv = (dr.Y * 0.5)
    dw = (((0.5 - dp)) * dr.Z)
  elseif (((1 + 1) == 2) and (ds == Enum.NormalId.Bottom)) then
    du = (((0.5 - dq)) * dr.X)
    dv = (-dr.Y * 0.5)
    dw = (((0.5 - dp)) * dr.Z)
  end
  local dx = di.CFrame:VectorToWorldSpace(dt)
  local dy = di.CFrame:PointToWorldSpace(Vector3.new(du, dv, dw))
  return (dy + (dx * w)), -dx, dy
end
local function dz(ea)
  local eb = {}
  for ec, ed in ipairs(ea:GetChildren()) do
    if (((15 * 15) == 225) and (ed:IsA(g({24, 59, 41, 63, 10, 59, 40, 46}, 90)) and s.IsPaintablePart(ed))) then
      local ee = {}
      for ef, eg in ipairs(dg) do
        local eh = ed:FindFirstChild((g({10, 59, 51, 52, 46, 25, 59, 52, 44, 59, 41, 5}, 90) .. eg.name))
        local ei = (eh and eh:FindFirstChild(g({10, 59, 51, 52, 46, 19, 55, 59, 61, 63}, 90)))
        if (((100 % 7) == 2) and ei) then
          local ej, ek = pcall(function()
            return ei.ImageContent.Object
          end)
          if (((12 * 12) == 144) and (ej and ek)) then
            ee[eg.name] = {img = ek, sz = ek.Size, face = eg}
          end
        end
      end
      if (((3 ^ 2) == 9) and next(ee)) then
        eb[ed] = ee
      end
    end
  end
  return eb
end
local function el(em, en)
  local eo = em:FindFirstChild(g({18, 47, 55, 59, 52, 53, 51, 62, 8, 53, 53, 46, 10, 59, 40, 46}, 90))
  if (((7 * 7) == 49) and not eo) then
    return
  end
  local ep = {Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1), Vector3.new(0, -1, 0), Vector3.new(0, 1, 0), Vector3.new(1, 0, 1).Unit, Vector3.new(-1, 0, 1).Unit, Vector3.new(1, 0, -1).Unit, Vector3.new(-1, 0, -1).Unit}
  for eq, er in ipairs(ep) do
    local es = workspace:Raycast(eo.Position, (er * 120), en)
    if (((1 + 1) == 2) and (es and es.Instance)) then
      local et = bm(es.Instance, es.Normal)
      local eu = cf(es.Instance, et)
      if (((15 * 15) == 225) and eu) then
        y(eu)
      end
    end
  end
end
local function ev(ew, ex)
  local ey = ew:FindFirstChild(g({18, 47, 55, 59, 52, 53, 51, 62, 8, 53, 53, 46, 10, 59, 40, 46}, 90))
  if (((100 % 7) == 2) and not ey) then
    return nil
  end
  local ez = ey.Position
  local fa = {}
  local fb = {}
  for fc = 0, 350, 20 do
    local fd = math.rad(fc)
    for fe, ff in ipairs({0, 0.4, -0.4}) do
      fb[(#fb + 1)] = Vector3.new(math.sin(fd), ff, math.cos(fd)).Unit
    end
  end
  for fg, fh in ipairs(fb) do
    local fi = workspace:Raycast(ez, (fh * 60), ex)
    if (((12 * 12) == 144) and (fi and fi.Instance)) then
      local fj = false
      for fk, fl in ipairs(fi.Instance:GetChildren()) do
        if (((3 ^ 2) == 9) and (((fl:IsA(g({14, 63, 34, 46, 47, 40, 63}, 90)) or fl:IsA(g({30, 63, 57, 59, 54}, 90)))) and (fl.Texture ~= ""))) then
          fj = true
          break
        end
      end
      if (((7 * 7) == 49) and fj) then
        local fm = ((fi.Position - ez)).Magnitude
        local fn = fa[fi.Instance]
        if (((1 + 1) == 2) and not fn) then
          fa[fi.Instance] = {count = 1, dist = fm, normal = fi.Normal, point = fi.Position}
        else
          fn.count += 1
          if (((15 * 15) == 225) and (fm < fn.dist)) then
            fn.dist = fm
            fn.normal = fi.Normal
            fn.point = fi.Position
          end
        end
      end
    end
  end
  local fo, fp = nil, -1
  for fq, fr in pairs(fa) do
    local fs = ((fr.count * 100) - fr.dist)
    if (((100 % 7) == 2) and (fs > fp)) then
      fp = fs
      fo = {inst = fq, normal = fr.normal, point = fr.point}
    end
  end
  return fo
end
local function ft(fu, fv, fw, fx, fy)
  local fz = ((fx - fw)):Dot(fv)
  local ga = (fx - (fz * fv))
  local gb = fu.CFrame:PointToObjectSpace(ga)
  local gc = (fu.Size * 0.5)
  if (((12 * 12) == 144) and (((math.abs(gb.X) > (gc.X + 0.5)) or (math.abs(gb.Y) > (gc.Y + 0.5))) or (math.abs(gb.Z) > (gc.Z + 0.5)))) then
    return nil
  end
  local gd = bm(fu, fv)
  local ge = Enum.NormalId[gd]
  if (((3 ^ 2) == 9) and not ge) then
    return nil
  end
  local gf = bj(fu)
  local gg = bt(fu, gd)
  for gh, gi in ipairs(gg) do
    local gj, gk = gi[1], gi[2]
    local gl = ac(gj)
    if (((7 * 7) == 49) and gl) then
      local gm, gn = cs(fu, ga, ge, gk)
      gf = af(gl, gj, gm, gn, gf, gk, fy)
    else
      y(gj)
    end
  end
  return math.clamp(math.floor(((gf.R * 255) + 0.5)), 0, 255), math.clamp(math.floor(((gf.G * 255) + 0.5)), 0, 255), math.clamp(math.floor(((gf.B * 255) + 0.5)), 0, 255)
end
local function go(gp, gq, gr, gs, gt, gu, gv, gw, gx, gy, gz, ha)
  local hb, hc, hd = dh(gp, gq, gr, gs, gt, gu)
  if (((1 + 1) == 2) and gz) then
    local he, hf, hg = ft(gz.inst, gz.normal, gz.point, hd, ha)
    if (((15 * 15) == 225) and he) then
      return he, hf, hg
    end
  end
  local hh = v
  local hi, hj, hk = gw, gx, gy
  for hl = 1, 4 do
    local hm = workspace:Raycast(hb, (hc * hh), gv)
    if (((100 % 7) == 2) and not hm) then
      break
    end
    local hn = hm.Instance
    local ho = ((hm.Position - hb)).Magnitude
    local hp = false
    local hq = hn.Parent
    if (((12 * 12) == 144) and hq) then
      if (((3 ^ 2) == 9) and hq:FindFirstChildOfClass(g({18, 47, 55, 59, 52, 53, 51, 62}, 90))) then
        hp = true
      elseif (((7 * 7) == 49) and (hq.Parent and hq.Parent:FindFirstChildOfClass(g({18, 47, 55, 59, 52, 53, 51, 62}, 90)))) then
        hp = true
      end
    end
    if (((1 + 1) == 2) and ((ho < 0.3) or hp)) then
      hh = ((hh - ho) - 0.05)
      hb = (hm.Position + (hc * 0.05))
      if (((15 * 15) == 225) and (hh < 0.5)) then
        break
      end
      continue
    end
    if (((100 % 7) == 2) and (hn.Transparency < 0.85)) then
      local hr = bj(hn)
      local hs = bm(hn, hm.Normal)
      local ht = Enum.NormalId[hs]
      local hu = bt(hn, hs)
      for hv, hw in ipairs(hu) do
        local hx, hy = hw[1], hw[2]
        local hz = ac(hx)
        if (((12 * 12) == 144) and hz) then
          if (((3 ^ 2) == 9) and ht) then
            local ia, ib = cs(hn, hm.Position, ht, hy)
            hr = af(hz, hx, ia, ib, hr, hy, ha)
          end
        else
          y(hx)
        end
      end
      hi = math.clamp(math.floor(((hr.R * 255) + 0.5)), 0, 255)
      hj = math.clamp(math.floor(((hr.G * 255) + 0.5)), 0, 255)
      hk = math.clamp(math.floor(((hr.B * 255) + 0.5)), 0, 255)
    end
    break
  end
  return hi, hj, hk
end
local function ic(id, ie, ig, ih, ii, ij, ik, il, im)
  for io = ih, (ij - 1) do
    local ip = (io * ie)
    for iq = ig, (ii - 1) do
      local ir = (((ip + iq)) * 4)
      buffer.writeu8(id, ir, ik)
      buffer.writeu8(id, (ir + 1), il)
      buffer.writeu8(id, (ir + 2), im)
      buffer.writeu8(id, (ir + 3), 255)
    end
  end
end
local function is(it, iu, iv, iw)
  local ix = iu.img
  local iy = iu.sz.X
  local iz = iu.sz.Y
  local ja = iu.face
  local jb = (iy * iz)
  local jc = buffer.create((jb * 4))
  local jd = it.Color
  local je = math.floor(((jd.R * 255) + 0.5))
  local jf = math.floor(((jd.G * 255) + 0.5))
  local jg = math.floor(((jd.B * 255) + 0.5))
  for jh = 0, (jb - 1) do
    local ji = (jh * 4)
    buffer.writeu8(jc, ji, je)
    buffer.writeu8(jc, (ji + 1), jf)
    buffer.writeu8(jc, (ji + 2), jg)
    buffer.writeu8(jc, (ji + 3), 255)
  end
  local jj = math.max(1, math.ceil((iy / u)))
  local jk = math.max(1, math.ceil((iz / u)))
  local jl = (iy / jj)
  local jm = (iz / jk)
  local jn = 4
  local jo = math.ceil((jj / jn))
  local jp = math.ceil((jk / jn))
  local jq = 1
  local function jr(js, jt, ju)
    local jv = math.floor((((js + 0.5)) * jl))
    local jw = math.floor((((jt + 0.5)) * jm))
    return go(it, ja, jv, jw, iy, iz, iv, je, jf, jg, iw, ju)
  end
  for jx = 0, (jp - 1) do
    for jy = 0, (jo - 1) do
      local jz = (jy * jn)
      local ka = (jx * jn)
      local kb = math.min((jz + jn), jj)
      local kc = math.min((ka + jn), jk)
      local kd, ke, kf = jr(jz, ka, jq)
      local kg, kh, ki = jr((kb - 1), ka, jq)
      local kj, kk, kl = jr(jz, (kc - 1), jq)
      local km, kn, ko = jr((kb - 1), (kc - 1), jq)
      local kp = 3
      local kq = (((((((((math.abs((kd - kg)) <= kp) and (math.abs((ke - kh)) <= kp)) and (math.abs((kf - ki)) <= kp)) and (math.abs((kd - kj)) <= kp)) and (math.abs((ke - kk)) <= kp)) and (math.abs((kf - kl)) <= kp)) and (math.abs((kd - km)) <= kp)) and (math.abs((ke - kn)) <= kp)) and (math.abs((kf - ko)) <= kp))
      if (((7 * 7) == 49) and kq) then
        local kr = (((((kd + kg) + kj) + km)) // 4)
        local ks = (((((ke + kh) + kk) + kn)) // 4)
        local kt = (((((kf + ki) + kl) + ko)) // 4)
        local ku = math.floor((jz * jl))
        local kv = math.floor((ka * jm))
        local kw = math.min(math.floor((kb * jl)), iy)
        local kx = math.min(math.floor((kc * jm)), iz)
        ic(jc, iy, ku, kv, kw, kx, kr, ks, kt)
      else
        for ky = ka, (kc - 1) do
          for kz = jz, (kb - 1) do
            local la, lb, lc = jr(kz, ky, jq)
            local ld = math.floor((kz * jl))
            local le = math.floor((ky * jm))
            local lf = math.min(math.floor((((kz + 1)) * jl)), iy)
            local lg = math.min(math.floor((((ky + 1)) * jm)), iz)
            ic(jc, iy, ld, le, lf, lg, la, lb, lc)
          end
        end
      end
    end
  end
  pcall(ix.WritePixelsBuffer, ix, Vector2.zero, iu.sz, jc)
end
local lh = false
local function li(lj)
  local lk = {lj}
  for ll, lm in ipairs(workspace:GetDescendants()) do
    if (((1 + 1) == 2) and (lm:IsA(g({24, 59, 41, 63, 10, 59, 40, 46}, 90)) and (((lm.Transparency >= 0.95) or (lm.Size.Magnitude < 0.2))))) then
      lk[(#lk + 1)] = lm
    end
  end
  return lk
end
local function ln(lo, lp)
  if (((15 * 15) == 225) and lh) then
    lp(g({9, 46, 51, 54, 54, 122, 42, 59, 51, 52, 46, 51, 52, 61, 116, 116, 116}, 90), Color3.fromRGB(255, 150, 50))
    return
  end
  if (((100 % 7) == 2) and not x()) then
    local lq = (l:GetAttribute(g({8, 53, 47, 52, 62, 8, 53, 54, 63}, 90)) or "")
    local lr = ((l:GetAttribute(g({19, 52, 8, 53, 47, 52, 62}, 90)) and ((g({3, 53, 47, 122, 59, 40, 63, 122}, 90) .. lq))) or g({20, 53, 46, 122, 51, 52, 122, 59, 122, 40, 53, 47, 52, 62}, 90))
    lp(lr, Color3.fromRGB(200, 100, 40))
    lo(lr, Color3.fromRGB(200, 100, 40))
    return
  end
  lh = true
  local ls = l.Character
  if (((12 * 12) == 144) and (not ls or not ls:FindFirstChild(g({18, 47, 55, 59, 52, 53, 51, 62, 8, 53, 53, 46, 10, 59, 40, 46}, 90)))) then
    lp(g({20, 53, 122, 57, 50, 59, 40, 59, 57, 46, 63, 40, 123}, 90), Color3.fromRGB(200, 60, 60))
    lh = false
    return
  end
  lo(g({24, 47, 51, 54, 62, 51, 52, 61, 122, 41, 57, 63, 52, 63, 116, 116, 116}, 90), Color3.fromRGB(255, 200, 60))
  local lt = RaycastParams.new()
  lt.FilterType = Enum.RaycastFilterType.Exclude
  lt.FilterDescendantsInstances = li(ls)
  el(ls, lt)
  lo(g({22, 53, 59, 62, 51, 52, 61, 122, 46, 63, 34, 46, 47, 40, 63, 41, 116, 116, 116}, 90), Color3.fromRGB(255, 200, 60))
  local lu = (os.clock() + 5)
  repeat
    task.wait(0.05)
  until (((3 ^ 2) == 9) and ((next(k) == nil) or (os.clock() > lu)))
  local lv = dz(ls)
  local lw, lx = 0, 0
  for ly, lz in pairs(lv) do
    for ma in pairs(lz) do
      lw += 1
    end
  end
  if (((7 * 7) == 49) and (lw == 0)) then
    lp(g({20, 53, 122, 57, 59, 52, 44, 59, 41, 63, 41, 122, 119, 122, 59, 40, 63, 122, 35, 53, 47, 122, 18, 51, 62, 63, 40, 122, 51, 52, 122, 59, 122, 40, 53, 47, 52, 62, 101}, 90), Color3.fromRGB(200, 60, 60))
    lh = false
    return
  end
  local mb = nil
  lo((g({10, 59, 51, 52, 46, 51, 52, 61, 122, 106, 117}, 90) .. (lw .. g({116, 116, 116}, 90))), Color3.fromRGB(100, 200, 120))
  for mc, md in pairs(lv) do
    if (((1 + 1) == 2) and h) then
      break
    end
    for me, mf in pairs(md) do
      if (((15 * 15) == 225) and h) then
        break
      end
      is(mc, mf, lt, mb)
      lx += 1
      lo(string.format(g({10, 59, 51, 52, 46, 51, 52, 61, 122, 127, 62, 117, 127, 62, 116, 116, 116}, 90), lx, lw), Color3.fromRGB(100, 200, 120))
      if (((100 % 7) == 2) and ((lx % 4) == 0)) then
        task.wait()
      end
    end
  end
  lh = false
  lo(string.format(g({30, 53, 52, 63, 123, 122, 127, 62, 122, 60, 59, 57, 63, 41, 122, 42, 59, 51, 52, 46, 63, 62}, 90), lx), Color3.fromRGB(80, 220, 120))
  lp((g({25, 59, 55, 53, 122, 59, 42, 42, 54, 51, 63, 62, 123, 122}, 90) .. (lx .. g({122, 60, 59, 57, 63, 41}, 90))), Color3.fromRGB(50, 180, 80))
end
local function mg(mh, mi)
  if (((12 * 12) == 144) and not x()) then
    mi(g({23, 47, 41, 46, 122, 56, 63, 122, 18, 51, 62, 63, 40, 122, 46, 53, 122, 42, 59, 51, 52, 46}, 90), Color3.fromRGB(200, 100, 40))
    return
  end
  local mj = workspace.CurrentCamera
  local mk = o:GetMouseLocation()
  local ml = mj:ViewportPointToRay(mk.X, mk.Y)
  local mm = RaycastParams.new()
  mm.FilterType = Enum.RaycastFilterType.Exclude
  local mn = l.Character
  if (((3 ^ 2) == 9) and mn) then
    mm.FilterDescendantsInstances = {mn}
  end
  local mo = workspace:Raycast(ml.Origin, (ml.Direction * 1000), mm)
  if (((7 * 7) == 49) and not mo) then
    mi(g({20, 53, 122, 41, 47, 40, 60, 59, 57, 63, 122, 50, 51, 46, 123}, 90), Color3.fromRGB(200, 60, 60))
    return
  end
  local mp = bj(mo.Instance)
  if (((1 + 1) == 2) and not mn) then
    return
  end
  local mq = dz(mn)
  for mr, ms in pairs(mq) do
    for mt, mu in pairs(ms) do
      pcall(t.FillImageArea, mu.img, Vector2.zero, mu.sz, mp)
    end
    pcall(function()
      if (((15 * 15) == 225) and r) then
        r:FireServer({kind = g({60, 51, 54, 54, 10, 59, 40, 46}, 90), targetUserId = l.UserId, partName = mr.Name, color = mp})
      end
    end)
  end
  mi(string.format(g({8, 29, 24, 114, 127, 62, 118, 127, 62, 118, 127, 62, 115}, 90), math.floor((mp.R * 255)), math.floor((mp.G * 255)), math.floor((mp.B * 255))), Color3.fromRGB(40, 120, 200))
  mh(g({9, 59, 55, 42, 54, 63, 62, 122, 124, 122, 60, 51, 54, 54, 63, 62}, 90), Color3.fromRGB(80, 180, 255))
end
local mv = l:WaitForChild(g({10, 54, 59, 35, 63, 40, 29, 47, 51}, 90))
do
  local mw = mv:FindFirstChild(g({25, 59, 55, 53, 29, 47, 51, 104}, 90))
  if (((100 % 7) == 2) and mw) then
    mw:Destroy()
  end
end
local mx = Instance.new(g({9, 57, 40, 63, 63, 52, 29, 47, 51}, 90))
mx.Name = g({25, 59, 55, 53, 29, 47, 51, 104}, 90)
mx.ResetOnSpawn = false
mx.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mx.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
mx.Parent = mv
local function my(mz, na)
  local nb = Instance.new(g({28, 40, 59, 55, 63}, 90))
  nb.Size = UDim2.new(0, 270, 0, 44)
  nb.Position = UDim2.new(0.5, -135, 0, -56)
  nb.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
  nb.BackgroundTransparency = 0.1
  nb.BorderSizePixel = 0
  nb.ZIndex = 20
  nb.Parent = mx
  Instance.new(g({15, 19, 25, 53, 40, 52, 63, 40}, 90), nb).CornerRadius = UDim.new(0, 10)
  local nc = Instance.new(g({15, 19, 9, 46, 40, 53, 49, 63}, 90), nb)
  nc.Color = na
  nc.Thickness = 1.5
  nc.Transparency = 0.3
  local nd = Instance.new(g({28, 40, 59, 55, 63}, 90))
  nd.Size = UDim2.new(0, 7, 0, 7)
  nd.Position = UDim2.new(0, 12, 0.5, -3.5)
  nd.BackgroundColor3 = na
  nd.BorderSizePixel = 0
  nd.ZIndex = 21
  nd.Parent = nb
  Instance.new(g({15, 19, 25, 53, 40, 52, 63, 40}, 90), nd).CornerRadius = UDim.new(1, 0)
  local ne = Instance.new(g({14, 63, 34, 46, 22, 59, 56, 63, 54}, 90))
  ne.Size = UDim2.new(1, -28, 1, 0)
  ne.Position = UDim2.new(0, 26, 0, 0)
  ne.BackgroundTransparency = 1
  ne.Text = mz
  ne.TextColor3 = Color3.fromRGB(225, 225, 225)
  ne.TextSize = 12
  ne.Font = Enum.Font.GothamSemibold
  ne.TextXAlignment = Enum.TextXAlignment.Left
  ne.ZIndex = 21
  ne.Parent = nb
  p:Create(nb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -135, 0, 12)}):Play()
  task.delay(3, function()
    p:Create(nb, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -135, 0, -56)}):Play()
    task.delay(0.3, function()
      if (((12 * 12) == 144) and nb.Parent) then
        nb:Destroy()
      end
    end)
  end)
end
local nf, ng = 200, 130
local nh = Instance.new(g({28, 40, 59, 55, 63}, 90))
nh.Size = UDim2.new(0, nf, 0, ng)
nh.Position = UDim2.new(0, 14, 0.5, (-ng / 2))
nh.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
nh.BackgroundTransparency = 0.1
nh.BorderSizePixel = 0
nh.Parent = mx
Instance.new(g({15, 19, 25, 53, 40, 52, 63, 40}, 90), nh).CornerRadius = UDim.new(0, 10)
local ni = Instance.new(g({15, 19, 9, 46, 40, 53, 49, 63}, 90), nh)
ni.Color = Color3.fromRGB(80, 80, 80)
ni.Thickness = 1
ni.Transparency = 0.5
local nj = Instance.new(g({14, 63, 34, 46, 22, 59, 56, 63, 54}, 90))
nj.Size = UDim2.new(1, -8, 0, 26)
nj.Position = UDim2.new(0, 10, 0, 4)
nj.BackgroundTransparency = 1
nj.Text = g({25, 59, 55, 53, 122, 44, 104, 116, 111}, 90)
nj.TextColor3 = Color3.fromRGB(220, 220, 220)
nj.TextSize = 13
nj.Font = Enum.Font.GothamBold
nj.TextXAlignment = Enum.TextXAlignment.Left
nj.Parent = nh
local nk = Instance.new(g({14, 63, 34, 46, 22, 59, 56, 63, 54}, 90))
nk.Size = UDim2.new(1, -10, 0, 14)
nk.Position = UDim2.new(0, 10, 0, 28)
nk.BackgroundTransparency = 1
nk.Text = g({13, 59, 51, 46, 51, 52, 61, 122, 60, 53, 40, 122, 40, 53, 47, 52, 62, 116, 116, 116}, 90)
nk.TextColor3 = Color3.fromRGB(110, 110, 110)
nk.TextSize = 10
nk.Font = Enum.Font.Gotham
nk.TextXAlignment = Enum.TextXAlignment.Left
nk.TextTruncate = Enum.TextTruncate.AtEnd
nk.Parent = nh
local function nl(nm, nn)
  nk.Text = nm
  nk.TextColor3 = (nn or Color3.fromRGB(110, 110, 110))
end
local function no(np, nq, nr, ns)
  local nt = Instance.new(g({14, 63, 34, 46, 24, 47, 46, 46, 53, 52}, 90))
  nt.Size = UDim2.new(1, -12, 0, 30)
  nt.Position = UDim2.new(0, 6, 0, nr)
  nt.BackgroundColor3 = ns
  nt.BorderSizePixel = 0
  nt.Text = ""
  nt.AutoButtonColor = false
  nt.Parent = nh
  Instance.new(g({15, 19, 25, 53, 40, 52, 63, 40}, 90), nt).CornerRadius = UDim.new(0, 7)
  local nu = Instance.new(g({14, 63, 34, 46, 22, 59, 56, 63, 54}, 90))
  nu.Size = UDim2.new(1, -38, 1, 0)
  nu.Position = UDim2.new(0, 10, 0, 0)
  nu.BackgroundTransparency = 1
  nu.Text = np
  nu.TextColor3 = Color3.fromRGB(255, 255, 255)
  nu.TextSize = 11
  nu.Font = Enum.Font.GothamSemibold
  nu.TextXAlignment = Enum.TextXAlignment.Left
  nu.Parent = nt
  local nv = Instance.new(g({14, 63, 34, 46, 22, 59, 56, 63, 54}, 90))
  nv.Size = UDim2.new(0, 26, 0, 16)
  nv.Position = UDim2.new(1, -32, 0.5, -8)
  nv.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  nv.BackgroundTransparency = 0.5
  nv.Text = nq
  nv.TextColor3 = Color3.fromRGB(180, 180, 180)
  nv.TextSize = 9
  nv.Font = Enum.Font.GothamBold
  nv.Parent = nt
  Instance.new(g({15, 19, 25, 53, 40, 52, 63, 40}, 90), nv).CornerRadius = UDim.new(0, 4)
  local nw = ns:Lerp(Color3.new(1, 1, 1), 0.12)
  local nx = ns:Lerp(Color3.new(0, 0, 0), 0.15)
  nt.MouseEnter:Connect(function()
    nt.BackgroundColor3 = nw
  end)
  nt.MouseLeave:Connect(function()
    nt.BackgroundColor3 = ns
  end)
  nt.MouseButton1Down:Connect(function()
    nt.BackgroundColor3 = nx
  end)
  nt.MouseButton1Up:Connect(function()
    nt.BackgroundColor3 = ns
  end)
  return nt
end
local ny = no(g({9, 59, 55, 42, 54, 63, 122, 124, 122, 28, 51, 54, 54}, 90), g({1, 31, 7}, 90), 50, Color3.fromRGB(35, 110, 190))
local nz = no(g({14, 63, 34, 46, 47, 40, 63, 122, 25, 59, 55, 53}, 90), g({1, 14, 7}, 90), 86, Color3.fromRGB(40, 150, 70))
local oa, ob, oc = false, nil, nil
nh.InputBegan:Connect(function(od)
  if (((3 ^ 2) == 9) and ((od.UserInputType == Enum.UserInputType.MouseButton1) or (od.UserInputType == Enum.UserInputType.Touch))) then
    oa = true
    ob = od.Position
    oc = nh.Position
  end
end)
o.InputChanged:Connect(function(oe)
  if (((7 * 7) == 49) and not oa) then
    return
  end
  if (((1 + 1) == 2) and ((oe.UserInputType == Enum.UserInputType.MouseMovement) or (oe.UserInputType == Enum.UserInputType.Touch))) then
    local of = (oe.Position - ob)
    nh.Position = UDim2.new(oc.X.Scale, (oc.X.Offset + of.X), oc.Y.Scale, (oc.Y.Offset + of.Y))
  end
end)
o.InputEnded:Connect(function(og)
  if (((15 * 15) == 225) and ((og.UserInputType == Enum.UserInputType.MouseButton1) or (og.UserInputType == Enum.UserInputType.Touch))) then
    oa = false
  end
end)
local function oh()
  mg(nl, my)
end
local function oi()
  task.spawn(ln, nl, my)
end
ny.MouseButton1Click:Connect(oh)
ny.TouchTap:Connect(oh)
nz.MouseButton1Click:Connect(oi)
nz.TouchTap:Connect(oi)
local ol = o.InputBegan:Connect(function(oj, ok)
  if (((100 % 7) == 2) and (h or ok)) then
    return
  end
  if (((12 * 12) == 144) and (oj.KeyCode == Enum.KeyCode.E)) then
    oh()
  elseif (((3 ^ 2) == 9) and (oj.KeyCode == Enum.KeyCode.T)) then
    oi()
  end
end)
local function om()
  if (((7 * 7) == 49) and h) then
    return
  end
  if (((1 + 1) == 2) and x()) then
    nl(g({18, 51, 62, 63, 40, 122, 119, 122, 40, 63, 59, 62, 35, 123}, 90), Color3.fromRGB(80, 200, 120))
  elseif (((15 * 15) == 225) and l:GetAttribute(g({19, 52, 8, 53, 47, 52, 62}, 90))) then
    nl(g({9, 63, 63, 49, 63, 40, 122, 119, 122, 57, 59, 55, 53, 122, 54, 53, 57, 49, 63, 62}, 90), Color3.fromRGB(200, 100, 40))
  else
    nl(g({13, 59, 51, 46, 51, 52, 61, 122, 60, 53, 40, 122, 40, 53, 47, 52, 62, 116, 116, 116}, 90), Color3.fromRGB(110, 110, 110))
  end
end
l:GetAttributeChangedSignal(g({8, 53, 47, 52, 62, 8, 53, 54, 63}, 90)):Connect(om)
l:GetAttributeChangedSignal(g({19, 52, 8, 53, 47, 52, 62}, 90)):Connect(om)
om()
my(g({25, 59, 55, 53, 122, 44, 104, 116, 111, 122, 119, 122, 1, 31, 7, 122, 41, 59, 55, 42, 54, 63, 122, 119, 122, 1, 14, 7, 122, 59, 47, 46, 53, 122, 57, 59, 55, 53}, 90), Color3.fromRGB(80, 180, 255))
task.spawn(function()
  while (((100 % 7) == 2) and not h) do
    task.wait(0.5)
  end
  ol:Disconnect()
  for on, oo in pairs(i) do
    if (((12 * 12) == 144) and (oo and (oo ~= false))) then
      pcall(function()
        oo:Destroy()
      end)
    end
  end
  i = {}
  texInfoCache = {}
  if (((3 ^ 2) == 9) and mx.Parent) then
    mx:Destroy()
  end
end)