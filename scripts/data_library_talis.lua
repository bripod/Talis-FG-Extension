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
		
		-- create "talis" node in DB if not present, otherwise, clear child nodes from "talis" node
		if DB.findNode("talis") then
			DB.setPublic("talis",true);
			DB.deleteChildren("talis.seats");
			DB.findNode("talis.pot");
			DB.setValue("talis.pot.CP","number",0);
			DB.setValue("talis.pot.SP","number",0);
			DB.setValue("talis.pot.GP","number",0);
			DB.setValue("talis.pot.currentbetCP","number",0);
			DB.setValue("talis.pot.currentbetSP","number",0);
			DB.setValue("talis.pot.currentbetGP","number",0);
			DB.setValue("talis.currentround","number",1);
			DB.setPublic("talis.currentround",true);
			DB.createNode("talis.tableRules").setPublic(true);
		else 
			DB.createNode("talis").setPublic(true);
			DB.createNode("talis.seats");
			DB.createNode("talis.pot").setPublic(true);
			DB.createNode("talis.pot.CP","number");
			DB.createNode("talis.pot.SP","number");
			DB.createNode("talis.pot.GP","number");
			DB.createNode("talis.tableRules").setPublic(true);
			DB.createNode("talis.pot.currentbetCP","number");
			DB.createNode("talis.pot.currentbetSP","number");
			DB.createNode("talis.pot.currentbetGP","number");
			DB.setValue("talis.currentround","number",1);
			DB.setPublic("talis.currentround",true);
		end
		
		-- create the Host window, not shared with users
		local wWindowHost = Interface.openWindow("talis_host","talis");

		-- share client window with every person connected.
		-- moved all this to talis.xml/button_text
		--[[
		local aList = ConnectionManagerADND.getUserLoggedInList();
		
		for _,name in pairs(aList) do

			local sUserNode = "talis." .. name;
			local wWindowClient = Interface.openWindow("talis_client",sUserNode);
			
			--[/[
			-- test for updating pot values
			local nAnteSP = DB.getValue("talis.tableRules.ante.SP");
			DB.setValue(sUserNode .. ".spentSP","number",nAnteSP);
			local nNewPotSP = DB.getValue("talis.pot.SP") + nAnteSP;
			DB.setValue("talis.pot.SP","number",nNewPotSP);
			--]/]
			DB.setOwner(sUserNode,name);
			
			--[/[ 
			-- share(): If called as a host, parameters can be used to control the recipient list. 
			-- this also shares with the host, not sure how to fix, since the host does not show up in the aList
			-- probably should be called from a "deal" button on the host window
			-- i.e., host opens /talis, sets up params, hits deal, then players see window
			-- the sharing code should be moved to the host window anyway, so maybe moot, but will likely need to figure out why this works the way it does anyway
			--]/]
			wWindowClient.share(name);

			---[/[
			wWindowClient.close(false); -- host does not need all the client windows open, but this doesn't work - client does not see window at all
			--]/]

		end
		--]]
	end
end


