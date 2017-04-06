---
layout: post
title: "Template for running React app in Google AppEngine"
date: 2017-04-05
---

I've been playing with [Google Cloud](http://cloud.google.com/) for some time now, mainly to compare it with what Amazon has to offer. In general, the experience with Google Cloud is very enjoyable, and feels much more developer-friendly than enterprise-friendly than [AWS](http://aws.amazon.com/). There were some things that are more mature and more convenient in Amazon's cloud, like DynamoDB with it's pricing model or messaging with SNS, SQS and Kinesis. One thing that I feel is much better in Google's cloud platform is AppEngine, the Platform-as-a-Service solution. It feels more complete than Elastic Beanstalk, and whole process is more straightforward.

The whole point of me playing with the cloud solutions was decreasing the time-to-market of my projects. Very often I have a seemingly great idea, but the execution takes forever. I lose interest and the project dies before even anyone has a chance to use that. I was constantly trying to to cut some corners in the implementation, especially on the frontend side. After spending some time with AngularJS 1.x I gave ReactJS a try, and immediately got hooked. It's not as explicit as AngularJS, but still it provides some structure to the Javascript code. The last problem I had was the deployment of a React application to the cloud. I tried deploying to the Google Cloud Storage (as well as S3), but I ran into problems I described in one the earlier posts. I decided to run my JS frontend as a Google AppEngine module, but not without some hacks.

Google AppEngine used to have a static serving capabilities, but with introduction of Flex environments I can't find them anymore. I was stranded with serving statics on my own. Moreover, to avoid difficulties such as CORS and additional module to upkeed, I wanted to run a thin layer of API in my module as well. The most obvious solution in the world of Javascript is [Express.js](https://expressjs.com/), and that's exactly what I settled for. I also used an exquisite package [`create-react-app`](https://github.com/facebookincubator/create-react-app) to bootstrap the React application itself. The `create-react-app` documentation recommends using some external web server for serving both statics and the API data (in the blog post [here](https://www.fullstackreact.com/articles/using-create-react-app-with-a-server/)), but I hated the solution - if I wanted to keep them running in separate environments, I would just go with the Cloud Storage solution.

The first step was to initialize the main package, where to whole application will live:

    $ npm init
    
This will create the default project structure for us, fill out the fields like repository, version, author, license, etc. Let's just install some minimal dependencies:

    $ npm install --save express
    
Not much, isn't it? Fortunately, Express comes with a middleware to serve statics (in fact, it's the only middleware that is provided by default), so the whole static-serving stuff will be pretty easy to do. Before we write the actual serving code, let's initialize the application that will run in the browser:

    $ npm install -g create-react-app
    $ create-react-app client
    
This will create another Javascript application INSIDE our main application. This may seem weird, but actually it allows us to keep our server side separate from the client side, and still serve them from a single Javascript package. For development purposes, you can still use the `create-react-app` scripts, for example for development server:

    $ cd client
    $ npm start
    
or to build the application:

    $ npm start build
    
You will have all the benefits of a regular React application, like auto-refresh or JSX compilation. Once you have that ready, you can write the actual server script:

{% highlight javascript %}
var express = require('express')
var app = express()
var path = require('path')

app.use(express.static('client/build'));

app.get('/api', function(req, res) {
    res.send('Hello World');
});

app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, 'client/build', 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, function() {
    console.log('Example app');
});
{% endhighlight %}

As you can see, we're telling our server to serve statics (i.e. the built ReactJS part) from `client/build` directory, so whatever path matches a file in the statics directory, will be served as static. The API part will be served from '/api' path, and everything else will be serving `index.html` file - this will allow us to use `react-router` package. In order to run the server, you need to add one line in the main `package.json`:

{% highlight javascript %}
{
  ...
  "scripts": {
    "start": node app.js",
    ...
  }
  ...
}
{% endhighlight %}

This solution works for the initiali stages of the project and gets the job done, but it's far for perfect. Sure, it allows to move fast and run within a single server, but the statics should be served with a dedicated solution, ideally with a CDN. With solution like this, the API service will be scaled along with the web page resources server, which is a waste of resources. Not to mention that for now there is no caching settings.

The other problems are with the development process, but I believe they can be addressed pretty easily. When you run the API server, the statics are run from the `client/build` folder, which makes you lose all the benefits of using ReactJS goodness. It's definitely a work in progress, not ready to publish that anywhere.
