# Gemview

An unofficial CLI interface for querying information from rubygems.org. It uses the [gems](https://rubygems.org/gems/gems) gem internally.

Note: This gem is not directly affiliated with `rubygems.org`. It's just a hobby project.

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

## Demo

![GIF demoing the info and search subcommands](./assets/gemview-v1.0.0.gif)

## Development

### Testing & Linting

```console
$ rake
```

### Testing

```console
$ rake spec
```

### Linting

```console
$ rake standard
$ rake standard:fix
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apainintheneck/gemview.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
