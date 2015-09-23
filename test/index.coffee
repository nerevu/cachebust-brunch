expect = require('chai').expect

path = require 'path'
fse = require 'fs-extra'

Hash = require('../src/index')

FIXTURES_SHA1SUMS =
  'public/empty.css': 'da39a3ee'
  'public/oneliner.css': '7638fdaa'

FIXTURES_OUTPUT =
  'public/empty.css': 'public/empty-da39a3ee.css'
  'public/oneliner.css': 'public/oneliner-7638fdaa.css'
  'public/dot.dot.css': 'public/dot.dot-da39a3ee.css'

buildFilename = (file) ->
  path.join(__dirname, file)

testFileExists = (file) ->
  fse.existsSync(buildFilename(file))

setupGeneratedFiles = ->
  fse.removeSync path.join(__dirname, 'public')
  fse.copySync path.join(__dirname, 'fixtures'), path.join(__dirname, 'public')

describe 'Hash', ->
  hash = null

  beforeEach ->
    hash = new Hash(
      env: ['production']
      paths:
        public: path.join('test', 'public')
    )

#  after ->
#    fse.removeSync path.join(__dirname, 'public')

  it 'is an instance of Hash', ->
    expect(hash).to.be.instanceof(Hash)

  describe 'hash calculation', ->
    beforeEach ->
      setupGeneratedFiles()

    it 'calculate hash for test files', ->
      for file of FIXTURES_SHA1SUMS
        expect(hash._calculateHash(path.join(__dirname, file))).to.equal FIXTURES_SHA1SUMS[file]


  describe 'file rename operations', ->
    beforeEach ->
      setupGeneratedFiles()

    it 'check output filenames', ->
      for file of FIXTURES_OUTPUT
        expect(hash._hash(path.join(__dirname, file))).to.equal path.join(__dirname, FIXTURES_OUTPUT[file])

  describe 'no generated files', ->
    beforeEach ->
      setupGeneratedFiles()
      hash.onCompile({})

    it 'original files exist', ->
      for file of FIXTURES_OUTPUT
        expect(testFileExists(file)).to.be.true

    it 'no hashed files exist', ->
      for file of FIXTURES_OUTPUT
        expect(testFileExists(FIXTURES_OUTPUT[file])).to.be.false

    it 'manifest has been created', ->
      expect(testFileExists('public/manifest.json')).to.be.true

    it 'manifest should be empty', ->
      manifest = fse.readFileSync(buildFilename('public/manifest.json'))
      expect(manifest.toString()).to.be.equal '{}'

