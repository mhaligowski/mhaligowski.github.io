---
layout: post
title: "Developing Grunt plugin"
date: 2014-03-02
---

While developing my side project in AngularJS, I ran into a problem with building distribution of the app. Everything seemed to work just fine: the unit and integration tests on my machine, the build process on Travis CI, the deployment to S3 (I'll be switching to CloudFront soon, though). I sent a message to my tester/wife, asking for a quick review. I received a single complaint: why does it load so slow?

I ran the developer plugin in Chrome, and found the reason: the AngularJS minified script took nearly 1MB with no compression (thank you, S3!). It turned out that grunt-google-cdn plugin, wrapping google-cdn util, had not been updated for quite a long time, resulting in downloading the AngularJS library from bower, instead of a CDN. In fact, it was too late to just dump the version in the dependencies - the API had changed, and it was already easier just to write own plugin from scratch.

## Step 0. To the GitHubMobile!
When you are to write your own Grunt plugin, you are probably aware of the JS ecosystem. I am refering here to [NPM (Node.js Package Manager)](https://www.npmjs.org/ NPM), which is a package manager for node.js. If you want your plugin (or in fact any node.js module) to be available for other developers, you have to publish it there. You can easily google for advice how you should do that, but I decided to go with Travis CI, which can automatically publish your code to NPM. So, I initialized a repository [grunt-google-cdnify](https://github.com/mhaligowski/grunt-google-cdnify "Repository for grunt-google-cdnify") and configured Travis CI for auto-deployment to NPM from git branch master (in opposite for develop branch for development).

## Step 1. Initialize the plugin
Having the deployment configured, the plugin initialization is really easy. All you have to do is:

{% highlight bash %}
    $ npm install -g grunt-init
    $ git clone git://github.com/gruntjs/grunt-init-gruntplugin.git ~/.grunt-init/gruntplugin
    $ grunt-init gruntplugin
{% endhighlight %} 

The first command install `grunt-init` package, the second one installs the template for a Grunt plugin, and the last one initializes that. During initialization you will be asked couple of questions, regardings names, license, your email etc. All of the steps can be found on [Grunt website](http://gruntjs.com/creating-plugins "Creating plugins"), which you should defintitely visit before starting development of your own plugin. It also contains info on naming your plugin with one important note: **do not prefix your plugin with grunt-contrib**. It is reserved for Grunt development team.

## Step 2. You write your tests first, right?
The template comes with sample test written in nodeunit. You can probably call that an integration test, as the idea is to run your plugin against a set of arguments, just like in a real Grunt task, and then compare the results. In my `Gruntfile.js` it looked like this:

{% highlight js %}
    module.exports = function(grunt) {
        cdnify: {
            integration: {
                html: [ 'tmp/integration/index.html' ],
                bower: 'test/fixtures/integration/bower.json'
            },
            multifile: {
                html: [ 'tmp/multifile/*.html' ],
                bower: 'test/fixtures/multifile/bower.json'
            }
        }
    }

    grunt.registerTask('test', ['clean', 'copy', 'cdnify', 'nodeunit']);
{% endhighlight %}

As you can see, my `cdnify` task is run against two sets of arguments (yes, I have two test cases). First, the plugin is run, then the `nodeunit` task compares the results with expected values.

My plugin was rather straightforward, but obviously not all plugins are like that. In such case, you will probably need to write some unit tests.

## Step 3. Write the plugin
To be honest, that was the easy part, at least for my plugin. What I did was basically registering a [multitask](http://gruntjs.com/creating-tasks#multi-tasks "Grunt tasks"), that run the `google-cdn` for replacing the JS libraries from bower with CDN versions. Easy as that, I fell into a trap of asynchronicity.

It turns out that Grunt runs its tasks asynchronously, which can lead to problems with bower cache access. In order to do that, Grunt provides a way to tell that the task is asynchronous:

{% highlight js %}
    grunt.registerMultiTask('yourtask', 'Asynchronous task', function() {
        var done = this.done();

        // asynchronous stuff

        done();
    }
{% endhighlight %}

It works fine, but for working on multiple files in my case I had to use additional node.js module `async`. It helps when working with asynchronous code, and is definitely worth checking out. It contains `each` method, which allows you to run asynchonous code on collection of objects, and do additional execution upon all the previous job were finished.

{% highlight js %}
    asynch.each(collection, 
        function(collectionItem, functionToBeCalledWhenAsyncProcessingIsFinished) {
            runAsyncOperation(function(result, error) {
                // this is callback for asynchronous operation
                functionToBeCalledWhenAsyncProcessingIsFinished();
            });
        },
        function(err) {
            // run after all the async operations is done
        }
    )
{% endhighlight %}

## Sum up
Writing Grunt plugins isn't really very hard. Hope I cleared out a little how one does that. Have fun writing ours! 

Grunt-google-cdnify is available [here](https://www.npmjs.org/package/grunt-google-cdnify).