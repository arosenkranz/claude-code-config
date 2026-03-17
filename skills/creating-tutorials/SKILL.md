---
name: creating-tutorials
description: Transform complex technical concepts into engaging, hands-on learning experiences with progressive skill building. Use when writing tutorials, creating learning guides, designing hands-on exercises, or teaching technical concepts.
---

# Tutorial Engineering

Create effective tutorials that turn confusion into confidence through hands-on practice.

## Tutorial Structure

### Opening Section

```markdown
# Building a Real-Time Chat App with WebSockets

## What You'll Learn

By the end of this tutorial, you'll understand:
* How WebSockets enable real-time communication
* The difference between HTTP and WebSocket protocols
* How to implement a chat server and client
* Event-driven patterns for real-time applications

## Prerequisites

* Basic JavaScript knowledge
* Node.js installed (v18+)
* A code editor (VS Code recommended)
* Terminal/command line familiarity

## Time Estimate

45 minutes

## What We're Building

[Screenshot of final application]

A real-time chat application where multiple users can send messages that appear instantly for all connected users.
```

### Progressive Sections

Break complex topics into digestible steps:

1. **Concept Introduction** - Theory with real-world analogies
2. **Minimal Example** - Simplest working implementation
3. **Guided Practice** - Step-by-step walkthrough
4. **Variations** - Exploring different approaches
5. **Challenges** - Self-directed exercises
6. **Troubleshooting** - Common errors and solutions

## Writing Principles

### Show, Don't Tell

```markdown
❌ BAD: "WebSockets maintain a persistent connection."

✅ GOOD:
"Let's see WebSockets in action. Run this server code:

\`\`\`javascript
const WebSocket = require('ws');
const server = new WebSocket.Server({ port: 8080 });

server.on('connection', (socket) => {
  console.log('Client connected!');
  socket.send('Welcome!');
});
\`\`\`

Now in a browser, run:

\`\`\`javascript
const socket = new WebSocket('ws://localhost:8080');
socket.onmessage = (event) => console.log(event.data);
\`\`\`

Notice the 'Welcome!' message appears immediately? The connection stays open, allowing instant communication both ways."
```

### Incremental Complexity

```markdown
## Part 1: Basic Server (10 minutes)

Start with the simplest possible server:

\`\`\`javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(3000);
\`\`\`

Run it:
\`\`\`bash
node server.js
\`\`\`

Visit http://localhost:3000 - you should see "Hello World".

## Part 2: Adding Routes (10 minutes)

Now let's add user management:

\`\`\`javascript
const express = require('express');
const app = express();

// NEW: Parse JSON bodies
app.use(express.json());

// NEW: User data storage
const users = [];

// Existing route
app.get('/', (req, res) => {
  res.send('Hello World');
});

// NEW: Create user route
app.post('/users', (req, res) => {
  const user = { id: users.length + 1, ...req.body };
  users.push(user);
  res.json(user);
});

app.listen(3000);
\`\`\`

Test the new endpoint:
\`\`\`bash
curl -X POST http://localhost:3000/users \\
  -H "Content-Type: application/json" \\
  -d '{"name":"Alice"}'
\`\`\`
```

### Frequent Validation

```markdown
## Checkpoint: Test Your Work

Before continuing, verify everything works:

1. **Start the server:**
   \`\`\`bash
   node server.js
   \`\`\`

2. **Check for this output:**
   \`\`\`
   Server running on port 3000
   Database connected
   \`\`\`

3. **Test the endpoint:**
   \`\`\`bash
   curl http://localhost:3000/health
   \`\`\`
   Should return: `{"status":"ok"}`

**If you see errors:** Check the [Troubleshooting](#troubleshooting) section below.

✅ **Ready to continue?** Great! Let's add authentication.
```

## Code Example Standards

### Step-by-Step Progression

```markdown
// ❌ BAD: Everything at once
const app = express()
  .use(cors())
  .use(bodyParser.json())
  .use(authenticate)
  .post('/api/users', validate, createUser)
  .listen(3000);

// ✅ GOOD: Build incrementally

// Step 1: Create the app
const app = express();

// Step 2: Add middleware for parsing
app.use(express.json());

// Step 3: Add authentication (we'll implement this next)
app.use(authenticate);

// Step 4: Define routes
app.post('/api/users', validate, createUser);

// Step 5: Start the server
app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### Always Include Context

```javascript
// ✅ Show necessary imports
import express from 'express';
import { createUser, getUser } from './users.js';

// ✅ Show complete, runnable examples
const app = express();
app.use(express.json());

