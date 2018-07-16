fs = require 'fs'
crypto = require 'crypto'
pathlib = require 'path'
glob = require 'glob'

module.exports = class Hash
  brunchPlugin: yes

  constructor: (@config) ->
    @options = @config?.plugins?.hash ? {}
    @publicFolder = @config.paths.public
    @targets = @options.extensions or [/\.css$/, /\.js$/]

  onCompile: (generatedFiles) =>
    unless @config.optimize
      return

    hashedFiles = {}

    for target in @targets
      for generatedFile in generatedFiles
        path = generatedFile.path

        if path.match target
          hashedName = @_hash path
          inputPath = pathlib.relative(@publicFolder, path)
          outputPath = pathlib.relative(@publicFolder, hashedName)
          hashedFiles[inputPath] = outputPath

    manifest = @options.manifest or pathlib.join @publicFolder, 'manifest.json'
    fs.writeFileSync manifest, JSON.stringify(hashedFiles, null, 4)

  _calculateHash: (file) =>
    shasum = crypto.createHash 'sha1'
    shasum.update fs.readFileSync file
    precision = @options.precision or 8
    shasum.digest('hex')[0...precision]

  _hash: (file) =>
    dir = pathlib.dirname(file)
    ext = pathlib.extname(file)
    base = pathlib.basename(file, ext)

    hash = @_calculateHash file
    outputBase = "#{base}-#{hash}#{ext}"
    outputFile = pathlib.join(dir, outputBase)
    fs.renameSync file, outputFile
    outputFile




