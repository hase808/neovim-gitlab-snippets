# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the Neovim GitLab Snippets plugin.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Common Issues](#common-issues)
- [Authentication Problems](#authentication-problems)
- [Connection Issues](#connection-issues)
- [Configuration Problems](#configuration-problems)
- [Plugin Not Working](#plugin-not-working)
- [Performance Issues](#performance-issues)
- [UI/Display Issues](#uidisplay-issues)
- [Debugging Techniques](#debugging-techniques)
- [Getting Help](#getting-help)

---

## Quick Diagnostics

### Run Health Check First

Always start with the health check:

```vim
:checkhealth gitlab-snippets
```

This will check:

- ✓ Dependencies installed
- ✓ Configuration valid
- ✓ Tokens available
- ✓ Connection to GitLab
- ✓ Platform compatibility

### Quick Fix Checklist

1. [ ] Token is set in environment variable
2. [ ] Token has `api` scope
3. [ ] GitLab URL is correct
4. [ ] Network connection is working
5. [ ] Dependencies are installed
6. [ ] Plugin is loaded correctly

---

## Common Issues

### Issue: "No GitLab instances configured"

**Symptoms:**

- Error when running `:GitLabSnippets`
- Health check shows no instances

**Solution:**

```lua
-- Add to your Neovim config
require("gitlab-snippets").setup({
  instances = {
    primary = { url = "https://gitlab.com" }
  }
})
```

### Issue: "Token not found for instance"

**Symptoms:**

- Error message about missing token
- Cannot fetch snippets

**Solutions:**

1. **Set default token:**

   ```bash
   export GITLAB_SNIPPETS_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
   ```

2. **Set instance-specific token:**

   ```bash
   export GITLAB_SNIPPETS_TOKEN_PRIMARY="glpat-xxxxxxxxxxxxxxxxxxxx"
   ```

3. **Verify token is set:**
   ```bash
   echo $GITLAB_SNIPPETS_TOKEN
   echo $GITLAB_SNIPPETS_TOKEN_PRIMARY
   ```

### Issue: "Command not found: GitLabSnippets"

**Symptoms:**

- Command doesn't exist
- Tab completion doesn't work

**Solutions:**

1. **Ensure plugin is loaded:**

   ```vim
   :lua print(package.loaded["gitlab-snippets"])
   ```

2. **Manually load plugin:**

   ```vim
   :lua require("gitlab-snippets").setup({})
   ```

3. **Check plugin installation:**
   ```vim
   :PackerStatus  " or :Lazy depending on package manager
   ```

### Issue: "No snippets found"

**Symptoms:**

- Empty list when browsing
- No errors but no results

**Solutions:**

1. **Verify you have snippets:**

   - Log into GitLab web interface
   - Check snippets exist in selected category

2. **Check token permissions:**

   - Token needs `api` scope
   - For private snippets, token must be from correct user

3. **Try different snippet types:**
   - Personal vs Public vs Project snippets

---

## Authentication Problems

### 401 Unauthorized Error

**Symptoms:**

```
Failed to fetch snippets: 401: Unauthorized.
Please check your GitLab token and its permissions (api scope).
```

**Causes:**

1. Token is invalid or expired
2. Token lacks required scope
3. Token is for wrong GitLab instance

**Solutions:**

1. **Generate new token:**

   - GitLab → User Settings → Access Tokens
   - Create token with `api` scope
   - Update environment variable

2. **Verify token scope:**

   ```bash
   # Test token with curl
   curl -H "PRIVATE-TOKEN: your-token" \
     https://gitlab.com/api/v4/user
   ```

3. **Check token expiration:**
   - Tokens expire on set date
   - Generate new token if expired

### 403 Forbidden Error

**Symptoms:**

```
Failed to fetch snippets: 403: Forbidden.
You might not have access to this resource.
```

**Causes:**

1. Insufficient permissions
2. Admin endpoints without admin rights
3. Private resources without access

**Solutions:**

1. **Check resource access:**

   - Verify you have access in GitLab UI
   - For project snippets, check project membership

2. **Use appropriate snippet type:**
   - Don't use "All Snippets" without admin
   - Use "Your Snippets" for personal items

---

## Connection Issues

### Network Connection Failed

**Symptoms:**

```
Failed to connect to GitLab instance
Connection test failed with status: 0
```

**Causes:**

1. Network connectivity issues
2. Firewall blocking connection
3. Proxy configuration needed
4. GitLab instance down

**Solutions:**

1. **Test network connectivity:**

   ```bash
   # Ping GitLab server
   ping gitlab.com

   # Test HTTPS connection
   curl -I https://gitlab.com
   ```

2. **Check firewall:**

   ```bash
   # Check if port 443 is open
   nc -zv gitlab.com 443
   ```

3. **Configure proxy (if needed):**

   ```bash
   export HTTP_PROXY="http://proxy.company.com:8080"
   export HTTPS_PROXY="http://proxy.company.com:8080"
   ```

4. **Verify GitLab URL:**
   ```lua
   -- Check configuration
   :lua print(vim.inspect(require("gitlab-snippets.config").options))
   ```

### SSL Certificate Issues

**Symptoms:**

- SSL verification errors
- Certificate warnings

**Solutions:**

1. **Update CA certificates:**

   ```bash
   # macOS
   brew install ca-certificates

   # Linux
   sudo update-ca-certificates
   ```

2. **For self-signed certificates:**
   ```bash
   # Add certificate to trust store
   export SSL_CERT_FILE=/path/to/cert.pem
   ```

---

## Configuration Problems

### Multiple Instances Not Working

**Symptoms:**

- Only one instance appears
- Wrong instance being used

**Solutions:**

1. **Verify configuration:**

   ```lua
   require("gitlab-snippets").setup({
     instances = {
       personal = { url = "https://gitlab.com" },
       work = { url = "https://gitlab.work.com" }
     }
   })
   ```

2. **Check instance-specific tokens:**
   ```bash
   export GITLAB_SNIPPETS_TOKEN_PERSONAL="token1"
   export GITLAB_SNIPPETS_TOKEN_WORK="token2"
   ```

### Configuration Not Loading

**Symptoms:**

- Default settings being used
- Custom settings ignored

**Solutions:**

1. **Ensure setup is called:**

   ```lua
   -- Must call setup with config
   require("gitlab-snippets").setup({
     -- your config here
   })
   ```

2. **Check load order:**

   - Setup must be called after plugin loads
   - Use `config` function in package manager

3. **Verify no syntax errors:**
   ```vim
   :lua require("gitlab-snippets").setup({ instances = { test = { url = "https://gitlab.com" }}})
   ```

---

## Plugin Not Working

### Dependencies Missing

**Symptoms:**

```
plenary.nvim is required but not installed
telescope.nvim is required but not installed
```

**Solutions:**

1. **Install dependencies:**

   ```lua
   -- lazy.nvim
   {
     "plugin-url",
     dependencies = {
       "nvim-lua/plenary.nvim",
       "nvim-telescope/telescope.nvim",
     }
   }
   ```

2. **Manual installation:**

   ```bash
   git clone https://github.com/nvim-lua/plenary.nvim \
     ~/.local/share/nvim/site/pack/deps/start/plenary.nvim

   git clone https://github.com/nvim-telescope/telescope.nvim \
     ~/.local/share/nvim/site/pack/deps/start/telescope.nvim
   ```

### Neovim Version Issues

**Symptoms:**

- Plugin features not working
- Unexpected errors

**Solutions:**

1. **Check Neovim version:**

   ```vim
   :version
   ```

2. **Update Neovim:**

   ```bash
   # macOS
   brew upgrade neovim

   # Linux
   sudo apt update && sudo apt upgrade neovim
   ```

3. **Minimum version: v0.10.0**

---

## Performance Issues

### Slow Snippet Loading

**Symptoms:**

- Long delay fetching snippets
- UI freezes during loading

**Causes:**

1. Large number of snippets
2. Slow network connection
3. GitLab API rate limiting

**Solutions:**

1. **Check network speed:**

   ```bash
   # Time API request
   time curl -H "PRIVATE-TOKEN: token" \
     https://gitlab.com/api/v4/snippets
   ```

2. **Reduce snippet count:**

   - Use specific snippet types
   - Organize with projects

3. **Check rate limits:**
   ```bash
   # Check rate limit headers
   curl -I -H "PRIVATE-TOKEN: token" \
     https://gitlab.com/api/v4/snippets | grep RateLimit
   ```

### Memory Usage

**Symptoms:**

- Neovim using excessive memory
- Slowdown over time

**Solutions:**

1. **Clear preview state:**

   ```lua
   -- Restart plugin
   :lua package.loaded["gitlab-snippets"] = nil
   :lua require("gitlab-snippets").setup({})
   ```

2. **Limit snippet fetching:**
   - Don't repeatedly fetch large lists
   - Close picker when not needed

---

## UI/Display Issues

### Preview Not Showing

**Symptoms:**

- Empty preview window
- No syntax highlighting

**Solutions:**

1. **Check file extension:**

   - Snippets need file extension for highlighting
   - Update snippet filename in GitLab

2. **Verify content fetching:**
   ```lua
   :lua local api = require("gitlab-snippets.api")
   :lua print(api.get_snippet_content("primary", 123))
   ```

### Telescope Errors

**Symptoms:**

- Picker doesn't open
- Telescope-related errors

**Solutions:**

1. **Verify Telescope installation:**

   ```vim
   :Telescope
   ```

2. **Load extension manually:**

   ```lua
   :lua require("telescope").load_extension("gitlab_snippets")
   ```

3. **Check for conflicts:**
   - Disable other Telescope extensions
   - Check for keybinding conflicts

---

## Debugging Techniques

### Enable Debug Mode

```lua
-- Add to your config
vim.g.gitlab_snippets_debug = true

-- Or create debug wrapper
local function debug_wrapper()
  vim.g.gitlab_snippets_debug = true
  require("gitlab-snippets").pick_instance()
  vim.g.gitlab_snippets_debug = false
end
```

### Inspect Internal State

```lua
-- Check configuration
:lua print(vim.inspect(require("gitlab-snippets.config").options))

-- Test API directly
:lua local api = require("gitlab-snippets.api")
:lua print(vim.inspect(api.list_instances()))
:lua print(vim.inspect(api.test_connection("primary")))

-- Check specific snippet
:lua print(vim.inspect(api.get_snippet("primary", 12345)))
```

### Log API Requests

```lua
-- Monkey-patch for debugging
local original_request = require("gitlab-snippets.api").request
require("gitlab-snippets.api").request = function(...)
  print("API Request:", vim.inspect({...}))
  local result, err = original_request(...)
  print("API Response:", vim.inspect(result or err))
  return result, err
end
```

### Test in Minimal Environment

Create `minimal_test.vim`:

```vim
set nocompatible
set runtimepath^=~/.local/share/nvim/site/pack/*/start/*
set runtimepath^=.

lua << EOF
require("gitlab-snippets").setup({
  instances = {
    test = { url = "https://gitlab.com" }
  }
})
EOF
```

Run:

```bash
nvim -u minimal_test.vim
```

---

## Getting Help

### Before Asking for Help

1. **Run health check:**

   ```vim
   :checkhealth gitlab-snippets
   ```

2. **Collect information:**

   - Neovim version: `:version`
   - Plugin version: Check git tag/commit
   - Error messages: Full text
   - Configuration: Your setup code

3. **Try minimal config:**
   - Test with minimal setup
   - Isolate the issue

### Where to Get Help

1. **GitHub Issues:**

   - [Issue Tracker](https://git.unhappy.computer/hase808/neovim-gitlab-snippets/issues)
   - Search existing issues first
   - Provide minimal reproduction

2. **Issue Template:**

   ````markdown
   **Environment:**

   - Neovim version:
   - Plugin version:
   - OS:

   **Configuration:**

   ```lua
   -- Your config here
   ```
   ````

   **Steps to reproduce:**

   1.
   2.

   **Expected behavior:**

   **Actual behavior:**

   **Error messages:**

   ```

   ```

3. **Community:**
   - Neovim Discord/Matrix
   - Reddit r/neovim
   - Stack Overflow

### Common Solutions Summary

| Problem           | Quick Solution                         |
| ----------------- | -------------------------------------- |
| No token          | `export GITLAB_SNIPPETS_TOKEN="token"` |
| 401 Error         | Generate new token with `api` scope    |
| No snippets       | Check you have snippets in GitLab      |
| Plugin not found  | Reinstall with dependencies            |
| Connection failed | Check network and GitLab URL           |
| Slow performance  | Use specific snippet types             |
| Preview issues    | Add file extensions to snippets        |

---

## Emergency Fixes

### Complete Reset

```bash
# 1. Remove plugin
rm -rf ~/.local/share/nvim/site/pack/*/start/neovim-gitlab-snippets

# 2. Clear cache
rm -rf ~/.cache/nvim/gitlab-snippets

# 3. Reinstall
# Use your package manager to reinstall

# 4. Basic config
cat > ~/.config/nvim/plugin/gitlab-snippets.lua << EOF
require("gitlab-snippets").setup({
  instances = {
    primary = { url = "https://gitlab.com" }
  }
})
EOF

# 5. Set token
export GITLAB_SNIPPETS_TOKEN="your-token"

# 6. Test
nvim -c "checkhealth gitlab-snippets"
```

---

**Last Updated:** 2025-08-09  
**Plugin Version:** v0.0.2
