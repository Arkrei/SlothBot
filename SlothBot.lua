--[[ 
     SlothBot
     Please read the ReadMe
]]--

local Discordia = require("discordia")
local Client = discordia.Client()

local BotToken = "Put your own token here"
local BotFunctions = {}

local GifCount
local ImageCount

local SlothFacts = {}

local function Split(str, pat)
     local t = {} 
     local fpat = "(.-)" .. pat
     local last_end = 1
     local s, e, cap = str:find(fpat, 1)
     while s do
        if s ~= 1 or cap ~= "" then
           table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
     end
     if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
     end
     return t
end

local function GetDirCount(dir,ext)
     local Count = 0 
     local directory = io.popen("dir "..dir):lines()
     for file in directory do
          local str=Split(file,ext)
          Count = Count + #str
     end
     return Count
end

GifCount = GetDirCount("GIF",".gif")
ImageCount = GetDirCount("Images",".png")

BotFunctions[".slothfact"] = function(message)
     local Channel = message.channel
     Channel:send(SlothFacts[math.random(#SlothFacts)])
end
BotFunctions[".slothpic"] = function(message)
     local Channel = message.channel
     Channel:send({file="Images/"..tostring(math.random(ImageCount))..".png"})
end
BotFunctions[".slothgif"] = function(message)
     local Channel = message.channel
     Channel:send({file="GIF/"..tostring(math.random(GifCount))..".gif"})
end
BotFunctions[".help"] = function(message)
     local Channel = message.channel
     local Author = message.author 
     Channel:send{
          embed = {
               title = "Help",
               description = "Here are a list of commands",
               author = {
                    name = Author.username,
                    icon_url = Author.avatarURL
               },
               fields = { 
                    {name = ".slothpic",value = "Will reply with a random picture of a Sloth",inline = true},
                    {name = ".slothgif",value = "Will reply with a random GIF of a Sloth",inline = false},
                    {name = ".slothfact",value = "Will reply with a random fact about Sloths",inline = false}
               },
               footer = {
                    text = "SlothBot, for people passionate about sloths :)"
               },
               color = 0x000000
     }}
end

Client:on("ready", function()
     Client:setGame(".help")
end)

Client:on('messageCreate', function(message)
     local Message = message.content:lower()
     local Channel = message.channel

     if BotFunctions[Message] ~= nil then
          BotFunctions[Message](message)
     end
end)

Client:run("Bot "..BotToken)

for line in io.lines("Facts.txt") do
    table.insert(SlothFacts, line)
end