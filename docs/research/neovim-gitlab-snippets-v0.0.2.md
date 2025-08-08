# Neovim GitLab Snippets v0.0.2 - Development Plan

**Target Release:** v0.0.2
**Current Version:** v0.0.1
**Planning Date:** 2025-08-08
**Status:** Planning Phase

## Executive Summary

This document outlines the development plan for v0.0.2 of the neovim-gitlab-snippets plugin, focusing on two key improvement areas identified during the comprehensive code review:

1. **Utils Module Optimization**: Leverage native Neovim built-in functions
2. **Testing Infrastructure**: Implement comprehensive test suite for reliability and maintainability

## 🎯 Objectives

### Primary Goals

- [ ] Reduce code duplication by leveraging Neovim built-ins
- [ ] Establish comprehensive testing infrastructure
- [ ] Improve code maintainability and reliability
- [ ] Enhance developer experience with automated testing

### Success Metrics

- [ ] 100% removal of redundant utility functions
- [ ] ≥80% test coverage for core functionality
- [ ] Zero breaking changes for end users
- [ ] CI/CD pipeline established with automated testing

---

## 📋 Task 1: Utils Module Optimization

### Current State Analysis

**File:** `lua/gitlab-snippets/utils.lua`

Current implementation contains custom functions that duplicate Neovim built-in functionality:

```lua
-- Current custom implementation
M.split = function(str, delimiter)
  local result = {}
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

M.contains = function(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end
```

### Proposed Changes

#### 1.1 Replace Custom Functions with Neovim Built-ins

| Current Function   | Neovim Built-in      | Status       | Risk Level |
| ------------------ | -------------------- | ------------ | ---------- |
| `utils.split()`    | `vim.split()`        | ✅ Available | 🟢 Low     |
| `utils.contains()` | `vim.tbl_contains()` | ✅ Available | 🟢 Low     |

#### 1.2 Implementation Steps

**Phase 1: Analysis & Validation**

- [ ] Audit all usage of `utils.split()` and `utils.contains()`
- [ ] Verify Neovim built-in compatibility (Neovim 0.10+)
- [ ] Create compatibility testing script
- [ ] Document API differences (if any)

**Phase 2: Gradual Migration**

- [ ] Update `picker.lua` to use `vim.split()` directly
- [ ] Update `picker.lua` to use `vim.tbl_contains()` if needed
- [ ] Replace all `require("gitlab-snippets.utils")` calls
- [ ] Maintain backward compatibility during transition

**Phase 3: Cleanup**

- [ ] Remove unused functions from `utils.lua`
- [ ] Evaluate if `utils.lua` should be removed entirely
- [ ] Update imports across all modules
- [ ] Update documentation

#### 1.3 Code Changes Required

**Files to Modify:**

- `lua/gitlab-snippets/utils.lua` - Remove redundant functions
- `lua/gitlab-snippets/picker.lua` - Update import statements
- Any other files importing utils (to be confirmed during audit)

**Example Migration:**

```lua
-- Before
local utils = require("gitlab-snippets.utils")
local lines = utils.split(content, "\n")

-- After
local lines = vim.split(content, "\n")
```

#### 1.4 Testing Strategy for Utils Migration

- [ ] Unit tests for `vim.split()` equivalency
- [ ] Unit tests for `vim.tbl_contains()` equivalency
- [ ] Integration tests to ensure no regressions
- [ ] Manual testing of all plugin functionality

#### 1.5 Estimated Timeline

| Phase                 | Duration       | Dependencies         |
| --------------------- | -------------- | -------------------- |
| Analysis & Validation | 2-3 hours      | Code review          |
| Gradual Migration     | 4-6 hours      | Testing framework    |
| Cleanup               | 1-2 hours      | Migration completion |
| **Total**             | **7-11 hours** |                      |

---

## 🧪 Task 2: Comprehensive Testing Infrastructure

### Current State Analysis

**Testing Status:** ❌ No existing test suite
**Dependencies:** plenary.nvim (already required)
**Risk Level:** 🟡 Medium - Adding new infrastructure

### Proposed Testing Architecture

#### 2.1 Testing Framework Selection

**Recommended Stack:**

- **Primary:** plenary.nvim + busted (industry standard)
- **Alternative:** vusted (if plenary integration issues)
- **Mock Library:** luassert.mock for API mocking

**Rationale:**

- plenary.nvim already required as dependency
- Established patterns in Neovim ecosystem
- Excellent mocking capabilities for HTTP requests

#### 2.2 Test Suite Structure

```
tests/
├── minimal_init.lua              # Minimal Neovim config for testing
├── fixtures/                     # Test data and mocks
│   ├── mock_api_responses.json   # GitLab API response samples
│   ├── test_configs.lua          # Various configuration scenarios
│   └── sample_snippets.lua       # Sample snippet data
├── gitlab-snippets/              # Main test modules
│   ├── api_spec.lua              # API module tests
│   ├── config_spec.lua           # Configuration tests
│   ├── health_spec.lua           # Health check tests
│   ├── picker_spec.lua           # Picker logic tests (limited)
│   └── utils_spec.lua            # Utils tests (during migration)
├── integration/                  # Integration tests
│   ├── full_workflow_spec.lua    # End-to-end scenarios
│   └── error_scenarios_spec.lua  # Error handling tests
└── helpers/                      # Test utilities
    ├── mock_gitlab.lua           # GitLab API mocking helpers
    ├── test_utils.lua            # Common test utilities
    └── assertions.lua            # Custom assertion helpers
```

