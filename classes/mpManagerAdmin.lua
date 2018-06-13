-- 
-- MpManager - Admin
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

Admin = {};
local Admin_mt = Class(Admin);

function Admin:new(id)
	local self = {};
	setmetatable(self, Admin_mt);
	
	self.AdminId = id;	
	self.name = "defaultAdmin";
	
	return self;
end;

function Admin:setName(name, noEventSend)
	if name ~= nil and name ~= self.name then
		self.name = name;
	end;
end;

function Admin:getName()
	return self.name;
end;


MpManagerAdmin = {};
g_mpManager.admin = MpManagerAdmin;

function MpManagerAdmin:load()
	MpManagerAdmin.adminIds = 0;
	MpManagerAdmin.adminPw = "defaulPasswort";
	MpManagerAdmin.isLoggedIn = false;
	MpManagerAdmin.admins = {};
	g_mpManager.saveManager:addSave(MpManagerAdmin.saveSavegame, MpManagerAdmin);
	g_mpManager.loadManager:addLoad(MpManagerAdmin.loadSavegame, MpManagerAdmin);
end;

function MpManagerAdmin:setLogIn(state)
	MpManagerAdmin.isLoggedIn = state;
end;

function MpManagerAdmin:getLogIn()
	return MpManagerAdmin.isLoggedIn;
end;

function MpManagerAdmin:verifyPassworword(pw, login)
	if MpManagerAdmin.adminPw == pw then
		if login then
			MpManagerAdmin:setLogIn(true);
		end;
		return true;
	end;
	return false;
end;

function MpManagerAdmin:getNextAdminId()
	MpManagerAdmin.adminIds = MpManagerAdmin.adminIds + 1;
	return MpManagerAdmin.adminIds;
end;

function MpManagerAdmin:newAdmin(name, noEventSend)
	MpManagement_Admin_NewAdmin.sendEvent(name, noEventSend);
	local newAdmin = Admin:new(MpManagerAdmin:getNextAdminId());
	newAdmin:setName(name, noEventSend);
	table.insert(MpManagerAdmin.admins, newAdmin);
end;

function MpManagerAdmin:removeAdmin(index, noEventSend)
	MpManagement_Admin_RemoveAdmin.sendEvent(index, noEventSend)
	local ret = MpManagerAdmin.admins[index]:getName();
	table.remove(MpManagerAdmin.admins, index);
	if g_currentMission.missionInfo.playerName == ret then
		MpManagerAdmin:setLogIn(false);
		MpManagerGui.guis["MpManagerScreen"]:setPage(MpManagerGui.guis["MpManagerScreen"].PAGE_HOME);
	end;
	return ret;
end;

function MpManagerAdmin:removeAdminByName(name)
	for index,admin in pairs(MpManagerAdmin.admins) do
		if admin:getName() == name then
			MpManagerAdmin:removeAdmin(index)
			break;
		end;
	end;
end;

function MpManagerAdmin:getNameIsAdmin(name)
	for _,admin in pairs(MpManagerAdmin.admins) do
		if admin:getName() == name then
			return true;
		end;
	end;
	return false;
end;

function MpManagerAdmin:changeAdminByName(oldName, newName, noEventSend)
	MpManagement_Admin_ChangeAdminByName.sendEvent(oldName, newName, noEventSend)
	for _,admin in pairs(MpManagerAdmin.admins) do
		if admin:getName() == oldName then
			admin:setName(newName);
			break;
		end;
	end;
end;

function MpManagerAdmin:setAdminPasswort(newPasswort, noEventSend)
	if newPasswort ~= nil and newPasswort ~= "" and MpManagerAdmin.adminPw ~= newPasswort then
		MpManagement_Admin_Password.sendEvent(newPasswort, noEventSend)
		MpManagerAdmin.adminPw = newPasswort;
	end;
end;

function MpManagerAdmin:getAdminPasswort()
	return MpManagerAdmin.adminPw;
end;

function MpManagerAdmin:getAdmins()
	return MpManagerAdmin.admins;
end;

function MpManagerAdmin:saveSavegame()
	g_mpManager.saveManager:setXmlString("admins#password",MpManagerAdmin.adminPw);
	local index = 0;
	for _,admin in pairs(MpManagerAdmin.admins) do
		g_mpManager.saveManager:setXmlString(string.format("admins.admin(%d)", index), admin:getName());
		index = index + 1;
	end;
end;

function MpManagerAdmin:loadSavegame()
	g_mpManager.admin.adminPw = Utils.getNoNil(g_mpManager.loadManager:getXmlString("admins#password"), "defaultPasswort");
	local index = 0;
	while true do
		local addKey = string.format("admins.admin(%d)", index);
		if not g_mpManager.loadManager:hasXmlProperty(addKey) then
			break;
		end;
		local adminName = g_mpManager.loadManager:getXmlString(addKey);
		g_mpManager.admin:newAdmin(adminName, true);
		index = index + 1;
	end;
end;

function MpManagerAdmin:writeStream(streamId, connection)
	streamWriteString(streamId, g_mpManager.admin.adminPw);
	streamWriteInt32(streamId, table.getn(g_mpManager.admin.admins));
	for _,admin in pairs(g_mpManager.admin.admins) do
		streamWriteString(streamId, admin:getName());
	end;
end;

function MpManagerAdmin:readStream(streamId, connection)
	g_mpManager.admin.adminPw = streamReadString(streamId);
	local count = streamReadInt32(streamId);
	for i=1, count do
		local newAdmin = Utils.getNoNil(streamReadString(streamId), "defaultAdmin");
		g_mpManager.admin:newAdmin(newAdmin, true);
	end;
end;