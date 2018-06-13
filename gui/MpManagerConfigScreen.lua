-- 
-- MpManager - ConfigScreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerConfigScreen = {};
local MpManagerConfigScreen_mt = Class(MpManagerConfigScreen, ScreenElement);

local numPages = 6;
for i=1, numPages do
	MpManagerConfigScreen["PAGE_" .. tostring(i)] = i;
end;

function MpManagerConfigScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerConfigScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerConfigScreen:resetConfig()
	self.temp_admins = {};
	self.temp_users = {};
	self.temp_farms = {};
	
	self.additionalsDialogs = 1;
	
	self.adminList:deleteListItems();
	self.userList:deleteListItems();
	self.farmList:deleteListItems();
	self.farmUserList:deleteListItems();
	self.farmleaderList:deleteListItems();	
	self:createDefaultData();
	
	self.currentPage = MpManagerConfigScreen.PAGE_1;
	self:onPageChange();
	self:updateFarmUsersList();
	self:updateFarmLeaderList();
	self.activeFarmUserIndex = 1;
	self.activeFarmleaderIndex = 1;
end;

function MpManagerConfigScreen:onCreate()	
	self.numPages = numPages;
	self:setStepsText();
	
	self.additionalsDialogs = 1;
	
	self.temp_admins = {};
	self.temp_users = {};
	self.temp_farms = {};
	
	self.adminList:removeElement(self.adminListTemplate);
	self.userList:removeElement(self.userListTemplate);
	self.farmList:removeElement(self.farmListTemplate);
	self.farmUserList:removeElement(self.farmUserListTemplate);
	self.farmleaderList:removeElement(self.farmleaderListTemplate);
	
	self:createDefaultData();
	
	self.currentPage = MpManagerConfigScreen.PAGE_1;
	self:onPageChange();
	self:updateFarmUsersList();
	self:updateFarmLeaderList();
	self.activeFarmUserIndex = 1;
	self.activeFarmleaderIndex = 1;
end;

function MpManagerConfigScreen:createDefaultData()
	if g_currentMission.missionInfo.playerName ~= nil then
		local player = g_currentMission.missionInfo.playerName;
		
		table.insert(self.temp_admins, player);
		self.currentNewAdmin = player;
		local newItem = self.adminListTemplate:clone(self.adminList);	
		if table.getn(self.adminList.listItems) %2 == 0 then
			newItem:applyProfile("mpManagerConfigPageListItemOdd");
		end;
		newItem:updateAbsolutePosition();				
		self.currentNewAdmin = "";
		self.adminList:updateItemPositions();
		
		table.insert(self.temp_users, {user=player, farm=""});
		self.currentNewUser = player;
		local newItem = self.userListTemplate:clone(self.userList);	
		if table.getn(self.userList.listItems) %2 == 0 then
			newItem:applyProfile("mpManagerConfigPageListItemOdd");
		end;
		newItem:updateAbsolutePosition();				
		self.currentNewUser = "";
		self.userList:updateItemPositions();
	end;
end;

function MpManagerConfigScreen:onCreateAdminListText(element)	
	if self.currentNewAdmin ~= nil then
		element:setText(self.currentNewAdmin);
	end;
end;
function MpManagerConfigScreen:onCreateUserListText(element)	
	if self.currentNewUser ~= nil then
		element:setText(self.currentNewUser);
	end;
end;
function MpManagerConfigScreen:onCreateFarmListText(element)	
	if self.currentNewFarm ~= nil then
		element:setText(self.currentNewFarm);
	end;
end;
function MpManagerConfigScreen:onCreateFarmUserListTextUser(element)	
	if self.currentNewFarmUser ~= nil then
		element:setText(self.currentNewFarmUser.user);
	end;
end;
function MpManagerConfigScreen:onCreateFarmUserListTextFarm(element)	
	if self.currentNewFarmUser ~= nil then
		element:setText(self.currentNewFarmUser.farm);
	end;
end;
function MpManagerConfigScreen:onCreateFarmleaderListTextFarm(element)	
	if self.currentNewFarmLeader ~= nil then
		element:setText(self.currentNewFarmLeader.farm);
	end;
