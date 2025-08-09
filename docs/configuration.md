# Configuration Guide

This guide covers all configuration options for the Neovim GitLab Snippets plugin.

## Table of Contents

- [Quick Start](#quick-start)
- [Installation](#installation)
- [Basic Configuration](#basic-configuration)
- [Environment Variables](#environment-variables)
- [Multiple Instances](#multiple-instances)
- [Advanced Configuration](#advanced-configuration)
- [Token Management](#token-management)
- [Troubleshooting Configuration](#troubleshooting-configuration)

---

## Quick Start

### Minimal Configuration

```lua
-- Using lazy.nvim
{
  "https://git.unhappy.computer/hase808/neovim-gitlab-snippets",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
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

### Environment Setup

```bash
# Add to your shell configuration (.bashrc, .zshrc, etc.)
export GITLAB_SNIPPETS_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
```

---

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "https://git.unhappy.computer/hase808/neovim-gitlab-snippets",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("gitlab-snippets").setup({
      -- Your configuration here
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "https://git.unhappy.computer/hase808/neovim-gitlab-snippets",
  requires = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("gitlab-snippets").setup({
      -- Your configuration here
    })
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'https://git.unhappy.computer/hase808/neovim-gitlab-snippets'

" In your init.vim, after plug#end()
lua << EOF
require("gitlab-snippets").setup({
  -- Your configuration here
})
EOF
```

---

## Basic Configuration

### Configuration Structure

```lua
require("gitlab-snippets").setup({
  -- GitLab instances configuration
  instances = {
    -- Instance identifier (used for token lookup)
    primary = {
      -- GitLab instance URL
      url = "https://gitlab.com"
    }
  },

  -- Default action when selecting a snippet
  default_action = "insert"  -- "insert" or "new_file"
})
```

### Configuration Options

#### `instances` (table)

Define one or more GitLab instances to connect to.

**Structure:**

```lua
instances = {
  [instance_name] = {
    url = "GitLab instance URL"
  }
}
```

**Example:**

```lua
instances = {
  primary = { url = "https://gitlab.com" },
  work = { url = "https://gitlab.mycompany.com" },
  personal = { url = "https://git.example.org" }
}
```

#### `default_action` (string)

Default action when selecting a snippet without using specific keybindings.

**Values:**

- `"insert"` - Insert snippet at cursor position (default)
- `"new_file"` - Open snippet in a new buffer

**Example:**

```lua
default_action = "new_file"
```

---

## Environment Variables

### Token Configuration

The plugin uses environment variables to securely store GitLab Personal Access Tokens.

#### Default Token

Used for all instances unless an instance-specific token is defined:

```bash
export GITLAB_SNIPPETS_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
```

#### Instance-Specific Tokens

Override the default token for specific instances:

```bash
# Token for instance named "primary"
export GITLAB_SNIPPETS_TOKEN_PRIMARY="glpat-yyyyyyyyyyyyyyyyyyyy"

# Token for instance named "work"
export GITLAB_SNIPPETS_TOKEN_WORK="glpat-zzzzzzzzzzzzzzzzzzzz"
```

**Naming Convention:**

- `GITLAB_SNIPPETS_TOKEN_` + uppercase instance name
- Example: Instance `work` → `GITLAB_SNIPPETS_TOKEN_WORK`

### Creating a GitLab Personal Access Token

1. Log into your GitLab instance
2. Navigate to **User Settings** → **Access Tokens**
3. Click **Add new token**
4. Configure the token:
   - **Token name:** `neovim-gitlab-snippets`
   - **Expiration date:** Choose based on your security policy
   - **Scopes:** Select `api` (required)
5. Click **Create personal access token**
6. Copy the token immediately (it won't be shown again)

### Token Security Best Practices

1. **Never commit tokens to version control**

   ```bash
   # Add to .gitignore
   .env
   .env.local
   ```

2. **Use a password manager or secure storage**

   ```bash
   # Store in a secure file
   echo "export GITLAB_SNIPPETS_TOKEN='token'" >> ~/.env.private
   # Source it in your shell config
   source ~/.env.private
   ```

3. **Set appropriate file permissions**

   ```bash
   chmod 600 ~/.env.private
   ```

4. **Use different tokens for different instances**
   - Limits exposure if one token is compromised
   - Allows instance-specific permissions

---

## Multiple Instances

### Configuration Example

```lua
require("gitlab-snippets").setup({
  instances = {
    -- Public GitLab
    gitlab_com = {
      url = "https://gitlab.com"
    },

    -- Company GitLab
    work = {
      url = "https://gitlab.company.com"
    },

    -- Self-hosted GitLab
    personal = {
      url = "https://git.mydomain.com"
    },

    -- Development instance
    dev = {
      url = "https://gitlab-dev.company.com"
    }
  }
})
```

### Environment Variables for Multiple Instances

```bash
# ~/.bashrc or ~/.zshrc

# Default token (fallback for all instances)
export GITLAB_SNIPPETS_TOKEN="glpat-default-token"

# Instance-specific tokens
export GITLAB_SNIPPETS_TOKEN_GITLAB_COM="glpat-gitlab-com-token"
export GITLAB_SNIPPETS_TOKEN_WORK="glpat-work-token"
export GITLAB_SNIPPETS_TOKEN_PERSONAL="glpat-personal-token"
export GITLAB_SNIPPETS_TOKEN_DEV="glpat-dev-token"
```

### Token Resolution Order

1. Check for instance-specific token (`GITLAB_SNIPPETS_TOKEN_<INSTANCE>`)
2. Fall back to default token (`GITLAB_SNIPPETS_TOKEN`)
3. Error if no token found

---

## Advanced Configuration

### Complete Configuration Example

```lua
-- ~/.config/nvim/lua/plugins/gitlab-snippets.lua

return {
  "https://git.unhappy.computer/hase808/neovim-gitlab-snippets",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  -- Lazy loading
  cmd = { "GitLabSnippets" },

  -- Keybindings
  keys = {
    { "<leader>gs", "<cmd>GitLabSnippets<cr>", desc = "GitLab Snippets" },
  },

  config = function()
    require("gitlab-snippets").setup({
      instances = {
        -- Production instances
        gitlab = {
          url = "https://gitlab.com"
        },
        github = {
          url = "https://gitlab.github.com"  -- GitHub's GitLab instance
        },

        -- Work instances
        work_prod = {
          url = "https://gitlab.company.com"
        },
        work_staging = {
          url = "https://gitlab-staging.company.com"
        },

        -- Personal instances
        personal = {
          url = "https://git.mydomain.com"
        }
      },

      -- Open snippets in new buffer by default
      default_action = "new_file"
    })
  end,
}
```

### Integration with Telescope

```lua
-- Add to Telescope configuration
require("telescope").setup({
  extensions = {
    gitlab_snippets = {
      -- Telescope-specific options can go here
    }
  }
})

-- Load the extension
require("telescope").load_extension("gitlab_snippets")

-- Create a keybinding
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope gitlab_snippets<cr>", { desc = "GitLab Snippets" })
```

### Custom Keybindings

```lua
-- Global keybinding for quick access
vim.keymap.set("n", "<leader>gs", "<cmd>GitLabSnippets<cr>", { desc = "Browse GitLab Snippets" })

-- Direct access to specific instance
vim.keymap.set("n", "<leader>gw", function()
  require("gitlab-snippets.picker").pick_snippet_type("work")
end, { desc = "Work GitLab Snippets" })

-- Direct access to personal snippets
vim.keymap.set("n", "<leader>gp", function()
  require("gitlab-snippets.picker").pick_user_snippets("gitlab")
end, { desc = "Personal GitLab Snippets" })
```

---

## Token Management

### Using direnv for Project-Specific Tokens

Create `.envrc` in your project:

```bash
# .envrc
export GITLAB_SNIPPETS_TOKEN_WORK="project-specific-token"
```

Install and configure direnv:

```bash
# Install direnv
brew install direnv  # macOS
sudo apt install direnv  # Ubuntu/Debian

# Add to shell
eval "$(direnv hook zsh)"  # or bash

# Allow the .envrc file
direnv allow
```

### Using 1Password CLI

```bash
# Store token in 1Password
op item create --category=password \
  --title="GitLab Snippets Token" \
  --vault="Development" \
  password="glpat-xxxxxxxxxxxxxxxxxxxx"

# In your shell config
export GITLAB_SNIPPETS_TOKEN="$(op read 'op://Development/GitLab Snippets Token/password')"
```

### Using pass (Password Store)

```bash
# Store token
pass insert development/gitlab-snippets-token

# In your shell config
export GITLAB_SNIPPETS_TOKEN="$(pass development/gitlab-snippets-token)"
```

---

## Troubleshooting Configuration

### Verify Configuration

Run the health check:

```vim
:checkhealth gitlab-snippets
```

### Common Issues

#### 1. Token Not Found

**Error:** "Token not found for instance: work"

**Solution:**

```bash
# Check environment variable is set
echo $GITLAB_SNIPPETS_TOKEN_WORK

# If empty, set it
export GITLAB_SNIPPETS_TOKEN_WORK="your-token-here"
```

#### 2. Invalid Token

**Error:** "401: Unauthorized. Please check your GitLab token"

**Solution:**

1. Verify token has `api` scope
2. Check token hasn't expired
3. Ensure token is for the correct GitLab instance

#### 3. Instance Not Configured

**Error:** "Instance not found: work"

**Solution:**

```lua
-- Add instance to configuration
require("gitlab-snippets").setup({
  instances = {
    work = { url = "https://gitlab.company.com" }
  }
})
```

#### 4. Connection Failed

**Error:** "Failed to connect to GitLab instance"

**Solution:**

1. Check network connectivity
2. Verify GitLab URL is correct
3. Check for proxy configuration
4. Ensure GitLab instance is accessible

### Debug Configuration

```lua
-- Print current configuration
:lua print(vim.inspect(require("gitlab-snippets.config").options))

-- Test specific instance
:lua print(vim.inspect(require("gitlab-snippets.api").test_connection("primary")))
```

---

## Best Practices

1. **Use Instance-Specific Tokens**

   - Better security isolation
   - Easier to revoke/rotate
   - Clear audit trail

2. **Set Token Expiration**

   - Use reasonable expiration dates
   - Set calendar reminders for renewal
   - Document renewal process

3. **Organize Instances Logically**

   - Group by purpose (work, personal, oss)
   - Use descriptive names
   - Document instance purposes

4. **Secure Token Storage**

   - Never hardcode tokens
   - Use encrypted storage when possible
   - Restrict file permissions

5. **Regular Health Checks**
   - Run `:checkhealth` after configuration changes
   - Verify all instances are accessible
   - Test after token renewal

---

## Configuration Schema Reference

```lua
{
  -- Required: Instance configurations
  instances = {
    [string] = {  -- Instance identifier
      url = string  -- Required: GitLab URL
    }
  },

  -- Optional: Default snippet action
  default_action = "insert" | "new_file"  -- Default: "insert"
}
```

---

**Last Updated:** 2025-08-09  
**Plugin Version:** v0.0.2
