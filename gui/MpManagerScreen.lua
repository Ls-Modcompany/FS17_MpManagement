-- 
-- GUI-FarmConfiguratorScreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerScreen = {};

MpManagerScreen.PAGE_EMPTY = 0;
MpManagerScreen.PAGE_KONTO = 1;
MpManagerScreen.PAGE_ORDERS = 2;
MpManagerScreen.PAGE_MONEYOUTPUT = 3;
MpManagerScreen.PAGE_MONEYINPUT = 4;
MpManagerScreen.PAGE_BILLTRANSFEROVERWIEW = 5;
MpManagerScreen.PAGE_BILL = 6;
MpManagerScreen.PAGE_TRANSFER = 7;
MpManagerScreen.PAGE_NEWBILL = 8;
MpManagerScreen.PAGE_NEWTRANSFER = 9;
MpManagerScreen.PAGE_HOME = 10;
MpManagerScreen.PAGE_ADMIN = 11;
MpManagerScreen.PAGE_SETTINGS = 12;
MpManagerScreen.PAGE_WEB = 13;
MpManagerScreen.PAGE_OPENPOSTS = 14;

MpManagerScreen.PAGE_ADMIN_COUNT = 5;
MpManagerScreen.PAGE_ADMIN_ADMIN = 1;
MpManagerScreen.PAGE_ADMIN_PLAYERS = 2;
MpManagerScreen.PAGE_ADMIN_FARMS = 3;
MpManagerScreen.PAGE_ADMIN_ADDITIONALS_1 = 4;
MpManagerScreen.PAGE_ADMIN_ADDITIONALS_2 = 5;

MpManagerScreen.PAGE_SETTINGS_COUNT = 4;--
MpManagerScreen.PAGE_SETTINGS_ASSIGNS = 1;
MpManagerScreen.PAGE_SETTINGS_VEHICLES = 2;
MpManagerScreen.PAGE_SETTINGS_ANIMALS = 3;
MpManagerScreen.PAGE_SETTINGS_PRICES = 4;


local MpManagerScreen_mt = Class(MpManagerScreen, ScreenElement);

function MpManagerScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    self.isOpen = false
	
	self.mainMenue = {};
	self.activePage = MpManagerScreen.PAGE_EMPTY;
	
	self.pages = {};
	self.pages_admin = {};
	self.pages_settings = {};

    return self;
end;

function MpManagerScreen:onCreate()
	self.profileHudsChecked = false;
	self.activeAdminPage = 1;
	self.activeSettingsPage = 1;
	self:setPage(MpManagerScreen.PAGE_HOME);

	self.mpManager_items_openPosts_list:removeElement(self.mpManager_openPosts_listTemplate);
	self.mpManager_items_moneyOutput_list:removeElement(self.mpManager_moneyOutput_listTemplate);
	self.mpManager_items_moneyInput_list:removeElement(self.mpManager_moneyInput_listTemplate);
	self.mpManager_items_home_list:removeElement(self.mpManager_home_listTemplate);
	self.mpManager_admin_admin_list:removeElement(self.mpManager_admin_admin_listItemTemplate);
	self.mpManager_admin_player_list:removeElement(self.mpManager_admin_player_listItemTemplate);
	self.mpManager_admin_farm_list:removeElement(self.mpManager_admin_farm_listItemTemplate);
	self.mpManager_settings1_list:removeElement(self.mpManager_settings1_listItemTemplate);
	self.mpManager_settings2_list:removeElement(self.mpManager_settings2_listItemTemplate);	
	self.gui_bills_list:removeElement(gui_bills_list_template);	
	self.gui_transfer_list:removeElement(gui_transfer_list_template);	
	
	for i = g_mpManager.utils:getTableLenght(g_currentMission.husbandries) + 1, 8 do
		self["mpManager_settings_husbandry" .. i]:setVisible(false);
	end;
	
	self:loadAdminPageState();
	self:loadSettingsPageState();
end;
function MpManagerScreen:onCreate_loaded()
	self:setPageMenu(self.mainMenue[tostring(MpManagerScreen.PAGE_HOME)]);
end;

function MpManagerScreen:onClose(element)
    MpManagerScreen:superClass().onClose(self);
end

function MpManagerScreen:onOpen()
    MpManagerScreen:superClass().onOpen(self);
	
	self.mpManager_items_openPosts_list:deleteListItems();
	self:reloadOpenPostsOutputs();
	self.mpManager_items_moneyOutput_list:deleteListItems();
	self:reloadMoneyOutputs();
	self.mpManager_items_moneyInput_list:deleteListItems();
	self:reloadMoneyInputs();
	self.mpManager_items_home_list:deleteListItems();
	self:reloadHome();
	self:loadAdminPage();
	self:loadSettingsPage();
	self:loadBills();
end

function MpManagerScreen:update(dt)
    MpManagerScreen:superClass().update(self, dt);
	
	if g_mpManager.reloadScreen then
		self.mpManager_items_openPosts_list:deleteListItems();
		self.mpManager_items_moneyOutput_list:deleteListItems();
		self.mpManager_items_moneyInput_list:deleteListItems();
		self.mpManager_items_home_list:deleteListItems();
		self:reloadHome();
		self:loadAdminTable();
		self:loadPlayerTable();
		self:loadFarmTable();
		self:loadSettingsPage();
		self:reloadMoneyOutputs();
		self:reloadOpenPostsOutputs();
		self:reloadMoneyInputs();
		g_mpManager.reloadScreen = false;
	end;
end

function MpManagerScreen:onClickBack()
	g_gui:showGui("");
end;

--Buttons MainMenue
function MpManagerScreen:onCreate_mainMenueToggleButton(element)
	if self.mainMenue[element.name] == nil then
		self.mainMenue[element.name] = element;
	else
		g_debug.write(-1, "MainMenuToggleButton %s already exists.", element.name);
	end;
