.PHONY: help test test-config test-health test-all format lint lint-strict check-format ci

# Default target shows help
.DEFAULT_GOAL := help

# Show help information
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

# Run all tests
test: ## Run all tests
	@echo "Running all tests..."
	@nvim --headless --noplugin -u tests/minimal_init.lua -c "lua require('plenary.busted').run('tests/config_spec.lua')" -c "quit"
	@nvim --headless --noplugin -u tests/minimal_init.lua -c "lua require('plenary.busted').run('tests/health_spec.lua')" -c "quit"

# Run config tests only
test-config: ## Run configuration module tests only
	@echo "Running config tests..."
	@nvim --headless --noplugin -u tests/minimal_init.lua -c "lua require('plenary.busted').run('tests/config_spec.lua')" -c "quit"

# Run health tests only  
test-health: ## Run health check tests only
	@echo "Running health tests..."
	@nvim --headless --noplugin -u tests/minimal_init.lua -c "lua require('plenary.busted').run('tests/health_spec.lua')" -c "quit"

# Run all tests with verbose output
test-all: ## Run all tests with verbose output
	@echo "Running all tests with verbose output..."
	@nvim --headless --noplugin -u tests/minimal_init.lua -c "lua require('plenary.busted').run('tests/', {verbose=true})" -c "quit"

# Format Lua code using stylua
format: ## Format Lua code with stylua
	@echo "Formatting Lua code with stylua..."
	@which stylua > /dev/null || (echo "stylua not found. Install with: cargo install stylua" && exit 1)
	@stylua lua/ tests/ --check || (echo "Running stylua formatter..." && stylua lua/ tests/)

# Check if code is formatted
check-format: ## Check code formatting without modifying files
	@echo "Checking code formatting..."
	@which stylua > /dev/null || (echo "stylua not found. Install with: cargo install stylua" && exit 1)
	@stylua lua/ tests/ --check

# Lint Lua code using luacheck (warnings only)
lint: ## Lint Lua code with luacheck (warnings only)
	@echo "Linting Lua code with luacheck..."
	@which luacheck > /dev/null || (echo "luacheck not found. Install with: luarocks install luacheck" && exit 1)
	@luacheck lua/ tests/ --globals vim || true

# Lint Lua code strictly (fail on warnings)
lint-strict: ## Lint Lua code strictly (fail on warnings)
	@echo "Linting Lua code strictly with luacheck..."
	@which luacheck > /dev/null || (echo "luacheck not found. Install with: luarocks install luacheck" && exit 1)
	@luacheck lua/ tests/ --globals vim

# Run all CI checks
ci: test lint-strict check-format ## Run all CI checks (tests, linting, formatting)
	@echo "All CI checks passed!"