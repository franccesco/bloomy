# Bloomy
[![RSpec Tests](https://github.com/franccesco/bloomy/actions/workflows/main.yml/badge.svg)](https://github.com/franccesco/bloomy/actions/workflows/main.yml) [![Deploy Docs](https://github.com/franccesco/bloomy/actions/workflows/deploy_docs.yml/badge.svg)](https://github.com/franccesco/bloomy/actions/workflows/deploy_docs.yml)

Bloomy is a Ruby library for interacting with the Bloom Growth API. It provides convenient methods for getting user details, todos, rocks, meetings, measurables, and issues.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bloomy'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install bloomy
```

## Configuration

### Initialize the Configuration

First, you need to initialize the configuration and set up the API key.

```ruby
require 'bloomy'

config = Bloomy::Configuration.new
```

### Configure the API Key

You can configure the API key using your username and password. Optionally, you can store the API key locally under `~/.bloomy/config.yaml` for future use.

```ruby
config.configure_api_key("your_username", "your_password", store_key: true)
```

You can also set an `BG_API_KEY` environment variable and it will be loaded automatically for you once you initialize a client. A configuration is useful if you plan to use a fixed API key for your operations. However, you can also pass an API key when initializing a client without doing any configuration.

## Client Initialization

Once the configuration is set up, you can initialize the client. The client provides access to various features such as managing users, todos, rocks, meetings, measurables, and issues.

> [!NOTE]
> Passing an API key is entirely optional and only useful if you plan to use different API keys to manage different organizations. This will bypass the regular configuration process.

```ruby
client = Bloomy::Client.new(api_key: "abc...")
```

## Using Client Features

### User Management

To interact with user-related features:

```ruby
# Fetch current user details
current_user_details = client.user.details

# Search for users
search_results = client.user.search("John Doe")
```

### Meeting Management

To interact with meeting-related features:

```ruby
# List all meetings for the current user
meetings = client.meeting.list

# Get details of a specific meeting
meeting_details = client.meeting.details(meeting_id)
```

### Todo Management

To interact with todo-related features:

```ruby
# List all todos for the current user
todos = client.todo.list

# Create a new todo
new_todo = client.todo.create(title: "New Task", meeting_id: 1, due_date: "2024-06-15")
```

### Rock Management

To interact with rock-related features:

```ruby
# List all rocks for the current user
rocks = client.rock.list

# Create a new rock
new_rock = client.rock.create(title: "New Rock", meeting_id: 1)
```

### Measurable Management

To interact with measurable-related features:

```ruby
# Get current week details
current_week = client.measurable.current_week

# Get the scorecard for the user
scorecard = client.measurable.scorecard
```

### Issue Management

To interact with issue-related features:

```ruby
# Get details of a specific issue
issue_details = client.issue.details(issue_id)

# Create a new issue
new_issue = client.issue.create("New Issue", meeting_id)
```
