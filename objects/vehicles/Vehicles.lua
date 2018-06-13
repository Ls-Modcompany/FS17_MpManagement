-- 
-- MpManager -  Vehicles
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerVehicles = {};
g_mpManager.vehicles = MpManagerVehicles;

SpecializationUtil.registerSpecialization("MpManager_VehiclesSpec", "MpManager_VehiclesSpec", g_mpManager.dir .. "objects/vehicles/VehiclesSpec.lua");

function MpManagerVehicles:load()	
	for _,vehicleType in pairs(VehicleTypeUtil.vehicleTypes) do
		--for _,spec in pairs(vehicleType.specializations) do
			--if spec == SpecializationUtil.getSpecialization("steerable") then
				table.insert(vehicleType.specializations, SpecializationUtil.getSpecialization("MpManager_VehiclesSpec"));
			--end;
		--end;
	end;	
end;

function MpManagerVehicles:toggleVehicle(old)
	return function(s, delta)
		if not s.isToggleVehicleAllowed then return; end;

		local numVehicles = table.getn(s.steerables);
		if numVehicles > 0 then
			local index, oldIndex = 1, 1;
			if not s.controlPlayer and s.controlledVehicle ~= nil then
				for i=1, numVehicles do
					if s.controlledVehicle == s.steerables[i] then
						oldIndex = i;
						index = i+delta;
						if index > numVehicles then index = 1; end;
						if index < 1 then index = numVehicles; end;
						break;
					end;
				end;
			else
				if delta < 0 then index = numVehicles end
			end;

			local found = false;
			repeat
				if not s.steerables[index].isBroken and not s.steerables[index].isControlled and not s.steerables[index].nonTabbable then
					if s.steerables[index].mpManager_farm == g_mpManager.assignabels.notAssign then
						found = true;
					else
						if s.steerables[index].mpManager_farm ~= nil and s.steerables[index].mpManager_farm ~= "" then
							if g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName) == s.steerables[index].mpManager_farm then
								found = true;
							else
								index = index +delta;
								if index > numVehicles then index = 1;	end;
								if index < 1 then index = numVehicles; end;
							end;							
						else
							index = index +delta;
							if index > numVehicles then index = 1;	end;
							if index < 1 then index = numVehicles; end;
						end;
					end;
				else
					index = index +delta;
					if index > numVehicles then index = 1;	end;
					if index < 1 then index = numVehicles; end;
				end;
			until found or index == oldIndex;
			if found then g_currentMission:requestToEnterVehicle(s.steerables[index]) end;
		end;
	end;
end;

function MpManagerVehicles:requestToEnterVehicle(old) 
	return function(v, vehicle)
		if (vehicle.stationCraneId) ~= nil or (vehicle.mpManager_farm ~= nil and vehicle.mpManager_farm ~= "") and ((g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName) == vehicle.mpManager_farm) or (vehicle.mpManager_farm == g_mpManager.assignabels.notAssign)) then
			old(v, vehicle);
		else
			g_currentMission:showBlinkingWarning(g_i18n:getText("Assignables_noVehicleEnter"), 2000);
		end;
	end;
end;

function MpManagerVehicles:loadInternalRailroadVehicle(old)
	return function(v, savegame, splineLength)
		local s = old(v, savegame, splineLength)
		local spec = SpecializationUtil.getSpecialization("MpManager_VehiclesSpec")
		if v.specializations ~= nil then
			table.insert(v.specializations, spec);		
			spec.load(v, savegame, splineLength);
			spec.postLoad(v, savegame, splineLength);
		end;
		return s;
	end;
end;

BaseMission.toggleVehicle = MpManagerVehicles:toggleVehicle(BaseMission.toggleVehicle);
BaseMission.requestToEnterVehicle = MpManagerVehicles:requestToEnterVehicle(BaseMission.requestToEnterVehicle);
RailroadVehicle.loadInternal = MpManagerVehicles:loadInternalRailroadVehicle(RailroadVehicle.loadInternal);