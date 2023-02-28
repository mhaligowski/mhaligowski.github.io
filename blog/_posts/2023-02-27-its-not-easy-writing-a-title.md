---
layout: post
title: "Today I Learned: It’s Not Easy Writing a Title"
date: 2023-02-27
tags: writing, investigation
---

{::comment} INTRO: what I wanted to achieve {:/comment}
This is not really a technology/programming post, even though it started as one. While writing the post on VSCode snippets I realied that the title in the front matters is always lowercased. This happens because the title is taken from the filename, without any modifications. You can even spot that the title in one of the recent posts is written in lowercase. I wondered if this can be validated somehow (talking about the silly things to keep the mind occupied).

{::comment} why it was hard? {:/comment}
The title-ification is a surprisingly complex concept. I initially thought about making an NPM package to handle that, but then I started digging. English is not my mother's tongue, and initially I hoped it's just as simple as a capitalization of every letter, like this:

    > Today I Learned: It’s Not Easy Writing A Title

This is the simplest thing to implement (and understand), but I remembered that the "a" shouldn't really be capitalized in the titles, and son shouldn't "an". So, maybe every two letter word should be lowercased? Of course, starting with the 2nd position?

At this point other questions started popping up:

* how should the colon be treated in regards to capitalization?,
* are there any words shorter than 3 letters that SHOULDN'T be lowercased?,
* and on, and on, and on...

{::comment} how I solved it {:/comment}
I tried to find a definitive list of such cases, in hope of converting it to JS library and publish it as an NPM packager. Years ago I owned a paper copy of [Chicago Manual of Style](https://www.chicagomanualofstyle.org/home.html), a definitive guide on how to write in English (well, American-English). I had misplaced my copy a long time ago, but thankfully a Google search gave me something better: online [Title Case Converter](https://titlecaseconverter.com/).

It turned out the the problem is more complex than I initially expected. There are actually multiple standards on how to properly settle the case of the characters in the title, anc Chicago Manual of Style is just one of them. A [post](https://titlecaseconverter.com/rules/) by the author (one Matthias Belz from Germany) gives a pretty nice explanation.

{::comment} what else did i need {:/comment}
Now, on to integrate it into the blog writing!