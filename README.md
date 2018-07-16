# cachebust-brunch

The best of [fingerprinter-brunch](https://github.com/paulcsmith/fingerprinter-brunch), [hashfingerprint-brunch](https://github.com/jvanderneutstulen/hashfingerprint-brunch), and [timestamp-brunch](https://github.com/fabienL/timestamp-brunch).

A [Brunch][] plugin that will rename assets with an unique SHA hash. This will allow better caching of assets. It will automatically rewrite the urls, and also write to a manifest file.

## Usage

`npm install --save cachebust-brunch`

_Note: if you're using [gzip-brunch][] make sure cachebust-brunch is listed before gzip-brunch in the dependency list of your package.json_

## Options

Default configuration:

```coffeescript
module.exports = config:
  plugins:
    cachebust:
      manifest: 'public/manifest.json'
      reference: 'index.html'
      extensions: [
        /\.js$/
        /\.css$/
      ]
      precision: 8
```

### manifest

Output location of the manifest file.

### reference

The file where the urls should be rewritten.

### extensions

Array of extensions to match. Regex must be acceptable by `str.match`.
The array will be matched against the list of generated files.

### precision

The number of characters of the SHA1 hash to use in the hashed
filename. Default should be fine.

## Brunch build

```
brunch build
```

Script tags will compile as

```html
<script src="js/vendor.js"></script>
<script src="js/app.js"></script>
```

```
brunch build --production
```

Script tags will compile as

```html
<script src="js/vendor-24179978.js"></script>
<script src="js/app-24179978.js"></script>
```

## License

MIT

[Brunch]: http://brunch.io
[gzip-brunch]: https://github.com/banyan/gzip-brunch
