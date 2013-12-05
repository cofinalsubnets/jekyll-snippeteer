# snippeteer
code snippet extractor & runner for Jekyll blog posts. test your examples with almost no effort!

```shell
$ cat post.markdown
herp derp blog post

{% highlight c %}
int herp;
{% endhighlight %}

{% highlight python %}
puts('derpity')
{% endhighlight %}

{% highlight c %}
double derp = herp;
{% endhighlight %}

$ snippeteer snip post.markdown
wrote post.markdown.c
wrote post.markdown.py
$ cat post.markdown.c
int herp;
double derp = herp;
```

`snippeteer` also knows how to run code in some languages directly:

```shell
$ snippeteer run post.markdown
derpity
```

## extending

`snippeteer` can be extended to recognize new languages:

```shell
$ cat snip_ext.rb
class Snippeteer::Lang
  register "trendy", ".tr", "runtrendy"
end
$ snippeteer --load snip_ext.rb run trendy-lang-takes-hacker-news-by-storm.markdown
```

