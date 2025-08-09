# Testing Documentation

Comprehensive guide to testing the Neovim GitLab Snippets plugin.

## Table of Contents

- [Testing Overview](#testing-overview)
- [Test Environment Setup](#test-environment-setup)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [Test Structure](#test-structure)
- [Testing Patterns](#testing-patterns)
- [CI/CD Testing](#cicd-testing)
- [Manual Testing](#manual-testing)
- [Coverage Goals](#coverage-goals)

---

## Testing Overview

### Testing Stack

- **Framework:** [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) busted
- **Runner:** Neovim headless mode
- **CI/CD:** GitLab CI with Alpine Linux
- **Tools:** luacheck (linting), stylua (formatting)

### Test Philosophy

1. **Focused Testing:** Test core functionality, not UI
2. **Isolation:** Each test should be independent
3. **Simplicity:** Avoid complex mocking when possible
4. **Reliability:** Tests should be deterministic
5. **Speed:** Keep test suite fast (<30 seconds)

### Current Test Coverage

| Module     | Coverage | Priority | Notes                    |
| ---------- | -------- | -------- | ------------------------ |
| config.lua | 100%     | High     | Configuration management |
| health.lua | 100%     | Medium   | Health check validation  |
| api.lua    | 0%       | Low      | External dependency      |
| picker.lua | 0%       | Low      | UI component             |
| init.lua   | 0%       | Low      | Simple orchestration     |

---

## Test Environment Setup

### Prerequisites

```bash
# Install Neovim
brew install neovim  # macOS
sudo apt install neovim  # Ubuntu/Debian

# Install test dependencies
git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/test/start/plenary.nvim
```

### Test File Structure

```
tests/
├── minimal_init.lua     # Test environment configuration
├── config_spec.lua      # Configuration module tests
├── health_spec.lua      # Health check tests
└── fixtures/           # Test fixtures (if needed)
    └── test_data.lua
```

### Minimal Init Configuration

```lua
-- tests/minimal_init.lua
-- Set up minimal Neovim environment for testing

-- Add plenary to runtime path
local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
vim.opt.rtp:prepend(plenary_dir)

-- Add plugin to runtime path
local plugin_dir = vim.fn.getcwd()
vim.opt.rtp:prepend(plugin_dir)

-- Minimal configuration
vim.cmd("runtime plugin/plenary.vim")
vim.o.swapfile = false
vim.bo.swapfile = false

-- Load plenary busted
require("plenary.busted")
```

---

## Running Tests

### Using Make Commands

```bash
# Run all tests
make test

# Run specific test file
make test-config    # Run config tests only
make test-health    # Run health tests only

# Run with verbose output
make test-all

# Run full CI suite
make ci            # Runs linting, formatting, and tests
```

### Manual Test Execution

```bash
# Run all tests
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/')" \
  -c "quit"

# Run specific test file
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/config_spec.lua')" \
  -c "quit"

# Run with debugging output
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "lua require('plenary.busted').run('tests/', {verbose=true})" \
  -c "quit"
```

### Interactive Testing

```lua
-- Start Neovim with test environment
nvim -u tests/minimal_init.lua

-- In Neovim, run tests interactively
:lua require('plenary.busted').run('tests/')
```

---

## Writing Tests

### Test File Template

```lua
-- tests/module_spec.lua
describe("module_name", function()
    -- Setup and teardown
    before_each(function()
        -- Reset state before each test
    end)

    after_each(function()
        -- Cleanup after each test
    end)

    -- Group related tests
    describe("function_name", function()
        it("should do expected behavior", function()
            -- Arrange
            local input = "test"

            -- Act
            local result = module.function(input)

            -- Assert
            assert.are.equal("expected", result)
        end)

        it("should handle edge cases", function()
            -- Test edge cases
        end)

        it("should handle errors gracefully", function()
            -- Test error conditions
        end)
    end)
end)
```

### Assertion Types

```lua
-- Equality assertions
assert.are.equal(expected, actual)
assert.are.same(expected_table, actual_table)  -- Deep equality

-- Boolean assertions
assert.is_true(value)
assert.is_false(value)
assert.is_nil(value)
assert.is_not_nil(value)

-- Type assertions
assert.is_table(value)
assert.is_string(value)
assert.is_number(value)
assert.is_function(value)

-- Error assertions
assert.has_error(function() error("test") end)
assert.has_no.errors(function() return true end)

-- Spy assertions (for mocking)
assert.spy(my_spy).was_called()
assert.spy(my_spy).was_called_with("arg1", "arg2")
```

### Example: Configuration Tests

```lua
-- tests/config_spec.lua
local config = require("gitlab-snippets.config")

describe("gitlab-snippets.config", function()
    before_each(function()
        -- Reset config before each test
        config.options = {}
    end)

    describe("setup", function()
        it("should load default configuration when no options provided", function()
            config.setup()

            assert.are.same({
                instances = {},
                default_action = "insert",
            }, config.options)
        end)

        it("should merge user configuration with defaults", function()
            local user_opts = {
                instances = {
                    gitlab_com = {
                        url = "https://gitlab.com",
                    },
                },
                default_action = "new_file",
            }

            config.setup(user_opts)

            assert.are.equal("new_file", config.options.default_action)
            assert.are.same(user_opts.instances, config.options.instances)
        end)

        it("should preserve defaults when user provides partial config", function()
            local user_opts = {
                instances = {
                    gitlab_com = { url = "https://gitlab.com" },
                },
            }

            config.setup(user_opts)

            assert.are.equal("insert", config.options.default_action)
            assert.are.same(user_opts.instances, config.options.instances)
        end)
    end)

    describe("get_instance", function()
        it("should return nil for non-existent instance", function()
            config.setup()

            local instance = config.get_instance("non_existent")

            assert.is_nil(instance)
        end)

        it("should return correct instance configuration", function()
            config.setup({
                instances = {
                    gitlab_com = { url = "https://gitlab.com" },
                    work = { url = "https://work.gitlab.com" },
                },
            })

            local instance = config.get_instance("work")

            assert.are.same({ url = "https://work.gitlab.com" }, instance)
        end)
    end)
end)
```

---

## Test Structure

### Organization Principles

1. **One spec file per module**

   - `config_spec.lua` → `config.lua`
   - `health_spec.lua` → `health.lua`

2. **Nested describe blocks**

   - Top level: Module name
   - Second level: Function/feature name
   - Third level: Specific scenarios

3. **Descriptive test names**
   - Start with "should"
   - Describe expected behavior
   - Be specific about conditions

### Test Data Management

```lua
-- tests/fixtures/test_data.lua
local M = {}

M.sample_snippet = {
    id = 12345,
    title = "Test Snippet",
    file_name = "test.lua",
    description = "A test snippet",
    author = {
        name = "Test User",
        username = "testuser",
    },
    created_at = "2024-01-01T00:00:00Z",
    updated_at = "2024-01-01T00:00:00Z",
}

M.sample_instance = {
    url = "https://gitlab.example.com",
}

return M
```

### Mocking Strategies

```lua
-- Mock external dependencies
describe("with mocked dependencies", function()
    local original_curl

    before_each(function()
        -- Save original
        original_curl = package.loaded["plenary.curl"]

        -- Create mock
        package.loaded["plenary.curl"] = {
            get = function()
                return {
                    status = 200,
                    body = '{"test": "data"}',
                }
            end,
        }
    end)

    after_each(function()
        -- Restore original
        package.loaded["plenary.curl"] = original_curl
    end)

    it("should handle mocked response", function()
        -- Test with mock
    end)
end)
```

---

## Testing Patterns

### Pattern 1: State Reset

```lua
describe("stateful module", function()
    local original_state

    before_each(function()
        -- Save original state
        original_state = vim.deepcopy(module.state)
    end)

    after_each(function()
        -- Restore original state
        module.state = original_state
    end)

    -- Tests that modify state
end)
```

### Pattern 2: Environment Variables

```lua
describe("environment-dependent tests", function()
    local original_env

    before_each(function()
        original_env = os.getenv("GITLAB_SNIPPETS_TOKEN")
        -- Set test environment
        vim.fn.setenv("GITLAB_SNIPPETS_TOKEN", "test-token")
    end)

    after_each(function()
        -- Restore environment
        if original_env then
            vim.fn.setenv("GITLAB_SNIPPETS_TOKEN", original_env)
        else
            vim.fn.setenv("GITLAB_SNIPPETS_TOKEN", "")
        end
    end)

    it("should read token from environment", function()
        -- Test environment-dependent behavior
    end)
end)
```

### Pattern 3: Error Testing

```lua
describe("error handling", function()
    it("should handle nil input gracefully", function()
        assert.has_no.errors(function()
            module.function(nil)
        end)
    end)

    it("should return error for invalid input", function()
        local result, err = module.function("invalid")
        assert.is_nil(result)
        assert.is_string(err)
        assert.are.equal("Expected error message", err)
    end)

    it("should throw error for critical failure", function()
        assert.has_error(function()
            module.critical_function("bad_input")
        end, "Critical error message")
    end)
end)
```

### Pattern 4: Async Testing

```lua
describe("async operations", function()
    it("should handle async operations", function()
        local done = false
        local result

        module.async_function(function(res)
            result = res
            done = true
        end)

        -- Wait for async operation
        vim.wait(1000, function()
            return done
        end)

        assert.is_not_nil(result)
        assert.are.equal("expected", result)
    end)
end)
```

---

## CI/CD Testing

### GitLab CI Configuration

```yaml
# .gitlab-ci.yml
stages:
  - lint
  - test
  - release

variables:
  GIT_SUBMODULE_STRATEGY: recursive

lint:
  stage: lint
  image: alpine:latest
  before_script:
    - apk add --no-cache make gcc musl-dev lua5.3 lua5.3-dev luarocks5.3 git cargo
    - luarocks-5.3 install luacheck
    - cargo install stylua --locked
    - export PATH="$PATH:$HOME/.cargo/bin"
  script:
    - make lint-strict
    - make check-format

test:
  stage: test
  image: alpine:latest
  before_script:
    - apk add --no-cache neovim git make
    - git clone --depth 1 https://github.com/nvim-lua/plenary.nvim /tmp/plenary.nvim
  script:
    - make test
  artifacts:
    reports:
      junit: test-results.xml
```

### Local CI Testing

```bash
# Run CI checks locally before pushing
make ci

# Individual CI steps
make lint-strict     # Linting
make check-format    # Format checking
make test           # Test suite
```

---

## Manual Testing

### Test Checklist

#### Installation Testing

- [ ] Fresh installation with lazy.nvim
- [ ] Fresh installation with packer.nvim
- [ ] Upgrade from previous version
- [ ] Dependency resolution

#### Configuration Testing

- [ ] Single instance configuration
- [ ] Multiple instance configuration
- [ ] Token from environment variable
- [ ] Instance-specific tokens
- [ ] Invalid configuration handling

#### Feature Testing

- [ ] Browse personal snippets
- [ ] Browse public snippets
- [ ] Browse project snippets
- [ ] Preview snippet content
- [ ] Toggle metadata view
- [ ] Insert snippet at cursor
- [ ] Open snippet in buffer
- [ ] Syntax highlighting in preview

#### Error Handling

- [ ] Missing token
- [ ] Invalid token
- [ ] Network errors
- [ ] Empty snippet lists
- [ ] Invalid GitLab URL

#### Health Check

- [ ] All checks pass with valid config
- [ ] Appropriate warnings for issues
- [ ] Clear error messages

### Manual Test Script

```lua
-- manual_test.lua
-- Run with: nvim -u manual_test.lua

-- Load plugin
vim.opt.rtp:prepend(".")
vim.opt.rtp:prepend("path/to/plenary.nvim")
vim.opt.rtp:prepend("path/to/telescope.nvim")

-- Configure
require("gitlab-snippets").setup({
    instances = {
        test = { url = "https://gitlab.com" }
    }
})

-- Set test token
vim.fn.setenv("GITLAB_SNIPPETS_TOKEN", "your-test-token")

-- Run health check
vim.cmd("checkhealth gitlab-snippets")

-- Test commands
vim.cmd("GitLabSnippets")
```

---

## Coverage Goals

### Current Coverage

| Module     | Lines | Functions | Branches | Overall |
| ---------- | ----- | --------- | -------- | ------- |
| config.lua | 100%  | 100%      | 100%     | 100%    |
| health.lua | 85%   | 100%      | 75%      | 87%     |
| api.lua    | 0%    | 0%        | 0%       | 0%      |
| picker.lua | 0%    | 0%        | 0%       | 0%      |
| init.lua   | 0%    | 0%        | 0%       | 0%      |

### Target Coverage

- **Core Modules (config, health):** ≥90%
- **API Module:** ≥60% (with mocking)
- **UI Modules (picker):** ≥40%
- **Overall:** ≥70%

### Coverage Improvement Plan

1. **Phase 1:** Core module coverage (completed)
2. **Phase 2:** API module with mocking
3. **Phase 3:** Integration tests
4. **Phase 4:** UI component testing

### Measuring Coverage

```bash
# Install coverage tool
luarocks install luacov

# Run tests with coverage
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "lua require('luacov')" \
  -c "lua require('plenary.busted').run('tests/')" \
  -c "quit"

# Generate report
luacov

# View report
cat luacov.report.out
```

---

## Best Practices

### Do's

1. **Write tests first** for bug fixes
2. **Keep tests simple** and focused
3. **Use descriptive names** for tests
4. **Test edge cases** and error conditions
5. **Mock external dependencies** when needed
6. **Clean up after tests** (restore state)
7. **Group related tests** in describe blocks

### Don'ts

1. **Don't test implementation details**
2. **Don't create interdependent tests**
3. **Don't test external libraries**
4. **Don't ignore flaky tests**
5. **Don't skip error cases**
6. **Don't hardcode paths or values**
7. **Don't test UI interactions directly**

### Test Quality Checklist

- [ ] Test has clear purpose
- [ ] Test name describes what it tests
- [ ] Test is independent
- [ ] Test is deterministic
- [ ] Test includes assertions
- [ ] Test handles cleanup
- [ ] Test is maintainable

---

## Troubleshooting Tests

### Common Issues

#### Tests Not Running

```bash
# Check plenary is installed
ls ~/.local/share/nvim/site/pack/test/start/plenary.nvim

# Check test file syntax
nvim tests/config_spec.lua
:lua require('plenary.busted').run('tests/config_spec.lua')
```

#### Environment Issues

```bash
# Set PLENARY_DIR if needed
export PLENARY_DIR=~/.local/share/nvim/site/pack/test/start/plenary.nvim
make test
```

#### Assertion Failures

```lua
-- Add debugging output
it("should work", function()
    local result = module.function()
    print(vim.inspect(result))  -- Debug output
    assert.are.equal("expected", result)
end)
```

---

**Last Updated:** 2025-08-09  
**Plugin Version:** v0.0.2
