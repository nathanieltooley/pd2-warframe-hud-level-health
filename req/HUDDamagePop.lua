local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

local mvec_add = mvector3.add
local mvec_lerp = mvector3.lerp
local mvec_set = mvector3.set
local tmp_vec = Vector3()

---@class HUDDamagePop
---@field new fun(self, panel, pos, damage, proc_type, is_crit, is_headshot):HUDDamagePop
HUDDamagePop = HUDDamagePop or WFHud:panel_class()

HUDDamagePop.ALPHA_CURVE = { 1, 1, 0.5, 0 }
HUDDamagePop.SCALE_CURVE = { 1, 0.5, 1.5, 1.5 }
HUDDamagePop.PROC_TYPE_TEXTURE_RECTS = {
	impact = { 0, 0, 48, 48 },
	puncture = { 48, 0, 48, 48 },
	electricity = { 0, 48, 48, 48 },
	heat = { 48, 48, 48, 48 },
	toxin = { 96, 48, 48, 48 },
	blast = { 144, 48, 48, 48 }
}
HUDDamagePop.COLORS = {
	"damage",
	"yellow_crit",
	"orange_crit",
	"red_crit"
}

---@param panel Panel
---@param pos Vector3
---@param damage number
---@param proc_type string?
---@param is_crit boolean?
---@param is_headshot boolean?
function HUDDamagePop:init(panel, pos, damage, proc_type, is_crit, is_headshot)
	self._crit_mod = (is_crit and 1 or 0) + (is_headshot and 1 or 0)

	self._panel = panel:panel({
		visible = false,
		layer = -99 + self._crit_mod
	})

	local color = damage == 0 and WFHud.settings.colors.muted or WFHud.settings.colors[HUDDamagePop.COLORS[self._crit_mod + 1]]

	if self.PROC_TYPE_TEXTURE_RECTS[proc_type] then
		self._proc_bitmap = self._panel:bitmap({
			texture = "guis/textures/wfhud/damage_types",
			texture_rect = self.PROC_TYPE_TEXTURE_RECTS[proc_type],
			color = color
		})
	end

	self._damage_text = self._panel:text({
		text = string.format("%u", math.abs(math.ceil(damage * 10))),
		font = WFHud.fonts.default,
		color = color,
		x = 0
	})

	self._pos = pos

	self._dir = Vector3(-0.5 + math.random(), -0.5 + math.random(), math.random())
	self._offset = Vector3()

	self._panel:animate(callback(self, self, "_animate"))
end

function HUDDamagePop:_animate()
	local cam = managers.viewport:get_current_camera()

	over(1, function (t)
		if not alive(cam) or not alive(WFHud:ws()) then
			return
		end

		local size = math.ceil(WFHud.font_sizes.default * font_scale * hud_scale * (1 + (self._crit_mod ^ 1.5) * 0.5) * math.bezier(self.SCALE_CURVE, t))

		self._damage_text:set_font_size(size)
		local _, _, tw, _ = self._damage_text:text_rect()

		if self._proc_bitmap then
			self._proc_bitmap:set_size(size, size)
			self._proc_bitmap:set_x(tw)
		end

		mvec_lerp(tmp_vec, self._dir, math.DOWN, t)
		mvec_add(self._offset, tmp_vec)

		mvec_set(tmp_vec, self._offset)
		mvec_add(tmp_vec, self._pos)

		local screen_pos = WFHud:ws():world_to_screen(cam, tmp_vec)
		self._panel:set_size(tw + (self._proc_bitmap and size or 0), size)
		self._panel:set_center(screen_pos.x, screen_pos.y)
		self._panel:set_alpha(math.bezier(self.ALPHA_CURVE, t))
		self._panel:set_visible(screen_pos.z > 0)
	end)

	self._panel:parent():remove(self._panel)
end
