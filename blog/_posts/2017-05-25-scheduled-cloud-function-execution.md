---
layout: post
title:  "Scheduled executions of Google Cloud Functions"
date:   2017-05-25
---

Going serverless allows developers to focus their efforts on the code and not to worry about the infrastructure. This sounds great in theory, but in practice it comes with lots of trade-offs. In case of event-driven computing, developers are limited only to the triggers provided to them by the cloud providers.

Everything is fine as long as the triggers fit in the most popular use cases. These usually are reacting to some messages (SNS, Kinesis in AWS, PubSub in Google Cloud), file or database update. One common situation that seems to be forgotten by cloud providers is time-based execution. What if you want to run your cloud function every day, at exactly 2am? Or you need to check some value every 15 seconds?

AWS, as the more mature platform, started providing cron-based Lambda executions some time ago, but in case of Google Cloud, it doesn't seem that such feature will come in a foreseeable future. I saw that developers face problems running their functions in given time intervals, and came up with a solution to that. I was inspired by a similar solution provided by AWS. Unfortunately, I couldn't remember the source of that.

The original idea was surprisingly simple: spin up an EC2 instance that will have the cron configured, and based on that will publish to an SNS topic. The AWS Lambda function was subscribed to the topic, and was triggered once the message was emitted. This worked well, except for the fact that that it wasn't easy to modify the periods when needed. I could also used a topic provided by the author of the original idea, but then I was giving up on the configurability at all. That meant my function being triggered every 15 minutes, and it was my decision whether I want to take the action or not.

Fortunately, Google AppEngine has task queues. Usually they are considered as a way of distributing the work across multiple applications, or as an integration point. Except for push queues and pull queues, which are indeed designed to serve these purposes, Google Cloud also offers extremely easy to configure cron jobs for AppEngine, which are exactly what's needed in our case.

Before digging into the code, let's recap what we are actually going to do. We'll be running a single AppEngine application, with a single HTTP endpoint. The handler will be called with an interval configured in the cron jobs, and it's only responsibility will be to emit a message to PubSub. The Cloud Function (or many cloud functions) will be subscribed to the topic and will be triggered accordingly. 

Let's start with the handler, an AppEngine application. Currently Google Cloud offers two types of environments: older standard and newer flexible. The latter allows to write in Javascript, which I would probably would go for because of the development time. Flexible environments are too expensive though (at least for the kind of thing I'm trying to achieve), and what I'm going to do is easy in other languages as well. That's why I'll stick with Python standard environment, and the main application that's responsible for emitting to PubSub looks like this:

{% highlight python %}
# main.py
import webapp2

from google.cloud import pubsub


class WatchPage(webapp2.RequestHandler):
    def get(self):
        pubsub_client = pubsub.Client()
        topic = pubsub_client.topic('timer-topic')

        message_id = topic.publish('ping'.encode('utf-8'))
        self.response.write(message_id)



app = webapp2.WSGIApplication([
    ('/watch', WatchPage),
], debug=True)
{% endhighlight %}

There's not much happening here: with every execution the PubSub client gets created and a message `ping` is emitted to topic named `timer-topic`. It would probably make sense to emit for example the timestamp of current  execution - do as you please.

Once the app is ready and deployed (there are some quirks about deploying Python code to AppEngine, read about it [here](https://cloud.google.com/appengine/docs/standard/python/tools/using-libraries-python-27), you need to create the PubSub topic, either in the web console, or in the CLI tool:

{% highlight bash %}
$ gcloud beta pubsub topics create timer-topic
{% endhighlight %}

Now you can try running the AppEngine app from your browser:

{% highlight bash %}
% cloud app browse
{% endhighlight %}

Got to `/watch`, and you should see a random number - an id of the message emitted to the topic. This means that the app is working properly and you are ready to configure the cron job. The cron just calls the endpoint exactly the same way you just did. You just need a single file to set that up, `cron.yaml`. The example below runs every 1 hour (more on the configuration [here](https://cloud.google.com/appengine/docs/standard/python/config/cronref)):

{% highlight yaml %}
cron:
    - description: "regular job"
      url: /watch
      schedule: every 1 hours
{% endhighlight %}

You can deploy the file just like you would deploy the application:

{% highlight bash %}
$ gcloud app deploy cron.yaml
{% endhighlight %}

At this point the application is emitting a message to the PubSub topic every 1 hour, and it is ready to be subscribed by your function. Now, once you have your Cloud Function ready, you need to deploy it with a proper trigger:

{% highlight bash %}
$ gcloud beta functions deploy timer-function --trigger-topic timer-topic (...)
{% endhighlight %}

And you're set! The standard environment has quotas that are enough for this kind of use case. Before you run it in production, be sure to add some level of verification whether the HTTP call is actually coming from AppEngine. Other way, it will be possible to interfere with your timer easily.

The full code for the AppEngine application is available as a [gist](https://gist.github.com/mhaligowski/e1c420fcb3cc7d2df92a0cd7e4de5dfa).
