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
end

function onButtonPress()
	local sTalisUserNode = DB.getPath(window.getDatabaseNode());
	local sRoundNumber = "round" .. DB.getValue("talis.currentround");
	local test = DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".raise");
	Debug.chat(test);
	
	if DB.getValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".raise") == 0 then
	
		local betCP = DB.getValue("talis.tableRules." .. sRoundNumber .. "bet" .. ".CP");
		local betSP = DB.getValue("talis.tableRules." .. sRoundNumber .. "bet" .. ".SP"); 
		local betGP = DB.getValue("talis.tableRules." .. sRoundNumber .. "bet" .. ".GP");

		updateCurrentBet(betCP, betSP, betGP, sTalisUserNode);
		updatePlayerCommitted(betCP, betSP, betGP, sTalisUserNode);
		updatePot(betCP, betSP, betGP, sTalisUserNode);
	
		DB.setValue(sTalisUserNode .. ".bet." .. sRoundNumber .. ".raise","number",1);
		
	end
	
end