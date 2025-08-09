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

## 🧪 Task 2: Minimal Testing Infrastructure

### Current State Analysis

**Testing Status:** ❌ No existing test suite
**Dependencies:** plenary.nvim (already required)
**Risk Level:** 🟢 Low - Simple infrastructure only

### Proposed Testing Architecture

#### 2.1 Testing Framework Selection

**Recommended Stack:**
- **Primary:** plenary.nvim only (minimal setup)
- **No API mocking:** Too complex for this plugin scope
- **No UI testing:** Telescope integration not worth testing complexity

#### 2.2 Minimal Test Suite Structure

```
tests/
├── minimal_init.lua     # Basic plenary setup
├── config_spec.lua      # Config parsing/validation
└── health_spec.lua      # Dependency checks
```

#### 2.3 Focused Testing Plan

**2.3.1 Configuration Module Tests (`config_spec.lua`)**

```lua
describe("gitlab-snippets.config", function()
  -- Essential tests only:
  -- ✅ Default configuration loading
  -- ✅ User configuration merging
  -- ✅ Instance retrieval by name
  -- ✅ Invalid configuration handling
end)
```

**Priority:** 🔴 High
**Coverage Target:** Basic functionality only
**Complexity:** 🟢 Low

**2.3.2 Health Check Tests (`health_spec.lua`)**

```lua
describe("gitlab-snippets.health", function()
  -- Basic dependency checks:
  -- ✅ plenary.nvim availability
  -- ✅ telescope.nvim availability
  -- ✅ Neovim version compatibility
end)
```

**Priority:** 🟡 Medium
**Coverage Target:** Basic checks only
**Complexity:** 🟢 Low

#### 2.4 Test Execution Infrastructure

**File:** `tests/minimal_init.lua`

```lua
-- Minimal Neovim configuration for testing
local plenary_dir = os.getenv("PLENARY_DIR") or "~/.local/share/nvim/lazy/plenary.nvim"
local gitlab_snippets_dir = vim.fn.getcwd()

vim.opt.rtp:prepend(plenary_dir)
vim.opt.rtp:prepend(gitlab_snippets_dir)

require("plenary.busted")
```

**Simple Makefile:**

```makefile
.PHONY: test

# Run all tests
test:
	nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

#### 2.5 Realistic Implementation Timeline

| Phase                    | Tasks                          | Duration   |
| ------------------------ | ------------------------------ | ---------- |
| **Basic Infrastructure** | Test setup, config tests      | 2 hours    |
| **Health Tests**         | Dependency validation          | 1 hour     |
| **Total**               |                                | **3 hours**|

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

