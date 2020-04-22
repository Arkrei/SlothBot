--[[ 
     SlothBot
     Please read the ReadMe
]]--

local Discordia = require("discordia")
local Client = Discordia.Client()
local PrettyPrint = require('pretty-print')

local BotToken = "Put your own token here"
local BotFunctions = {}
local Sandbox = setmetatable({ }, { __index = _G })
local GifCount
local ImageCount

local SlothFacts = {}

local function code(str)
     return string.format('```\n%s```', str)
 end
 
 local function println(...)
     local ret = {}
     for i = 1, select('#', ...) do
         local arg = tostring(select(i, ...))
         table.insert(ret, arg)
     end
     return table.concat(ret, '\t')
 end
 
 local function prettyln(...)
     local ret = {}
     for i = 1, select('#', ...) do
         local arg = PrettyPrint.strip(PrettyPrint.dump(select(i, ...)))
         table.insert(ret, arg)
     end
     return table.concat(ret, '\t')
 end
 
 local function Interpreter(arg, msg)
     arg = arg:gsub('```\n?', '')
     local lines = {}
     Sandbox.message = msg
     Sandbox.print = function(...)
         table.insert(lines, println(...))
     end
     Sandbox.p = function(...)
         table.insert(lines, prettyln(...))
     end
     local fn, syntaxError = load(arg, 'DiscordBot', 't', Sandbox)
     if not fn then return msg:reply(code(syntaxError)) end
     local success, runtimeError = pcall(fn)
     if not success then return msg:reply(code(runtimeError)) end
     lines = table.concat(lines, '\n')
     if #lines > 1990 then
         lines = lines:sub(1, 1990)
     end
     return msg:reply(code(lines))
 end

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
     Channel:send("Fact! "..SlothFacts[math.random(#SlothFacts)])
end
BotFunctions[".slothpic"] = function(message)
     local Channel = message.channel
     Channel:send({content="Picture!",file="Images/"..tostring(math.random(ImageCount))..".png"})
end
BotFunctions[".slothgif"] = function(message)
     local Channel = message.channel
     Channel:send({content="GIF!",file="GIF/"..tostring(math.random(GifCount))..".gif"})
end
BotFunctions[".help"] = function(message)
     local Channel = message.channel
     local Author = message.author 
     Author:send{
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
                    {name = ".slothfact",value = "Will reply with a random fact about Sloths",inline = false},
                    {name = ".lua [CODE]",value = "Without the [] the bot will attempt to interpret the code you provided in lua and print the output",inline = false}
               },
               footer = {
                    text = "SlothBot, for people passionate about sloths :) This bot is also open-source if you wanna check it out head to https://www.github.com/sloth-squad/SlothBot"
               },
               color = 0x000000
     }}
end

Client:on("ready", function()
     Client:setGame(".help")
end)

Client:on('messageCreate', function(message)
     if message.guild == nil then return end
     local Message = message.content:lower()
     local Channel = message.channel
     
     local HasAttachPermissions = message.guild.me:hasPermission(Channel,0x00008000)
     
     if Message:lower():sub(1,4) == ".lua" then
          if string.find(Message,"while true do") then message:reply("I cannot compile that") end
          Interpreter(Message:sub(6,#Message),message)
     end
     
     if BotFunctions[Message] ~= nil then
          if HasAttachPermissions then
               BotFunctions[Message](message)
          elseif not HasAttachPermissions then
               Channel:send("I do not have permission to attach links :( sloth sad now")
          end
          return
     end
end)

Client:run("Bot "..BotToken)

for line in io.lines("Facts.txt") do
    table.insert(SlothFacts, line)
end