end;
function MpManagerConfigScreen:onCreateFarmleaderListTextLeader(element)	
	if self.currentNewFarmLeader ~= nil then
		element:setText(self.currentNewFarmLeader.leader);
	end;
end;

function MpManagerConfigScreen:onClose(element)
    MpManagerConfigScreen:superClass().onClose(self);
end
function MpManagerConfigScreen:onOpen()
    MpManagerConfigScreen:superClass().onOpen(self);
end

function MpManagerConfigScreen:onSelectionChangedAdminList(index)
	self.activeAdminIndex = index;
end;
function MpManagerConfigScreen:onSelectionChangedUserList(index)
	self.activeUserIndex = index;
end;
function MpManagerConfigScreen:onSelectionChangedFarmList(index)
	self.activeFarmIndex = index;
end;
function MpManagerConfigScreen:onSelectionChangedFarmUserList(index)
	self.activeFarmUserIndex = index;
end;
function MpManagerConfigScreen:onSelectionChangedFarmleaderList(index)
	self.activeFarmleaderIndex = index;
end;

function MpManagerConfigScreen:update(dt)
    MpManagerConfigScreen:superClass().update(self, dt);
end

function MpManagerConfigScreen:updateFarmUsersList()
	self.farmUserList:deleteListItems();
	for _, user in pairs(self.temp_users) do
		local findFarm = false;
		for _, farm in pairs(self.temp_farms) do
			if farm.farm == user.farm then
				findFarm = true;
				break;
			end;
		end;
		if not findFarm then
			user.farm = "";
		end;
		self.currentNewFarmUser = user;
		local newItem = self.farmUserListTemplate:clone(self.farmUserList);		
		if table.getn(self.farmUserList.listItems) %2 == 0 then
			newItem:applyProfile("mpManagerConfigPageListItemOdd");
		end;
		newItem:updateAbsolutePosition();	
		self.currentNewFarmUser = nil;
		self.farmUserList:updateItemPositions();
	end;
end;
function MpManagerConfigScreen:updateFarmLeaderList()
	self.farmleaderList:deleteListItems();
	for _, farm in pairs(self.temp_farms) do	
		local findLeader = false;
		for _, user in pairs(self.temp_users) do
			if farm.leader == user.user then
				findLeader = true;
				break;
			end;
		end;
		if not findLeader then
			farm.leader = "";
		end;	
		if farm.leader == "" then
			local numUsers = 0;
			local temp_user  = "";
			for _,user in pairs(self.temp_users) do
				if user.farm == farm.farm then
					numUsers = numUsers + 1;
					temp_user = user.user;
				end;
			end;
			if numUsers == 1 then
				farm.leader = temp_user;
			end;
		end;
		self.currentNewFarmLeader = farm;
		local newItem = self.farmleaderListTemplate:clone(self.farmleaderList);		
		if table.getn(self.farmleaderList.listItems) %2 == 0 then
			newItem:applyProfile("mpManagerConfigPageListItemOdd");
		end;
		newItem:updateAbsolutePosition();	
		self.currentNewFarmLeader = nil;
		self.farmleaderList:updateItemPositions();
	end;
end;

function MpManagerConfigScreen:onClickBreak()
	g_gui:showGui("");
	g_mpManager.breakConfig();
	self:resetConfig();
end;
function MpManagerConfigScreen:onClickBack()
	local oldPage = self.currentPage;
	if self.currentPage > 1 then
		self.currentPage = self.currentPage - 1;
		self:onPageChange(oldPage);
	end;
end;
function MpManagerConfigScreen:onClickContinue()
	local oldPage = self.currentPage;
	if self.currentPage < self.numPages then
		self.currentPage = self.currentPage + 1;
		self:onPageChange(oldPage);
	elseif self.currentPage == self.numPages then
		if self:checkEntries() then
			self.mainScreen:setVisible(false);
			local dialog = g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_AdminPw_header"), g_i18n:getText("mpManagerConfig_AdminPw_text"), g_i18n:getText("mpManagerConfig_AdminPw_button"), 1, self.onClickAdminPw, self);
			dialog:setCallbackBack(self.goToLastPage, self);
		end;
	end;
end;

function MpManagerConfigScreen:goToLastPage()
	self.mainScreen:setVisible(true);
end;