app.post('/users', async (req, res) => {
  try {
    const user = await createUser(req.body);
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.listen(3000);

// ❌ DON'T show incomplete snippets like:
// app.post('/users', createUser);
// (Where does createUser come from? How is it implemented?)
```

## Tutorial Types

### Concept Tutorial

Focus: Deep understanding of a single concept

```markdown
# Understanding JavaScript Closures

## What is a Closure?

A closure is when a function "remembers" variables from its outer scope.

Let's build understanding step by step:

### Step 1: Basic Function

\`\`\`javascript
function greet() {
  const message = 'Hello';
  console.log(message);
}

greet(); // "Hello"
\`\`\`

### Step 2: Nested Function

\`\`\`javascript
function greet() {
  const message = 'Hello';

  function sayIt() {
    console.log(message); // Accesses outer variable
  }

  sayIt();
}

greet(); // "Hello"
\`\`\`

### Step 3: Returning the Inner Function (This is a Closure!)

\`\`\`javascript
function greet() {
  const message = 'Hello';

  return function sayIt() {
    console.log(message); // Still accesses outer variable!
  };
}

const greeter = greet();
greeter(); // "Hello" - message was "remembered"
\`\`\`

**Key insight:** `message` exists even after `greet()` finished executing. The inner function "closed over" the variable.
```

### Building Tutorial

Focus: Create something functional from scratch

```markdown
# Build a Task Manager API

## What We're Building

A REST API for managing tasks with:
* Create, read, update, delete tasks
* Task status tracking
* User authentication
* Data persistence

## Part 1: Project Setup (5 min)

\`\`\`bash
mkdir task-api
cd task-api
npm init -y
npm install express
\`\`\`

## Part 2: Basic Server (5 min)

Create `server.js`:

\`\`\`javascript
const express = require('express');
const app = express();

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(3000, () => {
  console.log('API running on http://localhost:3000');
});
\`\`\`

**Test it:** Visit http://localhost:3000/health

[Continue building incrementally...]
```

## Troubleshooting Section

```markdown
## Troubleshooting

### "Cannot GET /"

**Symptom:** Browser shows "Cannot GET /" error

**Cause:** Express can't find your HTML file

**Solution:** Check these items:
1. Is `index.html` in the `public` folder?
2. Did you add the static middleware?
   \`\`\`javascript
   app.use(express.static('public'));
   \`\`\`
3. Restart the server after adding the middleware

### "Port 3000 already in use"

**Symptom:** Error message when starting server

**Cause:** Another process is using port 3000

**Solution:** Either:
1. Stop the other process: `lsof -ti:3000 | xargs kill`
2. Use a different port:
   \`\`\`javascript
   app.listen(3001); // Use 3001 instead
   \`\`\`

### Connection Closes Immediately

**Symptom:** WebSocket connects then disconnects right away

**Cause:** Client code has an error before event handlers are set up

**Solution:** Check browser console for errors. Make sure you're setting up event handlers BEFORE trying to send:

\`\`\`javascript
// ✅ GOOD: Set up handlers first
socket.onopen = () => {
  socket.send('Hello');
};

// ❌ BAD: Send before ready
socket.send('Hello'); // Socket might not be open yet
socket.onopen = () => { /* ... */ };
\`\`\`
```

## Exercises and Challenges

```markdown
## Practice Challenges

### Challenge 1: Add Timestamps

**Goal:** Show when each message was sent

**Hints:**
* Add a `timestamp` field to message objects
* Use `new Date().toISOString()` for the timestamp
* Display it in the UI next to each message

**Solution:** [See solution.md](./solutions/timestamps.md)

### Challenge 2: User Names

**Goal:** Let users choose a name that appears with their messages

**Requirements:**
* Prompt for name when user connects
* Display name with each message
* Handle case where user doesn't provide name

**Bonus:** Make the name editable after setting it

### Challenge 3: Private Messaging

**Difficulty:** ⭐⭐⭐ Advanced

**Goal:** Allow users to send messages to specific users

**Steps:**
1. Assign unique IDs to each connected user
2. Create a `/dm` command: `/dm userID message`
3. Parse the command and send only to target user
4. Show private messages differently in the UI
```

## Learning Outcomes

```markdown
## Summary

Congratulations! You've built a real-time chat application. You learned:

✅ How WebSockets maintain persistent connections
✅ The Socket.io event-driven programming model
✅ Broadcasting messages to multiple clients
✅ Handling real-time state synchronization

## Next Steps

Ready to level up? Try these enhancements:

### Beginner
* Add message history (store last 50 messages)
* Implement "user is typing" indicator
* Add emoji support

### Intermediate
* User authentication with JWT
* Persistent storage with PostgreSQL
* Message editing and deletion

### Advanced
* Private chat rooms
* File sharing
* Video/audio calls with WebRTC

## Additional Resources

* [Socket.io Documentation](https://socket.io/docs/)
* [WebSocket API Reference](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
* [Real-Time Architecture Patterns](https://example.com/patterns)
```

## Tutorial Quality Checklist

- [ ] Learning objectives clearly stated
- [ ] Prerequisites explicitly listed
- [ ] Time estimate provided
- [ ] Code examples are complete and runnable
- [ ] Each step produces visible progress
- [ ] Frequent validation checkpoints
- [ ] Common errors anticipated
- [ ] Troubleshooting section included
- [ ] Practice exercises provided
- [ ] Next steps suggested
- [ ] Working example code available
