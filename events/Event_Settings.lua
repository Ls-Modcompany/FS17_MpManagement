-- 
-- MpManager - Event - Settings
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - Settings - Set settings
MpManagement_Settings_SetState = {};
MpManagement_Settings_SetState_mt = Class(MpManagement_Settings_SetState, Event);
InitEventClass(MpManagement_Settings_SetState, "MpManagement_Settings_SetState");
function MpManagement_Settings_SetState:emptyNew()
	return Event:new(MpManagement_Settings_SetState_mt);
end;
function MpManagement_Settings_SetState:new(name, index)
	local self = MpManagement_Settings_SetState:emptyNew();
	self.name = name;
	self.index = index;
	return self;
end;
function MpManagement_Settings_SetState:readStream(streamId, connection)
	self.name = streamReadString(streamId);
	self.index = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_Settings_SetState:writeStream(streamId, connection)
	streamWriteString(streamId, self.name);
	streamWriteInt32(streamId, self.index);
end;
function MpManagement_Settings_SetState:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.settings:setState(self.name, self.index, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Settings_SetState.sendEvent(name, index, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Settings_SetState:new(name, index))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Settings_SetState:new(name, index))
		end
	end
end;