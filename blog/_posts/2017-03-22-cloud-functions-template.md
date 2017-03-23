---
layout: post
title: "Cloud Functions template"
date: 2017-03-22
---

I've been using [Google Cloud Functions](https://cloud.google.com/functions/) a lot recently. I quickly realized, that I set up most of them in a pretty similar way. I figured that I could share that with other developers, to make it better and share the experiences. So, I distilled my template into a git repository, which is available [here](https://github.com/mhaligowski/cloud-functions-template).

The template uses [Gulp](http://gulpjs.com/) as a toolkit for automating tasks in Javascript projects. I picked it as it seems to get more steam than other similar solutions, like [Grunt](https://gruntjs.com/). In case you haven't that installed in your system, before you continue you need to install Gulp with two commands:

```
$ npm install gulp-cli -g
$ npm install gulp -D
```

Once you have it done, you can start using the template. Probably the easiest way to do that is to download and unzip it from [GitHub](https://github.com/mhaligowski/cloud-functions-template/archive/master.zip). This way you get raw files, without playing with git remotes and such. Remember to update `README` file and `package.json` to include information about your function. After you do that, you can install the local packages with:

```
$ npm install
```

Now, what does the template provide? Not much for now, to be honest. The first problem I was trying to solve was the tricky deployment of Cloud Functions. The thing is, when you deploy from your root repository, there is no easy way of ignoring the `node_modules` directory, which includes all the dependencies your code use. What you can do, is use a `--include-node-modules`, but I don't really want to push my local modules to staging bucket, as they probably contain some development dependencies or some old modules. I would rather just have Google Cloud Functions install them on its own. What I came up with, is copying all the Javascript files and `package.json` to a separate directory, and deploy it from there. To do that, just run

```
$ gulp dist
```

This will do exactly what I described above, with the addition of running tests before. Ah, tests! I hated not having tests for my Cloud Functions, especially when it's so easy to create a stub in Javascript. So, my template also has tests configured, using [Mocha](https://mochajs.org/). There is even an example, so you can start writing tests immediately. In order to run the test suites only, just run:

```
$ gulp test
```

These are all the features for now. I could probably add some minifier, linter and other stuff, but I think this is still good place to start. I haven't tested the template with solutions that utilize multiple Javascript files, I will certainly update that as soon as I know what I want to achieve. Let me know if you are, or planning to use the template, and let me know if there are any improvements you would need!