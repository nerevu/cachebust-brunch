fs      = require 'fs'
sysPath = require 'path'
crypto  = require 'crypto'
pathlib = require 'path'

module.exports = class Hash
  brunchPlugin: yes

  constructor: (@config) ->
    @options = @config?.plugins?.hash ? {}
    @targets = @options.extensions or [ /\.css$/, /\.js$/ ]

  onCompile: (generatedFiles) ->
    #return unless @config.optimize

    map = {}

    for target in @targets
      for generatedFile in generatedFiles
        file = generatedFile.path
        if file.match target

          output_file = @_hash file

          input_map = pathlib.relative(@config.paths.public, file)
          output_map = pathlib.relative(@config.paths.public, output_file)

          console.info("Map: #{input_map} => #{output_map}")
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


    console.info("Renaming: #{file} => #{output_file}")
    fs.renameSync file, output_file

    output_file

