--// Elements
local elements = {
    ["Main"] = gurt.select("#main-div"),
    ["Login"] = gurt.select("#login"),
    ["Register"] = gurt.select("#getstarted"),
}

if string.find(string.lower(gurt.location.href), string.lower("dashboard")) then -- temp fix
    return
end

elements["Register"]:on('click', function()
    gurt.location.goto('/auth/register.html')
end)

elements["Login"]:on('click', function()
    gurt.location.goto('/auth/login.html')
end)
