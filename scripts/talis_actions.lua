---
--- Initialization
---
SEATS = "talis.seats"
local sActivePlayer = nil;

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


function getSortedSeatList(showFolded)
	local aEntries = {};
	for _,v in pairs(getSeatNodes()) do
		--Debug.chat(v);
		vNodeName = DB.getPath(v);
		if showFolded == false then
			if DB.getValue(vNodeName .. ".folded") ~= 1 then
				table.insert(aEntries, v);
			end
		else
			table.insert(aEntries, v);
		end
	end
	if #aEntries > 0 then
		table.sort(aEntries, sortfuncSimple);
	end
	return aEntries;
end


function nextPlayer(bCheck)
	local nodeActive = getActiveSeat();
	local nIndexActive = 0;
	-- Determine the next seat node
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
	-- If next actor not available, start at top of list again
	if aEntries[nIndexActive + 1] == nil then 
		for i = 1,#aEntries do
			if aEntries[i] then
				nIndexFirst = i;
				break;
			end
		end
		nodeNext = aEntries[nIndexFirst];
	end
	local sNodeActive = DB.getPath(nodeActive);
	local sNodeNext = DB.getPath(nodeNext);
	local sCurrentRound = "round" .. DB.getValue("talis.currentround");
	local sNodeNextBets = ".bet." .. sCurrentRound;
	local currentBetCP = DB.getValue("talis.pot.currentbetCP");
	local currentBetSP = DB.getValue("talis.pot.currentbetSP");
	local currentBetGP = DB.getValue("talis.pot.currentbetGP");
	local playerBetCP = DB.getValue(sNodeNext .. sNodeNextBets .. ".CP");
	local playerBetSP = DB.getValue(sNodeNext .. sNodeNextBets .. ".SP");
	local playerBetGP = DB.getValue(sNodeNext .. sNodeNextBets .. ".GP");
	if bCheck ~= true and playerBetGP == currentBetGP and playerBetSP == currentBetSP and playerBetCP == currentBetCP and DB.getValue(sNodeNext .. ".folded") ~= 1 then
		nextRound();
	elseif DB.getValue(sNodeNext .. ".folded") ~= 1 then
		DB.setValue(sNodeActive .. ".active","number",0)
		DB.setValue(sNodeNext .. ".active","number",1)
		User.ringBell(DB.findNode(sNodeNext).getOwner());
		local rMessage = {};
		local sChatText = DB.getValue(sNodeNext .. ".name") .. "'s Turn";
		if playerBetGP == currentBetGP and playerBetSP == currentBetSP and playerBetCP == currentBetCP then
			sChatText = sChatText .. ": Check";
		end
		if playerBetGP + playerBetSP + playerBetCP < currentBetGP + currentBetSP + currentBetCP then
			sChatText = sChatText .. ": Call";
		end
		if playerBetGP + playerBetSP + playerBetCP <= currentBetGP + currentBetSP + currentBetCP and DB.getValue(sNodeNext .. sNodeNextBets .. ".raise") ~= 1 then
			sChatText = sChatText .. ", Raise";
		end
		sChatText = sChatText .. " or Fold";
		rMessage.text = sChatText;
		rMessage.mode = "ooc";
		rMessage.font = "emote";
		Comm.deliverChatMessage(rMessage);
	else
		DB.setValue(sNodeActive .. ".active","number",0)
		DB.setValue(sNodeNext .. ".active","number",1)
		nextPlayer(bCheck);
	end
end


function startGame()
	local aEntries = getSortedSeatList();
	local sFirstSeat = DB.getPath(aEntries[1]);
	DB.setValue(sFirstSeat .. ".active","number",1);
	local aSeats = DB.getChildren("talis.seats");
	for _,seatID in pairs(aSeats) do
		sSeatID = DB.getPath(seatID);
		local wWindowClient = Interface.openWindow("talis_client",sSeatID);
		sUserName = DB.getValue(seatID,"player");
		local sRoundNumber = "round" .. DB.getValue("talis.currentround");
		local nAnteCP = DB.getValue("talis.tableRules.ante.CP");
		local nNewPotCP = DB.getValue("talis.pot.CP") + nAnteCP;
		local nAnteSP = DB.getValue("talis.tableRules.ante.SP");
		local nNewPotSP = DB.getValue("talis.pot.SP") + nAnteSP;
		local nAnteGP = DB.getValue("talis.tableRules.ante.GP");
		local nNewPotGP = DB.getValue("talis.pot.GP") + nAnteGP;
		DB.setValue(sSeatID .. ".spentCP","number",nAnteCP);
		DB.setValue("talis.pot.CP","number",nNewPotCP);
		DB.setValue(sSeatID .. ".spentSP","number",nAnteSP);
		DB.setValue("talis.pot.SP","number",nNewPotSP);
		DB.setValue(sSeatID .. ".spentGP","number",nAnteGP);
		DB.setValue("talis.pot.GP","number",nNewPotGP);
		DB.setOwner(sSeatID,sUserName);
		wWindowClient.share(sUserName);
	end
	local rMessage = {};
	local sChatText = "~= A Game of Talis =~";
	rMessage.text = sChatText;
	rMessage.mode = "story";
	rMessage.font = "reference-title";
	Comm.deliverChatMessage(rMessage);
	local sPlayers = "Players: ";
	if #aEntries > 0 then
		for i = 1,#aEntries do
			local sSeatName = DB.getPath(aEntries[i]);	
			sPlayers = sPlayers .. DB.getValue(sSeatName .. ".name");
			if i < #aEntries and i+1 == #aEntries then
				sPlayers = sPlayers .. " & "
			elseif i < #aEntries then
				sPlayers = sPlayers .. ", "
			end
		end
	end
	rMessage.text = sPlayers;
	rMessage.mode = "ooc";
	rMessage.font = "whisperfont"; --narratorfont
	Comm.deliverChatMessage(rMessage);
	startRoundMessage(DB.getValue("talis.currentround"));
