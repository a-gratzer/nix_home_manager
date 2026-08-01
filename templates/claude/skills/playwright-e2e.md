---
name: playwright-e2e
description: >-
  End-to-end browser testing using the Playwright MCP server. Automates web
  interactions (navigate, click, type, fill forms, upload files, drag-and-drop),
  captures snapshots/screenshots, monitors network requests and console messages,
  validates page content and behaviour, and generates structured test reports.

  Use this skill whenever the user wants to test a web application end-to-end,
  automate browser interactions, verify page content or user flows, monitor
  network traffic or console logs in a browser session, capture screenshots
  or accessibility snapshots, or run any kind of browser-based validation.
  Trigger on phrases like "test this page", "verify the login flow",
  "check if the form works", "automate this browser workflow", "validate the
  UI", "run an E2E test", "capture a screenshot of", "check console errors",
  "monitor network requests", "/playwright-e2e", or any request to interact
  with or validate a web application through a browser.
---

# Playwright E2E Testing

End-to-end browser testing using the Playwright MCP server. This skill uses
accessibility-tree-based snapshots (no vision model needed), supports all
modern browser interactions, and produces structured test reports.

## Available MCP Tools

The Playwright MCP server provides these tool categories via `browser_*`:

### Navigation & History
- `browser_navigate` — Navigate to a URL
- `browser_navigate_back` — Go back in history
- `browser_close` — Close the current page

### Interaction
- `browser_click` — Click an element (supports double-click, right-click, modifiers)
- `browser_type` — Type text into an editable element (supports `submit` and `slowly`)
- `browser_fill_form` — Fill multiple form fields at once
- `browser_select_option` — Select dropdown options (single or multi)
- `browser_hover` — Hover over an element
- `browser_drag` — Drag and drop between elements
- `browser_drop` — Drop files or MIME data onto an element
- `browser_press_key` — Press a keyboard key (e.g., `ArrowLeft`, `Enter`)
- `browser_handle_dialog` — Accept or dismiss a browser dialog, optionally with prompt text
- `browser_file_upload` — Upload one or more files via file input
- `browser_resize` — Resize the browser window (for responsive testing)

### Observation & Validation
- `browser_snapshot` — Capture the accessibility snapshot of the page (preferred over screenshots for structural validation)
- `browser_take_screenshot` — Take a screenshot (PNG or JPEG, full-page or viewport, CSS or device pixel scale)
- `browser_find` — Search the snapshot for text or regex (cheaper than full snapshot for locating elements)
- `browser_evaluate` — Evaluate JavaScript on the page or on a specific element
- `browser_run_code_unsafe` — Run arbitrary Playwright code (use for complex assertions or page interactions not covered by other tools)

### Network
- `browser_network_requests` — List network requests since page load (with regex filter)
- `browser_network_request` — Get full details (headers, body) of a single request
- `browser_route` — Mock network requests matching a URL pattern
- `browser_route_list` — List active network routes
- `browser_unroute` — Remove network routes
- `browser_network_state_set` — Toggle online/offline mode

### Console & Logs
- `browser_console_messages` — Get browser console messages (filterable by level)

### Tabs
- `browser_tabs` — List, create, close, or select browser tabs

### Storage & State
- `browser_cookie_list` / `browser_cookie_get` / `browser_cookie_set` / `browser_cookie_delete` / `browser_cookie_clear` — Cookie management
- `browser_localstorage_clear` / `browser_localstorage_delete` / `browser_localstorage_get` / `browser_localstorage_set` — localStorage management

### Coordination & Waits
- `browser_wait_for` — Wait for text to appear/disappear or a specified time to pass

## End-to-End Test Workflow

When asked to create or run an E2E test, follow this structured workflow:

### Step 1: Understand the Test Scenario

Clarify what needs to be tested:
- **Target URL** — The page or application under test
- **User flow** — The sequence of actions to perform
- **Expected results** — What should be visible, what state should result
- **Edge cases** — Error states, empty data, auth failures, network issues
- **Test data** — Any login credentials, form inputs, or fixture data needed

Ask clarifying questions if the scenario is vague. For example:
- "Should this test run against staging or production?"
- "Are there specific error messages to verify?"
- "Should I test responsive behavior at different viewport sizes?"
- "Do you need network traffic monitored for API call validation?"

### Step 2: Set Up the Browser

```bash
# Navigate to the starting URL
browser_navigate(url="https://example.com")

# Optionally set viewport for responsive testing
browser_resize(width=1280, height=720)

# Optionally clear state for a clean test
browser_cookie_clear()
browser_localstorage_clear()
```