function MpManagerConfigScreen:checkEntries()
	local canContinue = true;	
	if table.getn(self.temp_admins) == 0 then
		canContinue = false;
		g_mpManager:showInfoDialog(g_i18n:getText("mpManagerConfig_error1"));		
	end;	
	if canContinue then
		if table.getn(self.temp_users) == 0 then
			canContinue = false;
			g_mpManager:showInfoDialog(g_i18n:getText("mpManagerConfig_error2"));
		else
			for _,user in pairs(self.temp_users) do
				if user.user == nil or user.farm == nil or user.farm == "" then
					canContinue = false;
					g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_error3"), user.user));
				end;
			end;
		end;
	end;	
	if canContinue then
		if table.getn(self.temp_farms) == 0 then
			canContinue = false;
			g_mpManager:showInfoDialog(g_i18n:getText("mpManagerConfig_error4"));
		else
			for _,farm in pairs(self.temp_farms) do
				if farm.farm == nil or farm.leader == nil or farm.leader == "" then
					canContinue = false;
					g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_error5"), farm.farm));
				end;
			end;
		end;
	end;
	return canContinue;
end;

--Create Admin
function MpManagerConfigScreen:onClickAddAdmin()
	g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_AddAdmin_header"), g_i18n:getText("mpManagerConfig_AddAdmin_text"), g_i18n:getText("mpManagerConfig_AddAdmin_button"), 1, self.onClickAddAdminCreate, self);
end;
function MpManagerConfigScreen:onClickAddAdminCreate(newAdmin)
	if newAdmin == "" then
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddAdmin_textInfo3")));
	else
		canCreate = true;
		for _,name in pairs(self.temp_admins) do
			if name == newAdmin then
				canCreate = false;
				break;
			end;
		end;
		
		if canCreate then
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddAdmin_textInfo"), newAdmin));
			table.insert(self.temp_admins, newAdmin);
			self.currentNewAdmin = newAdmin;
			local newItem = self.adminListTemplate:clone(self.adminList);	
			if table.getn(self.adminList.listItems) %2 == 0 then
				newItem:applyProfile("mpManagerConfigPageListItemOdd");
			end;
			newItem:updateAbsolutePosition();				
			self.currentNewAdmin = "";
			self.adminList:updateItemPositions();
		else
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddAdmin_textInfo2"), newAdmin));
		end;
	end;
end;

--Remove Admin
function MpManagerConfigScreen:onClickRemoveAdmin()
	if self.activeAdminIndex ~= nil and self.temp_admins[self.activeAdminIndex] ~= nil then
		g_mpManager:showCheckDialog(string.format(g_i18n:getText("mpManagerConfig_RemoveAdmin_text"), self.temp_admins[self.activeAdminIndex]), self.onClickRemoveAdminRemove, nil, self) 
	end;
end;
function MpManagerConfigScreen:onClickRemoveAdminRemove()
	if self.activeAdminIndex ~= nil and self.temp_admins[self.activeAdminIndex] ~= nil then
		table.remove(self.temp_admins, self.activeAdminIndex);
		self.adminList:removeElement(self.adminList.listItems[self.activeAdminIndex]);
	end;
end;

--Create User
function MpManagerConfigScreen:onClickAddUser()
	g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_AddUser_header"), g_i18n:getText("mpManagerConfig_AddUser_text"), g_i18n:getText("mpManagerConfig_AddUser_button"), 1, self.onClickAddUserCreate, self);
end;
function MpManagerConfigScreen:onClickAddUserCreate(newUser)
	if newUser == "" then
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddUser_textInfo3")));
	else
		canCreate = true;
		for _,name in pairs(self.temp_users) do
			if name == newUser then
				canCreate = false;
				break;
			end;
		end;
		
		if canCreate then
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddUser_textInfo"), newUser));
			table.insert(self.temp_users, {user=newUser, farm=""});
			self.currentNewUser = newUser;
			local newItem = self.userListTemplate:clone(self.userList);	
			if table.getn(self.userList.listItems) %2 == 0 then
				newItem:applyProfile("mpManagerConfigPageListItemOdd");
			end;
			newItem:updateAbsolutePosition();				
			self.currentNewUser = "";
			self.userList:updateItemPositions();
		else
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddUser_textInfo2"), newUser));
		end;
		self:updateFarmUsersList();
		self:updateFarmLeaderList();
	end;