end


function endGame()
	local rMessage = {};
	local sChatText = "";
	local sShowdown = "";
	local aEntries = getSortedSeatList(false);
	if #aEntries > 1 then
		sChatText = "Showdown - ";
	else 
		sChatText = "Winner - ";
	end
	if #aEntries > 0 then
		for i = 1,#aEntries do
			local sSeatName = DB.getPath(aEntries[i]);
			sChatText = sChatText .. DB.getValue(sSeatName .. ".name");
			if i < #aEntries then
				sChatText = sChatText .. ", "
			end
		end
	end
	if #aEntries > 0 then
		for i = 1,#aEntries do
			local sSeatName = DB.getPath(aEntries[i]);	
			sShowdown = sShowdown .. DB.getValue(sSeatName .. ".name") .. " has " .. DB.getValue(sSeatName .. ".hand_total");
			if i < #aEntries then
				sShowdown = sShowdown .. "; "
			end
		end
	end
	rMessage.text = sChatText;
	rMessage.sender = "Dealer";
	rMessage.mode = "chat";
	Comm.deliverChatMessage(rMessage);
	if sShowdown ~= "" then
		rMessage.text = sShowdown;
		rMessage.mode = "chat";
		Comm.deliverChatMessage(rMessage);
	end
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
		local sChatText = "All bets have been placed";
		rMessage.text = sChatText;
		--rMessage.sender = "Dealer";
		rMessage.mode = "ooc";
		rMessage.font = "whisperfont";
		Comm.deliverChatMessage(rMessage);
		
		
		local sPlayers = "Remaining Players: ";
		local aEntries = getSortedSeatList(false);
		if #aEntries > 0 then
			for i = 1,#aEntries do
				local sSeatName = DB.getPath(aEntries[i]);	
				sPlayers = sPlayers .. DB.getValue(sSeatName .. ".name");
				if i < #aEntries and i+1 == #aEntries then
					sPlayers = sPlayers .. " & "
				elseif i < #aEntries then
					sPlayers = sPlayers .. ", "
				end
			end
		end
		rMessage.text = sPlayers;
		rMessage.mode = "ooc";
		rMessage.font = "whisperfont"; --narratorfont
		Comm.deliverChatMessage(rMessage);
		
		
		startRoundMessage(nRound);
	end
	-- reset active player to first player in sorted list
	local nodeActive = getActiveSeat();
	local aEntries = getSortedSeatList(false);
	local nIndexFirst = 0;
	for i = 1,#aEntries do
		if aEntries[i] then
			nIndexFirst = i;
			break;
		end
	end
	nodeNext = aEntries[nIndexFirst];
	local sNodeActive = DB.getPath(nodeActive);
	local sNodeNext = DB.getPath(nodeNext);
	DB.setValue(sNodeActive .. ".active","number",0)
	DB.setValue(sNodeNext .. ".active","number",1)	
end


