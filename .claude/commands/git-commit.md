---
description: Create a commit message for the current staged changes. Don't commit anything just display the commit message.
allowed-tools: Read(*), Bash(git status), Bash(git diff), Bash(git log)
---
# Git Commit

## Commit Message Guidelines

### 1. Use Conventional Commit Format

```
type(scope): description

[optional body]

[optional footer(s)]
```

### 2. Commit Types

- **feat**: New features or enhancements
- **fix**: Bug fixes
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semi-colons, etc.)
- **refactor**: Code refactoring without changing functionality
- **test**: Adding or updating tests
- **chore**: Build process, dependency updates, tooling changes
- **perf**: Performance improvements
- **ci**: CI/CD configuration changes
- **build**: Changes to build system or external dependencies

### 3. Scope Examples

- **api**: API-related changes
- **auth**: Authentication/authorization
- **ui**: User interface components
- **db**: Database changes
- **config**: Configuration files
- **utils**: Utility functions
- **routes**: Routing logic
- **middleware**: Middleware functions

### 4. Best Practices

**Subject Line:**

- Keep under 50 characters
- Use imperative mood ("Add" not "Added" or "Adds")
- No period at the end
- Capitalize first letter

**Body (when needed):**

- Wrap at 72 characters
- Explain WHY, not WHAT
- Separate from subject with blank line

**Footer:**

- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: description`

### 5. Examples

**Simple changes:**

```
feat(auth): add JWT token validation
fix(api): resolve null pointer in user lookup
docs(readme): update installation instructions
```

**With body:**

```
feat(dashboard): add real-time metrics display

Implements WebSocket connection for live data updates.
Improves user experience by showing current system status
without requiring page refreshes.

Fixes #234
```

**Breaking change:**

```
feat(api): restructure user endpoint responses

BREAKING CHANGE: User API now returns nested objects instead
of flat structure. Update client code accordingly.

Closes #456
```

### 6. Multi-file Change Strategy

- Focus on the primary purpose of the change
- Use the most significant component as scope
- Mention other changes in body if needed

### 7. Common Patterns

```
feat(ui): add dark mode toggle
fix(auth): prevent duplicate session creation
refactor(utils): extract common validation logic
test(api): add integration tests for user endpoints
chore(deps): update React to v18
perf(db): optimize user query with indexes
ci(github): add automated testing workflow
```
