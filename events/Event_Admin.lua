-- 
-- MpManager - Event - Admin
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - Admin - New Admin
MpManagement_Admin_NewAdmin = {};
MpManagement_Admin_NewAdmin_mt = Class(MpManagement_Admin_NewAdmin, Event);
InitEventClass(MpManagement_Admin_NewAdmin, "MpManagement_Admin_NewAdmin");
function MpManagement_Admin_NewAdmin:emptyNew()
	return Event:new(MpManagement_Admin_NewAdmin_mt);
end;
function MpManagement_Admin_NewAdmin:new(name)
	local self = MpManagement_Admin_NewAdmin:emptyNew();
	self.name = name;
	return self;
end;
function MpManagement_Admin_NewAdmin:readStream(streamId, connection)
	self.name = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Admin_NewAdmin:writeStream(streamId, connection)
	streamWriteString(streamId, self.name);
end;
function MpManagement_Admin_NewAdmin:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.admin:newAdmin(self.name, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Admin_NewAdmin.sendEvent(name, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Admin_NewAdmin:new(name))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Admin_NewAdmin:new(name))
		end
	end
end;

-- Synch for MpManager  - Admin - remove Admin
MpManagement_Admin_RemoveAdmin = {};
MpManagement_Admin_RemoveAdmin_mt = Class(MpManagement_Admin_RemoveAdmin, Event);
InitEventClass(MpManagement_Admin_RemoveAdmin, "MpManagement_Admin_RemoveAdmin");
function MpManagement_Admin_RemoveAdmin:emptyNew()
	return Event:new(MpManagement_Admin_RemoveAdmin_mt);
end;
function MpManagement_Admin_RemoveAdmin:new(index)
	local self = MpManagement_Admin_RemoveAdmin:emptyNew();
	self.index = index;
	return self;
end;
function MpManagement_Admin_RemoveAdmin:readStream(streamId, connection)
	self.index = streamReadInt16(streamId);
	self:run(connection);
end;
function MpManagement_Admin_RemoveAdmin:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.index);
end;
function MpManagement_Admin_RemoveAdmin:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.admin:removeAdmin(self.index, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Admin_RemoveAdmin.sendEvent(index, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Admin_RemoveAdmin:new(index))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Admin_RemoveAdmin:new(index))
		end
	end
end;

-- Synch for MpManager  - Admin - Change Admin by name
MpManagement_Admin_ChangeAdminByName = {};
MpManagement_Admin_ChangeAdminByName_mt = Class(MpManagement_Admin_ChangeAdminByName, Event);
InitEventClass(MpManagement_Admin_ChangeAdminByName, "MpManagement_Admin_ChangeAdminByName");
function MpManagement_Admin_ChangeAdminByName:emptyNew()
	return Event:new(MpManagement_Admin_ChangeAdminByName_mt);
end;
function MpManagement_Admin_ChangeAdminByName:new(oldName, newName)
	local self = MpManagement_Admin_ChangeAdminByName:emptyNew();
	self.oldName = oldName;
	self.newName = newName;
	return self;
end;
function MpManagement_Admin_ChangeAdminByName:readStream(streamId, connection)
	self.oldName = streamReadString(streamId);
	self.newName = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Admin_ChangeAdminByName:writeStream(streamId, connection)
	streamWriteString(streamId, self.oldName);
	streamWriteString(streamId, self.newName);
end;
function MpManagement_Admin_ChangeAdminByName:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.admin:changeAdminByName(self.oldName, self.newName, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Admin_ChangeAdminByName.sendEvent(oldName, newName, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Admin_ChangeAdminByName:new(oldName, newName))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Admin_ChangeAdminByName:new(oldName, newName))
		end
	end
end;

-- Synch for MpManager  - Admin - Password
MpManagement_Admin_Password = {};
MpManagement_Admin_Password_mt = Class(MpManagement_Admin_Password, Event);
InitEventClass(MpManagement_Admin_Password, "MpManagement_Admin_Password");
function MpManagement_Admin_Password:emptyNew()
	return Event:new(MpManagement_Admin_Password_mt);
end;
function MpManagement_Admin_Password:new(password)
	local self = MpManagement_Admin_Password:emptyNew();
	self.password = password;
	return self;
end;
function MpManagement_Admin_Password:readStream(streamId, connection)
	self.password = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Admin_Password:writeStream(streamId, connection)
	streamWriteString(streamId, self.password);
end;
function MpManagement_Admin_Password:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.admin:setAdminPasswort(self.password, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Admin_Password.sendEvent(password, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Admin_Password:new(password))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Admin_Password:new(password))
		end
	end
end;