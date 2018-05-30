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
			DB.deleteChildren("talis");
		else 
			DB.createNode("talis");
		end
		-- create the Host window, not shared with users
		local wWindowHost = Interface.openWindow("talis_host","talis");
		
		local aList = ConnectionManagerADND.getUserLoggedInList();
		-- share this window with every person connected.
		for _,name in pairs(aList) do

			local sUserNode = "talis." .. name;
			local wWindowClient = Interface.openWindow("talis_client",sUserNode);

			DB.setOwner(sUserNode,name);
			
			-- share(): If called as a host, parameters can be used to control the recipient list. 
			-- this also shares with the host, not sure how to fix, since the host does not show up in the aList
			-- probably should be called from a "deal" button on the host window
			-- i.e., host opens /talis, sets up params, hits deal, then players see window
			-- the sharing code should be moved to the host window anyway, so maybe moot, but will likely need to figure out why this works the way it does anyway
			wWindowClient.share(name);
		end
	end
end


