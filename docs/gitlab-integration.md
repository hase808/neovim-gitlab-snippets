# GitLab API Integration

Detailed documentation of how the Neovim GitLab Snippets plugin integrates with the GitLab API.

## Table of Contents

- [GitLab API Overview](#gitlab-api-overview)
- [Authentication](#authentication)
- [Supported Endpoints](#supported-endpoints)
- [Rate Limiting](#rate-limiting)
- [Error Handling](#error-handling)
- [Data Formats](#data-formats)
- [Version Compatibility](#version-compatibility)
- [Security Considerations](#security-considerations)
- [Performance Optimization](#performance-optimization)

---

## GitLab API Overview

### API Version

The plugin uses **GitLab API v4**, the current stable version.

- **Base URL Format:** `{instance_url}/api/v4/`
- **Documentation:** [GitLab API Docs](https://docs.gitlab.com/ee/api/)
- **Authentication:** Personal Access Token via `PRIVATE-TOKEN` header

### Supported GitLab Types

| GitLab Type   | Support Level | Notes                    |
| ------------- | ------------- | ------------------------ |
| GitLab.com    | ✓ Full        | Primary testing platform |
| GitLab CE/EE  | ✓ Full        | Self-hosted instances    |
| GitLab SaaS   | ✓ Full        | Cloud instances          |
| Legacy GitLab | ⚠️ Limited    | May work with API v4     |

---

## Authentication

### Personal Access Token

The plugin uses GitLab Personal Access Tokens for authentication.

#### Token Requirements

- **Scope:** `api` (required for full functionality)
- **Format:** `glpat-` followed by 20 characters
- **Expiration:** Set according to your security policy

#### Token Creation

1. **GitLab.com/Instance → User Settings → Access Tokens**
2. **Token Name:** `neovim-gitlab-snippets`
3. **Expiration:** Choose based on security policy
4. **Scopes:** Select `api`
5. **Create token and copy immediately**

#### Authentication Headers

```http
PRIVATE-TOKEN: glpat-xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json
```

### Token Security

- Tokens are stored in environment variables
- Never logged or displayed in error messages
- Transmitted only via HTTPS
- Instance-specific tokens supported for isolation

---

## Supported Endpoints

### User Information

#### GET /api/v4/user

**Purpose:** Connection testing and user verification

**Usage:**

```http
GET {instance_url}/api/v4/user
PRIVATE-TOKEN: glpat-xxxxxxxxxxxxxxxxxxxx
```

**Response:**

```json
{
  "id": 123,
  "username": "john_doe",
  "name": "John Doe",
  "email": "john@example.com",
  "state": "active"
}
```

**Plugin Usage:** Health check connection testing

### Personal Snippets

#### GET /api/v4/snippets

**Purpose:** Fetch user's personal snippets

**Parameters:**

- `per_page`: Number of results (default: 20, max: 100)
- `page`: Page number (default: 1)
- `order_by`: Sort field (`created_at`, `updated_at`, `title`)
- `sort`: Sort direction (`asc`, `desc`)

**Example:**

```http
GET {instance_url}/api/v4/snippets?per_page=50&order_by=updated_at&sort=desc
```

**Response:** Array of snippet objects (see [Data Formats](#data-formats))

### Public Snippets

#### GET /api/v4/snippets/public

**Purpose:** Fetch all public snippets from the instance

**Parameters:** Same as personal snippets

**Access Level:** Any authenticated user

**Usage:** Discover public code snippets

### All Snippets (Admin)

#### GET /api/v4/snippets/all

**Purpose:** Fetch all snippets (admin only)

**Requirements:**

- Admin privileges on the GitLab instance
- Will return 403 Forbidden for non-admin users

**Use Case:** Administrative overview, auditing

### Single Snippet Metadata

#### GET /api/v4/snippets/{id}

**Purpose:** Get detailed metadata for a specific snippet

**Parameters:**

- `{id}`: Snippet ID

**Response:** Complete snippet object with all metadata

### Snippet Content

#### GET /api/v4/snippets/{id}/raw

**Purpose:** Get raw content of a snippet

**Parameters:**

- `{id}`: Snippet ID

**Response:** Plain text content of the snippet file

**Content-Type:** `text/plain`

### Projects

#### GET /api/v4/projects

**Purpose:** List projects accessible to the user

**Parameters:**

- `membership`: Only projects user is member of (`true`)
- `simple`: Return basic project info (`false`)
- `per_page`: Results per page (max: 100)
- `archived`: Include archived projects (`false`)

**Usage:** Browse projects for project snippets

### Project Snippets

#### GET /api/v4/projects/{id}/snippets

**Purpose:** List snippets from a specific project

**Parameters:**

- `{id}`: Project ID
- Standard pagination parameters

**Access:** Requires project access

### Project Snippet Details

#### GET /api/v4/projects/{id}/snippets/{snippet_id}

**Purpose:** Get metadata for a project snippet

**Parameters:**

- `{id}`: Project ID
- `{snippet_id}`: Snippet ID

### Project Snippet Content

#### GET /api/v4/projects/{id}/snippets/{snippet_id}/raw

**Purpose:** Get raw content of a project snippet

**Parameters:**

- `{id}`: Project ID
- `{snippet_id}`: Snippet ID

---

## Rate Limiting

### GitLab.com Rate Limits

| Endpoint Type | Limit | Window   | Scope       |
| ------------- | ----- | -------- | ----------- |
| API Requests  | 2,000 | 1 minute | Per user    |
| Raw Content   | 300   | 1 minute | Per project |

### Rate Limit Headers

GitLab returns rate limit information in response headers:

```http
RateLimit-Limit: 2000
RateLimit-Observed: 1
RateLimit-Remaining: 1999
RateLimit-Reset: 2024-01-01T00:01:00Z
RateLimit-ResetTime: 60
```

### Plugin Rate Limiting Strategy

1. **No Background Requests:** Only fetch on user demand
2. **Single Request Model:** One request per user action
3. **No Automatic Retries:** Fail fast with clear error messages
4. **Pagination Awareness:** Default to reasonable page sizes

### Handling Rate Limits

When rate limited (HTTP 429):

```json
{
  "message": "429 Too Many Requests",
  "documentation_url": "https://docs.gitlab.com/ee/api/#rate-limits"
}
```

**Plugin Response:**

- Display clear error message to user
- Include retry time if available
- Don't automatically retry

---

## Error Handling

### HTTP Status Codes

#### 200 OK

- Successful request
- Standard response for GET requests

#### 401 Unauthorized

**Causes:**

- Invalid token
- Expired token
- Token without required scope

**Plugin Response:**

```
Failed to fetch snippets: 401: Unauthorized.
Please check your GitLab token and its permissions (api scope).
```

#### 403 Forbidden

**Causes:**

- Insufficient permissions
- Accessing admin endpoints without admin rights
- Private resources without access

**Plugin Response:**

```
Failed to fetch snippets: 403: Forbidden.
You might not have access to this resource or the token lacks necessary scopes.
```

#### 404 Not Found

**Causes:**

- Snippet doesn't exist
- Project doesn't exist
- Resource was deleted

**Plugin Response:**

```
Failed to fetch snippet content: 404: Resource not found.
Please check the URL or snippet ID.
```

#### 500 Internal Server Error

**Causes:**

- GitLab server issues
- Temporary service problems

**Plugin Response:**

```
Failed to fetch snippets: 500: Internal Server Error on GitLab.
Please try again later.
```

### Error Response Format

GitLab API errors typically follow this format:

```json
{
  "message": "404 Project Not Found",
  "documentation_url": "https://docs.gitlab.com/ee/api/"
}
```

### Plugin Error Processing

1. **Status Code Analysis:** Check HTTP status first
2. **Body Parsing:** Extract error message from JSON
3. **User-Friendly Messages:** Convert technical errors to actionable messages
4. **Context Addition:** Include relevant details (instance, snippet ID)

---

## Data Formats

### Snippet Object

```json
{
  "id": 12345,
  "title": "My Useful Snippet",
  "file_name": "example.lua",
  "description": "A helpful code snippet for...",
  "author": {
    "id": 123,
    "name": "John Doe",
    "username": "johndoe",
    "email": "john@example.com",
    "state": "active",
    "avatar_url": "https://gitlab.com/uploads/user/avatar/123/avatar.png"
  },
  "created_at": "2024-01-01T10:00:00.000Z",
  "updated_at": "2024-01-15T14:30:00.000Z",
  "project_id": null,
  "web_url": "https://gitlab.com/snippets/12345",
  "raw_url": "https://gitlab.com/snippets/12345/raw",
  "ssh_url_to_repo": "git@gitlab.com:snippets/12345.git",
  "http_url_to_repo": "https://gitlab.com/snippets/12345.git",
  "visibility": "private",
  "imported": false,
  "imported_from": null
}
```

### Project Object

```json
{
  "id": 12345,
  "name": "my-project",
  "name_with_namespace": "username/my-project",
  "path": "my-project",
  "path_with_namespace": "username/my-project",
  "description": "Project description here",
  "created_at": "2024-01-01T00:00:00.000Z",
  "updated_at": "2024-01-15T00:00:00.000Z",
  "default_branch": "main",
  "avatar_url": null,
  "web_url": "https://gitlab.com/username/my-project",
  "archived": false,
  "visibility": "private"
}
```

### User Object

```json
{
  "id": 123,
  "username": "johndoe",
  "name": "John Doe",
  "email": "john@example.com",
  "state": "active",
  "avatar_url": "https://gitlab.com/uploads/user/avatar/123/avatar.png",
  "web_url": "https://gitlab.com/johndoe",
  "created_at": "2023-01-01T00:00:00.000Z",
  "bio": null,
  "location": null,
  "public_email": "",
  "skype": "",
  "linkedin": "",
  "twitter": "",
  "organization": ""
}
```

---

## Version Compatibility

### GitLab Versions

| GitLab Version | API v4 | Plugin Status   | Notes           |
| -------------- | ------ | --------------- | --------------- |
| 16.x           | ✓      | ✅ Fully Tested | Current stable  |
| 15.x           | ✓      | ✅ Supported    | Well tested     |
| 14.x           | ✓      | ✅ Supported    | Tested          |
| 13.x           | ✓      | ⚠️ Should Work  | Limited testing |
| 12.x           | ✓      | ❓ Unknown      | End of life     |

### API Version History

- **API v4:** Current (GitLab 9.0+)
- **API v3:** Deprecated (removed in GitLab 11.0)

### Feature Compatibility

| Feature           | GitLab Version | Notes                   |
| ----------------- | -------------- | ----------------------- |
| Personal Snippets | 9.0+           | Core feature            |
| Public Snippets   | 9.0+           | Core feature            |
| Project Snippets  | 9.0+           | Core feature            |
| Admin Snippets    | 9.0+           | Requires admin          |
| Snippet Files     | 10.0+          | Multi-file snippets     |
| Visibility Levels | 9.0+           | Public/Internal/Private |

---

## Security Considerations

### Token Security

1. **Transmission:** Always HTTPS
2. **Storage:** Environment variables only
3. **Scope:** Minimal required (`api`)
4. **Rotation:** Regular token renewal
5. **Isolation:** Instance-specific tokens

### Data Privacy

1. **No Persistent Storage:** No caching of snippet content
2. **No Telemetry:** No usage tracking
3. **Memory Management:** Clear sensitive data after use
4. **Error Handling:** No token exposure in errors

### Network Security

1. **Certificate Validation:** Full SSL/TLS verification
2. **Timeout Handling:** Reasonable request timeouts
3. **No Plain HTTP:** Force HTTPS for all requests

### Access Control

1. **Token Permissions:** Respect GitLab permissions
2. **Visibility Levels:** Honor snippet visibility
3. **Project Access:** Respect project membership

---

## Performance Optimization

### Request Optimization

1. **Pagination:** Use reasonable page sizes (20-50)
2. **Selective Fields:** Request only needed data
3. **Single Requests:** One API call per operation
4. **Connection Reuse:** HTTP keep-alive

### Caching Strategy

1. **No Persistent Cache:** Always fresh data
2. **Session Cache:** Preview state only
3. **Memory Management:** Clear after operations

### Network Efficiency

1. **Concurrent Requests:** None (simple sequential)
2. **Request Size:** Minimize payload
3. **Compression:** Let HTTP client handle
4. **Timeouts:** Reasonable defaults

### User Experience

1. **Loading States:** Show progress where possible
2. **Error Recovery:** Clear error messages
3. **Responsive UI:** Don't block Neovim
4. **Fast Access:** Direct keyboard shortcuts

---

## Testing Integration

### Connection Testing

```lua
-- Test basic connectivity
local success, err = api.test_connection("instance_name")
if not success then
  print("Connection failed: " .. err)
end
```

### API Testing

```bash
# Manual API testing
export GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"

# Test user endpoint
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  https://gitlab.com/api/v4/user | jq

# Test snippets
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  https://gitlab.com/api/v4/snippets | jq
```

### Mock Testing

For testing without real GitLab API:

```lua
-- Mock curl for testing
package.loaded["plenary.curl"] = {
  get = function(opts)
    return {
      status = 200,
      body = '{"id": 123, "title": "Test Snippet"}'
    }
  end
}
```

---

**Last Updated:** 2025-08-09  
**Plugin Version:** v0.0.2  
**GitLab API Version:** v4
