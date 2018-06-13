-- 
-- MpManager - data
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerData = {};
g_mpManager.data = MpManagerData;

function MpManagerData:load()
	local xml = loadXMLFile("data", g_mpManager.dir .. "data.xml","data");
	
	MpManagerData.works = {};
	
	local i = 0;
	while true do
		local key = string.format("data.works.work(%d)", i);
		if not hasXMLProperty(xml, key) then			
			break;
		end;
		local name = getXMLString(xml, key .. "#name");
		local price = getXMLInt(xml, key .. "#price");
		local unit = getXMLString(xml, key .. "#unit");
		table.insert(self.works, {id=i+1, name=name, price=price, unit=unit});
		i = i + 1;
	end;	
end;

function MpManagerData:getWorkUnit(name)
	for _,w in pairs(MpManagerData.works) do
		if w.name == name then
			--return w.unit;
			return MpManagerData:getUnitText(w.unit);
		end;
	end;
	return "";
end;

function MpManagerData:getWorkText(name)
	return g_i18n:getText("work_" .. name);
end;

function MpManagerData:getUnitText(name)
	return g_i18n:getText("unit_" .. name);
end;

function MpManagerData:getUnitShortText(name)
	return g_i18n:getText("unitS_" .. name);
end;

function MpManagerData:getWorks()
	return MpManagerData.works;
end;

function MpManagerData:getDefaultPrices()
	local tbl = {};
	for _,w in pairs(MpManagerData.works) do
		table.insert(tbl, {name=w.name, price=w.price});
	end;
	return tbl;
end;



function MpManagerData:saveSavegame()
	
	
end;

function MpManagerData:loadSavegame()
	
	
end;

function MpManagerData:writeStream(streamId, connection)
	
	
end;

function MpManagerData:readStream(streamId, connection)
	
	
end;