end;

--Remove User
function MpManagerConfigScreen:onClickRemoveUser()
	if self.activeUserIndex ~= nil and self.temp_users[self.activeUserIndex] ~= nil then
		g_mpManager:showCheckDialog(string.format(g_i18n:getText("mpManagerConfig_RemoveUser_text"), self.temp_users[self.activeUserIndex].user), self.onClickRemoveUserRemove, nil, self) 
	end;
end;
function MpManagerConfigScreen:onClickRemoveUserRemove()
	if self.activeUserIndex ~= nil and self.temp_users[self.activeUserIndex] ~= nil then
		table.remove(self.temp_users, self.activeUserIndex);
		self.userList:removeElement(self.userList.listItems[self.activeUserIndex]);
	end;
	self:updateFarmUsersList();
	self:updateFarmLeaderList();
end;

--Create Farm
function MpManagerConfigScreen:onClickAddFarm()
	g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_AddFarm_header"), g_i18n:getText("mpManagerConfig_AddFarm_text"), g_i18n:getText("mpManagerConfig_AddFarm_button"), 1, self.onClickAddFarmCreate, self);
end;
function MpManagerConfigScreen:onClickAddFarmCreate(newFarm)
	if newFarm == "" then
		g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddFarm_textInfo3")));
	else
		canCreate = true;
		for _,name in pairs(self.temp_farms) do
			if name == newFarm then
				canCreate = false;
				break;
			end;
		end;
		
		if canCreate then
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddFarm_textInfo"), newFarm));
			table.insert(self.temp_farms, {farm=newFarm, leader=""});
			self.currentNewFarm = newFarm;
			local newItem = self.farmListTemplate:clone(self.farmList);	
			if table.getn(self.farmList.listItems) %2 == 0 then
				newItem:applyProfile("mpManagerConfigPageListItemOdd");
			end;
			newItem:updateAbsolutePosition();				
			self.currentNewFarm = "";
			self.farmList:updateItemPositions();
		else
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AddFarm_textInfo2"), newFarm));
		end;
		self:updateFarmUsersList();
		self:updateFarmLeaderList();
	end;
end;

--Remove Farm
function MpManagerConfigScreen:onClickRemoveFarm()
	if self.activeFarmIndex ~= nil and self.temp_farms[self.activeFarmIndex] ~= nil then
		g_mpManager:showCheckDialog(string.format(g_i18n:getText("mpManagerConfig_RemoveFarm_text"), self.temp_farms[self.activeFarmIndex].farm), self.onClickRemoveFarmRemove, nil, self) 
	end;
end;
function MpManagerConfigScreen:onClickRemoveFarmRemove()
	if self.activeFarmIndex ~= nil and self.temp_farms[self.activeFarmIndex] ~= nil then
		table.remove(self.temp_farms, self.activeFarmIndex);
		self.farmList:removeElement(self.farmList.listItems[self.activeFarmIndex]);
	end;
	self:updateFarmUsersList();
	self:updateFarmLeaderList();
end;

--Sort users to farms
function MpManagerConfigScreen:onClickFarmUser()
	if self.temp_users[self.activeFarmUserIndex] ~= nil and table.getn(self.temp_users) > 0 and table.getn(self.temp_farms) > 0 then
		local list = {};
		for _, farm in pairs(self.temp_farms) do
			table.insert(list, farm.farm);
		end;
		g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_FarmUser_header"), string.format(g_i18n:getText("mpManagerConfig_FarmUser_text"), self.temp_users[self.activeFarmUserIndex].user), g_i18n:getText("mpManagerConfig_FarmUser_button"), 2, self.onClickFarmUserChange, self, list);
	end;
end;
function MpManagerConfigScreen:onClickFarmUserChange(newFarm)
	g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_FarmUser_textInfo"), newFarm));
	self.temp_users[self.activeFarmUserIndex].farm = newFarm;
	self:updateFarmUsersList();
	self:updateFarmLeaderList();
end;

