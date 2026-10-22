--[[
    Agents Football | Purple Galaxy Edition
    Cosmetic UI demo for ScriptBlox sharing.
    This script only creates a menu and local UI toggles.
    Ball Magnet and Auto QB are visual settings only; no gameplay automation.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
    warn("Agents Football: run in a client-side environment.")
    return
end

local parent
local ok, result = pcall(function()
    if typeof(gethui) == "function" then
        return gethui()
    end
end)
if ok and result then
    parent = result
else
    local pg = player:FindFirstChildOfClass("PlayerGui")
        or player:WaitForChild("PlayerGui")
    parent = pg
end

local existing = parent:FindFirstChild("AgentsFootball")
if existing then existing:Destroy() end

local purple = Color3.fromRGB(164, 55, 255)
local brightPurple = Color3.fromRGB(205, 130, 255)
local white = Color3.fromRGB(248, 241, 255)
local muted = Color3.fromRGB(188, 160, 220)
local panelColor = Color3.fromRGB(15, 7, 29)

local settings = { BallMagnet = false, AutoQB = false, CatchRange = 15 }

local function make(className, props, target)
    local obj = Instance.new(className)
    for key, value in pairs(props) do obj[key] = value end
    obj.Parent = target
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius)}, obj)
end

local function stroke(obj, color, thickness)
    return make("UIStroke", {
        Color = color or purple,
        Thickness = thickness or 1,
        Transparency = 0.15
    }, obj)
end

local gui = make("ScreenGui", {
    Name = "AgentsFootball",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, parent)

local main = make("Frame", {
    Name = "GalaxyWindow",
    Size = UDim2.fromOffset(550, 475),
    Position = UDim2.new(0.5, -275, 0.5, -237),
    BackgroundColor3 = panelColor,
    BackgroundTransparency = 0.04,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, gui)
round(main, 18)
stroke(main, purple, 2)

local background = make("Frame", {
    Name = "Starfield",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(22, 7, 48),
    BorderSizePixel = 0,
    ZIndex = 0
}, main)
round(background, 18)

make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 9, 77)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 6, 27)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(49, 10, 85))
    }),
    Rotation = 35
}, background)

math.randomseed(os.clock() * 100000)
for i = 1, 90 do
    local size = math.random(2, 5)
    local star = make("Frame", {
        Name = "Star",
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.new(math.random(2, 98) / 100, 0,
            math.random(2, 98) / 100, 0),
        BackgroundColor3 = (i % 5 == 0) and brightPurple or white,
        BackgroundTransparency = math.random(0, 45) / 100,
        BorderSizePixel = 0,
        ZIndex = 1
    }, background)
    round(star, 10)
    if i % 4 == 0 then
        task.spawn(function()
            while star.Parent do
                local tween = TweenService:Create(star,
                    TweenInfo.new(math.random(8, 18) / 10,
                        Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = math.random(25, 85) / 100})
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.1)
            end
        end)
    end
end

local header = make("TextButton", {
    Name = "DragHeader",
    Size = UDim2.new(1, -20, 0, 75),
    Position = UDim2.fromOffset(10, 5),
    BackgroundTransparency = 1,
    Text = "✦  AGENTS FOOTBALL  ✦",
    TextColor3 = white,
    TextSize = 25,
    Font = Enum.Font.GothamBlack,
    ZIndex = 3
}, main)
make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, brightPurple),
        ColorSequenceKeypoint.new(0.5, white),
        ColorSequenceKeypoint.new(1, purple)
    })
}, header)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.fromOffset(0, 58),
    BackgroundTransparency = 1,
    Text = "✧  PURPLE GALAXY EDITION  ✧",
    TextColor3 = muted,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    ZIndex = 3
}, header)

local close = make("TextButton", {
    Size = UDim2.fromOffset(32, 30),
    Position = UDim2.new(1, -43, 0, 12),
    BackgroundColor3 = Color3.fromRGB(65, 19, 100),
    Text = "×",
    TextColor3 = white,
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    ZIndex = 5
}, main)
round(close, 8)
close.Activated:Connect(function() gui:Destroy() end)

local sidebar = make("Frame", {
    Size = UDim2.new(0, 145, 1, -95),
    Position = UDim2.fromOffset(12, 85),
    BackgroundColor3 = Color3.fromRGB(14, 7, 27),
    BackgroundTransparency = 0.14,
    BorderSizePixel = 0,
    ZIndex = 2
}, main)
round(sidebar, 12)
stroke(sidebar, Color3.fromRGB(107, 38, 175), 1)

local content = make("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -172, 1, -100),
    Position = UDim2.fromOffset(162, 88),
    BackgroundTransparency = 1,
    ZIndex = 2
}, main)

local items = {
    {"✦", "Main"}, {"⚙", "Settings"}, {"◎", "QB Assist"},
    {"◈", "Ball Magnet"}, {"★", "Misc"}
}
local pages, navButtons = {}, {}
local activePage = "Main"

