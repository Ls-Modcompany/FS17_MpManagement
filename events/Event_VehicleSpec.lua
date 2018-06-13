-- 
-- MpManager - Event - FinishConfig
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

SetFarmEvent = {};
SetFarmEvent_mt = Class(SetFarmEvent, Event);
InitEventClass(SetFarmEvent, "SetFarmEvent");

function SetFarmEvent:emptyNew()
    return Event:new(SetFarmEvent_mt);
end;
function SetFarmEvent:new(farm, vehicle)
    local self = SetFarmEvent:emptyNew()
    self.farm = farm;
    self.vehicle = vehicle;
    return self;
end;
function SetFarmEvent:readStream(streamId, connection)
    self.vehicle = readNetworkNodeObject(streamId);
    self.farm = streamReadString(streamId);
    self:run(connection);
end;
function SetFarmEvent:writeStream(streamId, connection)
    writeNetworkNodeObject(streamId, self.vehicle);
    streamWriteString(streamId, self.farm);
end;
function SetFarmEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(self, false, connection);
    end;
    if self.vehicle ~= nil then
        self.vehicle:setFarm(self.farm, true);
    end;
	g_mpManager.reloadScreen = true;
end;
function SetFarmEvent.sendEvent(farm, vehicle, noEventSend)
    --if vehicle.farm ~= farm then
        if noEventSend == nil or noEventSend == false then
            if g_server ~= nil then
                g_server:broadcastEvent(SetFarmEvent:new(farm, vehicle));
            else
                g_client:getServerConnection():sendEvent(SetFarmEvent:new(farm, vehicle));
            end;
        end;
    --end;
end;

SetAIFarmEvent = {};
SetAIFarmEvent_mt = Class(SetAIFarmEvent, Event);
InitEventClass(SetAIFarmEvent, "SetAIFarmEvent");
function SetAIFarmEvent:emptyNew()
    return Event:new(SetAIFarmEvent_mt);
end;
function SetAIFarmEvent:new(farm, name, vehicle)
    local self = SetAIFarmEvent:emptyNew()
    self.farm = farm;
    self.name = name;
    self.vehicle = vehicle;
    return self;
end;
function SetAIFarmEvent:readStream(streamId, connection)
    self.vehicle = readNetworkNodeObject(streamId);
    self.farm = streamReadString(streamId);
    self.name = streamReadString(streamId);
    self:run(connection);
end;
function SetAIFarmEvent:writeStream(streamId, connection)
    writeNetworkNodeObject(streamId, self.vehicle);
    streamWriteString(streamId, self.farm);
    streamWriteString(streamId, self.name);
end;
function SetAIFarmEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(self, false, connection);
    end;
    if self.vehicle ~= nil then
        self.vehicle:setAIFarm(self.farm, self.name, true);
    end;
end;
function SetAIFarmEvent.sendEvent(farm, name, vehicle, noEventSend)
    if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetAIFarmEvent:new(farm, name, vehicle));
		else
			g_client:getServerConnection():sendEvent(SetAIFarmEvent:new(farm, name, vehicle));
		end;
	end;
end;