end;
function MpManagerScreen:onCreate_button_konto(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_orders(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_openPosts(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_moneyinput(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_moneyoutput(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_billTransferOverview(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu2");
end;
function MpManagerScreen:onCreate_button_bill(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu2");
end;
function MpManagerScreen:onCreate_button_transfer(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu2");
end;
function MpManagerScreen:onCreate_button_newBill(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu2");
end;
function MpManagerScreen:onCreate_button_newTransfer(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu2");
end;
function MpManagerScreen:onCreate_button_home(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_admin(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_settings(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onCreate_button_web(element)
	self.target:checkProfileHuds();
	self.target:recreateButtonsOverlays(element, "button_menu1");
end;
function MpManagerScreen:onClick_mainMenueToggleButton(element, checked)
	if element.name == tostring(self.PAGE_KONTO) then
	elseif element.name == tostring(self.PAGE_ORDERS) then
	elseif element.name == tostring(self.PAGE_OPENPOSTS) then
		self.mpManager_items_openPosts_list:deleteListItems();
		self:reloadOpenPostsOutputs();
	elseif element.name == tostring(self.PAGE_MONEYOUTPUT) then
		self.mpManager_items_moneyOutput_list:deleteListItems();
		self:reloadMoneyOutputs();
	elseif element.name == tostring(self.PAGE_MONEYINPUT) then
		self.mpManager_items_moneyInput_list:deleteListItems();
		self:reloadMoneyInputs();
	elseif element.name == tostring(self.PAGE_BILLTRANSFEROVERWIEW) then
	elseif element.name == tostring(self.PAGE_BILL) then
		self:loadBills();
	elseif element.name == tostring(self.PAGE_TRANSFER) then
		self:loadTransfers();
	elseif element.name == tostring(self.PAGE_NEWBILL) then	
		local access = false;
		if g_mpManager.settings:getState("bills_create") == 1 then --Jeder
			access = true;
		elseif g_mpManager.settings:getState("bills_create") == 2 then --FarmLeader
			if g_mpManager.utils:getUsernameIsLeader(g_currentMission.missionInfo.playerName) then
				access = true;
			else
				g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo19"));
			end;
		end;
		if access then
			g_mpManager:showMpManagerBillScreen();
		end;
		element:setIsChecked(false);
		return;
	elseif element.name == tostring(self.PAGE_NEWTRANSFER) then		
		local access = false;
		if g_mpManager.settings:getState("transfers_create") == 1 then --Jeder
			access = true;
		elseif g_mpManager.settings:getState("transfers_create") == 2 then --FarmLeader
			if g_mpManager.utils:getUsernameIsLeader(g_currentMission.missionInfo.playerName) then
				access = true;
			else
				g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo20"));
			end;
		end;
		if access then
			g_mpManager:showMpManagerTransferScreen();
		end;
		element:setIsChecked(false);
		return;
	elseif element.name == tostring(self.PAGE_HOME) then
		self.mpManager_items_home_list:deleteListItems();
		self:reloadHome();
	elseif element.name == tostring(self.PAGE_ADMIN) then
		if g_mpManager.admin:getLogIn() then
			self.mpManager_admin_logInPage:setVisible(true);
		else
			self.mpManager_admin_logInPage:setVisible(false);
			if g_mpManager.admin:getNameIsAdmin(g_currentMission.missionInfo.playerName) then
				local dialog = g_mpManager:showInputDialog(g_i18n:getText("mpManager_AdminLogin_header"), g_i18n:getText("mpManager_AdminLogin_text"), g_i18n:getText("mpManager_AdminLogin_button"), 1, self.onClickAdminLogin, self);
				dialog:setCallbackBack(self.onClickAdminBack, self);
			else
				self:setPageMenu(self.mainMenue[tostring(MpManagerScreen.PAGE_HOME)]);
				g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo5"));
				return;
			end;
		end;
		self:loadAdminPage();
		self:loadAdminTable();
		self:loadPlayerTable();
		self:loadFarmTable();
		self:loadAdd1Table();
	elseif element.name == tostring(self.PAGE_SETTINGS) then
		if g_mpManager.utils:getUsernameIsLeader(g_currentMission.missionInfo.playerName) then
			self:loadSettingsPage();
		else 	
			self:setPageMenu(self.mainMenue[tostring(MpManagerScreen.PAGE_HOME)]);
			g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo21"));
			return;
		end;
	elseif element.name == tostring(self.PAGE_WEB) then
	end;
	self:setPageMenu(element);
end;
--Buttons MainMenue End

--Buttons additionals
function MpManagerScreen:checkProfileHuds()
	if not self.profileHudsChecked then
		local profile = g_gui:getProfile("button_menu1");
		if profile ~= nil then
			profile.values["imageFilename"] = MpManager.dir .. "huds/huds_1.dds";
		end;	
		profile = g_gui:getProfile("button_menu2");
		if profile ~= nil then
			profile.values["imageFilename"] = MpManager.dir .. "huds/huds_2.dds";
		end;
		self.profileHudsChecked = true;
	end;
end;	
function MpManagerScreen:recreateButtonsOverlays(element, profileName)
	GuiOverlay.createOverlay(element.overlay, g_gui:getProfile(profileName).values['imageFilename']);
end;
function MpManagerScreen:setPageMenu(element)	
	for _,button in pairs(self.mainMenue)do
		if button ~= element then
			button:setIsChecked(false);
		else
			button:setIsChecked(true);
		end;
	end;	
	self:setPage(element.name);
end;
--Buttons additionals End

--Pages
function MpManagerScreen:setPage(num)
	if type(num) == "string" then
		num = tonumber(num);
	end;
	self.activePage = num;
	for _, page in pairs(self.pages) do
		if page.name == string.format("mpManagerPage_%s", num) then
			page:setVisible(true);
		else
			page:setVisible(false);
		end;
	end;
end;
function MpManagerScreen:onCreate_page(element)
	if self.pages[element.name] == nil then
		self.pages[element.name] = element;
	else
		g_debug.write(-1, "Page %s already exists.", element.name);
	end;
end;
--Pages End

--Page: OpenPosts
function MpManagerScreen:reloadOpenPostsOutputs()
	local stats = g_mpManager.moneyStats:getSortByFarm();
	if stats == nil then
		return;
	end;
	self.openPostsList = {};
	if g_mpManager.utils:getTableLenght(stats) == 0 then return; end;	
	
	for k,v in pairs(stats) do	
		self.currentStat = v;
		local newItem = self.mpManager_openPosts_listTemplate:clone(self.mpManager_items_openPosts_list);	
		newItem:updateAbsolutePosition();		
		self.mpManager_items_openPosts_list:updateItemPositions();
		table.insert(self.openPostsList, k);
		self.currentStat = nil;	
	end;
end;
function MpManagerScreen:onDoubleClickOpenPosts(row)
	if row == nil then return; end;
	g_mpManager.moneyAssignabels:removeAssignment(self.openPostsList[row], g_currentMission.missionInfo.playerName);
	self.mpManager_items_openPosts_list:deleteListItems();
	self:reloadOpenPostsOutputs();
end;
function MpManagerScreen:onCreateOpenPostsDate(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.date);
	end;
end;
function MpManagerScreen:onCreateOpenPostsName(element)
	if self.currentStat ~= nil then
		element:setText("-");
	end;
end;
function MpManagerScreen:onCreateOpenPostsCategory(element)
	if self.currentStat ~= nil then
		element:setText(FinanceStats.statNamesI18n[self.currentStat.statType]);
	end;
end;
function MpManagerScreen:onCreateOpenPostsAddInfo(element)
	if self.currentStat ~= nil then
		local info = "-";
		if self.currentStat.id == MoneyAssignment.DLG_TRAIN then
			info = g_i18n:getText("mpManager_MoneyAssignment_train");
		elseif self.currentStat.id == MoneyAssignment.DLG_HANDTOOL then
			info = g_i18n:getText("mpManager_MoneyAssignment_handtool");
		elseif self.currentStat.id == MoneyAssignment.DLG_PLACEABLE then
			info = g_i18n:getText("mpManager_MoneyAssignment_placeable");
		elseif self.currentStat.id == MoneyAssignment.DLG_VEHICLE then
			info = g_i18n:getText("mpManager_MoneyAssignment_vehicle");
		elseif self.currentStat.id == MoneyAssignment.DLG_PALLETTRIGGER then
			info = g_i18n:getText("mpManager_MoneyAssignment_palletTrigger");
		elseif self.currentStat.id == MoneyAssignment.DLG_PICKUPOBJECTSSELLTRIGGER then
			info = g_i18n:getText("mpManager_MoneyAssignment_pickupObectsSellTrigger");
		end;	
		element:setText(info);
	end;
end;
function MpManagerScreen:onCreateOpenPostsSellTo(element)
	if self.currentStat ~= nil then
		element:setText("-");
	end;
end;
function MpManagerScreen:onCreateOpenPostsNum(element)
	if self.currentStat ~= nil then
		element:setText("-");
	end;
end;
function MpManagerScreen:onCreateOpenPostsBalance(element)
	if self.currentStat ~= nil then
		element:setText(string.format("%s",g_i18n:formatMoney(self.currentStat.money,0,true)));
	end;
end;
--Page: OpenPosts End

--Page: MoneyOutput
function MpManagerScreen:reloadMoneyOutputs()
	local stats = g_mpManager.moneyStats:getSortByFarm();
	if stats == nil then
		return;
	end;
	local numStats = table.getn(stats);	
	if numStats == 0 then
		return;
	end;	
	for nS = numStats, 1, -1 do	
		self.currentStat = stats[nS];
		if self.currentStat.amount < 0 then
			local newItem = self.mpManager_moneyOutput_listTemplate:clone(self.mpManager_items_moneyOutput_list);	
			newItem:updateAbsolutePosition();		
			self.mpManager_items_moneyOutput_list:updateItemPositions();
		end;
		self.currentStat = nil;	
	end;
end;
function MpManagerScreen:onCreateMoneyOutputDate(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.date);
	end;
end;
function MpManagerScreen:onCreateMoneyOutputName(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.name);
	end;
end;
function MpManagerScreen:onCreateMoneyOutputCategory(element)
	if self.currentStat ~= nil then
		element:setText(FinanceStats.statNamesI18n[self.currentStat.statType]);
	end;
end;
function MpManagerScreen:onCreateMoneyOutputAddInfo(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.addInfo);
	end;
end;
function MpManagerScreen:onCreateMoneyOutputSellTo(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.addFrom);
	end;
end;
function MpManagerScreen:onCreateMoneyOutputNum(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.num);
	end;
end;
function MpManagerScreen:onCreateMoneyOutputBalance(element)
	if self.currentStat ~= nil then
		element:setText(string.format("%s",g_i18n:formatMoney(self.currentStat.amount,0,true)));
	end;
end;
--Page: MoneyOutput End


--Page: MoneyInput
function MpManagerScreen:reloadMoneyInputs()
	local stats = g_mpManager.moneyStats:getSortByFarm();
	if stats == nil then
		return;
	end;
	local numStats = table.getn(stats);	
	if numStats == 0 then
		return;
	end;	
	for nS = numStats, 1, -1 do	
		self.currentStat = stats[nS];
		if self.currentStat.amount > 0 then
			local newItem = self.mpManager_moneyInput_listTemplate:clone(self.mpManager_items_moneyInput_list);	
			newItem:updateAbsolutePosition();		
			self.mpManager_items_moneyInput_list:updateItemPositions();
		end;
		self.currentStat = nil;	
	end;
end;
function MpManagerScreen:onCreateMoneyInputDate(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.date);
	end;
end;
function MpManagerScreen:onCreateMoneyInputName(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.name);
	end;
end;
function MpManagerScreen:onCreateMoneyInputCategory(element)
	if self.currentStat ~= nil then
		element:setText(FinanceStats.statNamesI18n[self.currentStat.statType]);
	end;
end;
function MpManagerScreen:onCreateMoneyInputAddinfo(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.addInfo);
	end;
end;
function MpManagerScreen:onCreateMoneyInputSellto(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.addFrom);
	end;
end;
function MpManagerScreen:onCreateMoneyInputNum(element)
	if self.currentStat ~= nil then
		element:setText(self.currentStat.num);
	end;
end;
function MpManagerScreen:onCreateMoneyInputBalanace(element)
	if self.currentStat ~= nil then
		element:setText(string.format("%s",g_i18n:formatMoney(self.currentStat.amount,0,true)));
	end;
end;
--Page: MoneyInput End

--Page: Home
function MpManagerScreen:reloadHome()
	local farms = g_mpManager.farm:getFarms();
	for _, farm in pairs(farms) do	
		self.currentFarm = farm;
		local newItem = self.mpManager_home_listTemplate:clone(self.mpManager_items_home_list);	
		newItem:updateAbsolutePosition();		
		self.mpManager_items_home_list:updateItemPositions();
		self.currentFarm = nil;	
	end;
end;
function MpManagerScreen:onCreateMoneyHomeFarmname(element)
	if self.currentFarm ~= nil then
		element:setText(self.currentFarm:getName());
	end;
end;
function MpManagerScreen:onCreateMoneyHomeFarmleader(element)
	if self.currentFarm ~= nil then
		element:setText(self.currentFarm:getLeader());
	end;
end;
function MpManagerScreen:onCreateMoneyHomeNumplayer(element)
	if self.currentFarm ~= nil then
		element:setText(g_mpManager.utils:getNumUserFromFarmname(self.currentFarm:getName()));
	end;
end;
function MpManagerScreen:onCreateMoneyHomeVehicles(element)
	if self.currentFarm ~= nil then
		local num = 0;		
		for _, item in pairs(g_currentMission.leasedVehicles) do
			for _, vehicle in pairs(item.items) do
				if vehicle:getFarm() == self.currentFarm:getName() then
					num = num + 1;
				end;
				
			end
		end			
		for storeItem, item in pairs(g_currentMission.ownedItems) do
			if StoreItemsUtil.getIsVehicle(storeItem) then
				for _, realItem in pairs(item.items) do
					if realItem:getFarm() == self.currentFarm:getName() then
						num = num + 1;
					end;
				end;
			end;
		end;	
		element:setText(tostring(num));
	end;
end;
function MpManagerScreen:onCreateMoneyHomeAnimals(element)
	if self.currentFarm ~= nil then
		local num = 0;		
		local husbandry = g_mpManager.husbandry:getHusbandryByFarmName(self.currentFarm:getName());
		if husbandry ~= nil then
			for _,count in pairs(husbandry) do
				num = num + count;
			end;	
		end;
		element:setText(tostring(num));
	end;
end;
function MpManagerScreen:onCreateMoneyHomeBalance(element)
	if self.currentFarm ~= nil then
		local money = self.currentFarm:getMoney();
		if money >= 0 then
			element:applyProfile("mpManager_listItemTextGreen");
		else
			element:applyProfile("mpManager_listItemTextRed");
		end;
		element:setText(string.format("%s",g_i18n:formatMoney(money,0,true)));
	end;
end;
--Page: Home End

--Page: Admin
function MpManagerScreen:onCreateAdminPageState(element)
    if self.adminPageStateElement == nil then
        self.adminPageStateElement = element
    end
end;
function MpManagerScreen:onCreate_admin_menu(element)
	if self.pages_admin[element.name] == nil then
		self.pages_admin[element.name] = element;
	else
		g_debug.write(-1, "Adminpage %s already exists.", element.name);
	end;
end;
function MpManagerScreen:onCreateAdminAdminName(element)
	if self.currentAdmin ~= nil then
		element:setText(self.currentAdmin:getName());
	end;
end;
function MpManagerScreen:onCreateAdminAdminFarm(element)
	if self.currentAdmin ~= nil then
		local farm = g_mpManager.utils:getFarmFromUsername(self.currentAdmin:getName());
		if farm == nil then
			farm = "-";
		end;
		element:setText(farm);
	end;
end;
function MpManagerScreen:onCreateAdminPlayerName(element)
	if self.currentUser ~= nil then
		element:setText(self.currentUser:getName());
	end;
end;
function MpManagerScreen:onCreateAdminPlayerFarm(element)
	if self.currentUser ~= nil then
		element:setText(self.currentUser:getFarm());
	end;
end;
function MpManagerScreen:onCreateAdminPlayerIsAdmin(element)
	if self.currentUser ~= nil then
		if g_mpManager.admin:getNameIsAdmin(self.currentUser:getName()) then
			element:setText(g_i18n:getText("mpManager_AdminHeader5_text1"));
		else
			element:setText(g_i18n:getText("mpManager_AdminHeader5_text2"));
		end;
	end;
end;
function MpManagerScreen:onCreateAdminFarmName(element)
	if self.currentFarm ~= nil then
		element:setText(self.currentFarm:getName());
	end;
end;
function MpManagerScreen:onCreateAdminFarmLeader(element)
	if self.currentFarm ~= nil then
		element:setText(self.currentFarm:getLeader());
	end;
end;
function MpManagerScreen:onCreateAdminFarmCapital(element)
	if self.currentFarm ~= nil then
		local money = self.currentFarm:getMoney();
		if money >= 0 then
			element:applyProfile("mpManager_listItemTextGreen");
		else
			element:applyProfile("mpManager_listItemTextRed");
		end;
		element:setText(string.format("%s",g_i18n:formatMoney(money,0,true)));
	end;
end;

function MpManagerScreen:onClickAdminLogin(password)
	if g_mpManager.admin:verifyPassworword(password, true) then
		self.mpManager_admin_logInPage:setVisible(true);
		self:loadAdminPage();
	else
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminLogin_text2"));
		self:onClickAdminBack();
	end;
end;
function MpManagerScreen:onClickAdminBack()
	self:setPageMenu(self.mainMenue[tostring(MpManagerScreen.PAGE_HOME)]);
end;
function MpManagerScreen:onClickAdminPageSelection()
	self.activeAdminPage = self.mpManager_admin_menu:getState();
	self:setAdminPages();
	self:updateAdminPageState();
end;
function MpManagerScreen:onClickAdminAdminPwOk()
	local newPassword = self.mpManager_admin_pw.text;
	if newPassword == "" then
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo1"));
	else
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo2"));
		g_mpManager.admin:setAdminPasswort(newPassword);
	end;
	self.mpManager_admin_pw:setText(g_mpManager.admin:getAdminPasswort());
end;
function MpManagerScreen:onClickAdminAdminNewAdminOk()
	local newAdminName = self.mpManager_admin_newAdmin.text;
	if newAdminName == "" then
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo3"));
	else
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo4"), newAdminName));
		g_mpManager.admin:newAdmin(newAdminName);
		self:loadAdminTable();
		self:loadPlayerTable();
		self:loadFarmTable();
	end;
	self.mpManager_admin_newAdmin:setText("");
end;
function MpManagerScreen:onClickAdminAdminDeleteAdminOk()
	if self.activeSelectionAdminAdminList == nil then
		return;
	end;
	local admins = g_mpManager.admin:getAdmins();	
	g_mpManager:showCheckDialog(string.format(g_i18n:getText("mpManager_AdminCheck1"), admins[self.activeSelectionAdminAdminList]:getName()), self.onClickAdminAdminDeleteAdminOkOk, nil, self) 
end;
function MpManagerScreen:onClickAdminAdminDeleteAdminOkOk()
	local admins = g_mpManager.admin:getAdmins();
	local deleteName = g_mpManager.admin:removeAdmin(self.activeSelectionAdminAdminList);
	if deleteName == g_currentMission.missionInfo.playerName then
		g_mpManager.admin:setLogIn(false);
		self:setPageMenu(self.mainMenue[tostring(MpManagerScreen.PAGE_HOME)]);
		self.mpManager_admin_logInPage:setVisible(false);
	end;
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
end;
function MpManagerScreen:onClickAdminPlayerNewPlayerOk()
	local newPlayerName = self.mpManager_admin_player_newName.text;
	if self.activeAdminPlayerFarm == nil then
		self.activeAdminPlayerFarm = 1;
	end;
	local farm = g_mpManager.farm:getFarmByIndex(self.activeAdminPlayerFarm):getName();
	if newPlayerName == "" then
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo3"));
	else
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo6"), newPlayerName));
		g_mpManager.user:newUser(newPlayerName, farm);
	end;
	self.mpManager_admin_player_newName:setText("");
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
end;
function MpManagerScreen:onClickAdminPageSelection2()
	self.activeAdminPlayerFarm = self.mpManager_admin_player_farm:getState();
end;
function MpManagerScreen:onClickAdminPlayerChangeName()
	if self.activeSelectionAdminPlayerList ~= nil then
		local currentName = g_mpManager.user:getUsers()[self.activeSelectionAdminPlayerList]:getName();
		g_mpManager:showInputDialog(g_i18n:getText("mpManager_AdminInput1_header"), g_i18n:getText("mpManager_AdminInput1_text"), g_i18n:getText("mpManager_AdminInput1_button"), 1, self.onClickAdminPlayerChangeNameOk, self, currentName);
	end;
end;
function MpManagerScreen:onClickAdminPlayerChangeNameOk(newName)
	if newName == "" then
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo3"));
	else
		local oldName = g_mpManager.user:getUsers()[self.activeSelectionAdminPlayerList]:getName();
		if g_mpManager.farm:getUserIsLeader(oldName) then
			g_mpManager.farm:changeLeaderByName(oldName, newName);
		end;
		if g_mpManager.admin:getNameIsAdmin(oldName) then
			g_mpManager.admin:changeAdminByName(oldName, newName);
		end;
		g_mpManager.user:getUsers()[self.activeSelectionAdminPlayerList]:setName(newName);		
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo8"), newName));
		g_mpManager.bill:onPlayerNameChange(oldName, newName);
		g_mpManager.transfer:onPlayerNameChange(oldName, newName);
		self:loadAdminTable();
		self:loadPlayerTable();
		self:loadFarmTable();
	end;
end;
function MpManagerScreen:onClickAdminPlayerChangeFarm()
	if self.activeSelectionAdminPlayerList ~= nil then
		local name = g_mpManager.user:getUsers()[self.activeSelectionAdminPlayerList]:getName();
		
		if g_mpManager.farm:getUserIsLeader(name) then
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo10"), name));
		else
			local list = {};
			for _, farm in pairs(g_mpManager.farm:getFarms()) do
				table.insert(list, farm:getName());
			end;
			g_mpManager:showInputDialog(g_i18n:getText("mpManager_AdminInput2_header"), string.format(g_i18n:getText("mpManager_AdminInput2_text"), name), g_i18n:getText("mpManager_AdminInput2_button"), 2, self.onClickAdminPlayerChangeFarmOk, self, list);
		end;
	end;
end;
function MpManagerScreen:onClickAdminPlayerChangeFarmOk(newFarm)	
	g_mpManager.user:getUsers()[self.activeSelectionAdminPlayerList]:setFarm(newFarm);
	g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo9"), newFarm));
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
end;
function MpManagerScreen:onClickAdminPlayerDelete()
	local name = g_mpManager.user:getUsers()[self.activeSelectionAdminPlayerList]:getName();
	if g_mpManager.farm:getUserIsLeader(name) then
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo7"), name));
	else
		g_mpManager:showCheckDialog(string.format(g_i18n:getText("mpManager_AdminCheck2"), name), self.onClickAdminPlayerDeleteOk, nil, self);
	end;
end;
function MpManagerScreen:onClickAdminPlayerDeleteOk()
	local users = g_mpManager.user:getUsers();
	local deleteName = g_mpManager.user:removeUser(self.activeSelectionAdminPlayerList);
	if deleteName == g_currentMission.missionInfo.playerName then
		g_mpManager:setCanShowGui(false, true);
	end;
	if g_mpManager.admin:getNameIsAdmin(deleteName) then
		g_mpManager.admin:removeAdminByName(deleteName);
	end;
	g_mpManager.bill:onPlayerDelete(deleteName);
	g_mpManager.transfer:onPlayerDelete(deleteName);
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
end;
function MpManagerScreen:onClickAdminFarmNewFarm()
	local newFarmName = self.mpManager_admin_farm_newFarm.text;
	if self.activeAdminFarmLeader == nil then
		self.activeAdminFarmLeader = 1;
	end;	
	local leader = self.mpManager_admin_farm_leader.texts[self.activeAdminFarmLeader];
	if self.mpManager_admin_farm_leader.texts[self.activeAdminFarmLeader] == "-" then
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo16"));
	else		
		if newFarmName == "" then
			g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo3"));
		else
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo15"), newFarmName));
			g_mpManager.farm:newFarm(newFarmName, leader);
			for _,user in pairs(g_mpManager.user:getUsers()) do
				if user:getName() == leader then
					user:setFarm(newFarmName);
					break;
				end;
			end;
		end;
	end;	
	self.mpManager_admin_farm_newFarm:setText("");
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
end;
function MpManagerScreen:onClickAdminPageSelection3()
	self.activeAdminFarmLeader = self.mpManager_admin_farm_leader:getState();
end;
function MpManagerScreen:onClickAdminFarmChangeName()
	if self.activeSelectionAdminFarmList ~= nil and g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList] ~= nil then
		local currentName = g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList]:getName();
		g_mpManager:showInputDialog(g_i18n:getText("mpManager_AdminInput3_header"), g_i18n:getText("mpManager_AdminInput3_text"), g_i18n:getText("mpManager_AdminInput3_button"), 1, self.onClickAdminFarmChangeNameOk, self, currentName);
	end;
end;
function MpManagerScreen:onClickAdminFarmChangeNameOk(newName)
	if newName == "" then
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo3"));
	else
		if self.activeSelectionAdminFarmList == nil then
			self.activeSelectionAdminFarmList = 1;
		end;
		local oldName = g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList]:getName();
		g_mpManager.user:changeFarmName(oldName, newName);		
		g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList]:setName(newName);		
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo11"), newName));
		g_mpManager.bill:onFarmNameChange(oldName, newName);
		g_mpManager.transfer:onFarmNameChange(oldName, newName);		
		self:loadAdminTable();
		self:loadPlayerTable();
		self:loadFarmTable();
	end;
end;
function MpManagerScreen:onClickAdminFarmChangeLeader()
	if self.activeSelectionAdminFarmList ~= nil and g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList] ~= nil then
		local name = g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList]:getName();	
		
		local list = {};
		for _, user in pairs(g_mpManager.user:getUsers()) do
			if not g_mpManager.farm:getUserIsLeader(user:getName()) then
				table.insert(list, user:getName());
			end;
		end;
		if table.getn(list) == 0 then
			g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo12"));
		else
			g_mpManager:showInputDialog(g_i18n:getText("mpManager_AdminInput4_header"), string.format(g_i18n:getText("mpManager_AdminInput4_text"), name), g_i18n:getText("mpManager_AdminInput4_button"), 2, self.onClickAdminFarmChangeLeaderOk, self, list);
		end;
	end;
end;
function MpManagerScreen:onClickAdminFarmChangeLeaderOk(newLeader)	
	local farm = g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList];
	local oldLeader = farm:getLeader();			
	g_mpManager.farm:changeLeaderByName(oldLeader, newLeader);
	
	local user = g_mpManager.utils:getUserFromUsername(newLeader);
	local farmName = farm:getName();
	if user:getFarm() ~= farmName then
		user:setFarm(farmName);
	end;
	
	g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManager_AdminInfo13"), newLeader));
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
end;
function MpManagerScreen:onClickAdminFarmDelete()
	if table.getn(g_mpManager.farm:getFarms()) <= 1 then
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo14"));
	else
		if self.activeSelectionAdminFarmList ~= nil and g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList] ~= nil then
			local farm = g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList]:getName();
			g_mpManager:showCheckDialog(string.format(g_i18n:getText("mpManager_AdminCheck3"), farm), self.onClickAdminFarmDeleteOk, nil, self);
		end;
	end;
end;
function MpManagerScreen:onClickAdminFarmDeleteOk()	
	if self.activeSelectionAdminFarmList ~= nil and g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList] ~= nil then
		local deleteName = g_mpManager.farm:removeFarm(self.activeSelectionAdminFarmList);
		local replaceFarm = g_mpManager.farm:getFarms()[1]:getName();
		for _,user in pairs(g_mpManager.user:getUsers()) do
			if user:getFarm() == deleteName then
				user:setFarm(replaceFarm);
			end;
		end;	
		g_mpManager.bill:onFarmDelete(deleteName);
		g_mpManager.transfer:onFarmDelete(deleteName);
		self:loadAdminTable();
		self:loadPlayerTable();
		self:loadFarmTable();
	end;
end;
function MpManagerScreen:onClickAdminFarmChangeCaptial()
	if self.activeSelectionAdminFarmList ~= nil and g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList] ~= nil then
		local currentCapital = g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList]:getMoney();
		g_mpManager:showInputDialog(g_i18n:getText("mpManager_AdminInput5_header"), g_i18n:getText("mpManager_AdminInput5_text"), g_i18n:getText("mpManager_AdminInput5_button"), 1, self.onClickAdminFarmChangeCaptialOk, self, tostring(currentCapital));
	end;
end;
function MpManagerScreen:onClickAdminFarmChangeCaptialOk(newMoney)
	local m = tonumber(newMoney);
	if m ~= nil then
		g_mpManager.farm:getFarms()[self.activeSelectionAdminFarmList]:setMoney(m);
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo17"));
	else
		g_mpManager:showInfoDialog(g_i18n:getText("mpManager_AdminInfo18"));
	end;
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
end;

function MpManagerScreen:onSelectionChangedAdminAdminList(index)
	self.activeSelectionAdminAdminList = index;
end;
function MpManagerScreen:onSelectionChangedAdminPlayerList(index)
	self.activeSelectionAdminPlayerList = index;
end;
function MpManagerScreen:onSelectionChangedAdminFarmList(index)
	self.activeSelectionAdminFarmList = index;
end;

function MpManagerScreen:loadAdminPageState()
	for i=table.getn(self.mpManager_admin_pageStateBox.elements), 1, -1 do
        self.mpManager_admin_pageStateBox.elements[i]:delete();
    end
	
	for i=1, MpManagerScreen.PAGE_ADMIN_COUNT do
		self.adminPageStateElement:clone(self.mpManager_admin_pageStateBox);
	end;
    self.mpManager_admin_pageStateBox:invalidateLayout()
	
	local texts = {};
	for i=1, MpManagerScreen.PAGE_ADMIN_COUNT do
		table.insert(texts, g_i18n:getText(string.format("mpManager_AdminMenu_%s", i)));
	end;
    self.mpManager_admin_menu:setTexts(texts);
	self:updateAdminPageState();
	self:setAdminPages();
end;
function MpManagerScreen:loadAdminPage()
	self.mpManager_admin_pw:setText(g_mpManager.admin:getAdminPasswort());
	self:loadAdminTable();
	self:loadPlayerTable();
	self:loadFarmTable();
	self:loadAdd1Table();
end;
function MpManagerScreen:loadAdminTable()
	self.mpManager_admin_admin_list:deleteListItems();
	local admins = g_mpManager.admin:getAdmins();
	for _, admin in pairs(admins) do	
		self.currentAdmin = admin;
		local newItem = self.mpManager_admin_admin_listItemTemplate:clone(self.mpManager_admin_admin_list);	
		newItem:updateAbsolutePosition();		
		self.mpManager_admin_admin_list:updateItemPositions();
		self.currentAdmin = nil;	
	end;
end;
function MpManagerScreen:loadPlayerTable()
	self.mpManager_admin_player_list:deleteListItems();
	local users = g_mpManager.user:getUsers();
	for _, user in pairs(users) do	
		self.currentUser = user;
		local newItem = self.mpManager_admin_player_listItemTemplate:clone(self.mpManager_admin_player_list);	
		newItem:updateAbsolutePosition();		
		self.mpManager_admin_player_list:updateItemPositions();
		self.currentUser = nil;	
	end;
	
	local farms = g_mpManager.farm:getFarms();
	local farmTbl = {};
	for _,farm in pairs(farms) do
		table.insert(farmTbl, farm:getName());
	end;
    self.mpManager_admin_player_farm:setTexts(farmTbl);	
end;
function MpManagerScreen:loadFarmTable()
	self.mpManager_admin_farm_list:deleteListItems();
	local farms = g_mpManager.farm:getFarms();
	for _, farm in pairs(farms) do	
		self.currentFarm = farm;
		local newItem = self.mpManager_admin_farm_listItemTemplate:clone(self.mpManager_admin_farm_list);	
		newItem:updateAbsolutePosition();		
		self.mpManager_admin_farm_list:updateItemPositions();
		self.currentFarm = nil;	
	end;
	local userTbl = {};
	for _,user in pairs(g_mpManager.user:getUsers()) do
		local name = user:getName();
		if not g_mpManager.farm:getUserIsLeader(name) then
			table.insert(userTbl, name);
		end;
	end;
	if table.getn(userTbl) == 0 then
		table.insert(userTbl, "-");
	end;
    self.mpManager_admin_farm_leader:setTexts(userTbl);	
end;
function MpManagerScreen:updateAdminPageState()
	for index, state in pairs(self.mpManager_admin_pageStateBox.elements) do
        state.state = GuiOverlay.STATE_NORMAL;
        if index == self.activeAdminPage then
            state.state = GuiOverlay.STATE_FOCUSED;
        end
    end
end;
function MpManagerScreen:setAdminPages()
	for name, element in pairs(self.pages_admin) do
		if name == tostring(self.activeAdminPage) then
			element:setVisible(true);
		else
			element:setVisible(false);
		end;
	end;
end;



-- Additionals1
function MpManagerScreen:loadAdd1Table()
	local setting = nil;
	
	-- AssignablesBuildings	
	setting = g_mpManager.settings:getSetting("assignabelsBuildings");
	self.mpManager_admin_settings_assignabelsBuildings:setTexts(setting.tbl);	
	self.mpManager_admin_settings_assignabelsBuildings:setState(setting.active, false);
	
	setting = g_mpManager.settings:getSetting("bills_create");
	self.mpManager_admin_settings_bills_create:setTexts(setting.tbl);	
	self.mpManager_admin_settings_bills_create:setState(setting.active, false);
	
	setting = g_mpManager.settings:getSetting("bills_pay");
	self.mpManager_admin_settings_bills_pay:setTexts(setting.tbl);	
	self.mpManager_admin_settings_bills_pay:setState(setting.active, false);
	
	setting = g_mpManager.settings:getSetting("transfers_create");
	self.mpManager_admin_settings_transfers_create:setTexts(setting.tbl);	
	self.mpManager_admin_settings_transfers_create:setState(setting.active, false);
end;

function MpManagerScreen:onClickAdminSettings_assignabelsBuildings(index)
	g_mpManager.settings:setState("assignabelsBuildings", index);
end;

function MpManagerScreen:onClickAdminSettings_bills_create(index)
	g_mpManager.settings:setState("bills_create", index);
end;

function MpManagerScreen:onClickAdminSettings_bills_pay(index)
	g_mpManager.settings:setState("bills_pay", index);
end;

function MpManagerScreen:onClickAdminSettings_transfers_create(index)
	g_mpManager.settings:setState("transfers_create", index);
end;


function MpManagerScreen:onClickAdminSettings5_1()
	g_mpManager:showCheckDialog(g_i18n:getText("mpManager_AdminCheck4"), self.onClickAdminSettings5_1_ok, nil, self) 
end;
function MpManagerScreen:onClickAdminSettings5_1_ok()
	for farmname, statFarms in pairs(g_mpManager.moneyStats.sortByFarm) do
		for pos, stat in pairs(statFarms) do
			if stat.amount < 0 then
				g_mpManager.moneyStats:removeMoneyStatsFromFarm(g_mpManager.utils:getFarmTblFromFarmname(farmname), pos);
			end;
		end;
	end;
end;

function MpManagerScreen:onClickAdminSettings5_2()
	g_mpManager:showCheckDialog(g_i18n:getText("mpManager_AdminCheck5"), self.onClickAdminSettings5_2_ok, nil, self) 
end;
function MpManagerScreen:onClickAdminSettings5_2_ok()
	for farmname, statFarms in pairs(g_mpManager.moneyStats.sortByFarm) do
		for pos, stat in pairs(statFarms) do
			if stat.amount > 0 then
				g_mpManager.moneyStats:removeMoneyStatsFromFarm(g_mpManager.utils:getFarmTblFromFarmname(farmname), pos);
			end;
		end;
	end;
end;

function MpManagerScreen:onClickAdminSettings5_3()
	g_mpManager:showCheckDialog(g_i18n:getText("mpManager_AdminCheck6"), self.onClickAdminSettings5_3_ok, nil, self) 
end;
function MpManagerScreen:onClickAdminSettings5_3_ok()
	for pos,_ in pairs(g_mpManager.bill.bills) do
		g_mpManager.bill:deleteBillById(pos);
	end;
end;

function MpManagerScreen:onClickAdminSettings5_4()
	g_mpManager:showCheckDialog(g_i18n:getText("mpManager_AdminCheck7"), self.onClickAdminSettings5_4_ok, nil, self) 
end;
function MpManagerScreen:onClickAdminSettings5_4_ok()
	for pos,_ in pairs(g_mpManager.transfer.transfers) do
		g_mpManager.transfer:deleteTransferById(pos);
	end;
end;



--Page: Admin end

--Page: Web






--Page: Web end



--Page: Settings
function MpManagerScreen:loadSettingsPage()
	self:loadSettings1Table();
	self:loadSettings2Table();
	self:loadSettings3Table();
	self:loadSettings4Table();	
end;
function MpManagerScreen:onCreate_settings_menu(element)
	if self.pages_settings[element.name] == nil then
		self.pages_settings[element.name] = element;
	else
		g_debug.write(-1, "Settingspage %s already exists.", element.name);
	end;
end;
function MpManagerScreen:onCreateSettingsPageState(element)
    if self.settingsPageStateElement == nil then
        self.settingsPageStateElement = element
    end
end;
function MpManagerScreen:onClickSettingsPageSelection()
	self.activeSettingsPage = self.mpManager_settings_menu:getState();
	self:setSettingsPages();
	self:updateSettingsPageState();
end;
function MpManagerScreen:setSettingsPages()
	for name, element in pairs(self.pages_settings) do
		if name == tostring(self.activeSettingsPage) then
			element:setVisible(true);
		else
			element:setVisible(false);
		end;
	end;
end;
function MpManagerScreen:updateSettingsPageState()
	for index, state in pairs(self.mpManager_settings_pageStateBox.elements) do
        state.state = GuiOverlay.STATE_NORMAL;
        if index == self.activeSettingsPage then
            state.state = GuiOverlay.STATE_FOCUSED;
        end
    end
end;
function MpManagerScreen:loadSettingsPageState()
	for i=table.getn(self.mpManager_settings_pageStateBox.elements), 1, -1 do
        self.mpManager_settings_pageStateBox.elements[i]:delete();
    end
	
	for i=1, MpManagerScreen.PAGE_SETTINGS_COUNT do
		self.settingsPageStateElement:clone(self.mpManager_settings_pageStateBox);
	end;
    self.mpManager_settings_pageStateBox:invalidateLayout()
	
	local texts = {};
	for i=1, MpManagerScreen.PAGE_SETTINGS_COUNT do
		table.insert(texts, g_i18n:getText(string.format("mpManager_SettingsMenu_%s", i)));
	end;
    self.mpManager_settings_menu:setTexts(texts);
	self:updateSettingsPageState();
	self:setSettingsPages();
end;

function MpManagerScreen:onCreateSettings1Name(element)
	if self.currentSettings1 ~= nil then
		local text = self.currentSettings1.name
		if text == Assignables.notAssign then
			text = g_i18n:getText("Assignables_notAssigned");
		end;
		element:setText(text);
	end;
end;
function MpManagerScreen:onCreateSettings1Farm(element)
	if self.currentSettings1 ~= nil then
		local text = self.currentSettings1.object.mpManagerFarm
		if text == Assignables.notAssign or text == nil or text == "" then
			text = g_i18n:getText("Assignables_notAssigned");
		end;
		element:setText(text);
	end;
end;
function MpManagerScreen:onCreateSettings1Change()
	if self.activeSelectionSettings1List == nil or self.activeSelectionSettings1List == 0 then
		self.activeSelectionSettings1List = 1;
	end;
	local assign = g_mpManager.assignabels:getAllAsignables()[self.activeSelectionSettings1List];
	local list = {};
	local activeItem = 1;
	table.insert(list, g_i18n:getText("Assignables_notAssigned"));
	for i,farm in pairs(g_mpManager.farm:getFarms()) do
		local name = farm:getName();
		table.insert(list, name);
		if assign.object.mpManagerFarm == name then
			activeItem = i + 1;
		end;
	end;	
	local dlg = g_mpManager:showInputDialog(g_i18n:getText("mpManager_SettingsInput1_header"), string.format(g_i18n:getText("mpManager_SettingsInput1_text"), assign.name), g_i18n:getText("mpManager_SettingsInput1_button"), 2, self.onCreateSettings1ChangeOk, self, list);
	dlg.textTable:setState(activeItem, false);
end;

function MpManagerScreen:onCreateSettings1ChangeOk(newFarm)
	--Event
	if newFarm == g_i18n:getText("Assignables_notAssigned") then
		newFarm = g_mpManager.assignabels.notAssign;
	end;
	g_mpManager.assignabels:setAssignables(self.activeSelectionSettings1List, newFarm);
	self:loadSettings1Table();
end;

function MpManagerScreen:onSelectionChangedSettings1List(index)
	self.activeSelectionSettings1List = index;
end;
function MpManagerScreen:loadSettings1Table()
	self.mpManager_settings1_list:deleteListItems();
	local assignabels = g_mpManager.assignabels:getAllAsignables();
	for i, assign in pairs(assignabels) do	
		self.currentSettings1 = assign;
		local newItem = self.mpManager_settings1_listItemTemplate:clone(self.mpManager_settings1_list);	
		newItem:updateAbsolutePosition();		
		self.mpManager_settings1_list:updateItemPositions();
		self.currentSettings1 = nil;	
	end;
end;





-- local index = 1;
-- if farmName ~= nil then
	-- for i, farm in pairs(g_mpManager.farm:getFarms()) do
		-- if farm:getName() == farmname then
			-- index = i;
			-- break;
		-- end;
	-- end;
-- end;


function MpManagerScreen:onCreateSettings2Name(element)
	if self.currentSettings2 ~= nil then
		element:setText(StoreItemsUtil.storeItemsByXMLFilename[self.currentSettings2.configFileName:lower()].name);
	end;
end;
function MpManagerScreen:onCreateSettings2Farm(element)
	if self.currentSettings2 ~= nil then
		local text = self.currentSettings2:getFarm();
		if text == g_mpManager.assignabels.notAssign or text == nil then
			text = g_i18n:getText("Assignables_notAssigned");
		end;
		element:setText(text);
	end;
end;

function MpManagerScreen:loadSettings2Table()
	self.mpManager_settings2_list:deleteListItems();	
	self.settings2VehicleList = {};
	for _,vehicle in pairs(g_currentMission.vehicles) do
		if vehicle.stationCraneId == nil and vehicle.trainSystem == nil then
			if (vehicle.configFileName and StoreItemsUtil.storeItemsByXMLFilename[vehicle.configFileName:lower()]) then
				self.currentSettings2 = vehicle;
				local newItem = self.mpManager_settings2_listItemTemplate:clone(self.mpManager_settings2_list);	
				newItem:updateAbsolutePosition();		
				self.mpManager_settings2_list:updateItemPositions();
				self.currentSettings2 = nil;	
				table.insert(self.settings2VehicleList, vehicle);
			end;
		end;
	end;
end;


function MpManagerScreen:onSelectionChangedSettings2List(index)
	self.activeSelectionSettings2List = index;
end;
function MpManagerScreen:onCreateSettings2Change()
	if self.activeSelectionSettings2List == nil or self.activeSelectionSettings2List == 0 then
		self.activeSelectionSettings2List = 1;
	end;
	local vehicle = self.settings2VehicleList[self.activeSelectionSettings2List];
	local nameV = StoreItemsUtil.storeItemsByXMLFilename[vehicle.configFileName:lower()].name
	local list = {};
	local activeItem = 1;
	table.insert(list, g_i18n:getText("Assignables_notAssigned"));
	for i,farm in pairs(g_mpManager.farm:getFarms()) do
		local name = farm:getName();
		table.insert(list, name);
		if vehicle:getFarm() == name then
			activeItem = i + 1;
		end;
	end;	
	local dlg = g_mpManager:showInputDialog(g_i18n:getText("mpManager_SettingsInput2_header"), string.format(g_i18n:getText("mpManager_SettingsInput2_text"), nameV), g_i18n:getText("mpManager_SettingsInput2_button"), 2, self.onCreateSettings2ChangeOk, self, list);
	dlg.textTable:setState(activeItem, false);
end;

function MpManagerScreen:onCreateSettings2ChangeOk(newFarm)
	--Event
	local vehicle = self.settings2VehicleList[self.activeSelectionSettings2List];
	local state = self.activeSelectionSettings2List;
	if newFarm == g_i18n:getText("Assignables_notAssigned") then
		newFarm = g_mpManager.assignabels.notAssign;
	end;
	vehicle:setFarm(newFarm);
	self:loadSettings2Table();
	self.mpManager_settings2_list:setSelectedRow(state);
end;

function MpManagerScreen:loadSettings3Table()	
	local needChange = g_mpManager.husbandry:checkAnimals() or self.loadSettings3Table_firstLoad == nil;
	if needChange then
		for i = 1, g_mpManager.utils:getTableLenght(g_currentMission.husbandries) do
			if self["mpManager_settings_husbandry" .. i] ~= nil then
				self["mpManager_settings_husbandry" .. i]:setVisible(true);
			end;
		end;
		for i = g_mpManager.utils:getTableLenght(g_currentMission.husbandries) + 1, 8 do
			if self["mpManager_settings_husbandry" .. i] ~= nil then
				self["mpManager_settings_husbandry" .. i]:setVisible(false);
			end;
		end;
		self.loadSettings3Table_firstLoad = true;
	end;
	local farm = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName);
	local husbandry = g_mpManager.husbandry:getHusbandryByFarmName(farm:getName());
	local i = 1;
	for name, h in pairs(g_currentMission.husbandries) do
		self["mpManager_settings_husbandry" .. tostring(i)]:setText(tostring(husbandry[name]));
		self["mpManager_settings_husbandry" .. tostring(i) .. "_text"]:setText(AnimalUtil.animals[name].title);
		i = i + 1;
	end;	
	
	local listAnimals = {}
	for _,farm in pairs(g_mpManager.farm:getFarms()) do
		for name,count in pairs(g_mpManager.husbandry:getHusbandryByFarmName(farm:getName())) do
			if listAnimals[name] == nil then
				listAnimals[name] = 0;
			end;
			listAnimals[name] = listAnimals[name] + count;
		end;					
	end;	
	
	local showMessage = false;
	local text = g_i18n:getText("mpManager_SettingsHeader3_text1");
	local baseAnimals = {}
	for name, h in pairs(g_currentMission.husbandries) do
		if listAnimals[name] < h:getNumAnimals(0) then
			local dif = h:getNumAnimals(0) - listAnimals[name];
			text = string.format("%s %s (%s)",text, AnimalUtil.animals[name].title, dif);			
			showMessage = true;
		end;
	end;
	self.mpManager_settings3_infoBox:setVisible(showMessage);
	if showMessage then
		self.mpManager_settings3_infoText:setText(text);
	end;
