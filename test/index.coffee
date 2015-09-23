expect = require('chai').expect

path = require 'path'
#fs = require 'fs'
#fse = require 'fs-extra'

Hash = require('../src/index')

describe 'Hash', ->
  hash = null

  beforeEach ->
    hash = new Hash(
      env: ['production']
      paths:
        public: path.join('tests', 'public')
    )

#  after ->
#    fse.removeSync path.join(__dirname, 'public')

  it 'is an instance of Hash', ->
    expect(hash).to.be.instanceof(Hash)



