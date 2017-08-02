fingerprinter-brunch [![npm version](https://badge.fury.io/js/fingerprinter-brunch.svg)](http://badge.fury.io/js/fingerprinter-brunch)
======================

Originally forked from https://github.com/jvanderneutstulen/hashfingerprint-brunch

A [Brunch][] plugin that will rename assets with an unique SHA hash. This will allow
better caching of assets. It will write a manifest file, so other tooling can
rewrite the urls.

Usage
-----

`yarn add fingerprinter-brunch`

_Note: if you're using [gzip-brunch][] make sure fingerprinter-brunch is listed before
gzip-brunch in the dependency list of your package.json_


Options
-------

Default configuration:

```coffeescript
module.exports = config:
  plugins:
    fingerprinter:
      manifest: 'public/manifest.json'
      precision: 8
```

### manifest

Output location of the manifest file.

### precision

How many characters of the SHA1 hash must be used in the hashed
filename. Default should be fine.

License
-------

MIT


[Brunch]: http://brunch.io
[gzip-brunch]: https://github.com/banyan/gzip-brunch
