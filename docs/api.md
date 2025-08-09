# API Documentation

This document provides a complete API reference for all modules in the Neovim GitLab Snippets plugin.

## Table of Contents

- [Module: gitlab-snippets](#module-gitlab-snippets)
- [Module: gitlab-snippets.config](#module-gitlab-snippetsconfig)
- [Module: gitlab-snippets.api](#module-gitlab-snippetsapi)
- [Module: gitlab-snippets.picker](#module-gitlab-snippetspicker)
- [Module: gitlab-snippets.health](#module-gitlab-snippetshealth)

---

## Module: gitlab-snippets

Main plugin module that provides the public API and initialization.

**File:** `lua/gitlab-snippets/init.lua`

### Functions

#### `setup(opts)`

Initialize the plugin with user configuration.

**Parameters:**

- `opts` (table, optional): Configuration options
  - `instances` (table): GitLab instance configurations
  - `default_action` (string): Default action for snippets ("insert" or "new_file")

**Returns:** None

**Example:**

```lua
require("gitlab-snippets").setup({
  instances = {
    primary = { url = "https://gitlab.com" },
    work = { url = "https://gitlab.mycompany.com" }
  },
  default_action = "insert"
})
```

#### `health()`

Run health checks for the plugin.

**Parameters:** None

**Returns:** None

**Example:**

```lua
require("gitlab-snippets").health()
```

#### `pick_instance(opts)`

Open the Telescope picker to select a GitLab instance.

**Parameters:**

- `opts` (table, optional): Telescope picker options

**Returns:** None

**Example:**

```lua
require("gitlab-snippets").pick_instance()
```

---

## Module: gitlab-snippets.config

Configuration management module.

**File:** `lua/gitlab-snippets/config.lua`

### Properties

#### `defaults`

Default configuration values.

**Type:** table

**Structure:**

```lua
{
  instances = {},
  default_action = "insert"
}
```

#### `options`

Current active configuration after setup.

**Type:** table

### Functions

#### `setup(opts)`

Merge user configuration with defaults.

**Parameters:**

- `opts` (table, optional): User configuration options

**Returns:** None

**Example:**

```lua
local config = require("gitlab-snippets.config")
config.setup({
  instances = {
    gitlab_com = { url = "https://gitlab.com" }
  }
})
```

#### `get_instance(name)`

Retrieve configuration for a specific GitLab instance.

**Parameters:**

- `name` (string): Instance identifier

**Returns:**

- table|nil: Instance configuration or nil if not found

**Example:**

```lua
local config = require("gitlab-snippets.config")
local instance = config.get_instance("primary")
-- Returns: { url = "https://gitlab.com" }
```

---

## Module: gitlab-snippets.api

GitLab API interaction module.

**File:** `lua/gitlab-snippets/api.lua`

### Functions

#### `request(instance_name, endpoint, method, data)`

Make a generic API request to GitLab.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `endpoint` (string): API endpoint path
- `method` (string): HTTP method ("GET", "POST", "PUT", "DELETE")
- `data` (table, optional): Request body data

**Returns:**

- table|nil: Parsed JSON response or nil on error
- string: Error message if request failed

**Example:**

```lua
local api = require("gitlab-snippets.api")
local user, err = api.request("primary", "/user", "GET")
```

#### `list_instances()`

List all configured GitLab instances.

**Parameters:** None

**Returns:**

- table: Array of instance configurations with name and url

**Example:**

```lua
local api = require("gitlab-snippets.api")
local instances = api.list_instances()
-- Returns: { { name = "primary", url = "https://gitlab.com" } }
```

#### `list_user_snippets(instance_name)`

Fetch personal snippets for the authenticated user.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance

**Returns:**

- table|nil: Array of snippet objects or nil on error
- string: Error message if request failed

**Example:**

```lua
local api = require("gitlab-snippets.api")
local snippets, err = api.list_user_snippets("primary")
```

#### `list_public_snippets(instance_name)`

Fetch all public snippets from the GitLab instance.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance

**Returns:**

- table|nil: Array of snippet objects or nil on error
- string: Error message if request failed

#### `list_all_snippets(instance_name)`

Fetch all snippets (requires admin privileges).

**Parameters:**

- `instance_name` (string): Name of the GitLab instance

**Returns:**

- table|nil: Array of snippet objects or nil on error
- string: Error message if request failed

#### `list_projects(instance_name)`

List projects accessible to the authenticated user.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance

**Returns:**

- table|nil: Array of project objects or nil on error
- string: Error message if request failed

#### `list_project_snippets(instance_name, project_id)`

Fetch snippets from a specific project.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `project_id` (number): Project ID

**Returns:**

- table|nil: Array of snippet objects or nil on error
- string: Error message if request failed

#### `get_snippet(instance_name, snippet_id)`

Fetch a single personal/public snippet by ID.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `snippet_id` (number): Snippet ID

**Returns:**

- table|nil: Snippet object or nil on error
- string: Error message if request failed

#### `get_snippet_content(instance_name, snippet_id)`

Fetch raw content of a personal/public snippet.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `snippet_id` (number): Snippet ID

**Returns:**

- string|nil: Raw snippet content or nil on error
- string: Error message if request failed

#### `get_project_snippet(instance_name, project_id, snippet_id)`

Fetch a single project snippet by ID.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `project_id` (number): Project ID
- `snippet_id` (number): Snippet ID

**Returns:**

- table|nil: Snippet object or nil on error
- string: Error message if request failed

#### `get_project_snippet_content(instance_name, project_id, snippet_id)`

Fetch raw content of a project snippet.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `project_id` (number): Project ID
- `snippet_id` (number): Snippet ID

**Returns:**

- string|nil: Raw snippet content or nil on error
- string: Error message if request failed

#### `test_connection(instance_name)`

Test connection to a GitLab instance.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance

**Returns:**

- boolean: True if connection successful
- string: Error message if connection failed

**Example:**

```lua
local api = require("gitlab-snippets.api")
local success, err = api.test_connection("primary")
if not success then
  print("Connection failed: " .. err)
end
```

---

## Module: gitlab-snippets.picker

Telescope picker integration module.

**File:** `lua/gitlab-snippets/picker.lua`

### Functions

#### `pick_instance(opts)`

Display Telescope picker for GitLab instance selection.

**Parameters:**

- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `pick_snippet_type(instance_name, opts)`

Display picker for snippet type selection (personal, public, all, project).

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `pick_project(instance_name, opts)`

Display picker for project selection.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `pick_user_snippets(instance_name, opts)`

Display picker for personal snippets.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `pick_public_snippets(instance_name, opts)`

Display picker for public snippets.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `pick_all_snippets(instance_name, opts)`

Display picker for all snippets (requires admin).

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `pick_project_snippets(instance_name, project, opts)`

Display picker for project snippets.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `project` (table): Project object with id and name
- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `display_snippets(instance_name, snippets, title, opts)`

Display snippets in Telescope with preview.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `snippets` (table): Array of snippet objects
- `title` (string): Picker title
- `opts` (table, optional): Telescope picker options

**Returns:** None

#### `insert_snippet(instance_name, snippet)`

Insert snippet content at cursor position.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `snippet` (table): Snippet object

**Returns:** None

**Example:**

```lua
local picker = require("gitlab-snippets.picker")
picker.insert_snippet("primary", snippet)
```

#### `open_snippet_in_buffer(instance_name, snippet)`

Open snippet in a new buffer.

**Parameters:**

- `instance_name` (string): Name of the GitLab instance
- `snippet` (table): Snippet object

**Returns:** None

**Example:**

```lua
local picker = require("gitlab-snippets.picker")
picker.open_snippet_in_buffer("primary", snippet)
```

---

## Module: gitlab-snippets.health

Health check module for plugin diagnostics.

**File:** `lua/gitlab-snippets/health.lua`

### Functions

#### `check()`

Run comprehensive health checks for the plugin.

**Parameters:** None

**Returns:** None

**Checks performed:**

- Dependency verification (plenary.nvim, telescope.nvim)
- Platform compatibility (macOS ARM)
- Neovim version compatibility
- GitLab instance configuration
- Access token availability
- API connection testing

**Example:**

```vim
:checkhealth gitlab-snippets
```

---

## Data Structures

### Snippet Object

Structure returned by GitLab API for snippets:

```lua
{
  id = 12345,
  title = "My Snippet",
  file_name = "example.lua",
  description = "A helpful code snippet",
  author = {
    id = 123,
    name = "John Doe",
    username = "johndoe",
    email = "john@example.com",
    state = "active"
  },
  created_at = "2024-01-01T10:00:00Z",
  updated_at = "2024-01-02T10:00:00Z",
  web_url = "https://gitlab.com/snippets/12345",
  raw_url = "https://gitlab.com/snippets/12345/raw",
  project_id = nil,  -- Set for project snippets
  imported = false,
  imported_from = nil,
  snippet_type = "personal"  -- Added by plugin
}
```

### Instance Configuration

Structure for GitLab instance configuration:

```lua
{
  url = "https://gitlab.com",  -- GitLab instance URL
  -- Token is retrieved from environment variables
}
```

### Project Object

Structure returned by GitLab API for projects:

```lua
{
  id = 12345,
  name = "my-project",
  name_with_namespace = "username/my-project",
  description = "Project description",
  path = "my-project",
  path_with_namespace = "username/my-project",
  created_at = "2024-01-01T10:00:00Z",
  updated_at = "2024-01-02T10:00:00Z"
}
```

---

## Error Handling

All API functions follow a consistent error handling pattern:

1. Functions return `nil` and an error message on failure
2. Error messages include HTTP status codes and descriptions
3. Special handling for common HTTP errors (401, 403, 404, 500)
4. Connection errors are caught and reported

**Example error handling:**

```lua
local api = require("gitlab-snippets.api")
local snippets, err = api.list_user_snippets("primary")
if not snippets then
  vim.notify("Failed to fetch snippets: " .. err, vim.log.levels.ERROR)
  return
end
-- Process snippets...
```

---

## Environment Variables

The plugin uses environment variables for GitLab Personal Access Tokens:

- `GITLAB_SNIPPETS_TOKEN` - Default token for all instances
- `GITLAB_SNIPPETS_TOKEN_<INSTANCE>` - Instance-specific token (uppercase instance name)

**Example:**

```bash
export GITLAB_SNIPPETS_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
export GITLAB_SNIPPETS_TOKEN_PRIMARY="glpat-yyyyyyyyyyyyyyyyyyyy"
export GITLAB_SNIPPETS_TOKEN_WORK="glpat-zzzzzzzzzzzzzzzzzzzz"
```

---

## Version Compatibility

- **Plugin Version:** v0.0.2
- **Neovim:** v0.10.0+
- **GitLab API:** v4
- **Dependencies:**
  - plenary.nvim: Latest
  - telescope.nvim: Latest

