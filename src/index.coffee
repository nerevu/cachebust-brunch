fs = require 'fs'
crypto = require 'crypto'
pathlib = require 'path'
debug = require('debug') 'brunch:cachebust'

module.exports = class Cachebust
  brunchPlugin: true

  constructor: (@config) ->
    @options = @config?.plugins?.cachebust or {}
    @publicFolder = @config?.paths?.public or 'public'
    @targets = @options?.extensions or [/\.css$/, /\.js$/]

  onCompile: (files, assets) =>
    hashedFiles = {}

    if @config.optimize and @options.enabled
      @targets.forEach (target) =>
        files.forEach (file) =>
          path = file.path

          if path.match target
            hashedPath = @_hash path
            inputPath = pathlib.relative(@publicFolder, path)
            outputPath = pathlib.relative(@publicFolder, hashedPath)
            hashedFiles[inputPath] = outputPath

      @replaceContent hashedFiles

    manifest = @options.manifest or pathlib.join @publicFolder, 'manifest.json'
    fs.writeFileSync manifest, JSON.stringify(hashedFiles, null, 4)

  _calculateHash: (file) =>
    shasum = crypto.createHash 'sha1'
    shasum.update fs.readFileSync file
    precision = @options.precision or 8
    shasum.digest('hex')[0...precision]

  _hash: (path) =>
    dir = pathlib.dirname(path)
    ext = pathlib.extname(path)
    base = pathlib.basename(path, ext)

    hash = @_calculateHash path
    outputFile = "#{base}-#{hash}#{ext}"
    outputPath = pathlib.join(dir, outputFile)
    fs.renameSync path, outputPath
    outputPath


  replaceContent: (hashedFiles) =>
    reference = @options.reference or 'index.html'
    refFile = "#{@publicFolder}/#{reference}"
    content = fs.readFileSync(refFile, 'UTF-8')

    Object.entries(hashedFiles).forEach ([inputPath, outputPath]) =>
      regExp = new RegExp(inputPath)

      if regExp.test(content)
        content = content.replace(regExp, outputPath)
        debug("Replaced #{inputPath} by #{outputPath} in #{refFile}")

    fs.writeFileSync(refFile, content)