function newRound()
	DB.setValue("talis.currentround","number",1);
	DB.setValue("talis.pot.currentbetCP","number",0);
	DB.setValue("talis.pot.currentbetSP","number",0);
	DB.setValue("talis.pot.currentbetGP","number",0);
	DB.setValue("talis.pot.CP","number",0);
	DB.setValue("talis.pot.SP","number",0);
	DB.setValue("talis.pot.GP","number",0);
	for _,v in pairs(getSeatNodes()) do
		vNodeName = DB.getPath(v);
		for i=1,3 do
			sRound = tostring(i);
			DB.setValue(vNodeName .. ".active","number",0);
			DB.setValue(vNodeName .. ".folded","number",0);
			DB.setValue(vNodeName .. ".hand_total","number",0);
			DB.setValue(vNodeName .. ".card" .. sRound .. "_value","number",0);
			DB.setValue(vNodeName .. ".bet.round" .. sRound .. ".CP","number",0);
			DB.setValue(vNodeName .. ".bet.round" .. sRound .. ".SP","number",0);
			DB.setValue(vNodeName .. ".bet.round" .. sRound .. ".GP","number",0);
			DB.setValue(vNodeName .. ".bet.round" .. sRound .. ".raise","number",0);
			DB.setValue(vNodeName .. ".spentCP","number",0);
			DB.setValue(vNodeName .. ".spentSP","number",0);
			DB.setValue(vNodeName .. ".spentGP","number",0);
		end
	end
	
end


function startRoundMessage(nRound)
	local rMessage = {};
	local sRoundNode = "round" .. tostring(DB.getValue("talis.currentround")) .. "bet";
	local sBet = getBetString(DB.getValue("talis.tableRules." .. sRoundNode .. ".CP"),DB.getValue("talis.tableRules." .. sRoundNode .. ".SP"),DB.getValue("talis.tableRules." .. sRoundNode .. ".GP"));
	local sCard = "";
	if nRound == 1 then
		sCard = "First Card";
	elseif nRound == 2 then
		sCard = "Second Card";
	else
		sCard = "Final Card";
	end
	local sChatText = sCard .. ": Bets are " .. sBet;
	rMessage.text = sChatText;
	--rMessage.sender = "Dealer";
	rMessage.mode = "ooc";
	rMessage.font = "whisperfont";
	Comm.deliverChatMessage(rMessage);
	local aEntries = getSortedSeatList(false);
	local sFirstSeat = DB.getPath(aEntries[1]);
	sChatText = DB.getValue(sFirstSeat .. ".name") .. " starts the betting";
	rMessage.text = sChatText;
	rMessage.sender = "";
	rMessage.mode = "ooc";
	rMessage.font = "emote";
	Comm.deliverChatMessage(rMessage);
	
end


function updatePot(betCP, betSP, betGP, sTalisUserNode)
	local potCP = DB.getValue("talis.pot.CP") + betCP;
	local potSP = DB.getValue("talis.pot.SP") + betSP;
	local potGP = DB.getValue("talis.pot.GP") + betGP;
	DB.setValue("talis.pot.CP","number",potCP);
	DB.setValue("talis.pot.SP","number",potSP);
	DB.setValue("talis.pot.GP","number",potGP);
end


function updatePlayerCommitted(betCP, betSP, betGP, sTalisUserNode)
	local committedCP = DB.getValue(sTalisUserNode .. ".spentCP") + betCP;
	local committedSP = DB.getValue(sTalisUserNode .. ".spentSP") + betSP;
	local committedGP = DB.getValue(sTalisUserNode .. ".spentGP") + betGP;
	DB.setValue(sTalisUserNode  .. ".spentCP","number",committedCP);
	DB.setValue(sTalisUserNode  .. ".spentSP","number",committedSP);
	DB.setValue(sTalisUserNode  .. ".spentGP","number",committedGP);
end


function updateCurrentBet(betCP, betSP, betGP, sTalisUserNode)
	local sRoundNumber = "round" .. DB.getValue("talis.currentround");
	local spentCP = DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".CP") + betCP;
	local spentSP = DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".SP") + betSP;
	local spentGP = DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".GP") + betGP;
	DB.setValue(sTalisUserNode  .. ".bet." .. sRoundNumber .. ".CP","number",spentCP);
	DB.setValue(sTalisUserNode  .. ".bet." .. sRoundNumber .. ".SP","number",spentSP);
	DB.setValue(sTalisUserNode  .. ".bet." .. sRoundNumber .. ".GP","number",spentGP);
	DB.setValue("talis.pot.currentbetCP","number",spentCP);
	DB.setValue("talis.pot.currentbetSP","number",spentSP);
	DB.setValue("talis.pot.currentbetGP","number",spentGP);
end


function getBetString(betCP,betSP,betGP)
	local sBet = "";
	if betGP > 0 then 
		sBet = sBet .. betGP .. "gp";
		if betSP > 0 or betCP > 0 then
			sBet = sBet .. ", ";
		end
	end
	if betSP > 0 then 
		sBet = sBet .. betSP .. "sp";
		if betCP > 0 then
			sBet = sBet .. ", ";
		end
	end
	if betCP > 0 then 
		sBet = sBet .. betCP .. "cp";
	end
	return sBet;
end


