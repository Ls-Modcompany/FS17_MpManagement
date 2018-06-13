-- 
-- MpManagement - Specialization for vehicles
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 
-- 

MpManager_VehiclesSpec = {};

function MpManager_VehiclesSpec.prerequisitesPresent(specializations)
    return true;
end

function MpManager_VehiclesSpec:load(savegame)	
    self.setFarm = SpecializationUtil.callSpecializationsFunction("setFarm");
    self.setAIFarm = SpecializationUtil.callSpecializationsFunction("setAIFarm");
    self.getFarm = MpManager_VehiclesSpec.getFarm;
    self.getAIFarm = MpManager_VehiclesSpec.getAIFarm;
	
	self.mpManager_farm = g_mpManager.assignabels.notAssign;
	self.mpManager_aiFarm = "";
	self.mpManager_aiName = "";
end
function MpManager_VehiclesSpec:postLoad(savegame)	
	if savegame ~= nil then
		local farm = getXMLString(savegame.xmlFile, savegame.key..".mpManager#farm");
		if farm ~= nil then
			self.mpManager_farm = farm;
		end;
	end;
end

function MpManager_VehiclesSpec:setFarm(farm, noEventSend)
	g_mpManager.reloadScreen = true;
	self.mpManager_farm = Utils.getNoNil(farm, self.mpManager_farm);
	SetFarmEvent.sendEvent(self.mpManager_farm, self, noEventSend);
end;

function MpManager_VehiclesSpec:setAIFarm(farm, name, noEventSend)
	self.mpManager_aiFarm = Utils.getNoNil(farm, self.mpManager_aiFarm);
	self.mpManager_aiName = Utils.getNoNil(name, self.mpManager_aiName);
	SetAIFarmEvent.sendEvent(self.mpManager_aiFarm, self.mpManager_aiName, self, noEventSend);
end;

function MpManager_VehiclesSpec:getAIFarm()
    return self.mpManager_aiFarm, self.mpManager_aiName;
end

function MpManager_VehiclesSpec:getFarm()
    return self.mpManager_farm;
end

function MpManager_VehiclesSpec:delete()
    
end

function MpManager_VehiclesSpec:getSaveAttributesAndNodes(nodeIdent)
	if self.mpManager_farm ~= nil then
		return "", nodeIdent..'<mpManager farm="'..self.mpManager_farm..'" />';
	end;
end

function MpManager_VehiclesSpec:getXMLStatsAttributes()
    return nil;
end

function MpManager_VehiclesSpec:readStream(streamId, connection)
	self.mpManager_farm = streamReadString(streamId);
	if self.mpManager_farm == "" then
		self.mpManager_farm = nil;
	end;
end

function MpManager_VehiclesSpec:writeStream(streamId, connection)
	streamWriteString(streamId, Utils.getNoNil(self.mpManager_farm, ""));
	if self.mpManager_farm == "" then
		self.mpManager_farm = nil;
	end;
end

function MpManager_VehiclesSpec:readUpdateStream(streamId, timestamp, connection) end
function MpManager_VehiclesSpec:writeUpdateStream(streamId, connection, dirtyMask) end
function MpManager_VehiclesSpec:mouseEvent(posX, posY, isDown, isUp, button) end
function MpManager_VehiclesSpec:keyEvent(unicode, sym, modifier, isDown) end
function MpManager_VehiclesSpec:update(dt) end
function MpManager_VehiclesSpec:updateTick(dt) end
function MpManager_VehiclesSpec:draw() end