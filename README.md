# Neovim GitLab Snippets

![Logo](Logo.png)

A Neovim plugin that allows you to browse, preview, and insert GitLab code snippets directly from within Neovim. This plugin integrates with Telescope to provide a seamless UI experience.

## Features

- Configure multiple GitLab instances with different access tokens
- Browse your personal, public, or all snippets
- Preview snippets before using them
- Insert snippets at cursor position
- Open snippets in new buffers
- Full Telescope integration
- Health check to verify configuration

## Requirements

- Neovim v0.10.0+
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- macOS ARM (officially supported, may work on other platforms)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yourusername/neovim-gitlab-snippets",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("gitlab-snippets").setup({
      instances = {
        primary = { url = "https://gitlab.com" },
        work = { url = "https://gitlab.mycompany.com" },
      },
      default_action = "insert", -- or "new_file"
    })
  end,
}
```

## Configuration

The plugin requires a GitLab Personal Access Token to be set in an environment variable:
    - `GITLAB_SNIPPETS_TOKEN`: Default token used for all instances
    - `GITLAB_SNIPPETS_TOKEN_PRIMARY`: Token for the instance named "primary"
    - `GITLAB_SNIPPETS_TOKEN_WORK`: Token for the instance named "work"

Each token should have the api scope to access snippets.

## Usage

### Commands

- `:GitLabSnippets`: Open the Telescope picker to browse GitLab instances and snippets

### Telescope Integration

You can also access the plugin through Telescope:
```txt
:Telescope gitlab_snippets
```

### Workflow

1. Run `:GitLabSnippets` to open the Telescope picker
2. Select a GitLab instance
3. Choose the type of snippets you want to browse (personal, public, all)
4. Select a snippet from the list
5. Choose what to do with the snippet (preview, insert, open in new buffer)

### Health Checks

Run `:checkhealth gitlab-snippets` to verify that:

- All required dependencies are installed
- GitLab instances are configured correctly
- Access tokens are available
- Connections to GitLab instances work

## Troubleshooting

### Token Issues

If you encounter authentication errors, make sure your token:

- Is correctly set in the environment variable
- Has not expired
- Has the correct `api` scope

### Connection Problems

If you can't connect to GitLab:

- Verify your network connection
- Check that the GitLab instance URL is correct
- Ensure your token has the correct permissions
