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
    hashedFiles = {}

    unless @config.optimize
      for target in @targets
        for generatedFile in generatedFiles
          path = generatedFile.path

          if path.match target
            hashedName = @_hash path
            inputPath = pathlib.relative(@publicFolder, path)
            outputPath = pathlib.relative(@publicFolder, hashedName)
            hashedFiles[inputPath] = outputPath

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

    glob "#{@publicFolder}/#{reference}", {}, (err, refFiles) ->
      if err
        throw new Error('Error with reference param ', err)

      for _, refFile of refFiles
        if fs.existsSync(refFile)
          content = fs.readFileSync(refFile, 'UTF-8')

          for inputPath, outputPath of hashedFiles
            ext = path.extname(inputPath)
            base = path.basename(inputPath, ext)
            regExp = new RegExp(base + ext)

            if regExp.test(content)
              content = content.replace(regExp, outputPath)
              debug("Replaced #{inputPath} by #{outputPath} in #{refFile}")

          fs.writeFileSync(refFile, content)
        else
          throw new Error('File not found ', refFile)
