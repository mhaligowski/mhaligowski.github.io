---
layout: post
title:  "Mixing Google Cloud Functions and Express"
date:   2017-05-15
---

Google Cloud Functions are an awesome tool, which I have already described a couple of times in other posts. If you look at the functions triggered by HTTP calls, they turn out to be regular Express handlers. There are probably some differences in the internals, but that's not something that would change drastically how you write your functions.

So, the question is: can you run the functions written with Cloud Functions in mind with an Express application? Or, the other way around: can you split your Express application to separate Cloud Functions? This question may sound like a pure experiment, but I can imagine a situation where this could be useful. You may have already an application running in an App Engine instance, but you don't want to handle that anymore - splitting into bunch of Cloud Function makes perfect sense.

Let's assume we have a very simple application, with a single handler. All the handler does is returning a piece of text:

{% highlight js %}
// hello.js
module.exports = function hello(req, res) {
    res.send('Hello');
}
{% endhighlight %}

And the code to serve that is a regular Express boilerplate: 

{% highlight js %}
// server.js
var express = require('express');
var app = express();

var hello = require('./hello.js');

app.get('/hello', hello);

app.listen(3000, function() {
    console.log('Listening...');
});
{% endhighlight %}

Nothing unusual as for now. You can run the code in an App Engine environment, you can create a Docker container out of it, but also you can create a Cloud Function, without getting rid of Express part at the same time. This is very useful for larger refactorings, when you want to maintain the same functionality until the new dependency is resolved in all the places.

Here's the thing about Cloud Functions. In order to run properly, it requires `index.js` file or `function.js` file in the main folder that' deployed. We don't want to change anything in the current structure of the application, so here's a simple workaround:

{% highlight js %}
// function.js
exports.hello = require('./hello');
{% endhighlight %}

Bottom line of this is we make our handler available as an export, so that Cloud Functions can pick it up at deployment time. And so, to deploy the function you only need the specify the name of the function, and it needs to be identical with the exported name in `function.js` file:

{% highlight bash %}
$ gcloud beta functions deploy hello 
	--entry-point hello 
	--trigger-http 
	... other parameters
{% endhighlight %}

And this is it! You successfully converted a configured Express handler into a Cloud Function!

As you have probably noticed, there are some caveats with this. Cloud Functions don't have the router included, so all the call are being targeted to a specified address. That can pose a problem when your handler takes only specific HTTP method, for example you use that to read values from a form on your website. 

Another drawback is that you need to add every single exported function in `function.js` file. Usually it shouldn't be a problem, but when you have many functions to deploy, just going through them may be troublesome. Not to mention that you have to deploy your full application to the Cloud Functions!

All the files are available as a [Gist](https://gist.github.com/mhaligowski/d01fe1d6da0e7c5da586c95f5f4efaf4). Feel free to fiddle with them!
