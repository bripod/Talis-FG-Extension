


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

	local rMessage = {};
	local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " checks";
	rMessage.text = sChatText;
	Comm.deliverChatMessage(rMessage);	
	--setVisible(false);
	--nextPlayer();
end

function call(sTalisUserNode,sRoundNumber)

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
	Comm.deliverChatMessage(rMessage);	

end

function raise(sTalisUserNode,sRoundNumber)
	local rMessage = {};
	
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
	else
		local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " has already raised this round!"
		rMessage.text = sChatText;
	end
	Comm.deliverChatMessage(rMessage);

end

function fold(sTalisUserNode,sRoundNumber)
	local rMessage = {};
	local sChatText = DB.getValue(sTalisUserNode .. ".name") .. " folds!";
	rMessage.text = sChatText;
	rMessage.mode = "emote";
	Comm.deliverChatMessage(rMessage);
	if getValue() == 0 then
		if window.delete then
			window.delete();
		else
			window.getDatabaseNode().delete();
		end
	end
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
	end	
	
end