-- 
-- MpManager - SaveManager
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

SaveManager = {};
g_mpManager.saveManager = SaveManager;

SaveManager.toSave = {};

function SaveManager:addSave(save, target)
	table.insert(SaveManager.toSave, {save=save, target=target});
end;

function SaveManager:save()
	if g_server ~= nil then 		
		local savegameIndex = g_currentMission.missionInfo.savegameIndex;
		local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory;
		if savegameFolderPath == nil then
			savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), savegameIndex);
		end;
		if fileExists(savegameFolderPath .. '/careerSavegame.xml') then
			g_mpManager.saveManager.xml = loadXMLFile("careerSavegame", savegameFolderPath .. '/careerSavegame.xml',"careerSavegame");
			g_mpManager.saveManager.key = "careerSavegame.MpManager.";
			if g_mpManager.isConfig then
				setXMLBool(g_mpManager.saveManager.xml, "careerSavegame.MpManager#isConfig", true);
				for _,saveItem in pairs(g_mpManager.saveManager.toSave) do
					saveItem.save(saveItem.target);
				end;		
			else
				setXMLBool(g_mpManager.saveManager.xml, "careerSavegame.MpManager#isConfig", false);
			end;
			saveXMLFile(g_mpManager.saveManager.xml);
			delete(g_mpManager.saveManager.xml);
		end;
	end;
end;

function SaveManager:setXmlBool(addKey, value)
	setXMLBool(g_mpManager.saveManager.xml, g_mpManager.saveManager.key .. addKey, value);
end;

function SaveManager:setXmlString(addKey, value)
	setXMLString(g_mpManager.saveManager.xml, g_mpManager.saveManager.key .. addKey, value);
end;

function SaveManager:setXmlInt(addKey, value)
	setXMLInt(g_mpManager.saveManager.xml, g_mpManager.saveManager.key .. addKey, value);
end;

g_careerScreen.saveSavegame = Utils.appendedFunction(g_careerScreen.saveSavegame, g_mpManager.saveManager.save);