#### 2.3 Detailed Testing Plan

**2.3.1 Configuration Module Tests (`config_spec.lua`)**

```lua
describe("gitlab-snippets.config", function()
  -- Test scenarios:
  -- ✅ Default configuration loading
  -- ✅ User configuration merging
  -- ✅ Deep table merging behavior
  -- ✅ Instance retrieval by name
  -- ✅ Invalid configuration handling
  -- ✅ Empty configuration scenarios
end)
```

**Priority:** 🔴 High
**Coverage Target:** 95%
**Complexity:** 🟢 Low

**2.3.2 API Module Tests (`api_spec.lua`)**

```lua
describe("gitlab-snippets.api", function()
  -- HTTP Status Code Handling:
  -- ✅ 200 - Success responses
  -- ✅ 401 - Unauthorized (invalid token)
  -- ✅ 403 - Forbidden (insufficient permissions)
  -- ✅ 404 - Resource not found
  -- ✅ 500 - Server errors
  -- ✅ Network timeouts
  -- ✅ Invalid JSON responses

  -- Token Resolution:
  -- ✅ Instance-specific tokens (GITLAB_SNIPPETS_TOKEN_INSTANCE)
  -- ✅ Fallback to generic token (GITLAB_SNIPPETS_TOKEN)
  -- ✅ Missing token scenarios

  -- API Endpoints:
  -- ✅ list_user_snippets()
  -- ✅ list_public_snippets()
  -- ✅ list_all_snippets()
  -- ✅ list_project_snippets()
  -- ✅ get_snippet_content()
  -- ✅ get_project_snippet_content()
  -- ✅ test_connection()
end)
```

**Priority:** 🔴 High
**Coverage Target:** 90%
**Complexity:** 🟡 Medium (requires HTTP mocking)

**2.3.3 Health Check Tests (`health_spec.lua`)**

```lua
describe("gitlab-snippets.health", function()
  -- Dependency Checks:
  -- ✅ plenary.nvim availability
  -- ✅ telescope.nvim availability

  -- Platform Compatibility:
  -- ✅ macOS ARM detection
  -- ✅ Unsupported OS warnings

  -- Configuration Validation:
  -- ✅ Instance configuration presence
  -- ✅ Token availability verification
  -- ✅ Connection testing integration

  -- Neovim Version:
  -- ✅ Version compatibility checks
  -- ✅ Warning for older versions
end)
```

**Priority:** 🟡 Medium
**Coverage Target:** 85%
**Complexity:** 🟢 Low

**2.3.4 Picker Logic Tests (`picker_spec.lua`)**

```lua
describe("gitlab-snippets.picker", function()
  -- Note: Limited testing due to Telescope UI complexity

  -- Helper Functions:
  -- ✅ get_snippet_type_from_url()
  -- ✅ get_snippet_content() (integration with api)
  -- ✅ get_snippet_metadata() (integration with api)
  -- ✅ format_snippet_metadata()

  -- Data Processing:
  -- ✅ Snippet type detection and marking
  -- ✅ Display name formatting
  -- ✅ Author information handling
  -- ✅ Error handling for failed API calls
end)
```

**Priority:** 🟡 Medium
**Coverage Target:** 60% (UI components excluded)
**Complexity:** 🟡 Medium (Telescope integration)

**2.3.5 Integration Tests (`integration/`)**

```lua
describe("Full Workflow Integration", function()
  -- End-to-End Scenarios:
  -- ✅ Complete setup → instance selection → snippet retrieval
  -- ✅ Multi-instance configuration handling
  -- ✅ Error recovery and user notification flows
  -- ✅ Token rotation scenarios

  -- Performance Tests:
  -- ✅ Large snippet list handling
  -- ✅ API response time tolerance
  -- ✅ Memory usage validation
end)
```

**Priority:** 🟡 Medium
**Coverage Target:** 70%
**Complexity:** 🔴 High (requires complex setup)

#### 2.4 Mock Infrastructure

**2.4.1 GitLab API Mocking Strategy**

```lua
-- helpers/mock_gitlab.lua
local M = {}

M.mock_successful_response = function(data)
  return {
    status = 200,
    body = vim.fn.json_encode(data)
  }
end

M.mock_error_response = function(status, message)
  return {
    status = status,
    body = message or ""
  }
end

M.mock_snippets_list = function(count)
  local snippets = {}
  for i = 1, count do
    table.insert(snippets, {
      id = i,
      title = "Test Snippet " .. i,
      file_name = "test" .. i .. ".lua",
      author = { name = "Test User", username = "testuser" },
      created_at = "2024-01-01T00:00:00Z"
    })
  end
  return M.mock_successful_response(snippets)
end

return M
```

