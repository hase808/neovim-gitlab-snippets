# Neovim GitLab Snippets Documentation

Welcome to the comprehensive documentation for the Neovim GitLab Snippets plugin. This plugin integrates GitLab code snippets directly into your Neovim workflow through the Telescope interface.

## Documentation Overview

### Getting Started

- [**User Guide**](user-guide.md) - Installation, basic usage, and features
- [**Configuration Guide**](configuration.md) - Detailed setup and configuration options
- [**Plugin Reference**](plugin-reference.md) - Commands, keybindings, and features reference

### Development

- [**Developer Guide**](development.md) - Contributing, development setup, and coding standards
- [**Architecture Overview**](architecture.md) - Plugin structure and design patterns
- [**API Documentation**](api.md) - Complete API reference for all modules
- [**Testing Documentation**](testing.md) - Test suite architecture and running tests

### Integration & Support

- [**GitLab API Integration**](gitlab-integration.md) - API endpoints and authentication
- [**Troubleshooting Guide**](troubleshooting.md) - Common issues and solutions
- [**Changelog**](CHANGELOG.md) - Version history and migration guides

## Quick Links

- [Gitlab Repository](https://git.unhappy.computer/hase808/neovim-gitlab-snippets)
- [Issue Tracker](https://git.unhappy.computer/hase808/neovim-gitlab-snippets/issues)
- [Latest Release](https://git.unhappy.computer/hase808/neovim-gitlab-snippets/releases)

## Plugin Features

- 🔐 **Multi-Instance Support** - Configure multiple GitLab instances with different access tokens
- 🔍 **Snippet Browsing** - Browse personal, public, and project snippets
- 👁️ **Live Preview** - Preview snippets before using them with syntax highlighting
- 📊 **Metadata View** - Toggle between snippet content and detailed metadata
- ⌨️ **Quick Actions** - Insert snippets directly or open in new buffers
- 🔌 **Telescope Integration** - Seamless integration with Telescope.nvim
- 🏥 **Health Checks** - Built-in health check system to verify configuration

## Requirements

- Neovim v0.10.0+
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- GitLab Personal Access Token with `api` scope

## Quick Start

1. Install the plugin using your preferred package manager
2. Configure your GitLab instances in your Neovim configuration
3. Set up your GitLab Personal Access Token as an environment variable
4. Run `:GitLabSnippets` to start browsing snippets

For detailed instructions, see the [User Guide](user-guide.md).

## Documentation Version

**Plugin Version:** v0.0.2
**Documentation Last Updated:** 2025-08-09
**Neovim Compatibility:** v0.10.0+

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.

