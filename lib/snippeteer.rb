module Snippeteer
  VERSION = '0.1.0'
  # Container for code tagged with language metadata.
  class Snippet < Struct.new(:lang, :code); end

  # Filesystem interface for the document reader. Reads files
  # and writes/runs extracted snippets.
  class Writer
    attr_reader :path, :scanners

    # Takes a filename and a list of scanners. Scanners are expected to have
    # a `scan' method that takes a string and returns a list of Snippets.
    def initialize(path, scanners)
      @path, @scanners = path, scanners
    end

    # Write extracted snippets to files according to their language. Returns
    # a hash mapping language to filename.
    def write_sources
      basename = File.basename path
      sources.each_with_object({}) do |snip, written|
        lang, src = snip
        srcname = basename + lang.ext
        File.open(srcname, 'w') {|srcfile| srcfile.write src}
        written[lang] = srcname
      end
    end

    # Write extracted snippets, then execute them if an execution command is
    # given for their language. By default, removes the written files after
    # execution. Returns a list of filename, exit status pairs.
    def run_sources(cleanup = true)
      srcs = write_sources.each_with_object([]) do |written, run|
        lang, srcfile = written
        if lang.exec
          run << [srcfile, system("#{lang.exec} #{srcfile}")]
          FileUtils.rm srcfile if cleanup
        end
      end
    end

    def sources
      Reader.new(File.read(@path), @scanners).sources
    end
  end

  # Document reader. Extracts and aggregates snippets from data.
  class Reader
    attr_reader :data, :scanners
    def initialize(data, scanners)
      @data, @scanners = data, scanners
    end

    def snippets
      scanners.reduce([]) {|snips, scanner| snips + scanner.scan(data)}
    end

    def sources
      snippets.each_with_object({}) do |snip, srcs|
        srcs[snip.lang] ||= ""
        srcs[snip.lang] << snip.code
      end
    end
  end

  # Container & registry for language information.
  class Lang < Struct.new(:ext, :exec)
    UNKNOWN = new ".txt"
    @registry = {}

    class << self
      # Define a new (or redefine an old) language, with
      # filename extension and optional execution command.
      def register(name, ext, exec = nil)
        @registry[name] = new(ext, exec)
      end

      def find(lang)
        if found = @registry.keys.find {|m| m == lang}
          @registry[found]
        else
          UNKNOWN
        end
      end
    end

    # here's a super incomplete list of languages
    register "haskell", ".hs", "runhaskell"
    register "ruby", ".rb", "ruby"
    register "python", ".py", "python"
    register "c", ".c"
    register "c++", ".c++"
    register "php", ".php", "php -f"
    register "perl", ".pl", "perl"
    register "javascript", ".js"
    register "coffeescript", ".coffee", "coffee"
    register "clojure", ".clj", "clojure"
    register "clojurescript", ".cljs"
    register "erlang", ".erl"
    register "lisp", ".lisp", "sbcl --script" # arbitrary + non-portable choice
    register "shell", ".sh", "sh"
    register "java", ".java"
    register "lua", ".lua", "lua"
    register "scheme", ".scm"
    register "go", ".go"
    register "ocaml", ".ml"
  end

  # A _very_ simple parser for Jekyll pages that tries to extract code from
  # Liquid highlight tags and partition it by language. Should just work as
  # long as you don't give it nested highlight blocks or something like that.
  class LiquidHighlightScanner
    HIGHLIGHT = /^\s*{%\s*highlight\s+(\w+).*%}\s*$/
    ENDHIGHLIGHT = /^\s*{%\s*endhighlight\s*%}\s*$/

    def self.scan(doc)
      new(doc).scan
    end

    def initialize(doc)
      @lines = doc.lines.each
      @snips = []
    end

    def scan
      unhighlit
    rescue StopIteration
      @snips
    end

    private
    def highlit(lang)
      snip = Snippet.new lang, ""
      until (l = @lines.next) =~ ENDHIGHLIGHT
        snip.code += l
      end
      @snips << snip
      unhighlit
    end

    def unhighlit
      until (l = @lines.next) =~ HIGHLIGHT; end
      highlit Lang.find $1
    end
  end
end

