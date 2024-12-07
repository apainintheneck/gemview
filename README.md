# Gemview

An unofficial CLI interface for querying information from rubygems.org.

## Features
- Search for gems by name
- Find recently released gems
- Find recently updated gems
- Read information about gems interactively
- Read the readme and changelog for gems
  - Note: Supported on a best effort basis

## Installation
TODO: Write installation instructions here

## Usage

```
Commands:
  gemview author USERNAME             # Find gems by rubygems.org username
  gemview info NAME                   # Show gem info
  gemview releases                    # List the most recent new gem releases
  gemview search TERM                 # Search for gems
  gemview updates                     # List the most recent gem updates
  gemview version                     # Print version
```

## Development

### Testing

```console
$ bundle exec rspec
```

### Linting

```console
$ bundle exec standardrb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apainintheneck/gemview.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
