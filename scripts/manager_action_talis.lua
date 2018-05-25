---
--- Initialization
---

function onInit()
	GameSystem.actions["talisRoll"] = { };
	Comm.registerSlashHandler("talisRoll", processRoll);
	ActionsManager.registerResultHandler("talisRoll", onRoll);
	DB.setValue("Talis_Window.talisCard1","number",0);
	DB.setValue("Talis_Window.talisCard2","number",0);
	DB.setValue("Talis_Window.talisCard3","number",0);
	DB.setValue("Talis_Window.hand_total","number",0);
	
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
--	Debug.chat("rTalisRoll: ", rTalisRoll.nodeTalis);
	rRoll.sNodeTalis = rTalisRoll.nodeTalis.getNodeName();
--	Debug.chat("rRoll.sNodeTalis: ", rRoll.sNodeTalis);
	return rRoll;
end

-- Start the action process
function performRoll(draginfo, rActor, sDie, rTalisRoll)
	local rRoll = getRoll(rActor, sDie, rTalisRoll);
	ActionsManager.performAction(draginfo, rActor, rRoll);	
end

function onRoll(rSource, rTarget, rRoll)
	local nodeTalis = rRoll.sNodeTalis;
--	Debug.chat("nodeTalis: ",nodeTalis);
	talis_result = rRoll.aDice[1].result;
	DB.setValue(nodeTalis,"number",talis_result);
	local nHandTotal = DB.getValue("Talis_Window.talisCard1") + DB.getValue("Talis_Window.talisCard2") + DB.getValue("Talis_Window.talisCard3");
	Debug.chat(nHandTotal);
	DB.setValue("Talis_Window.hand_total","number",nHandTotal);
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);
end