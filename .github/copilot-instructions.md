# Copilot Instructions

## Project Snapshot
- Language: Ruby 3.3
- Main entry point: `lib/fontello_rails_converter.rb`
- Test stack: RSpec + SimpleCov
- Lint stack: RuboCop

## Development Rules
- Keep runtime dependencies in `fontello_rails_converter.gemspec`.
- Keep development and test dependencies in `Gemfile` groups.
- Maintain compatibility with Ruby `3.3.0`.
- Keep optional Rails integration behind `defined?(Rails)` checks.

## Quality Gate
- Run `bundle exec rubocop` before opening a PR.
- Run `bundle exec rspec` before opening a PR.
- Keep line coverage at or above `90%`.

## CI Expectations
- `CI Pipeline` runs in this order: `PR linter` (PR only), `rubocop` (PR only), `rspec` (PR + `master` push), `simplecov` (PR + `master` push).
- `CI Pipeline` comments current coverage in PRs and enforces minimum coverage with SimpleCov.
- `Release` runs after successful `CI Pipeline` on `master` pushes.
- `Publish` runs on published releases.
