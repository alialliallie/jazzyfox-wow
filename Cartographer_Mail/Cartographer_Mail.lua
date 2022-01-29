local L = AceLibrary("AceLocale-2.2"):new("Cartographer_Mail")
L:RegisterTranslations("enUS", function() return {
	["Mailboxes"] = true,
	["Module to remember mailboxes."] = true,
	["Mailbox"] = true,
	
	["Icon alpha"] = true,
	["Alpha transparency of the icon"] = true,
	["Icon size"] = true,
	["Size of the icons on the map"] = true,
	["Show minimap icons"] = true,
	["Show mailbox icons on the minimap"] = true,	
} end)

local mod = Cartographer:NewModule("Mailboxes", "AceEvent-2.0", "AceConsole-2.0")

function mod:OnInitialize()
	self.name    = L["Mailboxes"]
	self.title   = L["Mailboxes"]
	self.author  = "alialliallie"
	self.notes   = L["Module to remember mailboxes."]
	self.email   = "allison@wow.alliesaur.us"
	self.website = nil
	self.version = nil

	local opts = {}

	opts.toggle = {
		name = AceLibrary("AceLocale-2.2"):new("Cartographer")["Enabled"],
		desc = AceLibrary("AceLocale-2.2"):new("Cartographer")["Suspend/resume this module."],
		type  = 'toggle',
		order = -1,
		get   = function() return Cartographer:IsModuleActive(self) end,
		set   = function() Cartographer:ToggleModuleActive(self) end,
	}
	
	opts.alpha = {
		name = L["Icon alpha"],
		desc = L["Alpha transparency of the icon"],
		type = 'range',
		min = 0.1,
		max = 1,
		step = 0.05,
		isPercent = true,
		get = "GetIconAlpha",
		set = "SetIconAlpha",
		order = 1
	}
	
	opts.scale = {
		name = L["Icon size"],
		desc = L["Size of the icons on the map"],
		type = 'range',
		min = 0.5,
		max = 2,
		step = 0.05,
		isPercent = true,
		get = "GetIconScale",
		set = "SetIconScale",
		order = 2
	}
	
	opts.minimapicons = {
		name = L["Show minimap icons"],
		desc = L["Show mailbox icons on the minimap"],
		type = 'toggle',
		set = "ToggleShowingMinimapIcons",
		get = "IsShowingMinimapIcons",
		order = 3,
	}

	Cartographer.options.args.Mailboxes = {
		name = L["Mailboxes"],
		desc = self.notes,
		type = 'group',
		args = opts,
		handler = self,
	}

	self.db = Cartographer:AcquireDBNamespace("Mail")
	
	if not Cartographer_MailDB then
		Cartographer_MailDB = {}
	end
end

function mod:OnEnable()
	if Cartographer_Notes then
		if not self.icons_registered then
			Cartographer_Notes:RegisterIcon("Mailbox", {
				text = L["Mailbox"], 
				path = "Interface\\Addons\\Cartographer_Mail\\icons\\mail_icon",
			})
			self.icons_registered = true
		end
		Cartographer_Notes:RegisterNotesDatabase("Mailboxes", Cartographer_MailDB, self)
	else
		Cartographer:ToggleModuleActive(self, false)
	end

	self:RegisterEvent("MAIL_SHOW")
end

function mod:OnDisable()
	self:UnregisterAllEvents()
	
	if Cartographer_Notes then
		Cartographer_Notes:UnregisterNotesDatabase("Mailboxes")
	end
end

function mod:MAIL_SHOW()
	local x,y = GetPlayerMapPosition('player')
	local zone = GetRealZoneText()
	local existingNote = Cartographer_Notes:GetNearbyNote(zone, x, y, 0.05, 'Mailboxes') 
	if not existingNote then
		Cartographer_Notes:SetNote(zone, x, y, 'Mailbox', 'Mailboxes', 'title', 'Mailbox')
	end
end

function mod:IsShowingMinimapIcons()
	return self.db.profile.minimapIcons
end

function mod:ToggleShowingMinimapIcons()
	self.db.profile.minimapIcons = not self.db.profile.minimapIcons
end

function mod:GetIconScale()
	return self.db.profile.iconScale
end

function mod:SetIconScale(value)
	self.db.profile.iconScale = value
	Cartographer_Notes:RefreshMap()
end

function mod:GetIconAlpha()
	return self.db.profile.iconAlpha
end

function mod:SetIconAlpha(value)
	self.db.profile.iconAlpha = value
	Cartographer_Notes:RefreshMap()
end

function mod:IsMiniNoteHidden(zone,id,data)
	return not self.db.profile.minimapIcons
end

function mod:GetNoteTransparency(zone,id,data)
	return self.db.profile.iconAlpha
end

function mod:GetNoteScaling(zone,id,data)
	return self.db.profile.iconScale
end
