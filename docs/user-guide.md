# User Guide

A comprehensive guide to using the Neovim GitLab Snippets plugin.

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Basic Usage](#basic-usage)
- [Features](#features)
- [Workflows](#workflows)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Tips and Tricks](#tips-and-tricks)
- [Examples](#examples)

---

## Introduction

Neovim GitLab Snippets is a plugin that brings GitLab code snippets directly into your Neovim workflow. It allows you to browse, preview, and use code snippets from GitLab without leaving your editor.

### Key Features

- 🔍 **Browse** personal, public, and project snippets
- 👁️ **Preview** snippets with syntax highlighting
- 📊 **View metadata** including author, dates, and description
- ⚡ **Quick insert** snippets at cursor position
- 📝 **Open in buffer** for editing and saving
- 🔐 **Multi-instance** support for different GitLab servers

### Use Cases

- **Code Templates:** Store and reuse common code patterns
- **Configuration Files:** Keep configuration snippets handy
- **Documentation:** Access code examples and documentation
- **Team Sharing:** Share code snippets with your team
- **Learning Resources:** Browse public snippets for learning

---

## Installation

### Prerequisites

- Neovim v0.10.0 or higher
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- GitLab Personal Access Token

### Using lazy.nvim (Recommended)

```lua
-- ~/.config/nvim/lua/plugins/gitlab-snippets.lua
return {
  "https://git.unhappy.computer/hase808/neovim-gitlab-snippets",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "GitLabSnippets",  -- Lazy load on command
  keys = {
    { "<leader>gs", "<cmd>GitLabSnippets<cr>", desc = "GitLab Snippets" },
  },
  config = function()
    require("gitlab-snippets").setup({
      instances = {
        primary = { url = "https://gitlab.com" }
      }
    })
  end,
}
```

### Using packer.nvim

```lua
use {
  "https://git.unhappy.computer/hase808/neovim-gitlab-snippets",
  requires = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("gitlab-snippets").setup({
      instances = {
        primary = { url = "https://gitlab.com" }
      }
    })
  end
}
```

---

## Quick Start

### Step 1: Get a GitLab Token

1. Go to GitLab → **User Settings** → **Access Tokens**
2. Create a new token with `api` scope
3. Copy the token (starts with `glpat-`)

### Step 2: Set Environment Variable

```bash
# Add to ~/.bashrc or ~/.zshrc
export GITLAB_SNIPPETS_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"

# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc
```

### Step 3: Configure the Plugin

```lua
-- In your Neovim configuration
require("gitlab-snippets").setup({
  instances = {
    primary = { url = "https://gitlab.com" }
  }
})
```

### Step 4: Use the Plugin

```vim
:GitLabSnippets
```

Or use the keybinding if configured:

```
<leader>gs
```

---

## Basic Usage

### Opening the Plugin

There are three ways to open the plugin:

1. **Command:** `:GitLabSnippets`
2. **Keybinding:** `<leader>gs` (if configured)
3. **Telescope:** `:Telescope gitlab_snippets`

### Navigation Flow

```
1. Select GitLab Instance
   ↓
2. Choose Snippet Type
   ├─ Your Snippets (personal)
   ├─ Public Snippets
   ├─ All Snippets (admin only)
   └─ Project Snippets
   ↓
3. Browse and Preview Snippets
   ↓
4. Take Action (Insert/Open/View)
```

### Basic Actions

| Action           | Key      | Description                              |
| ---------------- | -------- | ---------------------------------------- |
| Preview          | Auto     | Automatically shows snippet content      |
| Toggle Metadata  | `Enter`  | Switch between content and metadata view |
| Insert at Cursor | `Ctrl+I` | Insert snippet at current position       |
| Open in Buffer   | `Ctrl+N` | Open snippet in new buffer               |
| Close            | `Esc`    | Close the picker                         |

---

## Features

### 1. Multi-Instance Support

Configure multiple GitLab instances:

```lua
require("gitlab-snippets").setup({
  instances = {
    personal = { url = "https://gitlab.com" },
    work = { url = "https://gitlab.company.com" },
    oss = { url = "https://gitlab.freedesktop.org" }
  }
})
```

### 2. Snippet Types

#### Personal Snippets

Your private and public snippets:

- Private snippets only visible to you
- Public snippets you've created
- Quick access to your code library

#### Public Snippets

All public snippets on the GitLab instance:

- Discover useful code from others
- Learn from community examples
- Find solutions to common problems

#### Project Snippets

Snippets from specific projects:

- Team-shared code snippets
- Project-specific templates
- Documentation and examples

#### All Snippets (Admin)

Requires admin privileges:

- View all snippets on the instance
- Audit and manage snippets
- Administrative overview

### 3. Live Preview

The preview window shows:

- **Syntax highlighting** based on file extension
- **Full content** of the snippet
- **Scrollable** for long snippets
- **Real-time** updates when navigating

### 4. Metadata View

Toggle to view snippet details:

- **Basic Info:** ID, title, filename
- **Description:** Full description text
- **Author:** Name, username, email
- **Timestamps:** Created and updated dates
- **URLs:** Web and raw URLs
- **Project:** Associated project (if any)

### 5. Smart Actions

#### Insert at Cursor (Ctrl+I)

- Inserts snippet at current cursor position
- Preserves indentation
- Maintains cursor position after insert

#### Open in Buffer (Ctrl+N)

- Creates new buffer with snippet content
- Sets appropriate filetype for syntax
- Names buffer after snippet title
- Ready for editing and saving

---

## Workflows

### Workflow 1: Using Code Templates

**Scenario:** You frequently need boilerplate code

1. Store templates as GitLab snippets
2. Open plugin: `:GitLabSnippets`
3. Navigate to your snippets
4. Find template
5. Press `Ctrl+I` to insert

**Example:** React component template

```jsx
// Stored as snippet: "React FC Template"
import React from 'react';

interface Props {
  // Add props here
}

const ComponentName: React.FC<Props> = ({ }) => {
  return (
    <div>
      {/* Component content */}
    </div>
  );
};

export default ComponentName;
```

### Workflow 2: Sharing Team Resources

**Scenario:** Share configuration files with team

1. Create project snippets in GitLab
2. Team members access via plugin
3. Browse project → Select project → View snippets
4. Insert or open configurations

**Example:** Shared ESLint config

```json
// Project snippet: "Team ESLint Config"
{
  "extends": ["@company/eslint-config"],
  "rules": {
    "no-console": "warn",
    "prefer-const": "error"
  }
}
```

### Workflow 3: Learning from Public Snippets

**Scenario:** Learn new techniques or find solutions

1. Browse public snippets
2. Search by viewing titles and descriptions
3. Preview interesting snippets
4. Open in buffer to study
5. Adapt for your needs

### Workflow 4: Quick Reference

**Scenario:** Need quick access to reference code

1. Store reference snippets (regex patterns, SQL queries, etc.)
2. Quick open: `<leader>gs`
3. Navigate to snippet
4. View in preview
5. Copy what you need

---

## Keyboard Shortcuts

### Global Shortcuts

| Key      | Action           | Context           |
| -------- | ---------------- | ----------------- |
| `j`/`k`  | Navigate up/down | List navigation   |
| `gg`/`G` | Go to top/bottom | List navigation   |
| `/`      | Search in list   | Telescope default |
| `?`      | Show mappings    | Telescope help    |
| `Esc`    | Close picker     | Any picker        |
| `Ctrl+C` | Cancel operation | Any picker        |

### Snippet List Shortcuts

| Key      | Action              | Description             |
| -------- | ------------------- | ----------------------- |
| `Enter`  | Toggle preview mode | Switch content/metadata |
| `Ctrl+I` | Insert at cursor    | Insert and close        |
| `Ctrl+N` | Open in buffer      | New buffer with content |
| `Ctrl+P` | Preview up          | Scroll preview up       |
| `Ctrl+N` | Preview down        | Scroll preview down     |

### Custom Keybindings

Add your own keybindings:

```lua
-- Quick access to personal snippets
vim.keymap.set("n", "<leader>gp", function()
  require("gitlab-snippets.picker").pick_user_snippets("primary")
end, { desc = "Personal GitLab Snippets" })

-- Direct project snippets
vim.keymap.set("n", "<leader>gP", function()
  require("gitlab-snippets.picker").pick_project("work")
end, { desc = "Project GitLab Snippets" })
```

---

## Tips and Tricks

### 1. Environment-Specific Tokens

Use direnv for project-specific tokens:

```bash
# .envrc in project root
export GITLAB_SNIPPETS_TOKEN_WORK="project-specific-token"
```

### 2. Quick Access Snippets

Create a "favorites" GitLab project for frequently used snippets:

- Easier to navigate
- Organized by project
- Shareable with team

### 3. Snippet Organization

Use consistent naming conventions:

```
[Category] Name - Description
[Template] React Component - Functional component with TypeScript
[Config] ESLint - Standard project configuration
[Script] Deploy - Deployment script for production
```

### 4. Metadata for Documentation

Use the description field effectively:

- Include usage instructions
- Add parameter descriptions
- Note dependencies
- Provide examples

### 5. File Extensions Matter

Always include file extensions in snippet filenames:

- Enables syntax highlighting
- Helps with filetype detection
- Makes purpose clear

### 6. Version Your Snippets

Include version info in description:

```
v2.0 - Updated for React 18
Compatible with Node 16+
Last updated: 2024-01-15
```

### 7. Use Multiple Instances

Separate concerns with different instances:

```lua
instances = {
  personal = { url = "https://gitlab.com" },        -- Personal projects
  work = { url = "https://work.gitlab.com" },       -- Work code
  learning = { url = "https://gitlab.com" },        -- Learning resources
}
```

---

## Examples

### Example 1: Configuration Snippets

Store various configuration files:

```yaml
# Snippet: "GitHub Actions - Node.js CI"
name: Node.js CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm ci
      - run: npm test
```

### Example 2: Utility Functions

Keep useful functions handy:

```lua
-- Snippet: "Neovim - Safe Require"
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Failed to load: " .. module, vim.log.levels.ERROR)
    return nil
  end
  return result
end
```

### Example 3: SQL Queries

Store complex queries:

```sql
-- Snippet: "PostgreSQL - User Activity Report"
WITH user_activity AS (
  SELECT
    user_id,
    COUNT(*) as action_count,
    MAX(created_at) as last_action
  FROM user_actions
  WHERE created_at > NOW() - INTERVAL '30 days'
  GROUP BY user_id
)
SELECT
  u.username,
  ua.action_count,
  ua.last_action
FROM users u
JOIN user_activity ua ON u.id = ua.user_id
ORDER BY ua.action_count DESC
LIMIT 100;
```

### Example 4: Docker Templates

```dockerfile
# Snippet: "Docker - Node.js Multi-stage"
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

### Example 5: Git Hooks

```bash
#!/bin/sh
# Snippet: "Git Hook - Pre-commit Linting"
files=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(js|jsx|ts|tsx)$')
if [ "$files" != "" ]; then
  npm run lint $files
  if [ $? -ne 0 ]; then
    echo "Linting failed. Please fix errors before committing."
    exit 1
  fi
fi
```

---

## Troubleshooting Quick Reference

### Common Issues

| Issue               | Solution                                                |
| ------------------- | ------------------------------------------------------- |
| "Token not found"   | Set `GITLAB_SNIPPETS_TOKEN` environment variable        |
| "401 Unauthorized"  | Check token has `api` scope and hasn't expired          |
| "No snippets found" | Verify you have snippets in selected category           |
| "Connection failed" | Check network and GitLab URL                            |
| Preview not showing | Check file has proper extension for syntax highlighting |

### Health Check

Run health check for diagnostics:

```vim
:checkhealth gitlab-snippets
```

---

## Next Steps

- Read the [Configuration Guide](configuration.md) for advanced setup
- Check the [Plugin Reference](plugin-reference.md) for all commands
- See [Troubleshooting Guide](troubleshooting.md) for detailed solutions
- Join the discussion in [GitLab Issues](https://git.unhappy.computer/hase808/neovim-gitlab-snippets/issues)

---

**Last Updated:** 2025-08-09  
**Plugin Version:** v0.0.2
