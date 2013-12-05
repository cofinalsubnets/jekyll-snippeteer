$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'snippeteer'
require 'rake'

Gem::Specification.new do |spec|
  spec.name = 'snippeteer'
  spec.version = Snippeteer::VERSION
  spec.author = 'feivel jellyfish'
  spec.email = 'walpurgisriot@gmail.com'
  spec.files = FileList['snippeteer.gemspec',
                        'README.markdown',
                        'LICENSE',
                        'lib/*',
                        'bin/*']
  spec.test_files = FileList['test/**/*']
  spec.executables = ["snippeteer"]
  spec.bindir = 'bin'
  spec.license = 'MIT/X11'
  spec.homepage = 'http://github.com/walpurgisriot/jekyll-snippeteer'
  spec.summary = 'Code snippet extractor & runner.'
  spec.description = 'Code snippet extractor & runner for Jekyll posts.'
end

