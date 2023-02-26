---
layout: post
title: "Quick Intro To Visual Studio Code Snippets"
date: 2023-02-25
---

{::comment} INTRO: what I wanted to achieve {:/comment}
I often have a huge block when trying to write a new post. In the spirit of trying to get rid of the obstacles and mental blocks, I figured I could try to make it a little easier by at least having some templates. I looked into couple options: using [Alfred snippets](https://www.alfredapp.com/help/features/snippets/) was one of them, but I eventually went with using [Visual Studio Code snippets](https://code.visualstudio.com/docs/editor/userdefinedsnippets).

{::comment} why it was hard? {:/comment}
Last time I created my templates, that was for [IntelliJ](https://www.jetbrains.com/idea/). That IDE provides an incredible set of snippets for creating Java classes, tests and others. Writing your own snippets was pretty straightforward too. I mostly use VS Code for editing these days (in place of Vim), since it became a pretty much default text editor for (Java|Type)Script, so naturally I figured I could go this way.

On the other hand, Alfred's snippets have an option of writing snippets too. I considered using it to kick-off the articles, with a little guide on the structure. While Alfred does the job, it ain't really a programmer's tool. I wasn't sure about the formatting, and the easiest way to use it is to use a keyword. VS Code fitted better here - I could use some auto-generated values, so it made more sense.

{::comment} how I solved it {:/comment}

The VSCode documentation on the snippets is pretty well-written, but the trimmed-down version requires creating a `.code-snippets` file. It's just a simple JSON file with a single object. Each property is a string representing a title, while the contents is a configuration of a snippet.

This is what my snippet for the blog posts:

```
  "post header": {
    "scope": "markdown",
    "prefix": "post",
    "body": [
      "---",
      "layout: post",
      "title: \"${0:${TM_FILENAME_BASE/-/ /g}}\"",
      "date: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE",
      "---"
    ],
    "isFileTemplate": true
  },
```

Most of the parameters are self-explanatory, but the most interesting one is probably the `body`. Each of the strings in the list represent a line in the snippet, and there are actually couple of variables I used:

* `${0:${TM_FILENAME_BASE/-/ /g}}` takes the filename and replaces hyphens with spaces (`sed`-like),
* `$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE` puts the current date.

The snippet is activated with a `Ctrl+Space` shortcut, i.e. invoking the IntelliSense helper.

{::comment} what else did i need {:/comment}
The snippet works pretty good (at least I wrote this post using it). There are still couple of things I can do better. Most importantly, I would like to understand what does the `isFileTemplate` parameter do. `isFileTemplate` is again self-explanatory, but I don't really know how to invoke this. Looks like you can replace a file with "Populate File from Snippet" command, but it seems like an extra step over just using IntelliSense.

The other improvement is formatting the title. The current version just takes the raw file name, which I like to keep lowercased. The [snippet docs](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_grammar) don't allow for the "title case", even though there's "Transform to Title Case" in the Command Palette.