### Step 3: Execute the User Flow

Use the interaction tools to simulate the user journey. Prefer the accessibility
snapshot (`browser_snapshot`) over screenshots for locating elements — it is
more reliable and gives you structured element references.

**Pattern for each interaction:**
1. Take a `browser_snapshot` to see available elements and their refs
2. Use the element ref (e.g., `e42`) from the snapshot as the `target` parameter
3. Perform the action (click, type, select, etc.)
4. Take another snapshot to verify the result

**Example: Login flow**
```
1. browser_navigate(url="https://example.com/login")
2. browser_snapshot → find input refs and button ref
3. browser_type(target="e12", text="user@example.com")
4. browser_type(target="e15", text="password123", submit=true)
5. browser_snapshot → verify "Dashboard" or "Welcome" text appears
```

**For complex forms**, use `browser_fill_form` instead of individual type calls:
```
browser_fill_form(fields=[
  {"target": "e12", "value": "user@example.com"},
  {"target": "e15", "value": "password123"},
  {"target": "e18", "value": "option2"}
])
```

### Step 4: Validate Results

Run assertions to verify the page is in the expected state. Use this priority
order for validation:

1. **Text presence** — Use `browser_snapshot` and check for expected text
2. **URL verification** — Use `browser_evaluate(function="() => window.location.href")`
3. **Element state** — Use `browser_evaluate` to check element properties
4. **Network validation** — Use `browser_network_requests` to verify API calls
5. **Console validation** — Use `browser_console_messages(level="error")` to check for errors

**Validation patterns:**

```javascript
// Check current URL
browser_evaluate(function="() => window.location.href")

// Check element visibility
browser_evaluate(function="() => document.querySelector('.success-message') !== null")

// Check element text content
browser_evaluate(function="() => document.querySelector('.cart-count').textContent")

// Check specific CSS property
browser_evaluate(function="() => getComputedStyle(document.querySelector('.error')).color")
```

For complex assertions, use `browser_run_code_unsafe`:
```javascript
browser_run_code_unsafe(code="async (page) => {
  await expect(page.getByRole('heading')).toHaveText('Dashboard');
  await expect(page.getByTestId('user-menu')).toBeVisible();
  const count = await page.getByTestId('item-count').textContent();
  return parseInt(count);
}")
```

### Step 5: Capture Evidence

Take screenshots at key points for the report:
```
browser_take_screenshot(filename="01-login-page.png")
# ... perform actions ...
browser_take_screenshot(filename="02-after-login.png")
# ... more actions ...
browser_take_screenshot(filename="03-final-state.png")
```

Also capture console output and network requests:
```
browser_console_messages(filename="console.log")
browser_network_requests(filename="network.log")
```

### Step 6: Generate the Report

Write a structured `report.md` file following this exact template:

```markdown
# E2E Test Report: [Test Name]

**Date**: [ISO date]
**URL Under Test**: [URL]
**Browser**: Playwright (Chromium via MCP)
**Viewport**: [width]×[height]

## Test Scenario

[Brief description of what was tested — the user flow, the expected behaviour]

## Test Steps & Results

| Step | Action | Expected Result | Actual Result | Status |
|------|--------|-----------------|---------------|--------|
| 1 | Navigate to /login | Page loads with login form | [Actual result] | ✅ / ❌ |
| 2 | Type credentials and submit | Redirect to dashboard | [Actual result] | ✅ / ❌ |
| ... | ... | ... | ... | ... |

## Assertions

| # | Assertion | Type | Expected | Actual | Passed |
|---|-----------|------|----------|--------|--------|
| 1 | Login form is visible | text-presence | "Sign In" heading | Found | ✅ |
| 2 | Redirect URL is correct | url | "/dashboard" | "/dashboard" | ✅ |
| 3 | User name displayed | text-presence | "John Doe" | "John Doe" | ✅ |

## Network Summary

- Total requests: [N]
- Failed requests: [N]
- Key API calls verified: [list]

## Console Summary

- Errors: [N]
- Warnings: [N]
- Notable messages: [list]

## Screenshots

| File | Description |
|------|-------------|
| 01-login-page.png | Initial login page |
| 02-after-login.png | Dashboard after successful login |
| 03-final-state.png | Final application state |

## Findings

### Issues Found
- [Any bugs, unexpected behavior, or failures]

### Warnings
- [Non-blocking concerns — slow load times, deprecated API usage, missing alt text, etc.]

### Recommendations
- [Suggested improvements or follow-up tests]

## Test Metadata

- **Duration**: [approximate time]
- **MCP Server**: @playwright/mcp@latest
- **Test Type**: [smoke / regression / exploratory / accessibility]
```

