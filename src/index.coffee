fs = require 'fs'
crypto = require 'crypto'
pathlib = require 'path'
glob = require 'glob'

module.exports = class Hash
  brunchPlugin: yes

  constructor: (@config) ->
    @options = @config?.plugins?.hash ? {}

  onCompile: (generatedFiles, generatedAssets) ->
    paths = glob.sync(pathlib.join(@config.paths.public, '*/*.*'))

    map = {}

    for path in paths
      unless path.match(/\.map$/)
        if @config.optimize
          outputPath = @_hash path
        else
          outputPath = path

        input_map = pathlib.relative(@config.paths.public, path)
        output_map = pathlib.relative(@config.paths.public, outputPath)

        map[input_map] = output_map

    manifest = @options.manifest or pathlib.join(@config.paths.public, 'manifest.json')
    fs.writeFileSync(manifest, JSON.stringify(map, null, 4))

  _calculateHash: (file) ->
    data = fs.readFileSync file
    shasum = crypto.createHash 'sha1'
    shasum.update(data)
    precision = @options.precision or 8
    shasum.digest('hex')[0..precision-1]


  _hash: (file) ->
    dir = pathlib.dirname(file)
    ext = pathlib.extname(file)
    base = pathlib.basename(file, ext)

    hash = @_calculateHash file

    output_base = "#{base}-#{hash}#{ext}"
    output_file = pathlib.join(dir, output_base)


    fs.renameSync file, output_file

    output_file
