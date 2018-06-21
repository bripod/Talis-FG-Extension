---
--- Initialization
---
SEATS = "talis.seats"
local sActivePlayer = nil;

function onInit()
	
end

function getSeatNodes()
	return DB.getChildren(SEATS);
end

function getSeatCount()
	return DB.getChildCount(SEATS);
end

function getActiveSeat()
	for _,v in pairs(getSeatNodes()) do
		if DB.getValue(v, "active", 0) == 1 then
			return v;
		end
	end
	return nil;
end

function getSeatFromNode(varNode)
	-- Get path name desired
	local sNode = "";
	if type(varNode) == "string" then
		sNode = varNode;
	elseif type(varNode) == "databasenode" then
		sNode = varNode.getNodeName();
	else
		return nil, "";
	end
	
	for _,v in pairs(getSeatNodes()) do
		if v.getNodeName() == sNode then
			return v, v.getNodeName();
		end
	end

	return nil, "";
end

function sortfuncSimple(node1, node2)
	return node1.getNodeName() < node2.getNodeName();
end

function getSortedSeatList()
	local aEntries = {};
	for _,v in pairs(getSeatNodes()) do
		table.insert(aEntries, v);
	end
	if #aEntries > 0 then
		table.sort(aEntries, sortfuncSimple);
	end
	return aEntries;
end

function nextPlayer()
	if not User.isHost() then
		return;
	end

	local nodeActive = getActiveSeat();
	Debug.chat("nodeActive",nodeActive);
	local nIndexActive = 0;
		
	-- Determine the next actor
	local nodeNext = nil;
	local aEntries = getSortedSeatList();
	if #aEntries > 0 then
		if nodeActive then
			for i = 1,#aEntries do
				if aEntries[i] == nodeActive then
					nIndexActive = i;
					break;
				end
			end
		end

		nodeNext = aEntries[nIndexActive + 1];

	end
	Debug.chat("nodeNext",nodeNext);

	-- If next actor available, advance effects, activate and start turn
	if nodeNext then
		Debug.chat(nodeNext);
	end
end

function startGame()
	local aSeats = DB.getChildren("talis.seats");
	for _,seatID in pairs(aSeats) do
		sSeatID = DB.getPath(seatID);
		
		local wWindowClient = Interface.openWindow("talis_client",sSeatID);
		sUserName = DB.getValue(seatID,"player");
		
		local sRoundNumber = "round" .. DB.getValue("talis.currentround");
		
		local nAnteCP = DB.getValue("talis.tableRules.ante.CP");
		DB.setValue(sSeatID .. ".spentCP","number",nAnteCP);
		local nNewPotCP = DB.getValue("talis.pot.SP") + nAnteCP;
		DB.setValue("talis.pot.CP","number",nNewPotCP);
		local nAnteSP = DB.getValue("talis.tableRules.ante.SP");
		DB.setValue(sSeatID .. ".spentSP","number",nAnteSP);
		local nNewPotSP = DB.getValue("talis.pot.SP") + nAnteSP;
		DB.setValue("talis.pot.SP","number",nNewPotSP);
		local nAnteGP = DB.getValue("talis.tableRules.ante.GP");
		DB.setValue(sSeatID .. ".spentGP","number",nAnteGP);
		local nNewPotGP = DB.getValue("talis.pot.GP") + nAnteGP;
		DB.setValue("talis.pot.GP","number",nNewPotGP);
		
		DB.setOwner(sSeatID,sUserName);
		wWindowClient.share(sUserName);
		
	end
	local rMessage = {};
--	local sChatText = "Start Round " .. tostring(DB.getValue("talis.currentround"));
--	rMessage.text = sChatText;
	rMessage.text = "Start Round " .. tostring(DB.getValue("talis.currentround"));
	rMessage.mode = "story";
	Comm.deliverChatMessage(rMessage);

	sRoundNode = "round" .. tostring(DB.getValue("talis.currentround")) .. "bet";
	sBet = TalisBet.getBetString(DB.getValue("talis.tableRules." .. sRoundNode .. ".CP"),DB.getValue("talis.tableRules." .. sRoundNode .. ".SP"),DB.getValue("talis.tableRules." .. sRoundNode .. ".GP"));
	rMessage.text = "Bets are " .. sBet;
	rMessage.mode = "ooc";
	Comm.deliverChatMessage(rMessage);
end

function endGame()
	-- tbd
	local rMessage = {};
	local sChatText = "Game Over";
	rMessage.text = sChatText;
	rMessage.mode = "story";
	Comm.deliverChatMessage(rMessage);
end

function nextRound()
	local nRound = DB.getValue("talis.currentround") + 1;
	if nRound == 4 then
		endGame();
	else
		DB.setValue("talis.currentround","number",nRound);
		DB.setValue("talis.pot.currentbetCP","number",0);
		DB.setValue("talis.pot.currentbetSP","number",0);
		DB.setValue("talis.pot.currentbetGP","number",0);
		local rMessage = {};
		local sChatText = "Start Round " .. tostring(nRound);
		rMessage.text = sChatText;
		rMessage.mode = "story";
		Comm.deliverChatMessage(rMessage);
		sRoundNode = "round" .. tostring(DB.getValue("talis.currentround")) .. "bet";
		sBet = TalisBet.getBetString(DB.getValue("talis.tableRules." .. sRoundNode .. ".CP"),DB.getValue("talis.tableRules." .. sRoundNode .. ".SP"),DB.getValue("talis.tableRules." .. sRoundNode .. ".GP"));
		rMessage.text = "Bets are " .. sBet;
		rMessage.mode = "ooc";
		Comm.deliverChatMessage(rMessage);
	end
end

function onButtonPress()
	if getName() == "startgame" then
		startGame();
	elseif getName() == "nextround" then
		nextRound();
	end	
	
end

