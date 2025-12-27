# Emerail

A Ruby on Rails email aggregator that allows you to consolidate multiple email accounts into a single unified inbox.

## Features

- User authentication with Devise
- Support for multiple email accounts per user
- IMAP email synchronization
- Background job processing with Sidekiq
- Email message pagination
- Read/unread status tracking
- Attachment detection
- Rate limiting with Rack::Attack
- Incremental email syncing (only fetches new messages)

## Tech Stack

- Ruby 3.4.7
- Rails 8.1.1
- PostgreSQL
- Sidekiq for background jobs
- Redis for job queue
- Devise for authentication
- Kaminari for pagination
- Rack::Attack for rate limiting

## Prerequisites

- Ruby 3.4.7 (use rbenv or rvm)
- PostgreSQL (version 9.3+)
- Redis (for Sidekiq)
- Bundler

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Emerail
```

2. Install dependencies:
```bash
bundle install
```

3. Setup environment variables:
Create a `.env` file in the root directory:
```bash
# Database (optional if using defaults)
DATABASE_URL=postgresql://localhost/emerail_development

# Rails
RAILS_ENV=development
```

4. Create and setup the database:
```bash
rails db:create
rails db:migrate
```

## Running the Application

You need to run three separate processes:

### 1. Redis Server
```bash
redis-server
```

### 2. Sidekiq (Background Jobs)
In a new terminal:
```bash
bundle exec sidekiq
```

### 3. Rails Server
In another terminal:
```bash
rails server
```

The application will be available at `http://localhost:3000`

## Usage

### 1. Create an Account
- Visit `http://localhost:3000/users/sign_up`
- Register with your email and password

### 2. Add an Email Account
- Navigate to `/email_accounts/new`
- Fill in your IMAP details:
  - Provider: Select "imap"
  - IMAP Host: e.g., `imap.gmail.com`
  - IMAP Port: e.g., `993`
  - IMAP SSL: Check if using SSL/TLS
  - Username: Your email address
  - Password: Your email password or app-specific password

### 3. Sync Emails
Emails are synced automatically via background jobs. To manually trigger a sync:
```bash
rails console
```
Then run:
```ruby
account = EmailAccount.first
SyncEmailAccountJob.perform_async(account.id)
```

### 4. View Emails
- Visit `http://localhost:3000` to see your aggregated emails
- Click on any email to view its full content
- Emails are automatically marked as read when viewed

## Configuration

### Email Sync Settings
Edit `app/services/email_sync_service.rb` to adjust:
- `BATCH_SIZE`: Number of emails to process at once (default: 50)
- `DEFAULT_SYNC_DAYS`: How many days back to sync on first sync (default: 30)

### Rate Limiting
Edit `config/initializers/rack_attack.rb` to adjust rate limits:
- Login attempts: 5 per minute per email
- Signups: 5 per 5 minutes per IP
- API requests: 300 per 5 minutes per IP
- Email account creation: 10 per hour per IP

### Pagination
Edit `app/controllers/email_messages_controller.rb` to change items per page (default: 50)

## Common Email Provider Settings

### Gmail
- IMAP Host: `imap.gmail.com`
- IMAP Port: `993`
- SSL: Yes
- Note: You'll need to use an App Password (not your regular password)
- Enable IMAP in Gmail settings

### Outlook/Hotmail
- IMAP Host: `outlook.office365.com`
- IMAP Port: `993`
- SSL: Yes

### Yahoo
- IMAP Host: `imap.mail.yahoo.com`
- IMAP Port: `993`
- SSL: Yes
- Note: You'll need to use an App Password

## Database Schema

### Users
- Email authentication with Devise
- Has many email accounts

### Email Accounts
- Belongs to a user
- Stores IMAP credentials (encrypted password)
- Tracks last sync time
- Supports multiple providers (IMAP, Gmail OAuth, Outlook OAuth)

### Email Messages
- Belongs to an email account
- Stores message content, metadata, and status
- Tracks read/unread status
- Detects attachments

## Development

### Running Tests
```bash
rails test
```

### Console
```bash
rails console
```

### Database Console
```bash
rails dbconsole
```

## Deployment

The project includes Docker support via Kamal. See `.kamal/` directory for deployment configuration.

## Security Considerations

1. Email passwords are encrypted using `has_secure_password`
2. Rate limiting is enabled to prevent abuse
3. User authentication required for all email operations
4. Unique message IDs prevent duplicate emails

## Future Enhancements

- OAuth support for Gmail and Outlook
- Email search functionality
- Folder/label support
- Email composition and sending
- Attachment downloads
- Email filtering and rules
- Mobile responsive design
- Email threading

## License

This project is available as open source.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

