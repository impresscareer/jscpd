logger = require 'winston'

{Detector} = require './detector'
{Strategy} = require './strategy'
{Report} = require './report'

optionsPreprocessor = require './preprocessors/options'
filesPreprocessor = require './preprocessors/files'
debugPreprocessor = require './preprocessors/debug'

Promise = require "bluebird"

class JsCpd

  preProcessors: [
    optionsPreprocessor
    filesPreprocessor
    debugPreprocessor
  ]

  LANGUAGES: []

  execPreProcessors: (list) ->
    preProcessor @ for preProcessor in list

  run: (options) ->
    @options = options
    @execPreProcessors @preProcessors

    unless @options.debug
      strategy = new Strategy @options
      detector = new Detector strategy

      report = new Report @options

      codeMap = detector.start @options.selectedFiles, @options['min-lines'], @options['min-tokens']

      generateReport = =>
        reportResult = report.generate codeMap
        @report = reportResult
        @map = codeMap
        report: @report, map: @map

      if @options.blame
        Promise
        .all(clone.blame() for clone in codeMap.clones)
        .then generateReport
        .error generateReport
      else
        return generateReport()

module.exports = JsCpd
