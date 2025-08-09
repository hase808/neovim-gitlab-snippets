# Changelog

All notable changes to the Neovim GitLab Snippets plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Full-text search within snippets
- Snippet editing capabilities
- Snippet creation from Neovim
- Async API requests for better performance
- Caching layer for improved speed

---

## [0.0.2] - 2025-08-09

### Added

- **Testing Infrastructure**

  - Comprehensive test suite using plenary.nvim
  - Configuration module tests with 100% coverage
  - Health check system tests
  - Automated CI/CD pipeline with GitLab CI
  - Makefile for test automation and code quality
  - Testing documentation and guidelines

- **Documentation System**

  - Complete documentation overhaul
  - API reference documentation
  - Architecture overview and design patterns
  - User guide with workflows and examples
  - Configuration guide with multiple instances
  - Developer guide for contributors
  - Troubleshooting guide with common issues
  - Plugin reference with all commands and features
  - GitLab API integration documentation

- **Code Quality Improvements**
  - Added luacheck for static analysis
  - Integrated stylua for code formatting
  - Standardized error handling patterns
  - Enhanced health check system
  - Improved code organization and modularity

### Changed

- **Health Check Enhancements**

  - More detailed dependency checking
  - Platform compatibility warnings
  - Connection testing for all instances
  - Better error messages and suggestions

- **Error Handling**

  - More descriptive error messages
  - Better context in error reporting
  - Graceful degradation for network issues
  - User-friendly troubleshooting hints

- **Code Organization**
  - Standardized module patterns
  - Consistent function signatures
  - Improved code documentation
  - Better separation of concerns

### Fixed

- Token resolution for multiple instances
- Environment variable handling edge cases
- Connection timeout handling
- Preview state management memory leaks

### Technical Debt

- **Removed Utils Module**
  - Replaced custom utility functions with Neovim built-ins
  - Used `vim.split()` instead of custom split function
  - Leveraged `vim.tbl_contains()` for table operations
  - Reduced code duplication and maintenance overhead

### Development

- **CI/CD Pipeline**

  - Automated testing on Alpine Linux
  - Code quality checks (linting and formatting)
  - Multi-stage pipeline with proper error handling
  - Integration with GitLab CI/CD

- **Development Tools**
  - Make targets for common development tasks
  - Automated test running and reporting
  - Code formatting and linting automation
  - Health check integration for debugging

---

## [0.0.1] - 2025-05-31

### Added

- **Initial Release**

  - Basic GitLab snippet integration for Neovim
  - Telescope.nvim integration for UI
  - Multi-instance GitLab support
  - Personal, public, and project snippet browsing
  - Live preview with syntax highlighting
  - Metadata view with detailed snippet information
  - Snippet insertion at cursor position
  - Open snippets in new buffers
  - Health check system for configuration validation

- **Core Features**

  - `:GitLabSnippets` command
  - Environment variable token management
  - Instance-specific token support
  - Error handling for API failures
  - Connection testing and validation

- **UI Features**

  - Telescope picker integration
  - Preview pane with syntax highlighting
  - Metadata toggle (Enter key)
  - Keyboard shortcuts (Ctrl+I, Ctrl+N)
  - Search and filtering capabilities

- **Configuration**

  - Multiple GitLab instance configuration
  - Default action settings
  - Environment variable token resolution
  - Flexible instance naming

- **Documentation**
  - Basic README with setup instructions
  - Configuration examples
  - Troubleshooting section
  - Screenshot gallery
  - Feature overview

---

## Migration Guides

### Migrating to v0.0.2

No breaking changes. All existing configurations continue to work.

**Optional Improvements:**

- Run `:checkhealth gitlab-snippets` to verify your setup
- Update documentation references to new docs structure
- Consider using instance-specific tokens for better security

### Future Migration Notes

Future versions may include:

- Configuration format changes (will be documented)
- New required dependencies (will be clearly noted)
- Breaking API changes (will follow semantic versioning)

---

## Dependencies

### Current Dependencies

| Dependency     | Minimum Version | Purpose                   |
| -------------- | --------------- | ------------------------- |
| Neovim         | 0.10.0          | Core runtime              |
| telescope.nvim | Latest          | UI framework              |
| plenary.nvim   | Latest          | Utilities and HTTP client |

### Development Dependencies

| Tool     | Purpose          | Required For |
| -------- | ---------------- | ------------ |
| luacheck | Static analysis  | Development  |
| stylua   | Code formatting  | Development  |
| make     | Build automation | Development  |

---

## Compatibility

### Neovim Versions

- **Supported:** 0.10.0+
- **Tested:** 0.10.0, 0.10.1
- **Recommended:** Latest stable

### Platform Support

| Platform       | Status                  | Notes                        |
| -------------- | ----------------------- | ---------------------------- |
| macOS ARM      | ✅ Officially Supported | Primary development platform |
| macOS Intel    | ⚠️ Should Work          | Limited testing              |
| Linux          | ⚠️ Should Work          | CI tested on Alpine          |
| Windows WSL    | ⚠️ Should Work          | Community reported           |
| Windows Native | ❓ Unknown              | Not tested                   |

---

## Contributing History

### Contributors

- **hase808** - Plugin author and primary maintainer
- Community contributors welcome!

---

**Note:** For detailed commit history, see the [Git log](https://git.unhappy.computer/hase808/neovim-gitlab-snippets/commits/main).
