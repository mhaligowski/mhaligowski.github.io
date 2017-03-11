---
layout: post
title: "Handling CORS in Google Cloud Functions"
date: 2017-03-10
---

I was lucky enough to be invited to alpha program of [Google Cloud Functions](https://cloud.google.com/functions/). I've been playing with the functions a little longer since then, and I'm liking them more and more. They are easy to write, fast to deploy and generally fun to work with. I am working on some little tutorial, but for now, I have one issue I can show how to solve.

Last week I started working on a little side project utilizing Cloud Functions. Creating the function went as smoothly as expected, but I ran into a problem when trying to wire-up a website that would call my service - the data was not showing up. I opened the dev console to be presented with an error:

```
XMLHttpRequest cannot load https://us-central1-cloud-functions-154702.cloudfunctions.net/hello. No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'http://localhost' is therefore not allowed access.
```

If you had previously been working with JavaScript frontend applications, you probably know already what is happening. When your web browser is calling a web service that is in a different domain, it doesn't make a GET or POST HTTP request right away, it rather starts with making an OPTIONS request, and compares the value of `Access-Control-Allow-Origin` header in the result with the current domain. When the header value matches the host, the browser goes on and the actual call is being made. Otherwise the action is stopped and the error similar to the one above is thrown. The mechanism is called Cross-Origin Resource Sharing (CORS), and you can read about it more on [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS). It's implemented in all of modern browsers, and it's supposed to increase security.

Now you know what happened and why, but how to actually handle that? The most straightforward solution is just verifying in the Cloud Function whether the request is an OPTIONS request, and returning an appropriate response:

```
if (req.method === `OPTIONS`) {
	res.set('Access-Control-Allow-Origin', << host >>)
	   .set('Access-Control-Allow-Methods', 'GET, POST')
	   .status(200);
	   return;
}
```

This will do the job, but it actually changes the logic of your function, and requires you include that logic in the business code. That makes your code a little more cluttered, and possibly a little harder to write unit tests for. Also, when you will need more complex CORS options, it may take more space and further hide the logic of your code.

Thankfully, Google Cloud Functions use the request and response objets syntax from [Express](http://expressjs.com/) web framework, which means we should be able to use at least part of the software that was written with that framework in mind.

I dug a little, and found that there is already a CORS handler for Express, named (surprisingly) [`cors`](https://www.npmjs.com/package/cors). It supports multiple options, for all the headers featured in the CORS specification. Since Express middleware (i.e. code that runs before the execution of actual handlers) has a little different API than the handlers, I needed to hack around the integration: 

```
var cors = require('cors');

// my function
var helloFn = function helloFn(req, res) {
    res.status(200)
        .send('Hello, Functions\n');
};

// CORS and Cloud Functions export logic
exports.hello = function hello(req, res) {
    var corsFn = cors();
    corsFn(req, res, function() {
        helloFn(req, res);
    });
}
```

As you can see, there is no modification of my original function. For the sake of exports, I renamed the original function to  `helloFn` instead. Now the CORS handling logic is outside of my core function, so I don't have to remember that when modifying my code. Also, instead of reinventing the wheel I reuse a proven library.

The `cors()` method generates a middleware, and optionally takes an object or a function, if you want to change the default settings. Full documentation is available in the [NPM](https://www.npmjs.com/package/cors). There are multiple other libraries for handling CORS, and I expect that those that follow the ExpressJS API for middleware, should work here.

In this post I present how to apply CORS middleware for Cloud Functions. Looking at the code to achieve that, there doesn't seem to be anything special about the CORS middleware. You should be able to set up any other middleware in the same way, and enhance your Cloud Functions with other features, like handling cookies or sessions, authentication etc. To read more about using ExpressJS middleware, go to the official [documentation](https://expressjs.com/en/guide/using-middleware.html).
