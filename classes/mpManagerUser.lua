-- 
-- MpManager - User
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

User = {};
local User_mt = Class(User);

function User:new(id)
	local self = {};
	setmetatable(self, User_mt);
	
	self.UserId = id;
	
	self.name = "defaultName";
	self.farm = "defaultFarm";
	
	return self;
end;

function User:setName(name, noEventSend)
	if name ~= nil and name ~= self.name then
		MpManagement_User_SetName.sendEvent(self.UserId, name, noEventSend)
		self.name = name;
	end;
end;

function User:setFarm(farm, noEventSend)
	if farm ~= nil and farm ~= self.farm then
		MpManagement_User_SetFarm.sendEvent(self.UserId, farm, noEventSend);
		self.farm = farm;
	end;
end;

function User:getName()
	return self.name;
end;

function User:getFarm()
	return self.farm;
end;

function User:getUserId()
	return self.UserId;
end;

MpManagerUser = {};
g_mpManager.user = MpManagerUser;

function MpManagerUser:load()
	MpManagerUser.userIds = 0;
	MpManagerUser.users = {};
	g_mpManager.saveManager:addSave(MpManagerUser.saveSavegame, MpManagerUser);
	g_mpManager.loadManager:addLoad(MpManagerUser.loadSavegame, MpManagerUser);
end;

function MpManagerUser:getNextUserId()
	MpManagerUser.userIds = MpManagerUser.userIds + 1;
	return MpManagerUser.userIds;
end;

function MpManagerUser:newUser(name, farm, noEventSend)
	MpManagement_User_NewUser.sendEvent(name, farm, noEventSend)
	local newUser = User:new(MpManagerUser:getNextUserId());
	newUser:setName(name, true);
	newUser:setFarm(farm, true);
	table.insert(MpManagerUser.users, newUser);
end;

function MpManagerUser:removeUser(index, noEventSend)
	MpManagement_User_RemoveUser.sendEvent(index, noEventSend);
	local ret = MpManagerUser.users[index]:getName();
	table.remove(MpManagerUser.users, index);
	return ret;
end;

function MpManagerUser:getUsers()
	return MpManagerUser.users;
end;

function MpManagerUser:getUserByIndex(index)
	return MpManagerUser.users[index];
end;

function MpManagerUser:changeFarmName(oldName, newName)
	for _,user in pairs(MpManagerUser.users) do
		if user:getFarm() == oldName then
			user:setFarm(newName);
		end;
	end;
end;

function MpManagerUser:saveSavegame()
	local index = 0;
	for _,user in pairs(MpManagerUser.users) do
		g_mpManager.saveManager:setXmlString(string.format("users.user(%d)#name", index), user:getName());
		g_mpManager.saveManager:setXmlString(string.format("users.user(%d)#farm", index), user:getFarm());
		index = index + 1;
	end;
end;

function MpManagerUser:loadSavegame()
	local index = 0;
	while true do
		local addKey = string.format("users.user(%d)", index);
		if not g_mpManager.loadManager:hasXmlProperty(addKey) then
			break;
		end;
		local name = g_mpManager.loadManager:getXmlString(addKey .. "#name");
		local farm = g_mpManager.loadManager:getXmlString(addKey .. "#farm");
		g_mpManager.user:newUser(name, farm, true);
		index = index + 1;
	end;
end;

function MpManagerUser:writeStream(streamId, connection)
	streamWriteInt32(streamId, table.getn(g_mpManager.user.users));
	for _,user in pairs(g_mpManager.user.users) do
		streamWriteString(streamId, user:getName());
		streamWriteString(streamId, user:getFarm());
	end;
end;

function MpManagerUser:readStream(streamId, connection)
	local count = streamReadInt32(streamId);
	for i=1, count do
		local name = streamReadString(streamId);
		local farm = streamReadString(streamId);
		g_mpManager.user:newUser(name, farm, true);
	end;
end;