--
--
-- slash command
--
--

function onInit()
	if User.isHost()  then
		Comm.registerSlashHandler("talis", processTalis);
	end
end

function processTalis(sCommand, sParams)
	if User.isHost() then
		local wWindow = Interface.openWindow("talis_main","Talis_Window");
		DB.setValue("Talis_Window.talisCard1","number",0);
		DB.setValue("Talis_Window.talisCard2","number",0);
		DB.setValue("Talis_Window.talisCard3","number",0);
		DB.setValue("Talis_Window.hand_total","number",0);
		if wWindow then
			local aList = ConnectionManagerADND.getUserLoggedInList();
			-- share this window with every person connected.
			for _,name in pairs(aList) do
				wWindow.share(name);
			end
		end
	end
end

