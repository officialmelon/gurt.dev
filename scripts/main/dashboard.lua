local domainEndpoint = "gurt://dns.web/auth/domains"
local ourDnsCreds = gurt.crumbs.get("dnsWEB")

local elements = {
    ["new-domain"] = gurt.select("#new-domain"),
    ["hosting"] = gurt.select("#hosting"),
    ["dashboard"] = gurt.select("#dashboard"),
}

elements["new-domain"]:on('click', function()
    gurt.location.goto('/create.html')
end)

elements["hosting"]:on('click', function()
    gurt.location.goto('/hosting.html')
end)

elements["dashboard"]:on('click', function()
    gurt.location.goto('/dashboard.html')
end)

function checkCredsAPI()
    local dnsCreds = gurt.crumbs.get("dnsWEB")
    local check = fetch("gurt://dns.web/auth/me", {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. dnsCreds
        }
    })
    if check.status ~= 200 or not dnsCreds then
        gurt.location.goto('/auth/connectdnsweb.html')
        return
    end
end
checkCredsAPI()


if ourDnsCreds == nil then --// does token exist?
    gurt.location.goto('/auth/connectdnsweb.html')
else
    -- get domains
    local response = fetch(domainEndpoint, {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. ourDnsCreds
        }
    })
    -- remove existing loading 
    if #response:json()["domains"] >= 1 then
        if gurt.select('#loading') then
            gurt.select('#loading'):remove()
        end
    end
    -- domains
    for _, domain in pairs(response:json()["domains"]) do
        if domain["status"] == "approved" then
            local newDomain = gurt.create('div', { style = 'domain-card approved' })
            local domainName = gurt.create('h1', { style = 'domain-card-text ml-5 h-12 bg-[#141414]', text = domain.name .. "." .. domain.tld })
            newDomain:append(domainName)
            local analytics = gurt.create('h1', { style = 'domain-card-text ml-5 h-12 bg-[#141414] text-xs text-[#8b8b8bff]', text = '[color=#8b8b8bff][color=#3b65b3]' .. "Analytics not setup." .. '[/color][/color]' })
            newDomain:append(analytics)
            local status = gurt.create('h1', { style = 'domain-card-text ml-5 h-12 bg-[#141414] text-xs text-[#8b8b8bff]', text = '[color=#8b8b8bff]Status: [color=#36a847]' .. domain.status .. '[/color][/color]' })
            newDomain:append(status)
            local manageDiv = gurt.create('div', { style = 'pt-4 border-t border-gray-700' })
            local manageButton = gurt.create('button', { style = 'bg-transparent ml-5 text-[#D6D6D6] text-xs font-roboto py-1 px-2 rounded', text = 'Manage →' })
            manageDiv:append(manageButton)
            newDomain:append(manageDiv)

            manageButton:on('click', function()
                gurt.location.goto('/domain.html?domain=' .. domain.name .. '.' .. domain.tld)
            end)

            gurt.select('#domain-holder'):append(newDomain)
        elseif domain["status"] == "pending" then
            local newDomain = gurt.create('div', { style = 'domain-card pending' })
            local domainName = gurt.create('h1', { style = 'domain-card-text ml-5 h-12 bg-[#141414]', text = "[color=#ffef3d]" .. domain.name .. "." .. domain.tld .. "[/color]" })
            local domainInfo = gurt.create('h1', { style = 'domain-card-text ml-5 h-12 bg-[#141414] text-xs text-[#8b8b8bff]', text = "[color=#ffef3d]Pending Approval[/color]" })
            newDomain:append(domainName)
            newDomain:append(domainInfo)
            gurt.select('#domain-holder'):append(newDomain)
        elseif domain["status"] == "denied" then
            local newDomain = gurt.create('div', { style = 'domain-card denied' })
            local domainName = gurt.create('h1', { style = 'domain-card-text ml-5 h-12 bg-[#141414]', text = "[color=#f54242]" .. domain.name .. "." .. domain.tld .. "[/color]" })
            local domainInfo = gurt.create('h1', { style = 'domain-card-text ml-5 h-12 bg-[#141414] text-xs text-[#8b8b8bff]', text = "[color=#f54242]Denied Approval[/color]" })
            newDomain:append(domainName)
            newDomain:append(domainInfo)
            gurt.select('#domain-holder'):append(newDomain)
        end
        print(domain["name"] .. "." .. domain["tld"] .. " - " .. domain["status"])
        Time.sleep(0.14) -- to prevent freezing
    end
end