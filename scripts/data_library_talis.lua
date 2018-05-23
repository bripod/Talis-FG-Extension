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
    local wWindow = Interface.openWindow("talisWindow","");
    if wWindow then
      local aList = ConnectionManagerADND.getUserLoggedInList();
      -- share this window with every person connected.
      for _,name in pairs(aList) do
        wWindow.share(name);
      end
    end
  end
end

