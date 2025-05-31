local M = {}
local curl = require("plenary.curl")
local config = require("gitlab-snippets.config")

local API_VERSION = "v4"

-- Get token from environment variable
local function get_token(instance_name)
  local token_var = "GITLAB_SNIPPETS_TOKEN_" .. string.upper(instance_name)
  local token = os.getenv(token_var)
  if not token then
    token = os.getenv("GITLAB_SNIPPETS_TOKEN")
  end
  return token
end

-- Private helper to fetch raw snippet content
local function _get_raw_snippet_content(instance_name, url_path)
  local instance_config = config.get_instance(instance_name)
  if not instance_config then
    return nil, "Instance not found: " .. instance_name
  end

  local token = get_token(instance_name)
  if not token then
    return nil, "Token not found for instance: " .. instance_name
  end

  local response = curl.get({
    url = instance_config.url .. "/api/" .. API_VERSION .. url_path,
    headers = {
      ["PRIVATE-TOKEN"] = token,
    },
  })

  if response.status ~= 200 then
    return nil, "Failed to fetch snippet content: " .. response.status .. " - " .. (response.body or "")
  end

  return response.body
end

-- Private helper to fetch snippet metadata
local function _get_snippet_metadata(instance_name, url_path)
  return M.request(instance_name, url_path, "GET")
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

  local url = instance_config.url .. "/api/" .. API_VERSION .. endpoint

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

  if response.status >= 400 then -- Check for any client or server error
    local error_message = string.format("API request to %s failed with status %d", url, response.status)
    if response.status == 401 then
      error_message = error_message .. ": Unauthorized. Please check your GitLab token and its permissions (api scope)."
    elseif response.status == 403 then
      error_message = error_message .. ": Forbidden. You might not have access to this resource or the token lacks necessary scopes."
    elseif response.status == 404 then
      error_message = error_message .. ": Resource not found. Please check the URL or snippet ID."
    elseif response.status == 500 then
      error_message = error_message .. ": Internal Server Error on GitLab. Please try again later."
    end
    if response.body and response.body ~= "" then
      error_message = error_message .. "\nDetails: " .. response.body
    end
    return nil, error_message
  end

  -- Handle non-error statuses that are not 200, 201, or 204 if necessary, though GitLab API usually sticks to these for success.
  if response.status ~= 200 and response.status ~= 201 and response.status ~= 204 then
    return nil,
        string.format(
          "API request to %s returned an unexpected status %d - %s",
          url,
          response.status,
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
  return _get_snippet_metadata(instance_name, "/snippets/" .. tostring(snippet_id))
end

-- Get snippet content
M.get_snippet_content = function(instance_name, snippet_id)
  return _get_raw_snippet_content(instance_name, "/snippets/" .. tostring(snippet_id) .. "/raw")
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
  return _get_snippet_metadata(instance_name, "/projects/" .. tostring(project_id) .. "/snippets/" .. tostring(snippet_id))
end

-- Get project snippet content
M.get_project_snippet_content = function(instance_name, project_id, snippet_id)
  return _get_raw_snippet_content(
    instance_name,
    "/projects/" .. tostring(project_id) .. "/snippets/" .. tostring(snippet_id) .. "/raw"
  )
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
    url = instance_config.url .. "/api/" .. API_VERSION .. "/user",
    headers = {
      ["PRIVATE-TOKEN"] = token,
    },
  })

  if response.status ~= 200 then
    return false, "Connection test failed with status: " .. response.status
  end

  return true
end

-- List projects
M.list_projects = function(instance_name)
  return M.request(instance_name, "/projects?simple=false&membership=true&per_page=100", "GET")
end

-- Return the module
return M
