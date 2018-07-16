fs = require 'fs'
crypto = require 'crypto'
pathlib = require 'path'
debug = require('debug') 'brunch:cachebust'

module.exports = class Cachebust
  brunchPlugin: yes

  constructor: (@config) ->
    @options = @config.plugins?.cachebust ? {}
    @publicFolder = @config.paths.public
    @targets = @options.extensions or [/\.css$/, /\.js$/]

  onCompile: (generatedFiles) =>
    hashedFiles = {}

    if @config.optimize
      for target in @targets
        for generatedFile in generatedFiles
          path = generatedFile.path

          if path.match target
            hashedName = @_hash path
            inputName = pathlib.relative(@publicFolder, path)
            outputName = pathlib.relative(@publicFolder, hashedName)
            hashedFiles[inputName] = outputName

      @replaceContent hashedFiles

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

  replaceContent: (hashedFiles) =>
    reference = @options.reference or 'index.html'
    refFile = "#{@publicFolder}/#{reference}"
    content = fs.readFileSync(refFile, 'UTF-8')

    for inputName, outputName of hashedFiles
      ext = path.extname(inputName)
      base = path.basename(inputName, ext)
      regExp = new RegExp("#{base}#{ext}")

      if regExp.test(content)
        content = content.replace(regExp, outputName)
        debug("Replaced #{inputName} by #{outputName} in #{refFile}")

    fs.writeFileSync(refFile, content)
