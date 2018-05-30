---
--- Initialization
---

function onInit()
	GameSystem.actions["talisRoll"] = { };
--	Comm.registerSlashHandler("talisRoll", processRoll);
	ActionsManager.registerResultHandler("talisRoll", onRoll);
	
--	DB.setValue("Talis_Window.talisCard1","number",0);
--	DB.setValue("Talis_Window.talisCard2","number",0);
--	DB.setValue("Talis_Window.talisCard3","number",0);
--	DB.setValue("Talis_Window.talisCard4","number",0);
--	DB.setValue("Talis_Window.hand_total","number",0);
--	DB.setValue("Talis_Window.betGPRound1","number",0);
--	DB.setValue("Talis_Window.betSPRound1","number",0);
--	DB.setValue("Talis_Window.betCPRound1","number",0);
--	DB.setValue("Talis_Window.betGPRound2","number",0);
--	DB.setValue("Talis_Window.betSPRound2","number",0);
--	DB.setValue("Talis_Window.betCPRound2","number",0);
--	DB.setValue("Talis_Window.betGPRound3","number",0);
--	DB.setValue("Talis_Window.betSPRound3","number",0);
--	DB.setValue("Talis_Window.betCPRound3","number",0);
--	DB.setValue("Talis_Window.potGP","number",0);
--	DB.setValue("Talis_Window.potSP","number",0);
--	DB.setValue("Talis_Window.potCP","number",0);
	
end

function processRoll(sCommand, sParams)
	performRoll(draginfo, rActor);
end

function getRoll(rActor, sDie, rTalisRoll)
	local rRoll = {};
	rRoll.sType = "talisRoll";
	rRoll.aDice = { sDie };
	rRoll.sDesc = "Talis!";
	rRoll.bSecret = true;
--	Debug.chat("getRoll rTalisRoll: ", rTalisRoll.nodeTalis);
	rRoll.sNodeTalis = rTalisRoll.nodeTalis.getNodeName();
--	Debug.chat("getRoll rRoll.sNodeTalis: ", rRoll.sNodeTalis);
	return rRoll;
end

-- Start the action process
function performRoll(draginfo, rActor, sDie, rTalisRoll)
	local rRoll = getRoll(rActor, sDie, rTalisRoll);
	ActionsManager.performAction(draginfo, rActor, rRoll);	
end

function onRoll(rSource, rTarget, rRoll)

	local sNodeTalis = rRoll.sNodeTalis;
	local sNodeTalisUser = DB.getParent(sNodeTalis).getNodeName();
	local talis_result = rRoll.aDice[1].result;

	-- must be a better place to set owner than here, just making sure that this will work
	local sUser = User.getUsername();
	DB.setOwner(sNodeTalis,sUser);
	DB.setValue(sNodeTalis,"number",talis_result);

	-- have not put the hand_total control back in yet ...

--	local nHandTotal = DB.getValue(sNodeTalisUser .. ".talisCard1") + DB.getValue(sNodeTalisUser .. ".talisCard2") + DB.getValue(sNodeTalisUser .. ".talisCard3");
--	DB.setValue(sNodeTalisUser .. "hand_total","number",nHandTotal);

-- these next two lines create & output the chat message as a GM secret roll - probably not necessary
--	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
--	Comm.deliverChatMessage(rMessage);
end