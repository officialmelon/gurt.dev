local domainEndpoint = "gurt://dns.web/domain"
local elements = {
    ["add-record"] = gurt.select("#add-record"),
    ["record-type"] = gurt.select("#record-type"),
    ["record-name"] = gurt.select("#record-name"),
    ["record-value"] = gurt.select("#record-value"),
    ["record-ttl"] = gurt.select("#record-ttl"),
    ["error-message"] = gurt.select("#error-message"),
    ["loading-records"] = gurt.select("#loading-records"),
    ["domain-name"] = gurt.select("#domain-name"),
    ["record-holder"] = gurt.select("#record-holder"),

    ["dashboard"] = gurt.select("#dashboard"),
    ["hosting"] = gurt.select("#hosting"),
    ["new-domain"] = gurt.select("#new-domain"),
}
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


local function apiFetch(endpoint, method, payload)
    local opts = {
        method = method,
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. dnsCreds
        }
    }
    if payload then opts.body = JSON.stringify(payload) end
    return fetch(endpoint, opts)
end

local function truncate(str, len)
    if #str > len then return str:sub(1, len) .. "..." end
    return str
end

local function showError(msg)
    elements["error-message"].text = msg
end

local function getRecords(domain)
    local endpoint = domainEndpoint .. "/" .. domain .. "/records"
    local res = apiFetch(endpoint, "GET")
    if res.status == 200 then return res:json() end
    showError(res:json()["error"] or "Unknown error")
    return {}
end

local function removeRecord(domain, id, recordDiv)
    local endpoint = domainEndpoint .. "/" .. domain .. "/records/" .. id
    local res = apiFetch(endpoint, "DELETE")
    if res.status == 200 then
        recordDiv:remove()
    else
        showError(res:json()["error"] or "Unknown error")
    end
end

local function createRecordElement(domain, v)
    local recordDiv = gurt.create('div', { style = 'flex flex-row justify-between w-35 h-12 rounded-xl border border-gray-700 mx-auto my-1' })
    recordDiv:append(gurt.create('h1', { style = 'text-lg ml-2 text-center', text = v.type }))
    recordDiv:append(gurt.create('h1', { style = 'text-lg text-center', text = truncate(v.name, 10) }))
    recordDiv:append(gurt.create('h1', { style = 'text-lg text-center', text = truncate(v.value, 10) }))
    local delBtn = gurt.create('button', { style = 'text-lg mr-2 mt-1 bg-transparent w-1 mx-auto text-[#FF0000] text-center', text = 'X' })
    delBtn:on('click', function() removeRecord(domain, v.id, recordDiv) end)
    recordDiv:append(delBtn)
    elements["record-holder"]:append(recordDiv)
end

local function renderRecords(domain)
    local records = getRecords(domain)
    if #records == 0 then
        elements["loading-records"].text = "No records found."
    else
        elements["loading-records"]:remove()
        for _, v in pairs(records) do createRecordElement(domain, v) end
    end
end

local function setDomainName(domain)
    elements["domain-name"].text = domain
end

local function onPageLoad()
    local domain = gurt.location.query.get('domain')
    if not domain then
        gurt.location.goto('/dashboard.html')
        return
    end
    setDomainName(domain)
    renderRecords(domain)

    elements["dashboard"]:on('click', function()
        gurt.location.goto('/dashboard.html')
    end)
    elements["hosting"]:on('click', function()
        gurt.location.goto('/hosting.html')
    end)
    elements["new-domain"]:on('click', function()
        gurt.location.goto('/create.html')
    end)
end

local function addRecord()
    local t, n, v, ttl = elements["record-type"].value, elements["record-name"].value, elements["record-value"].value, elements["record-ttl"].value
    if n == "" or not n then n = "@" end
    if ttl == "" or not ttl then ttl = "3600" end
    if not t or not n or not v or not ttl or t == "" or n == "" or v == "" or ttl == "" then
        showError("Please fill in all fields.")
        return
    end
    local domain = gurt.location.query.get('domain')
    if not domain then return end
    local payload = { name = n, ttl = ttl, type = t, value = v }
    local endpoint = domainEndpoint .. "/" .. domain .. "/records"
    local res = apiFetch(endpoint, "POST", payload)
    if res.status == 200 then
        createRecordElement(domain, res:json())
    else
        showError(res:text() or "Unknown error")
    end
end

elements["add-record"]:on('click', addRecord)
onPageLoad()