function check(sTalisUserNode,sRoundNumber)
	if DB.getValue(sTalisUserNode .. ".active") ~= 1 then
		return
	end
	local rMessage = {};
	local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " checks";
	rMessage.text = sChatText;
	rMessage.sender = "Dealer";
	rMessage.mode = "chat";
	Comm.deliverChatMessage(rMessage);	
	--setVisible(false);
	local bCheck = true;
	nextPlayer(bCheck);
end


function call(sTalisUserNode,sRoundNumber)
	local currentBetCP = DB.getValue("talis.pot.currentbetCP");
	local currentBetSP = DB.getValue("talis.pot.currentbetSP");
	local currentBetGP = DB.getValue("talis.pot.currentbetGP");
	
	if DB.getValue(sTalisUserNode .. ".active") ~= 1 or currentBetCP + currentBetSP + currentBetGP == 0 then
		return
	end
	local sRoundNumber = "round" .. DB.getValue("talis.currentround");
	local spentCP = DB.getValue("talis.pot.currentbetCP") - DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".CP");
	local spentSP = DB.getValue("talis.pot.currentbetSP") - DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".SP");
	local spentGP = DB.getValue("talis.pot.currentbetGP") - DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".GP");
	updateCurrentBet(spentCP, spentSP, spentGP, sTalisUserNode);
	updatePlayerCommitted(spentCP, spentSP, spentGP, sTalisUserNode);
	updatePot(spentCP, spentSP, spentGP, sTalisUserNode);
	local rMessage = {};
	local sCallAmount = getBetString(spentCP,spentSP,spentGP);
	local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " calls for " .. sCallAmount;
	rMessage.text = sChatText;
	rMessage.sender = "Dealer";
	rMessage.mode = "chat";
	Comm.deliverChatMessage(rMessage);	
	nextPlayer();
end


function raise(sTalisUserNode,sRoundNumber)
	if DB.getValue(sTalisUserNode .. ".active") ~= 1 then
		return
	end
	local rMessage = {};
	rMessage.sender = "Dealer";
	rMessage.mode = "chat";
	if DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".raise") ~= 1 then
		DB.setValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".raise","number",0);
	end
	if DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".raise") == 0 then
		local betCP = DB.getValue("talis.tableRules." .. sRoundNumber .. "bet" .. ".CP") + DB.getValue("talis.pot.currentbetCP");
		local betSP = DB.getValue("talis.tableRules." .. sRoundNumber .. "bet" .. ".SP") + DB.getValue("talis.pot.currentbetSP"); 
		local betGP = DB.getValue("talis.tableRules." .. sRoundNumber .. "bet" .. ".GP") + DB.getValue("talis.pot.currentbetGP");
		updateCurrentBet(betCP, betSP, betGP, sTalisUserNode);
		updatePlayerCommitted(betCP, betSP, betGP, sTalisUserNode);
		updatePot(betCP, betSP, betGP, sTalisUserNode);
		DB.setValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".raise","number",1);
		local sRaiseAmount = getBetString(betCP,betSP,betGP);
		local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " raises to " .. sRaiseAmount;
		rMessage.text = sChatText;
		Comm.deliverChatMessage(rMessage);
		nextPlayer();
--	else
--		local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " has already raised this round!"
--		rMessage.text = sChatText;
--		Comm.deliverChatMessage(rMessage);
	end
end


function fold(sTalisUserNode,sRoundNumber)
	if DB.getValue(sTalisUserNode .. ".active") ~= 1 or DB.getValue(sTalisUserNode .. ".folded") == 1 then
		return
	end
	local rMessage = {};
	local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " folds";
	rMessage.text = sChatText;
	rMessage.mode = "chat";
	rMessage.sender = "Dealer";
	Comm.deliverChatMessage(rMessage);
	DB.setValue(sTalisUserNode .. ".folded","number",1);
	local aEntries = getSortedSeatList(false);
	if #aEntries == 1 then
		endGame();
	else
		nextPlayer();
	end
	--[[
	if getValue() == 0 then
		if window.delete then
			window.delete();
		else
			window.getDatabaseNode().delete();
		end
	end
	--]]
end

function onButtonPress()
	local sTalisUserNode = DB.getPath(window.getDatabaseNode());
	local sRoundNumber = "round" .. DB.getValue("talis.currentround");
	if getName() == "checkbutton" then
		check(sTalisUserNode,sRoundNumber);
	elseif getName() == "callbutton" then
		call(sTalisUserNode,sRoundNumber);
	elseif getName() == "raisebutton" then
		raise(sTalisUserNode,sRoundNumber);
	elseif getName() == "foldbutton" then
		fold(sTalisUserNode,sRoundNumber);
	elseif getName() == "startgame" then
		startGame();
	elseif getName() == "nextround" then
		nextRound();
	elseif getName() == "newround" then
		newRound();
	end	
	
end