local function createPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = name == activePage,
        ZIndex = 2
    }, content)
    make("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)
    pages[name] = page
    return page
end

for _, item in ipairs(items) do
    local button = make("TextButton", {
        Size = UDim2.new(1, -12, 0, 52),
        Position = UDim2.fromOffset(6, 8),
        BackgroundColor3 = Color3.fromRGB(20, 10, 36),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Text = "  " .. item[1] .. "    " .. item[2],
        TextColor3 = muted,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3
    }, sidebar)
    round(button, 8)
    navButtons[item[2]] = button
    button.Activated:Connect(function()
        activePage = item[2]
        for pageName, page in pairs(pages) do
            page.Visible = pageName == activePage
        end
        for pageName, nav in pairs(navButtons) do
            nav.BackgroundColor3 = pageName == activePage
                and Color3.fromRGB(83, 23, 139)
                or Color3.fromRGB(20, 10, 36)
            nav.TextColor3 = pageName == activePage and white or muted
        end
    end)
end

-- Position sidebar buttons in a vertical list.
for index, item in ipairs(items) do
    navButtons[item[2]].Position = UDim2.fromOffset(6, 8 + (index - 1) * 57)
end

local mainPage = createPage("Main")
local settingsPage = createPage("Settings")
local qbPage = createPage("QB Assist")
local magnetPage = createPage("Ball Magnet")
local miscPage = createPage("Misc")

local function heading(page, text)
    make("TextLabel", {
        Size = UDim2.new(1, -8, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = brightPurple,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3
    }, page)
end

local function toggle(page, label, key, description)
    local card = make("Frame", {
        Size = UDim2.new(1, -8, 0, description and 78 or 53),
        BackgroundColor3 = Color3.fromRGB(24, 12, 43),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 3
    }, page)
    round(card, 9)
    stroke(card, Color3.fromRGB(98, 39, 152), 1)

    make("TextLabel", {
        Size = UDim2.new(1, -75, 0, 28),
        Position = UDim2.fromOffset(12, description and 8 or 12),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = white,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    }, card)

    if description then
        make("TextLabel", {
            Size = UDim2.new(1, -20, 0, 22),
            Position = UDim2.fromOffset(12, 35),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = muted,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 4
        }, card)
    end

    local button = make("TextButton", {
        Size = UDim2.fromOffset(48, 25),
        Position = UDim2.new(1, -59, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(65, 48, 81),
        Text = "OFF",
        TextColor3 = white,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        ZIndex = 4
    }, card)
    round(button, 12)

    local function refresh()
        button.Text = settings[key] and "ON" or "OFF"
        button.BackgroundColor3 = settings[key]
            and purple or Color3.fromRGB(65, 48, 81)
    end
    refresh()
    button.Activated:Connect(function()
        settings[key] = not settings[key]
        refresh()
    end)
end

local function rangeControl(page)
    local card = make("Frame", {
        Size = UDim2.new(1, -8, 0, 83),
        BackgroundColor3 = Color3.fromRGB(24, 12, 43),
        BorderSizePixel = 0,
        ZIndex = 3
    }, page)
    round(card, 9)
    stroke(card, Color3.fromRGB(98, 39, 152), 1)

    local value = make("TextLabel", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.fromOffset(10, 5),
        BackgroundTransparency = 1,
        TextColor3 = white,
        Text = "Catch Range: " .. settings.CatchRange,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    }, card)

    local function rangeButton(text, x, delta, color)
        local button = make("TextButton", {
            Size = UDim2.fromOffset(35, 30),
            Position = UDim2.fromOffset(x, 43),
            BackgroundColor3 = color,
            Text = text,
            TextColor3 = white,
            TextSize = 20,
            ZIndex = 4
        }, card)
        round(button, 6)
        button.Activated:Connect(function()
            settings.CatchRange = math.clamp(settings.CatchRange + delta, 5, 50)
            value.Text = "Catch Range: " .. settings.CatchRange
        end)
    end

    rangeButton("−", 10, -5, Color3.fromRGB(73, 26, 114))
    rangeButton("+", 51, 5, purple)
end

heading(mainPage, "✦  MAIN CONTROL")
toggle(mainPage, "Ball Magnet", "BallMagnet", "Visual setting only.")
rangeControl(mainPage)
toggle(mainPage, "Auto QB", "AutoQB", "Visual setting only.")

heading(settingsPage, "⚙  SETTINGS")
make("TextLabel", {
    Size = UDim2.new(1, -8, 0, 70),
    BackgroundColor3 = Color3.fromRGB(24, 12, 43),
    Text = "Agents Football\nPurple Galaxy Theme\nSettings reset when the script restarts.",
    TextColor3 = white, TextSize = 13, Font = Enum.Font.Gotham, ZIndex = 3
}, settingsPage)

heading(qbPage, "◎  QB ASSIST")
toggle(qbPage, "Auto QB", "AutoQB", "Visual setting only; no automated throws.")
make("TextLabel", {
    Size = UDim2.new(1, -8, 0, 65),
    BackgroundColor3 = Color3.fromRGB(24, 12, 43),
    Text = "QB features require supported game mechanics.",
    TextColor3 = muted, TextSize = 12, TextWrapped = true, ZIndex = 3
}, qbPage)

heading(magnetPage, "◈  BALL MAGNET")
toggle(magnetPage, "Ball Magnet", "BallMagnet", "Visual setting only; no ball movement.")
rangeControl(magnetPage)

heading(miscPage, "★  MISC")
make("TextLabel", {
    Size = UDim2.new(1, -8, 0, 90),
    BackgroundColor3 = Color3.fromRGB(24, 12, 43),
    Text = "✦ AGENTS FOOTBALL ✦\nPurple Galaxy Edition\nDecorative stars animate in the background.",
    TextColor3 = white, TextSize = 13, TextWrapped = true, ZIndex = 3
}, miscPage)

-- Make the first page active after every page exists.
activePage = "Main"
for name, page in pairs(pages) do page.Visible = name == activePage end
for name, button in pairs(navButtons) do
    button.BackgroundColor3 = name == activePage
        and Color3.fromRGB(83, 23, 139) or Color3.fromRGB(20, 10, 36)
    button.TextColor3 = name == activePage and white or muted
end

-- Drag by the title area.
local dragging, dragStart, startPosition = false, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale,
            startPosition.X.Offset + delta.X, startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

main.Size = UDim2.fromOffset(520, 450)
TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back,
    Enum.EasingDirection.Out), {Size = UDim2.fromOffset(550, 475)}):Play()

print("Agents Football | Purple Galaxy UI loaded")
