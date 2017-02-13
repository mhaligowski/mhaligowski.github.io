---
layout: post
title: "Hello, Google Cloud Functions"
date: 2005-02-01
---

Serverless is getting much attention in the cloud space recently, and it's easy to understand why. By introducing AWS Lambda, Amazon allowed to write new services in the blink of an eye, without having to worry about servers, scaling, and even about the underlying framework.

Developers all over the world fell in love with Lambdas, and soon new extensions followed. Amazon's competitors in the cloud market responded quickly, first with Microsoft Azure Functions, and now Google is introducing public Beta of their [Google Cloud Functions](https://cloud.google.com/functions/).

I was lucky enough to gain access to the alpha version of the product. I was able to play a little with that, and so I present you a very short introduction on how to start with Google Cloud Functions.

Most of the things I present here can be done from the Google Cloud browser UI, but I prefer working from my terminal - I'd just rather hit keys on my keyboard and see what is happening instantly, than watch progress bar, no matter how fancy it is.

I assume that you already have a Google Cloud account, along with a created project and installed Google Cloud SDK in your account. Since Cloud Functions are in beta now, you will need beta components in your SDK installed, so go ahead and type in your terminal:

```
$ gcloud components install beta
```

For deploying a function from your local directory you will also need a Cloud Storage bucket, so you will need `gsutil` installed. To verify that, type:

```
$ gcloud components list
```

For now, Google Cloud Functions supports only JavaScript in Node.js 6 (LTS). This is a little disappointing, but it's more than certain than new languages will follow pretty soon (Google Go, anyone?). I assume that you have Node.js installed already, so go ahead and create two files:

{% highlight js %}
// package.json
{
  "name": "hello",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}

// index.js
exports.hello = function hello(req, res) {
    res.status(200)
       .send('Hello, Functions\n');
};
{% endhighlight %}

It's not hard to guess what this code does. In case you're wondering, the `req` and `res` object follow the request and response object, as defined in [Express.js](http://expressjs.com/en/4x/api.html). 

The code is written, let's deploy it now. When you deploy Cloud Function from a local directory, it is required to have a deployment bucket in Google Cloud Storage service.  This is a little inconvenient, but thankfully Google Cloud also offers deploying directly from a git repository. For the purpose of this tutorial, let's stick to the first option, so create a deployment bucket:

```
$ gsutil mb gs://hello-deployments-123456
```

Remember that the buckets need to have names unique within **all** the Cloud Storage, so you may need to come up with a different name.

Once you have a bucket ready, you can deploy you code, by calling a command from the directory where you put your files:

```
$ gcloud beta functions deploy hello \
    --trigger-http \
    --stage-bucket gs://hello-deployments-123456
```

When calling `deploy` command, Google Cloud deploys or creates a new function, so there's no actual need to create a function before deployment.

You should see a bunch of log statements, saying the files are being copied, and among these a line saying that the status is `READY`. After the operation is finished, you can test it by typing:

```
$ gcloud functions call hello
executionId: x6rd2snkcdvm
result: Hello, Functions
```

If you see something similar to this, it means that your first function is running properly. You could get the actual URL from the deployment logs, but if you already lost (or forgot it), you can just ask for a description and look for `httpsTrigger` parameter:

```
$ gcloud functions describe hello

... [[ some output here ]]
httpsTrigger:
  url: https://[[ your url here]]
... [[ some other output ]]
```

Now, when you send an HTTP request with `curl` (or just visit the URL in your browser), you should see a message:

```
$ curl https://us-central1-your-project-123456.cloudfunctions.net/hello
Hello, Functions
```

And that's it! You created, deployed, and tested your very first Cloud Function. What you just did is just the tip of an iceberg. First, I haven't mentioned about the limits, but they are pretty similar to what competitors offer: you can define how much memory your function requires, and how long will it take to run.

In my example, I've shown how to create a basic HTTP trigger, but Google Cloud allows you to have other triggers as well: Google Datastore rows actions, Cloud Storage files, Google Pub/Sub notifications or Firebase actions. I haven't tried all of them yet, but will definitely do that. Have fun tinkering, and let me know whether there's something more to cover!