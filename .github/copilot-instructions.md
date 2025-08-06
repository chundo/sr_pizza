# Copilot Instructions for SR Pizza - Pizza Order API

## Project Overview

SR Pizza is a Ruby on Rails REST API application designed for managing pizza orders with asynchronous processing capabilities. The system allows customers to place pizza orders, tracks order status, and provides winner selection functionality for promotional campaigns.

## Business Domain

### Pizza Business Logic
- **Pizza Types**: `margherita`, `pepperoni`, `vegetarian`
- **Sizes**: `small`, `medium`, `large`
- **Order Lifecycle**: Creation → Processing (async) → Completion
- **Winner Selection**: Random selection from unique customers for promotions

### Key Business Rules
- Each customer can place multiple orders
- Winner selection ensures fairness (one chance per unique customer)
- Orders are processed asynchronously using background jobs
- All orders must have valid customer name, pizza type, and size

## Technical Architecture

### Technology Stack
- **Framework**: Ruby on Rails 7.2.0+
- **Ruby Version**: 3.2.0+
- **Database**: SQLite (development), PostgreSQL (production ready)
- **Background Jobs**: Redis + Sidekiq
- **Testing**: RSpec with comprehensive test coverage
- **Admin Interface**: RailsAdmin (development only)

### Code Organization Patterns

#### Models (`app/models/`)
- Follow Active Record patterns
- Use enums for predefined values (pizza_types, sizes)
- Include comprehensive validations
- Use CONSTANTS for allowed values arrays

#### Controllers (`app/controllers/`)
- RESTful design principles
- Consistent JSON API responses with `status` field
- Error handling with proper HTTP status codes
- Minimal controller logic, delegate to services

#### Services (`app/services/`)
- Business logic encapsulation
- Single responsibility principle
- Error handling with custom exceptions
- Comprehensive logging for debugging

#### Jobs (`app/jobs/`)
- Inherit from `ApplicationJob`
- Handle async operations (order processing)
- Include retry mechanisms and error handling
- Log job execution for monitoring

### API Design Patterns

#### Response Format
Always return JSON responses with consistent structure:

**Success Response:**
```json
{
  "status": "success",
  "data": { /* relevant data */ }
}
```

**Error Response:**
```json
{
  "status": "failed", 
  "errors": ["error message 1", "error message 2"]
}
```

#### Endpoint Conventions
- Use RESTful routes for resource operations
- Use POST for actions that don't fit REST (e.g., winner selection)
- Include meaningful endpoint names (`/winner_selection` not `/select_winner`)

### Testing Approach

#### RSpec Structure
- Model specs: Test validations, associations, and methods
- Controller specs: Test HTTP responses and status codes  
- Service specs: Test business logic and edge cases
- Job specs: Test async processing and error scenarios

#### Testing Patterns
- Use `let` and `let!` for test data setup
- Test both happy path and edge cases
- Mock external dependencies
- Test error scenarios thoroughly
- Use descriptive test names that explain behavior

#### Test Data
- Use realistic pizza business data in tests
- Include Spanish customer names (target market)
- Test with various pizza types and sizes combinations

## Development Guidelines

### Code Style
- Follow Ruby and Rails conventions
- Use RuboCop for linting (config in `.rubocop.yml`)
- Meaningful variable and method names
- Spanish text for user-facing messages (target market)

### Error Handling
- Use Rails standard error handling patterns
- Log errors with appropriate levels
- Return user-friendly error messages in Spanish
- Handle database constraints and validations properly

### Background Jobs
- Use Sidekiq for async processing
- Implement proper error handling and retries
- Log job progress for monitoring
- Keep jobs idempotent when possible

### Database Patterns
- Use Active Record migrations for schema changes
- Include proper indexes for performance
- Use constraints and validations at both model and DB level
- Consider data integrity in all operations

## Key Features to Understand

### Pizza Order Management
- CRUD operations for pizza orders
- Validation of pizza types and sizes
- Customer name tracking
- Async order processing with jobs

### Winner Selection System
- Random selection from unique customers
- Fair distribution (prevents bias from multiple orders)
- Error handling for edge cases (no orders available)
- Audit trail through logging

### Admin and Monitoring
- RailsAdmin interface for development
- Sidekiq web interface for job monitoring
- Health check endpoint (`/up`)
- Comprehensive logging

## Common Development Tasks

### Adding New Pizza Types
1. Update `PIZZA_TYPES` constant in `PizzaOrder` model
2. Update enum definition
3. Add validation tests
4. Update API documentation

### Adding New Endpoints
1. Add route in `config/routes.rb`
2. Create controller action with consistent response format
3. Add controller specs with all scenarios
4. Update documentation

### Background Job Development
1. Inherit from `ApplicationJob`
2. Include comprehensive error handling
3. Add logging for debugging
4. Write specs for all scenarios including failures

## Local Development Setup

### Required Services
- Rails server (`rails server`)
- Sidekiq worker (`bundle exec sidekiq`)
- Redis server (for Sidekiq)

### Common Commands
```bash
# Setup
bundle install
rails db:migrate
rails db:seed

# Development
rails server
bundle exec sidekiq

# Testing
bundle exec rspec
bundle exec rubocop

# Console debugging
rails console
```

### Debugging Tips
- Check `log/development.log` for Rails logs
- Monitor Sidekiq web interface for job status
- Use Rails console for data inspection
- Test API endpoints with curl commands

## Integration and Deployment Notes

### Production Considerations
- Switch to PostgreSQL database
- Configure Redis for production use
- Set up proper logging and monitoring
- Configure background job queues properly
- Use environment variables for configuration

### API Testing
Use curl commands for manual testing as documented in README.md. Always test both success and error scenarios.

When working on this codebase, prioritize:
1. Maintaining consistent API response formats
2. Comprehensive error handling
3. Proper async job implementation
4. Thorough testing of business logic
5. Clear logging for debugging and monitoring