#!/usr/bin/env ruby
require 'test/unit'
require_relative '../lib/snippeteer'

POST = <<EOF
hai this hurr is my blog
i have written sum coed:
{% highlight c %}
int num = 2;
{% endhighlight%}

{%highlight  ruby%}
nums = [1,2,3] # lol
{% endhighlight %}

{% highlight  c %}
const char *myTxt = "i am writin c";
// lol i dont get y C needs semmicolons?
{%  endhighlight  %}

<a href="mailto:the_code_kid93@yahoo.com">HIRE ME</a>
EOF

POST.freeze


class LangTest < Test::Unit::TestCase
  def test_find
    assert_equal Snippeteer::Lang.find("haskell"), Snippeteer::Lang.new(".hs", "runhaskell")
    assert_equal Snippeteer::Lang.find("ruby"),    Snippeteer::Lang.new(".rb", "ruby")
    assert_equal Snippeteer::Lang.find("blargysploo"), Snippeteer::Lang::UNKNOWN
  end

  def test_register
    # modifying entries
    Snippeteer::Lang.register "ruby", ".rb", "jruby"
    assert_equal Snippeteer::Lang.find("ruby").exec, "jruby"

    # creating new entries
    Snippeteer::Lang.register "made_up_lang", ".mul"
    assert_equal Snippeteer::Lang.find("made_up_lang"), Snippeteer::Lang.new(".mul", nil)
  end
end

class ScannerTest < Test::Unit::TestCase
  def test_scan
    results = Snippeteer::LiquidHighlightScanner.scan POST
    assert_equal results.size, 3
    assert_equal results.select {|r| r.lang.ext == ".c"}.size, 2
    assert_equal results.select {|r| r.lang.ext == ".rb"}.size, 1

    text = results.map(&:code).join
    assert !(text =~ /HIRE ME/)
  end
end

class ReaderTest < Test::Unit::TestCase
  def lang(l)
    Snippeteer::Lang.find l
  end

  def test_sources
    srcs = Snippeteer::Reader.new(POST, [Snippeteer::LiquidHighlightScanner]).sources
    assert_equal srcs.size, 2
    assert srcs.has_key? lang "ruby"
    assert srcs.has_key? lang "c"
    assert_equal srcs[lang "c"].lines.size, 3
  end
end

