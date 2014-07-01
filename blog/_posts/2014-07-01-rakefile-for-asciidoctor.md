---
layout: post
title: "Rakefile for Asciidoctor"
date: 2014-07-01
---

This one will be a short one. I fell in love with [Asciidoctor](http://www.asciidoctor.org), a Ruby implementation of the AsciiDoc markdown language. It is much more human-readeble than Markdown, it offers much more flexibility and generates much more beautiful documents than Markdown.

The only downside I've found is the building process. By default Asciidoctor provides three backends, that enable generating documents in HTML and two versions of DocBook (probably each one for each of the DocBook users). It can easily be enhanced by adding more backends from the repository. One of them is dzslides, which generates a nice HTML/JS presentation. It is still not really handy to build it, though:

    asciidoctor -b dzslides -T path/to/dzslides/template yourdocument.adoc

It may get worse when you have more options to use. Thankfully, Asciidoctor is written in Ruby and may use all of the Ruby toolkit, namely bundle for dependencies and rake for building the document. Here's my approach to that:

{% gist f8045192436ac4ebe7e4 %}


