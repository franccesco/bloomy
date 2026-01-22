# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bloomy is an unofficial Ruby gem for interacting with the Bloom Growth API. It provides methods for managing users, todos, goals/rocks, meetings, measurables/scorecards, issues, and headlines.

## Common Commands

```bash
# Run all tests (default rake task)
bundle exec rake

# Run tests with fail-fast
bundle exec rspec --fail-fast

# Run a specific test file
bundle exec rspec spec/bloomy_users_spec.rb

# Run a single test by line number
bundle exec rspec spec/bloomy_users_spec.rb:15

# Check code style
bundle exec standardrb

# Auto-fix style issues
bundle exec standardrb --fix

# Generate YARD documentation
bundle exec yard doc

# Interactive console with bloomy loaded
bundle exec ./bin/console

# Version bumping
bundle exec bump patch|minor|major
```

## Architecture

The gem follows a client-based API wrapper pattern:

- **`Bloomy::Client`** (`lib/bloomy/client.rb`) - Main entry point that initializes Faraday HTTP connection and provides access to all operation managers
- **`Bloomy::Configuration`** (`lib/bloomy/configuration.rb`) - Handles API key management (from env var `BG_API_KEY`, `~/.bloomy/config.yaml`, or direct parameter)
- **Operations** (`lib/bloomy/operations/`) - Feature implementations:
  - `users.rb` - User management
  - `todos.rb` - Todo management
  - `goals.rb` - Goal/Rock management
  - `meetings.rb` - Meeting management
  - `scorecard.rb` - Measurable/Scorecard management
  - `issues.rb` - Issue management
  - `headlines.rb` - Headlines management

All API responses are returned as Hash structures. Operations use the shared Faraday connection from the client with Bearer token authentication.

## Testing Notes

- Tests run against the live Bloom Growth API (no mocks)
- Tests create and delete actual data - use a non-critical account
- Required environment variables: `BG_USERNAME`, `BG_PASSWORD`
- Tests use `before(:all)`/`after(:all)` for setup/teardown of test data

## Code Style

- StandardRB enforces Ruby Style Guide
- YARD documentation required for classes/methods with `@examples`
- Always update YARD documentation when making code changes to keep docs aligned with implementation
- Pre-commit hooks enforce formatting (`pre-commit install`)
- Conventional Commits for commit messages
