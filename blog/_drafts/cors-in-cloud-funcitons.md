
Recently I wrote a short introduction on how and when to use Google Cloud Functions (if you missed that, it's available [here]({{ site.baseurl }}{% post_url 2017-02-15-hello-cloud-functions %})). I've been playing with the functions a little longer since then, and I'm liking them more and more. They are easy to write, fast to deploy and generally fun to work with.

Last week I started working on a little side project utilizing Cloud Functions. Creating the function went as smoothly as expected, but I ran into a problem when trying to wire-up a website that would call my service - the data was not showing up. I opened the dev console to be presented with an error:

```
XMLHttpRequest cannot load https://us-central1-cloud-functions-154702.cloudfunctions.net/hello. No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'http://localhost' is therefore not allowed access.
```

If you had previously been working on a JavaScript, you probably understand what is happening. When your web browser is calling a web service that is in a different domain, it doesn't make a GET or POST HTTP request right away, it rather starts with making an OPTIONS request, and compares the value of `Access-Control-Allow-Origin` header in the result with the current domain. When the header value matches the host, the actual call is being made,  otherwise the action is stopped and the error similar to the one above is thrown. The mechanism is called Cross-Origin Resource Sharing (CORS), and you can read about it more on [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS).

Now you know what happened, but how to actually handle that? The most obvious one is just verifying whether the request is an OPTION request, and returning an appropriate response:

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

I dug a little, and found that there is already a CORS handler for Express, named (surprisingly) [`cord`](https://www.npmjs.com/package/cors). It supports multiple options, for all the headers. Since Express middleware (i.e. code that runs before the execution of actual handlers) has a little different API than the handlers, I needed to modify the code a little: 

```
var cors = require('cors');

// my function
var helloFn = function helloFn(req, res) {
    res.status(200)
        .send('Hello, Functions\n');
};

// CORS logic
exports.hello = function hello(req, res) {
    var corsFn = cors();
    corsFn(req, res, function() {
        helloFn(req, res);
    });
}
```

As you can see, there is no modification of my original function. For the sake of exports, I renamed that to `helloFn` instead. Now the CORS handling logic is outside of my core function, so I don't have to remember that when modifying my code. Also, instead of reinventing the wheel I reuse a proven library.

The `cors()` method generates a middleware, and optionally takes an object or a function, if you want to change the default settings. Full documentation is available in the [NPM](https://www.npmjs.com/package/cors).
