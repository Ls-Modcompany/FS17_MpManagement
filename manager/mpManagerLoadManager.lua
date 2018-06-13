-- 
-- MpManager - LoadManager
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

LoadManager = {};
g_mpManager.loadManager = LoadManager;

LoadManager.toLoad = {};

function LoadManager:addLoad(loadF, target)
	table.insert(self.toLoad, {loadF=loadF, target=target});
end;

function LoadManager:loadSavegame()
	LoadManager.canLoad = false;
	if g_server ~= nil then 	
		local savegameIndex = g_currentMission.missionInfo.savegameIndex;
		local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory;
		if savegameFolderPath == nil then
			savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), savegameIndex);
		end;
		if fileExists(savegameFolderPath .. '/careerSavegame.xml') then
			LoadManager.canLoad = true;			
			g_mpManager.loadManager.xml = loadXMLFile("careerSavegame", savegameFolderPath .. '/careerSavegame.xml',"careerSavegame");
			g_mpManager.loadManager.key = "careerSavegame.MpManager";
			if hasXMLProperty(g_mpManager.loadManager.xml, g_mpManager.loadManager.key) then
				local isConfig = g_mpManager.loadManager:getXmlBool("#isConfig");
				if isConfig == nil then
					isConfig = false;
				end;
				g_mpManager:setConfig(isConfig, true);
				g_mpManager.loadManager.key = "careerSavegame.MpManager.";
				if g_mpManager.isConfig then
					for _,loadItem in pairs(g_mpManager.loadManager.toLoad) do
						loadItem.loadF(loadItem.target);
					end;		
				end;			
			end;
			--delete(g_mpManager.loadManager.xml);
		end;
	end;
end;

function LoadManager:hasXmlProperty(addKey)
	if LoadManager.canLoad then
		return hasXMLProperty(g_mpManager.loadManager.xml, g_mpManager.loadManager.key .. addKey);	
	else
		return false;
	end;
end;

function LoadManager:getXmlBool(addKey)
	if LoadManager.canLoad then
		return hasXMLProperty(g_mpManager.loadManager.xml, g_mpManager.loadManager.key .. addKey);	
	else
		return false;
	end;
	return getXMLBool(g_mpManager.loadManager.xml, g_mpManager.loadManager.key .. addKey);
end;

function LoadManager:getXmlString(addKey)
	if LoadManager.canLoad then
		return getXMLString(g_mpManager.loadManager.xml, g_mpManager.loadManager.key .. addKey);
	else
		return false;
	end;
end;

function LoadManager:getXmlInt(addKey)
	if LoadManager.canLoad then
		return getXMLInt(g_mpManager.loadManager.xml, g_mpManager.loadManager.key .. addKey);
	else
		return false;
	end;
end;