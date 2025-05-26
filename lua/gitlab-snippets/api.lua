local M = {}
local curl = require("plenary.curl")
local config = require("gitlab-snippets.config")

-- Get token from environment variable
local function get_token(instance_name)
  local token_var = "GITLAB_SNIPPETS_TOKEN_" .. string.upper(instance_name)
  local token = os.getenv(token_var)
  if not token then
    token = os.getenv("GITLAB_SNIPPETS_TOKEN")
  end
  return token
end

-- Make API request
M.request = function(instance_name, endpoint, method, data)
  local instance_config = config.get_instance(instance_name)
  if not instance_config then
    return nil, "Instance not found: " .. instance_name
  end

  local token = get_token(instance_name)
  if not token then
    return nil, "Token not found for instance: " .. instance_name
  end

  local url = instance_config.url .. "/api/v4" .. endpoint

  local headers = {
    ["PRIVATE-TOKEN"] = token,
    ["Content-Type"] = "application/json",
  }

  local opts = {
    url = url,
    headers = headers,
  }

  if data then
    opts.body = vim.fn.json_encode(data)
  end

  local response

  if method == "GET" then
    response = curl.get(opts)
  elseif method == "POST" then
    response = curl.post(opts)
  elseif method == "PUT" then
    response = curl.put(opts)
  elseif method == "DELETE" then
    response = curl.delete(opts)
  else
    return nil, "Unsupported method: " .. method
  end

  if response.status ~= 200 and response.status ~= 201 and response.status ~= 204 then
    return nil,
        string.format(
          "API request failed with status %d for URL %s - %s",
          response.status,
          url,
          (response.body or "")
        )
  end

  if response.body and response.body ~= "" then
    return vim.fn.json_decode(response.body)
  end

  return true
end

-- List all available instances
M.list_instances = function()
  local result = {}
  for name, instance in pairs(config.options.instances) do
    table.insert(result, {
      name = name,
      url = instance.url,
    })
  end
  return result
end

-- List user snippets
M.list_user_snippets = function(instance_name)
  return M.request(instance_name, "/snippets", "GET")
end

-- Get single snippet
M.get_snippet = function(instance_name, snippet_id)
  -- For personal/public snippets, we use the /snippets/:id endpoint
  return M.request(instance_name, "/snippets/" .. tostring(snippet_id), "GET")
end

-- Get snippet content
M.get_snippet_content = function(instance_name, snippet_id)
  -- For personal/public snippets, we use the /snippets/:id/raw endpoint
  local instance_config = config.get_instance(instance_name)
  if not instance_config then
    return nil, "Instance not found: " .. instance_name
  end

  local token = get_token(instance_name)
  if not token then
    return nil, "Token not found for instance: " .. instance_name
  end

  local response = curl.get({
    url = instance_config.url .. "/api/v4/snippets/" .. tostring(snippet_id) .. "/raw",
    headers = {
      ["PRIVATE-TOKEN"] = token,
    },
  })

  if response.status ~= 200 then
    return nil, "Failed to fetch snippet content: " .. (response.body or "")
  end

  return response.body
end

-- List all public snippets
M.list_public_snippets = function(instance_name)
  return M.request(instance_name, "/snippets/public", "GET")
end

-- List all snippets (requires admin)
M.list_all_snippets = function(instance_name)
  return M.request(instance_name, "/snippets/all", "GET")
end

-- List project snippets
M.list_project_snippets = function(instance_name, project_id)
  return M.request(instance_name, "/projects/" .. tostring(project_id) .. "/snippets", "GET")
end

-- Get project snippet
M.get_project_snippet = function(instance_name, project_id, snippet_id)
  return M.request(instance_name, "/projects/" .. tostring(project_id) .. "/snippets/" .. tostring(snippet_id), "GET")
end

-- Get project snippet content
M.get_project_snippet_content = function(instance_name, project_id, snippet_id)
  local instance_config = config.get_instance(instance_name)
  if not instance_config then
    return nil, "Instance not found: " .. instance_name
  end

  local token = get_token(instance_name)
  if not token then
    return nil, "Token not found for instance: " .. instance_name
  end

  local response = curl.get({
    url = instance_config.url .. "/api/v4/projects/" .. tostring(project_id) .. "/snippets/" .. tostring(
      snippet_id
    ) .. "/raw",
    headers = {
      ["PRIVATE-TOKEN"] = token,
    },
  })

  if response.status ~= 200 then
    return nil, "Failed to get project snippet content: " .. response.status .. " - " .. (response.body or "")
  end

  return response.body
end

-- Test connection to an instance
M.test_connection = function(instance_name)
  local instance_config = config.get_instance(instance_name)
  if not instance_config then
    return false, "Instance not found: " .. instance_name
  end

  local token = get_token(instance_name)
  if not token then
    return false, "Token not found for instance: " .. instance_name
  end

  local response = curl.get({
    url = instance_config.url .. "/api/v4/user",
    headers = {
      ["PRIVATE-TOKEN"] = token,
    },
  })

  if response.status ~= 200 then
    return false, "Connection test failed with status: " .. response.status
  end

  return true
end

-- Return the module
return M
