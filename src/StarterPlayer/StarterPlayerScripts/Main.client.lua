-- Client bootstrap: UI subscribes before the first periodic authoritative snapshot arrives.
local shared=game:GetService("ReplicatedStorage"):WaitForChild("BuildATree")
local folder=shared:WaitForChild("Network")
require(script.Parent.Controllers.UIController).Start({Intent=folder:WaitForChild("Intent"),State=folder:WaitForChild("State"),Feedback=folder:WaitForChild("Feedback")})
local chat=game:GetService("TextChatService")
chat.OnIncomingMessage=function(message)
 if message.TextSource then
  local player=game:GetService("Players"):GetPlayerByUserId(message.TextSource.UserId)
  if player and player:GetAttribute("GardenVIP") then local properties=Instance.new("TextChatMessageProperties"); properties.PrefixText="<font color='#FFD670'>[VIP]</font> "..message.PrefixText; return properties end
 end
 return nil
end
game:GetService("Players").LocalPlayer.Idled:Connect(function()
 require(script.Parent.Controllers.UIController).Toast("Your garden keeps growing offline. Rejoin later for offline earnings.")
end)
