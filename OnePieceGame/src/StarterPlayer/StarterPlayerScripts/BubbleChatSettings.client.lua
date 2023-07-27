local chat = game:GetService("Chat")

local bubbleSettings = {
	BackgroundColor3 = Color3.fromRGB(156, 156, 156)	,
	TextSize = 20,
	Font = Enum.Font.FredokaOne,
	BubbleDuration = 10,
	TailVisible = true
}

chat:SetBubbleChatSettings(bubbleSettings)