end;

function MpManagerScreen:onClickMpManager_settings_husbandry(button)
	local farm = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName);	
	local i = 1;
	for name, h in pairs(g_currentMission.husbandries) do
		if tostring(i) == button.name then
			local v = self["mpManager_settings_husbandry" .. tostring(i)].text;
			if tonumber(v) then
				g_mpManager.husbandry:setNumber(farm:getName(), name, tonumber(v));
				g_mpManager:showInfoDialog(g_i18n:getText("mpManager_SettingsInfo1"));		
			else
				g_mpManager:showInfoDialog(g_i18n:getText("mpManager_SettingsInfo2"));		
			end;
			break;
		end;
		i = i + 1;
	end;
	self:loadSettings3Table();
end;



function MpManagerScreen:onCreateSettings4Typ(element)
	if self.currentSettings4 ~= nil then
		element:setText(string.format("%s (%s)", g_mpManager.data:getWorkText(self.currentSettings4.name), g_mpManager.data:getWorkUnit(self.currentSettings4.name)));
	end;
end;
function MpManagerScreen:onCreateSettings4Price(element)
	if self.currentSettings4 ~= nil then
		element:setText(g_i18n:formatMoney(self.currentSettings4.price,0,true));
	end;
end;
function MpManagerScreen:onCreateSettings4Change()
	if self.activeSelectionSettings4List == nil or self.activeSelectionSettings4List == 0 then
		self.activeSelectionSettings4List = 1;
	end;
	local p = self.pricesList4[self.activeSelectionSettings4List];
	local dlg = g_mpManager:showInputDialog(g_i18n:getText("mpManager_SettingsInput4_header"), string.format(g_i18n:getText("mpManager_SettingsInput4_text"), g_mpManager.data:getWorkText(p.name)), g_i18n:getText("mpManager_SettingsInput4_button"), 1, self.onCreateSettings4ChangeOk, self);
