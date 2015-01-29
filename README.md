# TextMate Bundle Support Tools

Helpful ruby scripts for [TextMate 2](/textmate/textmate) bundle developers.

## Installation

    $ gem install tm_bundle_support

Now you can run commands from any `*.tmbundle` directory.

## Usage

Currently it provides next commands:

* `tm_bundle fix-names` — Updates filenames of commands, scripts and macros with its current title.
* `tm_bundle menu export (-f)` — Exports a tree of your bundle's menu items into `menu-%datetime%.yml` (or into `menu.yml` with `-f` flag) to let you easy order items, update uuids and rename submenus.
* `tm_bundle menu apply (--last)` — Updates `info.plist` with changes from `menu.yml` file. (to pick the latest one run with `--last`)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/tm_bundle_support/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
