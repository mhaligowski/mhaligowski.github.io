---
layout: post
title: "Clean code vs Java virus"
date: 2014-06-01
---

It's hard to believe, but there came a day that brought a virus in Java. It's nothing really fancy, but it received some recognition. I was curious enough to check out what's going on there, especially after receiving it from my sister via Facebook.

So the story is: one day, I received a Facebook message from my sister, which was saying "Hahaha" and a ZIP file to be downloaded. Beaing a seasoned Internet user I saved the file to a separate directory and like an experienced minesweeper went to the terminal to unzip it. I disarmed... er, unpacked the file just to see that it contrains a single JAR file. I knew my sister was learning Java at that time, but still, I was suspicious. I called her at once, just to hear that it's some kind of virus that's sending itself to all her friends.

After extracting the JAR file, it turned out that it contains only a single class: SEHKFCJZGYHEDGSCHJBKM. The META/INF/MANIFEST.MF file made it clear that it is the class to be run. One more interesting thing: the JAR file also contained the Eclipse stuff, ie. .classpath and .project files. The main class file though was clearly obfuscated, so I decided to decompile that to find out what's going on in there. The decompiled source code is [here](https://gist.github.com/mhaligowski/9d2272e3761010651549).