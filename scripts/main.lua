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

local function P()
    local response = fetch('https://api.example.com/users', {
    method = 'POST',
    headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bearer token123'
    },
    body = JSON.stringify({
        name = 'John Doe',
        email = 'john@example.com'
    })
})

-- Check response
if response:ok() then
    local data = response:json()  -- Parse JSON response
    local text = response:text()  -- Get as text
    
    trace.log('Status: ' .. response.status)
    trace.log('Status Text: ' .. response.statusText)
    
    -- Access headers
    local contentType = response.headers['content-type']
else
    trace.log('Request failed with status: ' .. response.status)
end
    
end