local tldEndpoint = "gurt://dns.web/tlds"
local domainEndpoint = "gurt://dns.web/domain"
local dnsCreds = gurt.crumbs.get("dnsWEB")

function checkCredsAPI()
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

-- POST /domain *
-- Submit a domain for approval. Requires authentication and consumes one registration slot. The request will be sent to the moderators via discord for verification.

-- Request:

-- {
--   "tld": "dev",
--   "ip": "192.168.1.100",
--   "name": "myawesome"
-- }
-- Error Responses:

-- 401 Unauthorized - Missing or invalid JWT token
-- 400 Bad Request - No registrations remaining, invalid domain, or offensive name
-- 409 Conflict - Domain already exists

local elements = {
    ["tld-select"] = gurt.select("#tld-select"),
    ["domain-name"] = gurt.select("#domain-name"),
    ["create-domain"] = gurt.select("#create-domain"),
    ["error-message"] = gurt.select("#error-message"),

    ["dashboard"] = gurt.select("#dashboard"),
    ["hosting"] = gurt.select("#hosting"),
    ["new-domain"] = gurt.select("#new-domain"),
}

local function requestDomain()
    local domainName = elements["domain-name"].value
    local tld = elements["tld-select"].value
    if domainName == "" or tld == "" then
        elements["error-message"].text = "Please enter a valid domain name and TLD."
        return
    end
    local payload = {
        tld = tld,
        name = domainName
    }
    
    local requestDomain = fetch(domainEndpoint, {
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. dnsCreds
        },
        body = JSON.stringify(payload)
    })
    print(requestDomain.status)
    print(payload)
    if requestDomain.status == 201 or requestDomain.status == 200 then
        print('Domain requested successfully!')
        elements["error-message"].text = "[color=green] Domain requested successfully! Please wait for approval. [/color]"
        Time.sleep(0.15)
        gurt.location.goto('/dashboard.html')
    elseif requestDomain.status == 400 or requestDomain.status == 409 then
        print("Error requesting domain: " .. requestDomain:json()['error'] or "Unknown error")
        elements["error-message"].text = requestDomain:json()['error'] or "Unknown error"
    end
end

elements["create-domain"]:on('click', function()
    requestDomain()
end)

elements["dashboard"]:on('click', function()
    gurt.location.goto('/dashboard.html')
end)
elements["hosting"]:on('click', function()
    gurt.location.goto('/hosting.html')
end)
elements["new-domain"]:on('click', function()
    gurt.location.goto('/create.html')
end)