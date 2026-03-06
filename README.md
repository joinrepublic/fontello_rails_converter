## fontello_rails_converter

[![CI Pipeline](https://github.com/railslove/fontello_rails_converter/actions/workflows/ci-pipeline.yml/badge.svg?branch=master)](https://github.com/railslove/fontello_rails_converter/actions/workflows/ci-pipeline.yml)

CLI gem for working with icon fonts from [fontello.com](http://fontello.com) in Rails apps.

Main capabilities:

1. Open the current Fontello session in the browser.
2. Download/copy icon assets into `vendor/assets`.
3. Convert generated CSS to Sass-friendly stylesheets.

## Compatibility

1. Ruby: `3.3.0`.
2. Active Support: supported (`activesupport` runtime dependency).
3. Rails: optional integration via Railtie, enabled automatically when Rails is present.

## Installation

Add to `Gemfile`:

```ruby
gem 'fontello_rails_converter'
```

Then run:

```bash
bundle install
```

## Quick Start

1. Download initial Fontello `.zip` into `tmp/fontello.zip`.
2. Run conversion from your Rails root:

```bash
bundle exec fontello convert --no-download
```

The command copies assets into `vendor/assets` and writes `fontello-demo.html` into `public/`.

## Typical Update Flow

1. Open existing session:

```bash
bundle exec fontello open
```

2. Save session in Fontello UI.
3. Fetch and convert latest assets:

```bash
bundle exec fontello convert
```

The session ID is persisted in `tmp/fontello_session_id`.

## Commands

```bash
bundle exec fontello open
bundle exec fontello download
bundle exec fontello copy
bundle exec fontello convert
```

Run help for the full option list:

```bash
bundle exec fontello --help
```

## Notable Options

1. `--no-download` (`convert`): convert local zip without downloading.
2. `--webpack` (`convert`): rewrite font URLs for webpack style imports (for example `url('~fontello.woff')`).
3. `--stylesheet-extension`: choose output extension (for example `.scss`).
4. `--rails-root`: process another app root path.

## Sass Enhancements

Conversion adds Rails/Sass-friendly improvements:

1. Rewrites font paths to `font-url(...)` (unless `--webpack` is used).
2. Adds placeholder selectors (for example `%icon-glass`) and generated class extensions.

## Configuration File

By default the CLI reads options from:

`config/fontello_rails_converter.yml`

You can override with `--options-file`.

## Additional Generated Stylesheets

Besides the main stylesheet (`fontname.scss`), Fontello may include files such as:

1. `fontname-ie7-codes.scss`
2. `fontname-embedded.scss`
3. `animation.scss`
4. `fontname-ie7.scss`
5. `fontname-codes.scss`

## Development

Quality gate used in CI and expected locally:

```bash
bundle exec rubocop
bundle exec rspec
```

SimpleCov enforces minimum line coverage at `90%`.

## CI/CD

The project uses GitHub Actions workflows:

1. `CI Pipeline`: PR linting, RuboCop, RSpec, coverage reporting.
2. `Release`: release-please automation on successful `master` push pipeline.
3. `Publish`: builds and publishes gem package on release events.
