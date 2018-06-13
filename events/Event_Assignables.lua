-- 
-- MpManager - Event - Assignables
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - Assignables - Set Assignables
MpManagement_Assignables_SetAssignables = {};
MpManagement_Assignables_SetAssignables_mt = Class(MpManagement_Assignables_SetAssignables, Event);
InitEventClass(MpManagement_Assignables_SetAssignables, "MpManagement_Assignables_SetAssignables");
function MpManagement_Assignables_SetAssignables:emptyNew()
	return Event:new(MpManagement_Assignables_SetAssignables_mt);
end;
function MpManagement_Assignables_SetAssignables:new(index, name)
	local self = MpManagement_Assignables_SetAssignables:emptyNew();
	self.index = index;
	self.name = name;
	return self;
end;
function MpManagement_Assignables_SetAssignables:readStream(streamId, connection)
	self.index = streamReadInt32(streamId);
	self.name = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Assignables_SetAssignables:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.index);
	streamWriteString(streamId, self.name);
end;
function MpManagement_Assignables_SetAssignables:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.assignabels:setAssignables(self.index, self.name, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Assignables_SetAssignables.sendEvent(index, name, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Assignables_SetAssignables:new(index, name))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Assignables_SetAssignables:new(index, name))
		end
	end
end;