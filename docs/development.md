# Developer Guide

This guide covers development setup, contribution guidelines, and best practices for the Neovim GitLab Snippets plugin.

## Table of Contents

- [Development Environment](#development-environment)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Testing](#testing)
- [CI/CD Pipeline](#cicd-pipeline)
- [Contributing](#contributing)
- [Release Process](#release-process)
- [Debugging](#debugging)

---

## Development Environment

### Prerequisites

- **Neovim:** v0.10.0 or higher
- **Git:** For version control
- **Make:** For running build tasks
- **Lua:** Understanding of Lua 5.1
- **Docker:** For CI/CD testing (optional)

### Required Tools

#### For Development

```bash
# macOS
brew install neovim
brew install luarocks

# Ubuntu/Debian
sudo apt install neovim
sudo apt install luarocks

# Arch Linux
sudo pacman -S neovim
sudo pacman -S luarocks
```

#### For Code Quality

```bash
# Install stylua (Lua formatter)
cargo install stylua --locked

# Install luacheck (Lua linter)
luarocks install luacheck
```

### Recommended Tools

- **IDE/Editor:** Neovim with LSP support
- **Git GUI:** GitLab Web IDE, tig, or lazygit
- **Testing:** plenary.nvim test runner

---

## Project Structure

```
neovim-gitlab-snippets/
├── .gitlab-ci.yml          # CI/CD configuration
├── LICENSE                  # MIT License
├── Makefile                # Build automation
├── README.md               # User documentation
├── RELEASE_NOTES.md        # Release notes
├── assets/                 # Images and media
│   ├── Logo.png
│   ├── instance.png
│   ├── neovim-gitlab-snippets.gif
│   ├── options.png
│   └── snippets.png
├── docs/                   # Documentation
│   ├── NOTES.md           # Development notes
│   ├── research/          # Research documents
│   └── *.md               # Documentation files
├── lua/
│   ├── gitlab-snippets/   # Main plugin code
│   │   ├── api.lua        # GitLab API client
│   │   ├── config.lua     # Configuration module
│   │   ├── health.lua     # Health checks
│   │   ├── init.lua       # Entry point
│   │   └── picker.lua     # Telescope integration
│   └── telescope/
│       └── _extensions/
│           └── gitlab_snippets.lua  # Telescope extension
└── tests/                  # Test suite
    ├── config_spec.lua     # Configuration tests
    ├── health_spec.lua     # Health check tests
    └── minimal_init.lua    # Test environment

```

### Module Descriptions

- **init.lua:** Plugin entry point, command registration
- **config.lua:** Configuration management and defaults
- **api.lua:** GitLab API client implementation
- **picker.lua:** Telescope UI and interaction logic
- **health.lua:** Diagnostic and validation system

---

## Getting Started

### 1. Fork and Clone

```bash
# Fork the repository on GitLab
# Clone your fork
git clone https://git.unhappy.computer/YOUR_USERNAME/neovim-gitlab-snippets.git
cd neovim-gitlab-snippets
```

### 2. Set Up Development Branch

```bash
# Add upstream remote
git remote add upstream https://git.unhappy.computer/hase808/neovim-gitlab-snippets.git

# Create development branch
git checkout -b feature/your-feature-name
```

### 3. Install Dependencies

```bash
# Install Neovim plugins for testing
git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
git clone https://github.com/nvim-telescope/telescope.nvim ~/.local/share/nvim/site/pack/vendor/start/telescope.nvim
```

### 4. Set Up Test Environment

```bash
# Create test configuration
cat > test_init.lua << 'EOF'
vim.opt.rtp:prepend(".")
vim.opt.rtp:prepend("~/.local/share/nvim/site/pack/vendor/start/plenary.nvim")
vim.opt.rtp:prepend("~/.local/share/nvim/site/pack/vendor/start/telescope.nvim")

require("gitlab-snippets").setup({
  instances = {
    test = { url = "https://gitlab.com" }
  }
})
EOF

# Test the plugin
nvim -u test_init.lua
```

---

## Development Workflow

### Branch Strategy

```
main                    # Stable release branch
├── dev-v0.0.2         # Development integration branch
├── feature/*          # Feature branches
├── bugfix/*           # Bug fix branches
└── hotfix/*           # Emergency fixes
```

### Workflow Steps

1. **Create Feature Branch**

   ```bash
   git checkout -b feature/add-search-function
   ```

2. **Make Changes**

   - Write code following style guidelines
   - Add/update tests
   - Update documentation

3. **Test Locally**

   ```bash
   # Run tests
   make test

   # Check formatting
   make check-format

   # Run linter
   make lint
   ```

4. **Commit Changes**

   ```bash
   git add .
   git commit -m "feat: add search function for snippets"
   ```

5. **Push and Create MR**
   ```bash
   git push origin feature/add-search-function
   # Create merge request on GitLab
   ```

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `chore:` Maintenance tasks

**Examples:**

```bash
feat(picker): add search functionality
fix(api): handle 404 errors properly
docs: update installation instructions
test(config): add edge case tests
```

---

## Code Style

### Lua Style Guide

#### General Rules

1. **Indentation:** Use tabs (Neovim standard)
2. **Line Length:** Max 120 characters
3. **Naming Conventions:**
   - `snake_case` for functions and variables
   - `UPPER_CASE` for constants
   - Descriptive names over abbreviations

#### Code Formatting

```lua
-- Good
local function fetch_snippet_content(instance_name, snippet_id)
    local content, err = api.get_snippet_content(instance_name, snippet_id)
    if not content then
        return nil, err
    end
    return content
end

-- Bad
local function fsc(i,s)
    local c,e=api.get_snippet_content(i,s)
    if not c then return nil,e end
    return c
end
```

#### Module Structure

```lua
-- Standard module pattern
local M = {}

-- Private variables
local private_var = "value"

-- Private functions
local function private_function()
    -- Implementation
end

-- Public functions
function M.public_function()
    -- Implementation
end

-- Return module
return M
```

### Formatting Tools

#### Using stylua

Configuration in `.stylua.toml`:

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Tabs"
indent_width = 4
quote_style = "AutoPreferDouble"
```

Run formatter:

```bash
# Check formatting
make check-format

# Auto-format
make format
```

#### Using luacheck

Configuration in `.luacheckrc`:

```lua
globals = { "vim" }
max_line_length = 120
```

Run linter:

```bash
# Run with warnings
make lint

# Run strict (fail on warnings)
make lint-strict
```

---

## Testing

### Test Structure

```
tests/
├── minimal_init.lua    # Test environment setup
├── config_spec.lua     # Configuration tests
└── health_spec.lua     # Health check tests
```

### Writing Tests

#### Test File Structure

```lua
-- tests/example_spec.lua
describe("module_name", function()
    before_each(function()
        -- Setup before each test
    end)

    after_each(function()
        -- Cleanup after each test
    end)

    describe("function_name", function()
        it("should do something", function()
            -- Test implementation
            assert.are.equal(expected, actual)
        end)

        it("should handle errors", function()
            -- Error case testing
            assert.has_error(function()
                -- Code that should error
            end)
        end)
    end)
end)
```

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
make test-config

# Run with verbose output
make test-all

# Run tests manually
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/config_spec.lua')" \
  -c "quit"
```

### Test Coverage

Current test coverage targets:

- Configuration module: 100%
- Health checks: 100%
- API module: 0% (external dependency)
- Picker module: 0% (UI component)

---

## CI/CD Pipeline

### Pipeline Stages

```yaml
stages:
  - lint # Code quality checks
  - test # Run test suite
  - release # Create releases
```

### CI Jobs

#### Lint Job

- Runs luacheck for static analysis
- Checks code formatting with stylua
- Fails on any violations

#### Test Job

- Sets up test environment
- Runs full test suite
- Reports test results

### Running CI Locally

```bash
# Run all CI checks
make ci

# Individual checks
make lint-strict
make check-format
make test
```

---

## Contributing

### Before Contributing

1. **Check existing issues** for similar features/bugs
2. **Discuss major changes** in an issue first
3. **Follow the code style** guidelines
4. **Write tests** for new functionality
5. **Update documentation** as needed

### Contribution Process

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Add tests**
5. **Update documentation**
6. **Run CI checks locally**
7. **Submit a merge request**

### Merge Request Guidelines

#### Title Format

```
<type>(<scope>): <description>
```

#### Description Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Tests pass locally
- [ ] Added new tests
- [ ] Updated existing tests

## Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

### Code Review Process

1. **Automated checks** must pass
2. **Peer review** by maintainer
3. **Testing** in different environments
4. **Documentation review**
5. **Merge** to development branch

---

## Release Process

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR:** Breaking changes
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes

### Release Steps

1. **Update Version**

   ```lua
   -- In relevant files
   local VERSION = "0.0.2"
   ```

2. **Update Documentation**

   - Update CHANGELOG.md
   - Update README.md version
   - Update docs with new features

3. **Create Release Notes**

   ```markdown
   # Release v0.0.2

   ## Features

   - Feature 1
   - Feature 2

   ## Fixes

   - Fix 1
   - Fix 2

   ## Breaking Changes

   - None
   ```

4. **Tag Release**

   ```bash
   git tag -a v0.0.2 -m "Release version 0.0.2"
   git push origin v0.0.2
   ```

5. **Create GitLab Release**
   - Use GitLab UI
   - Attach release notes
   - Mark as latest release

---

## Debugging

### Debug Logging

```lua
-- Add debug prints
local function debug_log(msg)
    if vim.g.gitlab_snippets_debug then
        print("[GitLab Snippets Debug]: " .. msg)
    end
end

-- Enable debug mode
vim.g.gitlab_snippets_debug = true
```

### Common Debugging Commands

```vim
" Check plugin is loaded
:lua print(vim.inspect(package.loaded["gitlab-snippets"]))

" Inspect configuration
:lua print(vim.inspect(require("gitlab-snippets.config").options))

" Test API connection
:lua print(vim.inspect(require("gitlab-snippets.api").test_connection("primary")))

" Run health check
:checkhealth gitlab-snippets
```

### Using Neovim's Built-in Debugger

```lua
-- Add breakpoint
require("gitlab-snippets.api").get_snippet_content = function(...)
    vim.api.nvim_echo({{"Breakpoint hit!", "WarningMsg"}}, true, {})
    -- Original function
end
```

### Performance Profiling

```lua
-- Profile function execution
local function profile(fn, name)
    return function(...)
        local start = vim.loop.hrtime()
        local result = {fn(...)}
        local duration = (vim.loop.hrtime() - start) / 1000000
        print(string.format("%s took %.2fms", name, duration))
        return unpack(result)
    end
end

-- Use profiler
api.list_user_snippets = profile(api.list_user_snippets, "list_user_snippets")
```

---

## Best Practices

### Code Quality

1. **Write self-documenting code**
2. **Keep functions small and focused**
3. **Handle errors gracefully**
4. **Add comments for complex logic**
5. **Use meaningful variable names**

### Testing

1. **Write tests before fixing bugs**
2. **Test edge cases**
3. **Keep tests independent**
4. **Use descriptive test names**
5. **Mock external dependencies**

### Documentation

1. **Update docs with code changes**
2. **Include examples**
3. **Keep README current**
4. **Document breaking changes**
5. **Add inline documentation**

### Security

1. **Never log sensitive data**
2. **Validate all inputs**
3. **Handle tokens securely**
4. **Follow least privilege principle**
5. **Review dependencies**

---

## Resources

### Documentation

- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [Telescope.nvim Docs](https://github.com/nvim-telescope/telescope.nvim)
- [Plenary.nvim Docs](https://github.com/nvim-lua/plenary.nvim)
- [GitLab API Docs](https://docs.gitlab.com/ee/api/)

### Tools

- [stylua](https://github.com/JohnnyMorganz/StyLua)
- [luacheck](https://github.com/mpeterv/luacheck)
- [Neovim LSP](https://neovim.io/doc/user/lsp.html)

### Community

- [Neovim Matrix](https://matrix.to/#/#neovim:matrix.org)
- [Neovim Discourse](https://neovim.discourse.group/)
- [GitLab Issues](https://git.unhappy.computer/hase808/neovim-gitlab-snippets/issues)

---

**Last Updated:** 2025-08-09  
**Plugin Version:** v0.0.2
