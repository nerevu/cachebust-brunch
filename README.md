hashfingerprint-brunch [![npm version](https://badge.fury.io/js/hashfingerprint-brunch.svg)](http://badge.fury.io/js/hashfingerprint-brunch)
======================

A [Brunch][] plugin that will rename assets with an unique SHA hash. This will allow
better caching of assets. It will write a manifest file, so other tooling can
rewrite the urls.

Usage
-----

`npm install --save hashfingerprint-brunch`

_Note: if you're using [gzip-brunch][] make sure hashfingerprint-brunch is listed before
gzip-brunch in the dependency list of your package.json_

By default hashfingerprint-brunch will process generated files with extension '.js' and '.css'.

### Hugo integration

For [Hugo][] to rewrite resource urls, use the following in your brunch config:

```coffeescript
modules.exports = config:
  # ...
  plugins:
    hashfingerprint:
      manifest: 'data/manifest.json'
  paths:
    public: 'static'
  # ...
```

Then in your Hugo templates use the following snippet:
```html
<link rel="stylesheet" href="/{{ index $.Site.Data.manifest "css/mycss.css" }}" />
```
This will lookup the fingerprinted filename for 'css/mycss.css' from data/manifest.json'.


Options
-------



License
-------

MIT


[Brunch]: http://brunch.io
[gzip-brunch]: https://github.com/banyan/gzip-brunch
[Hugo]: https://gohugo.io
