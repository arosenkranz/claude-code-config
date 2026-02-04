# Node/TypeScript MCP Server Implementation Guide

## Quick Reference

### Key Imports
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import express from "express";
import { z } from "zod";
```

### Server Initialization
```typescript
const server = new McpServer({
  name: "service-mcp-server",
  version: "1.0.0"
});
```

### Tool Registration Pattern
```typescript
server.registerTool(
  "tool_name",
  {
    title: "Tool Display Name",
    description: "What the tool does",
    inputSchema: { param: z.string() },
    outputSchema: { result: z.string() }
  },
  async ({ param }) => {
    const output = { result: `Processed: ${param}` };
    return {
      content: [{ type: "text", text: JSON.stringify(output) }],
      structuredContent: output
    };
  }
);
```

---

## Server Naming Convention

Node/TypeScript MCP servers must follow this naming pattern:
- **Format**: `{service}-mcp-server` (lowercase with hyphens)
- **Examples**: `github-mcp-server`, `jira-mcp-server`, `stripe-mcp-server`

## Project Structure

```
{service}-mcp-server/
├── package.json
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts          # Main entry point
│   ├── types.ts          # TypeScript type definitions
│   ├── tools/            # Tool implementations
│   ├── services/         # API clients and utilities
│   ├── schemas/          # Zod validation schemas
│   └── constants.ts      # Shared constants
└── dist/                 # Built JavaScript files
```

## Tool Implementation

### Tool Naming

Use snake_case for tool names with service prefix:
- `slack_send_message` not `send_message`
- `github_create_issue` not `create_issue`

### Complete Tool Example

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

const server = new McpServer({
  name: "example-mcp",
  version: "1.0.0"
});

const UserSearchInputSchema = z.object({
  query: z.string()
    .min(2, "Query must be at least 2 characters")
    .max(200, "Query must not exceed 200 characters")
    .describe("Search string to match against names/emails"),
  limit: z.number()
    .int()
    .min(1)
    .max(100)
    .default(20)
    .describe("Maximum results to return"),
  offset: z.number()
    .int()
    .min(0)
    .default(0)
    .describe("Number of results to skip for pagination")
}).strict();

type UserSearchInput = z.infer<typeof UserSearchInputSchema>;

server.registerTool(
  "example_search_users",
  {
    title: "Search Example Users",
    description: `Search for users in the Example system by name, email, or team.

Args:
  - query (string): Search string to match against names/emails
  - limit (number): Maximum results to return (default: 20)
  - offset (number): Number of results to skip (default: 0)

Returns:
  JSON with total count, users array, and pagination info.`,
    inputSchema: UserSearchInputSchema,
    annotations: {
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: true
    }
  },
  async (params: UserSearchInput) => {
    try {
      const data = await makeApiRequest("users/search", "GET", undefined, {
        q: params.query,
        limit: params.limit,
        offset: params.offset
      });

      const output = {
        total: data.total,
        count: data.users.length,
        offset: params.offset,
        users: data.users,
        has_more: data.total > params.offset + data.users.length
      };

      return {
        content: [{ type: "text", text: JSON.stringify(output, null, 2) }],
        structuredContent: output
      };
    } catch (error) {
      return {
        content: [{
          type: "text",
          text: `Error: ${error.message}`
        }]
      };
    }
  }
);
```

## Zod Schemas

```typescript
import { z } from "zod";

const CreateUserSchema = z.object({
  name: z.string()
    .min(1, "Name is required")
    .max(100, "Name must not exceed 100 characters"),
  email: z.string()
    .email("Invalid email format"),
  age: z.number()
    .int("Age must be a whole number")
    .min(0)
    .max(150)
}).strict();

enum ResponseFormat {
  MARKDOWN = "markdown",
  JSON = "json"
}
```

## Quality Checklist

- [ ] All tools have clear descriptions
- [ ] Input validation using Zod schemas
- [ ] Consistent error handling
- [ ] Pagination support for list operations
- [ ] Tool annotations provided
- [ ] No duplicate code
- [ ] Full TypeScript type coverage
- [ ] Builds successfully with `npm run build`
