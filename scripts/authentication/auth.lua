--// Networking
local api_endpoint = "gurt://dns.web"
local endpoints = {
    ["Authorization"] = {
        ["register"] = api_endpoint .. "/auth/register",
        ["login"] = api_endpoint .. "/auth/login",
        ["me"] = api_endpoint .. "/auth/me",
        ["invite"] = api_endpoint .. "/auth/invite",
        ["domains"] = api_endpoint .. "/auth/domains",
        ["redeem-invite"] = api_endpoint .. "/auth/redeem-invite"
    },
    ["Domain"] = {
        ["request"] = api_endpoint .. "/domain",
        ["existingDomain"] = api_endpoint .. "/domain/%1/%2",
        ["tlds"] = api_endpoint .. "/tlds",
        ["domainCheck"] = api_endpoint .. "/domain/check",
    },
}

local elements = {
    ["Main"] = gurt.select("#main-div"),
    ["Login"] = gurt.select("#login"),
    ["Register"] = gurt.select("#register"),

    ["Username"] = gurt.select("#username"),
    ["Password"] = gurt.select("#password"),
    ["Error"] = gurt.select("#error")
}

--// Example network requests

local function loginDNSWeb(username, password)
    local response = fetch(endpoints["Authorization"]["login"], {
        method = 'POST',
        headers = {
            ['Content-Type'] = 'application/json',
        },
        body = JSON.stringify({
            ["username"] = username,
            ["password"] = password
        })
    })
    if response:ok() then
        local data = response:json()
        if response.status == 200 then
            gurt.crumbs.set({
                name = "dnsWEB", 
                value = data["token"]
            })
        end
    end
    return response.status
end

--// If we are currently authenticating w dns.web
if string.find(string.lower(gurt.location.href), string.lower("connectdnsweb")) then
    elements["Login"]:on('click', function()
        if elements["Login"].text == "Authenticating..." then
            return
        end
        local username = elements["Username"].value
        local password = elements["Password"].value

        if username == "" or password == "" then
            elements["Error"].text = "Please fill in all fields."
            return
        end

        -- Authenticating
        elements["Login"].text = "Authenticating..."
        elements["Login"].classList:add('bg-[#363636]')

        local status = loginDNSWeb(username, password)
        if status == 200 then --// Success
            elements["Error"].text = "[color=green]Successfully authenticated as " .. username .. "[/color]"
            gurt.location.goto('/dashboard.html'  )
            return

        elseif status == 401 then --// Invalid auth
            elements["Error"].text = "Invalid username or password."
        else --// Unknown error
            elements["Error"].text = "Login failed with status: " .. status
        end

        elements["Login"].text = "Authenticate"
        elements["Login"].classList:remove('bg-[#363636]')
    end)
else --// Normal auth page
    elements["Register"]:on('click', function() -- IMPLEMENT REGISTER
        gurt.location.goto('/auth/connectdnsweb.html')
    end)

    elements["Login"]:on('click', function() -- IMPLEMENT LOGIN
        gurt.location.goto('/auth/connectdnsweb.html')
    end)
end