end;

function MpManagerScreen:onCreateSettings4ChangeOk(newPrice)
	if tonumber(newPrice) ~= nil then
		g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):setPrices(self.pricesList4[self.activeSelectionSettings4List].name, tonumber(newPrice));
		self:loadSettings4Table();
	end;
end;

function MpManagerScreen:onSelectionChangedSettings4List(index)
	self.activeSelectionSettings4List = index;
end;
function MpManagerScreen:loadSettings4Table()
	self.mpManager_settings4_list:deleteListItems();
	self.pricesList4 = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):getPrices();
	for _, price in pairs(self.pricesList4) do	
		self.currentSettings4 = price;
		local newItem = self.mpManager_settings4_listItemTemplate:clone(self.mpManager_settings4_list);	
		newItem:updateAbsolutePosition();		
		self.mpManager_settings4_list:updateItemPositions();
		self.currentSettings4 = nil;	
	end;
end;


--Page: Settings end


--Page: Bills start
function MpManagerScreen:loadBills()
	self.gui_bills_list:deleteListItems();	
	self.billsList = g_mpManager.bill:getBillsByFarmname(g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName));
	for _, bill in pairs(self.billsList) do			
		self.currentBill = bill;		
		if bill.state == g_mpManager.bill.STATE_PAYED then		
			self.currentBillProfile = "mpManager_listItemTextMiddleCenterTextGreen";
		else
			if bill.address == g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName) then
				self.currentBillProfile = "mpManager_listItemTextMiddleCenterTextRed";
			else
				self.currentBillProfile = "mpManager_listItemTextMiddleCenterTextOrange";
			end;
		end;
		local newItem = self.gui_bills_list_template:clone(self.gui_bills_list);	
		newItem:updateAbsolutePosition();		
		self.gui_bills_list:updateItemPositions();
		self.currentBill = nil;	
	end;
