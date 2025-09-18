local elements = {
    ["dashboard"] = gurt.select("#dashboard"),
    ["hosting"] = gurt.select("#hosting"),
    ["new-domain"] = gurt.select("#new-domain"),
}

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

elements["dashboard"]:on('click', function()
    gurt.location.goto('/dashboard.html')
end)
elements["hosting"]:on('click', function()
    gurt.location.goto('/hosting.html')
end)
elements["new-domain"]:on('click', function()
    gurt.location.goto('/create.html')
end)