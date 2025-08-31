# Gemview

[![Gem Version](https://badge.fury.io/rb/gemview.svg)](https://badge.fury.io/rb/gemview)

An unofficial TUI interface for querying information from rubygems.org. It uses the [gems](https://rubygems.org/gems/gems) gem internally. It requires the presence of the `less` pager and is tested on macOS and Linux.

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

## Navigation

For menus the arrow keys and j/k can be used for movement. Press enter to select a choice and escape or q to return to the previous menu or quit.

For paged content `less` is used internally so all the normal navigation commands work as expected.

## Demo

![GIF demoing the info and search subcommands](./assets/gemview-v1.2.0.gif)

## Implementation

Changelog and readme fetching is only supported for `github.com` and `gitlab.com` currently. This works by parsing the URI associated with one of these two sites from gem metadata, building a new URI associated with the given file and trying to download it as a raw file. Let me know if there are any other platforms I should add support for.

Markdown highlighting is added on a best effort basis and if the parser fails for some reason it just falls back to the raw text file.

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