end;

function MpManagerScreen:onDoubleClickBillsList(selectedRow)
	MpManager:showMpManagerBillScreen(self.billsList[selectedRow]) 
end;

function MpManagerScreen:onCreateBillsId(element)
	if self.currentBill ~= nil then
		element:applyProfile(self.currentBillProfile);
		element:setText(g_mpManager.bill:formatId(self.currentBill.num));
	end;
end;

function MpManagerScreen:onCreateBillsAddress(element)
	if self.currentBill ~= nil then
		element:applyProfile(self.currentBillProfile);
		element:setText(string.format("%s (%s)", g_mpManager.utils:getFarmTblFromFarmname(self.currentBill.address):getLeader(), self.currentBill.address));
	end;
end;

function MpManagerScreen:onCreateBillsSender(element)
	if self.currentBill ~= nil then
		element:applyProfile(self.currentBillProfile);
		element:setText(string.format("%s (%s)", self.currentBill.sender, g_mpManager.utils:getFarmFromUsername(self.currentBill.sender)));
	end;
end;

function MpManagerScreen:onCreateBillsNums(element)
	if self.currentBill ~= nil then
		element:applyProfile(self.currentBillProfile);
		element:setText(tostring(table.getn(self.currentBill.entries)));
	end;
end;

function MpManagerScreen:onCreateBillsPrice(element)
	if self.currentBill ~= nil then
		element:applyProfile(self.currentBillProfile);
		local price = 0;
		for _,e in pairs(self.currentBill.entries) do
			price = price + e.price;
		end;
		element:setText(g_i18n:formatMoney(price,0,true));
	end;