Save the report to the current working directory or a path specified by the user.

## Best Practices

### Element Location Strategy

Always use the accessibility snapshot (`browser_snapshot`) to locate elements.
The snapshot shows structured element refs like `e42` that are stable within
a page load. Prefer this order:

1. Use `browser_find(text="Submit")` to locate elements by visible text
2. Use `browser_snapshot` and scan for the element ref
3. Use `browser_evaluate` to query by test-id, role, or label if needed

Never guess element refs — always capture a fresh snapshot first.

### Waiting for Elements

Playwright MCP tools do not auto-wait. Use explicit waits:
```
browser_wait_for(text="Dashboard")   # Wait for text to appear
browser_wait_for(textGone="Loading") # Wait for text to disappear
browser_wait_for(time=2)             # Wait for N seconds
```

Always wait for page transitions and async content to settle before taking
snapshots or making assertions.

### Error Handling

If an action fails:
1. Take a screenshot to capture the current state
2. Check `browser_console_messages(level="error")` for JavaScript errors
3. Check `browser_network_requests` for failed API calls
4. Record the failure in the report with evidence
5. Continue with remaining test steps if possible (soft failures)

### Accessibility Testing

The snapshot captures the accessibility tree, which inherently validates:
- Elements have proper ARIA roles
- Interactive elements are reachable
- Text content is exposed to assistive technology
- Form labels are associated with inputs

Note any accessibility gaps found during testing in the report's Findings section.

### Responsive Testing

To test at different viewports:
```
browser_resize(width=375, height=812)   # Mobile
# ... test mobile layout ...
browser_resize(width=768, height=1024)  # Tablet
# ... test tablet layout ...
browser_resize(width=1280, height=720)  # Desktop
# ... test desktop layout ...
```

### Network Mocking

To test offline behaviour or mock API responses:
```
# Simulate offline mode
browser_network_state_set(state="offline")
# ... verify offline UI ...
browser_network_state_set(state="online")

# Mock an API response
browser_route(pattern="**/api/users", status=200,
  body='{"users": []}', contentType="application/json")

# Mock an error response
browser_route(pattern="**/api/submit", status=500,
  body='{"error": "Internal Server Error"}', contentType="application/json")

# Clean up routes
browser_unroute(pattern="**/api/*")
```

### Performance Monitoring

Monitor load performance using browser_evaluate:
```javascript
// Get navigation timing
browser_evaluate(function="() => {
  const t = performance.getEntriesByType('navigation')[0];
  return { domContentLoaded: t.domContentLoadedEventEnd - t.startTime,
           loadComplete: t.loadEventEnd - t.startTime };
}")
```

## Common Test Patterns

### Form Validation Test
```
1. browser_navigate → form page
2. browser_snapshot → locate fields
3. Submit empty form → verify validation errors
4. Fill with invalid data → verify field-level errors
5. Fill with valid data → verify success
```

### Authentication Flow Test
```
1. browser_navigate → protected page → verify redirect to login
2. Fill credentials → submit → verify redirect to protected page
3. Verify authenticated state (user name, menu items)
4. Logout → verify redirect to login
```

### CRUD Operation Test
```
1. browser_navigate → list page → verify items exist
2. Click "Create" → fill form → submit → verify new item in list
3. Click item → verify detail page
4. Click "Edit" → modify → save → verify changes
5. Click "Delete" → confirm dialog → verify item removed
```

### API Integration Test
```
1. Start monitoring: browser_route_list to verify no active mocks
2. browser_navigate → trigger API-calling feature
3. browser_network_requests(filter="/api/") → verify request count/URLs
4. browser_network_request(index=1) → verify request payload
5. browser_network_request(index=1, part="response") → verify response
```

### Accessibility Audit
```
1. browser_navigate → page under test
2. browser_snapshot → review full accessibility tree
3. Verify all images have alt text
4. Verify form inputs have associated labels
5. Verify heading hierarchy (h1 → h2 → h3)
6. Verify interactive elements have accessible names
```

## Running Complete Test Suites

For multi-page or multi-flow test suites:

1. Run each test flow as a separate browser session (navigate → flow → validate → close)
2. Collect screenshots and logs for each flow into organized directories
3. Generate a summary report with pass/fail counts across all flows
4. Include a master `report.md` that references individual flow reports
