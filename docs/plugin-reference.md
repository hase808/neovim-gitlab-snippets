# Plugin Reference

Complete reference for commands, keybindings, and features of the Neovim GitLab Snippets plugin.

## Table of Contents

- [Commands](#commands)
- [Keybindings](#keybindings)
- [Telescope Integration](#telescope-integration)
- [Health Check System](#health-check-system)
- [Configuration Options](#configuration-options)
- [Environment Variables](#environment-variables)
- [API Endpoints](#api-endpoints)
- [Error Codes](#error-codes)
- [Feature Matrix](#feature-matrix)

---

## Commands

### User Commands

#### `:GitLabSnippets`

Opens the Telescope picker to browse GitLab snippets.

**Usage:**

```vim
:GitLabSnippets
```

**Description:**

- Opens instance selection if multiple instances configured
- Goes directly to snippet type selection for single instance
- Requires valid configuration and authentication

**Example:**

```vim
:GitLabSnippets
" Opens picker → Select instance → Select snippet type → Browse snippets
```

---

## Keybindings

### Global Keybindings

No default global keybindings are set. Add your own:

```lua
-- Quick access
vim.keymap.set("n", "<leader>gs", "<cmd>GitLabSnippets<cr>", { desc = "GitLab Snippets" })

-- Via Telescope
vim.keymap.set("n", "<leader>ts", "<cmd>Telescope gitlab_snippets<cr>", { desc = "Telescope GitLab Snippets" })
```

### Picker Keybindings

#### Instance Picker

| Key       | Action   | Description      |
| --------- | -------- | ---------------- |
| `j`/`k`   | Navigate | Move up/down     |
| `<Enter>` | Select   | Choose instance  |
| `<Esc>`   | Close    | Exit picker      |
| `/`       | Search   | Filter instances |

#### Snippet Type Picker

| Key       | Action   | Description         |
| --------- | -------- | ------------------- |
| `j`/`k`   | Navigate | Move up/down        |
| `<Enter>` | Select   | Choose snippet type |
| `<Esc>`   | Close    | Go back or exit     |
| `/`       | Search   | Filter types        |

#### Project Picker

| Key             | Action   | Description      |
| --------------- | -------- | ---------------- |
| `j`/`k`         | Navigate | Move up/down     |
| `<Enter>`       | Select   | Choose project   |
| `<Esc>`         | Close    | Go back          |
| `/`             | Search   | Filter projects  |
| `<C-u>`/`<C-d>` | Page     | Scroll half page |

#### Snippet List

| Key             | Action             | Description                  |
| --------------- | ------------------ | ---------------------------- |
| `j`/`k`         | Navigate           | Move between snippets        |
| `<Enter>`       | **Toggle Preview** | Switch content/metadata view |
| `<C-i>`         | **Insert Snippet** | Insert at cursor and close   |
| `<C-n>`         | **New Buffer**     | Open snippet in new buffer   |
| `<Esc>`         | Close              | Exit snippet browser         |
| `/`             | Search             | Filter snippets by title     |
| `<C-u>`/`<C-d>` | Page               | Scroll snippet list          |
| `<C-p>`         | Preview Up         | Scroll preview up            |
| `<C-n>`         | Preview Down       | Scroll preview down          |
| `gg`/`G`        | Go to              | First/last snippet           |

### Custom Keybinding Examples

```lua
-- Direct access to specific functionality
local gs = require("gitlab-snippets")

-- Quick access to personal snippets
vim.keymap.set("n", "<leader>gp", function()
  require("gitlab-snippets.picker").pick_user_snippets("primary")
end, { desc = "Personal Snippets" })

-- Work instance shortcuts
vim.keymap.set("n", "<leader>gw", function()
  require("gitlab-snippets.picker").pick_snippet_type("work")
end, { desc = "Work Snippets" })

-- Direct project browsing
vim.keymap.set("n", "<leader>gP", function()
  require("gitlab-snippets.picker").pick_project("primary")
end, { desc = "Browse Projects" })
```

---

## Telescope Integration

### Extension Registration

The plugin registers as a Telescope extension:

```lua
require("telescope").load_extension("gitlab_snippets")
```

### Telescope Commands

#### `:Telescope gitlab_snippets`

Alternative way to open the snippet browser.

**Usage:**

```vim
:Telescope gitlab_snippets
```

**Equivalent to:**

```vim
:GitLabSnippets
```

### Extension Configuration

```lua
require("telescope").setup({
  extensions = {
    gitlab_snippets = {
      -- Extension-specific options would go here
      -- (Currently none defined)
    }
  }
})
```

### Integration with Telescope Features

- **Search:** Full text search in snippet titles
- **Preview:** Live preview with syntax highlighting
- **Navigation:** Standard Telescope navigation
- **Actions:** Custom actions for snippet operations

---

## Health Check System

### Running Health Checks

```vim
:checkhealth gitlab-snippets
```

### Health Check Categories

#### 1. Dependencies

**Checks:**

- ✓ `plenary.nvim` availability
- ✓ `telescope.nvim` availability
- ✓ Neovim version compatibility

**Possible Results:**

- **OK:** Dependency found and compatible
- **ERROR:** Dependency missing or incompatible
- **WARN:** Dependency found but version concern

#### 2. Platform Compatibility

**Checks:**

- ✓ Operating system (macOS ARM officially supported)
- ✓ Neovim version (v0.10.0+ recommended)

**Possible Results:**

- **OK:** Running on supported platform
- **WARN:** Unsupported platform but may work

#### 3. Configuration

**Checks:**

- ✓ GitLab instances configured
- ✓ Instance count and validity
- ✓ Configuration structure

**Possible Results:**

- **OK:** Configuration valid
- **WARN:** No instances configured
- **ERROR:** Invalid configuration

#### 4. Authentication

**Checks:**

- ✓ Token availability per instance
- ✓ Token source (default vs instance-specific)

**Possible Results:**

- **OK:** Token found for instance
- **WARN:** Using default token
- **ERROR:** No token found

#### 5. Connectivity

**Checks:**

- ✓ Network connection to each GitLab instance
- ✓ API authentication
- ✓ Basic API functionality

**Possible Results:**

- **OK:** Connection successful
- **ERROR:** Connection failed with reason

---

## Configuration Options

### Complete Configuration Schema

```lua
require("gitlab-snippets").setup({
  -- GitLab instance configurations (required)
  instances = {
    [string] = {           -- Instance identifier
      url = string         -- GitLab instance URL (required)
    }
  },

  -- Default snippet action (optional)
  default_action = string  -- "insert" or "new_file" (default: "insert")
})
```

### Instance Configuration

```lua
instances = {
  -- Simple instance
  primary = {
    url = "https://gitlab.com"
  },

  -- Multiple instances
  work = {
    url = "https://gitlab.company.com"
  },

  self_hosted = {
    url = "https://git.mydomain.org"
  }
}
```

### Default Action Options

| Value        | Description                | Behavior                                           |
| ------------ | -------------------------- | -------------------------------------------------- |
| `"insert"`   | Insert at cursor (default) | Inserts snippet content at current cursor position |
| `"new_file"` | Open in new buffer         | Creates new buffer with snippet content            |

```lua
-- Examples
default_action = "insert"    -- Default behavior
default_action = "new_file"  -- Always open in new buffer
```

---

## Environment Variables

### Token Variables

#### `GITLAB_SNIPPETS_TOKEN`

Default token used for all instances.

**Format:** `glpat-xxxxxxxxxxxxxxxxxxxx` (GitLab Personal Access Token)

**Usage:**

```bash
export GITLAB_SNIPPETS_TOKEN="glpat-your-token-here"
```

#### `GITLAB_SNIPPETS_TOKEN_<INSTANCE>`

Instance-specific token (overrides default).

**Format:** `GITLAB_SNIPPETS_TOKEN_` + uppercase instance name

**Examples:**

```bash
# For instance named "primary"
export GITLAB_SNIPPETS_TOKEN_PRIMARY="glpat-primary-token"

# For instance named "work"
export GITLAB_SNIPPETS_TOKEN_WORK="glpat-work-token"

# For instance named "self_hosted"
export GITLAB_SNIPPETS_TOKEN_SELF_HOSTED="glpat-selfhosted-token"
```

### Token Resolution Order

1. Check `GITLAB_SNIPPETS_TOKEN_<INSTANCE>`
2. Fall back to `GITLAB_SNIPPETS_TOKEN`
3. Error if no token found

---

## API Endpoints

### GitLab API v4 Endpoints Used

| Endpoint                                          | Purpose                  | HTTP Method |
| ------------------------------------------------- | ------------------------ | ----------- |
| `/api/v4/user`                                    | Connection testing       | GET         |
| `/api/v4/snippets`                                | Personal snippets        | GET         |
| `/api/v4/snippets/public`                         | Public snippets          | GET         |
| `/api/v4/snippets/all`                            | All snippets (admin)     | GET         |
| `/api/v4/snippets/{id}`                           | Single snippet metadata  | GET         |
| `/api/v4/snippets/{id}/raw`                       | Snippet raw content      | GET         |
| `/api/v4/projects`                                | User projects            | GET         |
| `/api/v4/projects/{id}/snippets`                  | Project snippets         | GET         |
| `/api/v4/projects/{id}/snippets/{snippet_id}`     | Project snippet metadata | GET         |
| `/api/v4/projects/{id}/snippets/{snippet_id}/raw` | Project snippet content  | GET         |

### API Parameters

#### List Snippets

- `per_page`: Number of results per page (default: 20, max: 100)
- `page`: Page number (default: 1)
- `order_by`: Sort order (`created_at`, `updated_at`, `title`)
- `sort`: Sort direction (`asc`, `desc`)

#### List Projects

- `simple`: Return simplified project objects
- `membership`: Only projects user is member of
- `per_page`: Results per page (max: 100)

---

## Error Codes

### HTTP Status Codes

| Code | Meaning      | Common Cause             | Solution                      |
| ---- | ------------ | ------------------------ | ----------------------------- |
| 200  | OK           | Success                  | -                             |
| 401  | Unauthorized | Invalid/expired token    | Generate new token            |
| 403  | Forbidden    | Insufficient permissions | Check token scopes            |
| 404  | Not Found    | Resource doesn't exist   | Verify snippet/project exists |
| 500  | Server Error | GitLab internal error    | Try again later               |

### Plugin Error Messages

#### Authentication Errors

```
Token not found for instance: primary
```

**Solution:** Set `GITLAB_SNIPPETS_TOKEN` or `GITLAB_SNIPPETS_TOKEN_PRIMARY`

```
401: Unauthorized. Please check your GitLab token and its permissions (api scope).
```

**Solution:** Generate new token with `api` scope

#### Configuration Errors

```
Instance not found: work
```

**Solution:** Add instance to configuration

```
No GitLab instances configured
```

**Solution:** Add instances to setup configuration

#### Network Errors

```
Connection test failed with status: 0
```

**Solution:** Check network connectivity and GitLab URL

```
Failed to fetch snippet content: 404
```

**Solution:** Verify snippet exists and you have access

---

## Feature Matrix

### Snippet Types Support

| Feature       | Personal | Public | Project | All (Admin) |
| ------------- | -------- | ------ | ------- | ----------- |
| Browse        | ✓        | ✓      | ✓       | ✓           |
| Preview       | ✓        | ✓      | ✓       | ✓           |
| Insert        | ✓        | ✓      | ✓       | ✓           |
| New Buffer    | ✓        | ✓      | ✓       | ✓           |
| Metadata View | ✓        | ✓      | ✓       | ✓           |
| Search        | ✓        | ✓      | ✓       | ✓           |

### GitLab Versions

| GitLab Version | API Version | Support Status     |
| -------------- | ----------- | ------------------ |
| 15.0+          | v4          | ✓ Fully Supported  |
| 14.0+          | v4          | ✓ Supported        |
| 13.0+          | v4          | ⚠️ Limited Testing |
| 12.0+          | v4          | ❓ Unknown         |

### Platform Support

| Platform | Architecture | Support Level          |
| -------- | ------------ | ---------------------- |
| macOS    | ARM64        | ✓ Officially Supported |
| macOS    | x86_64       | ⚠️ Should Work         |
| Linux    | Any          | ⚠️ Should Work         |
| Windows  | WSL          | ⚠️ Should Work         |
| Windows  | Native       | ❓ Untested            |

---

## Version Information

### Plugin Versions

- **Current Version:** v0.0.2
- **Minimum Neovim:** v0.10.0
- **API Version:** GitLab API v4
- **Last Updated:** 2025-08-09

### Changelog Summary

#### v0.0.2

- Added comprehensive testing infrastructure
- Improved health check system
- Enhanced documentation
- Code optimization and cleanup

#### v0.0.1

- Initial release
- Basic snippet browsing
- Telescope integration
- Multi-instance support

### Compatibility Notes

- Requires Neovim 0.10.0+ for full feature support
- Works with any GitLab instance using API v4
- Telescope.nvim and plenary.nvim are required dependencies

---

**Last Updated:** 2025-08-09  
**Plugin Version:** v0.0.2