end;

function MpManagerScreen:onCreateBillsState(element)
	if self.currentBill ~= nil then
		element:applyProfile(self.currentBillProfile);
		element:setText(g_mpManager.bill:getStateText(self.currentBill.state));
	end;
end;


--Page: Bills end


--Page: Transfers start
function MpManagerScreen:loadTransfers()
	self.gui_transfer_list:deleteListItems();	
	self.transferList = g_mpManager.transfer:getTransfersByFarmname(g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName));
	for _, transfer in pairs(self.transferList) do	
		self.currentTransfer= transfer;
		local newItem = self.gui_transfer_list_template:clone(self.gui_transfer_list);	
		newItem:updateAbsolutePosition();		
		self.gui_transfer_list:updateItemPositions();
		self.currentTransfer = nil;	
	end;
end;

function MpManagerScreen:onDoubleClickTransferList(selectedRow)
	MpManager:showMpManagerTransferScreen(self.transferList[selectedRow]) 
end;

function MpManagerScreen:onCreateTransferId(element)
	if self.currentTransfer ~= nil then
		element:setText(g_mpManager.transfer:formatId(self.currentTransfer.id));
	end;
end;

function MpManagerScreen:onCreateTransferDate(element)
	if self.currentTransfer ~= nil then	
		element:setText(self.currentTransfer.date);
	end;