--Set Farmleaders
function MpManagerConfigScreen:onClickFarmleader()
	if self.temp_farms[self.activeFarmleaderIndex] ~= nil and table.getn(self.temp_users) > 0 and table.getn(self.temp_farms) > 0 then
		local list = {};
		for _, user in pairs(self.temp_users) do
			if user.farm == self.temp_farms[self.activeFarmleaderIndex].farm then
				table.insert(list, user.user);
			end;
		end;
		if table.getn(list) > 0 then
			g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_FarmLeader_header"), string.format(g_i18n:getText("mpManagerConfig_FarmLeader_text"), self.temp_farms[self.activeFarmleaderIndex].farm), g_i18n:getText("mpManagerConfig_FarmLeader_button"), 2, self.onClickFarmleaderChange, self, list);
		else
			g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_FarmLeader_error1"), self.temp_farms[self.activeFarmleaderIndex].farm));
		end;
	end;
end;
function MpManagerConfigScreen:onClickFarmleaderChange(newLeader)
	g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_FarmLeader_textInfo"), newLeader));
	self.temp_farms[self.activeFarmleaderIndex].leader = newLeader;
	self:updateFarmLeaderList();
end;

--Create Admin Password
function MpManagerConfigScreen:onClickAdminPw(password)
	if password ~= nil and password ~= "" then
		self.temp_adminPw = password;
		local dialog = g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_AdminPw_textInfo"), password));
		dialog:setCallback(self.onClickAdminPwOK, self);
	else
		g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_AdminPw_header"), g_i18n:getText("mpManagerConfig_AdminPw_text"), g_i18n:getText("mpManagerConfig_AdminPw_button"), 1, self.onClickAdminPw, self);
		g_mpManager:showInfoDialog(g_i18n:getText("mpManagerConfig_error6"));
	end;
end;
function MpManagerConfigScreen:onClickAdminPwOK(password)
	local dialog = g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_FarmMoney_header"), g_i18n:getText("mpManagerConfig_FarmMone_text"), g_i18n:getText("mpManagerConfig_FarmMone_button"), 1, self.onClickFarmMoney, self);
	dialog:setCallbackBack(self.goToLastPage, self);		
end;

--Set Farmmoney
function MpManagerConfigScreen:onClickFarmMoney(money)
	if money ~= nil and money ~= "" and tonumber(money) ~= nil then
		self.temp_farmMoney = tonumber(money);
		local dialog = g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_FarmMone_textInfo"), g_i18n:formatMoney(self.temp_farmMoney, 0, true)));
		g_mpManager:finishConfig(nil, self.temp_adminPw, self.temp_admins, self.temp_farms, self.temp_users, self.temp_farmMoney);
		dialog:setCallback(self.showFinish, self);
	else
	local dialog = g_mpManager:showInputDialog(g_i18n:getText("mpManagerConfig_FarmMoney_header"), g_i18n:getText("mpManagerConfig_FarmMone_text"), g_i18n:getText("mpManagerConfig_FarmMone_button"), 1, self.onClickFarmMoney, self);
	dialog:setCallbackBack(self.goToLastPage, self);	
	g_mpManager:showInfoDialog(g_i18n:getText("mpManagerConfig_error8"));
	end;
end;

function MpManagerConfigScreen:showFinish()
	g_gui:showGui("");
	g_mpManager:showInfoDialog(g_i18n:getText("mpManagerConfig_finish"));
end;

function MpManagerConfigScreen:onPageChange(oldPage)
	for i=1, self.numPages do 
		if i == self.currentPage then
			self["gui_page_" .. tostring(i)]:setVisible(true);
		else
			self["gui_page_" .. tostring(i)]:setVisible(false);
		end;
	end;
	if oldPage == MpManagerConfigScreen.PAGE_1 then
		self.gui_buttons_firstStep:setVisible(false);
		self.gui_buttons_steps:setVisible(true);
	elseif self.currentPage == MpManagerConfigScreen.PAGE_1 then
		self.gui_buttons_firstStep:setVisible(true);
		self.gui_buttons_steps:setVisible(false);
	end;
	self:setStepsText();
end;

function MpManagerConfigScreen:setStepsText()
	self.gui_steps:setText(string.format("%s %s/%s", g_i18n:getText("mpManagerConfig_step1_headerStep"), self.currentPage, self.numPages));
end;