**2.4.2 Environment Mocking**

```lua
-- helpers/test_utils.lua
local M = {}

M.with_env = function(env_vars, test_fn)
  -- Save current environment
  local original_env = {}
  for key, _ in pairs(env_vars) do
    original_env[key] = os.getenv(key)
  end

  -- Set test environment
  for key, value in pairs(env_vars) do
    vim.fn.setenv(key, value)
  end

  -- Run test
  local success, result = pcall(test_fn)

  -- Restore environment
  for key, value in pairs(original_env) do
    vim.fn.setenv(key, value)
  end

  if not success then
    error(result)
  end
  return result
end

return M
```

#### 2.5 Test Execution Infrastructure

**2.5.1 Test Runner Configuration**

**File:** `tests/minimal_init.lua`

```lua
-- Minimal Neovim configuration for testing
local plenary_dir = os.getenv("PLENARY_DIR") or "~/.local/share/nvim/lazy/plenary.nvim"
local gitlab_snippets_dir = vim.fn.getcwd()

vim.opt.rtp:prepend(plenary_dir)
vim.opt.rtp:prepend(gitlab_snippets_dir)

-- Load required modules
require("plenary.busted")
```

**2.5.2 Makefile Integration**

**File:** `Makefile`

```makefile
.PHONY: test test-watch test-coverage lint format

# Run all tests
test:
	nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

# Run tests with watch mode (requires entr)
test-watch:
	find lua/ tests/ -name "*.lua" | entr -c make test

# Run specific test file
test-file:
	nvim --headless -c "PlenaryBustedFile $(FILE) {minimal_init = 'tests/minimal_init.lua'}"

# Format code with stylua
format:
	stylua lua/ tests/

# Lint code
lint:
	luacheck lua/ --config .luacheckrc

# Generate test coverage (if available)
test-coverage:
	@echo "Coverage reporting not implemented yet"
```

#### 2.6 Testing Implementation Timeline

| Phase                       | Tasks                            | Duration        | Dependencies        |
| --------------------------- | -------------------------------- | --------------- | ------------------- |
| **Phase 1: Infrastructure** | Minimal test setup, basic runner | 4-6 hours       | None                |
| **Phase 2: Config Tests**   | Complete config module testing   | 3-4 hours       | Phase 1             |
| **Phase 3: API Tests**      | HTTP mocking, API endpoint tests | 8-12 hours      | Phase 1, Mock setup |
| **Phase 4: Health Tests**   | Health check validation          | 2-3 hours       | Phase 1             |
| **Phase 5: Picker Tests**   | Limited picker logic testing     | 4-6 hours       | Phase 1, API mocks  |
| **Phase 6: Integration**    | End-to-end workflow testing      | 6-8 hours       | All previous        |
| **Total**                   |                                  | **30-43 hours** |                     |

---

## 🚀 Implementation Strategy

### Development Approach

**Methodology:** Incremental Development with Continuous Testing

1. **Feature Branches:** Each task gets its own feature branch
2. **Test-Driven:** Write tests before implementing changes
3. **Backward Compatibility:** Ensure zero breaking changes
4. **Documentation:** Update docs with each change

### Branch Strategy

```
main
├── feature/utils-optimization     # Task 1: Utils module changes
├── feature/testing-infrastructure # Task 2: Test suite implementation
└── dev-v0.0.2                # Integration branch for v0.0.2
```

### Risk Mitigation

| Risk                                    | Probability | Impact | Mitigation Strategy                       |
| --------------------------------------- | ----------- | ------ | ----------------------------------------- |
| Breaking changes during utils migration | Medium      | High   | Comprehensive testing, gradual rollout    |
| Test infrastructure complexity          | Medium      | Medium | Start simple, iterate incrementally       |
| Performance regression                  | Low         | Medium | Benchmark before/after, integration tests |
| Neovim compatibility issues             | Low         | High   | Test against multiple Neovim versions     |

---

## 📊 Success Criteria & Validation

### Task 1: Utils Optimization

- [ ] All custom utility functions replaced with Neovim built-ins
- [ ] Zero functional regressions (verified by test suite)
- [ ] Code size reduction measurable
- [ ] Performance maintained or improved

### Task 2: Testing Infrastructure

- [ ] ≥80% test coverage for core modules (config, api, health)
- [ ] ≥60% test coverage for picker module
- [ ] All tests pass on Neovim 0.10.0+
- [ ] Test execution time <30 seconds for full suite

### Overall Release Goals

- [ ] Backward compatibility maintained
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Release notes prepared
- [ ] No new external dependencies

---

## 📝 Documentation Updates Required

### Files to Update

- [ ] `README.md` - Add testing section
- [ ] `docs/NOTES.md` - Update todo status
- [ ] `CHANGELOG.md` - Document v0.0.2 changes
- [ ] `CONTRIBUTING.md` - Add testing guidelines (new file)

### New Documentation

- [ ] `docs/TESTING.md` - Testing guide for contributors
- [ ] `docs/DEVELOPMENT.md` - Development setup instructions