end;

function MpManagerScreen:onCreateTransferEmpf(element)
	if self.currentTransfer ~= nil then
		element:setText(self.currentTransfer.empf);
	end;
end;

function MpManagerScreen:onCreateTransferSender(element)
	if self.currentTransfer ~= nil then
		element:setText(string.format("%s (%s)", self.currentTransfer.sender, g_mpManager.utils:getFarmFromUsername(self.currentTransfer.sender)));
	end;
end;

function MpManagerScreen:onCreateTransferZweck(element)
	if self.currentTransfer ~= nil then
		element:setText(self.currentTransfer.zweck);
	end;
end;

function MpManagerScreen:onCreateTransferMoney(element)
	if self.currentTransfer ~= nil then
		if g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):getName() == self.currentTransfer.empf then
			element:applyProfile("mpManager_listItemTextMiddleCenterTextRed");
			element:setText(string.format("-%s",g_i18n:formatMoney(self.currentTransfer.money,0,true)));
		else
			element:applyProfile("mpManager_listItemTextMiddleCenterTextGreen");
			element:setText(string.format("%s",g_i18n:formatMoney(self.currentTransfer.money,0,true)));
		end;
	end;
end;
--Page: Transfers end

--Page: Web end
function MpManagerScreen:onClickWeb()
	openWebFile(MpManager.dir .. "mpManagerWeb.php", "");
end;
--Page: Web end