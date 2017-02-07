---
layout: post
title: "Integrating Google App Engine services with task queues"
date: 2017-02-06
---

Whatever application you are working on, when it reaches some size it is beneficial to split it into microservices, i.e. a couple of smaller ones. This allows you for better management of the resources in each, (usually) more transparent architecture and independent scaling of your components. Microservices are a hot topic nowadays, and if you want to know more about them, Martin Fowler wrote a [great piece](https://martinfowler.com/articles/microservices.html).

Microservices communicate with each other usually using an HTTP protocol, but there is a bunch of situations when simple HTTP calls are taking too long, or there are many steps that you need to take. In cases like this, you may need to use [publish-subscribe pattern](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern). In Google Cloud the most obvious option for that is [Google Cloud Pub/Sub](https://cloud.google.com/pubsub/docs/overview), but a very often overlooked feature for messaging between a bunch of App Engine services is [task queues](https://cloud.google.com/appengine/docs/python/taskqueue/).

## What are task queues
Task queues are a Google App Engine-specific option for performing some part of your work, usually one that takes some time to process or one that is not directly connected with the front-end application. If you are not familiar with pub/sub pattern, just think of them as of some messages being sent by one of the modules, and being received (and processed) by another.

If you are still not convinced, then let me mention one more benefit of task queues: they are usually way easier to setup, compared to whatever language or framework you are using. When you want to run some background jobs in, say, Django, the recommended way is to use [Celery](http://www.celeryproject.org/). This requires setting up some backend and additional configuration. In Java, you usually end up using some futures mechanism (I might be wrong here though, I usually ended up setting up a queue myself). Setting up a task queue in App Engine requires to add a single file in your default App Engine application.

Google App Engine offers two types of task queues. The first one is *push queues*, as in "push this message away from me", and the other one is *pull queues*, as in "make this task available for pulling". I'll give some use cases for both types, and show how to use them.

## Push queues
Adding a task to a push queue is basically saying "I need this to be done". I first came across them when writing an RSS aggregator. My use case was: "I have a bunch of URLs of feeds to get, I want them to be processed in a different module, one at a time, probably in parallel". If you have a similar situation, i.e. you have a relatively large task to be done and you want it to be done somewhere else, go ahead and use push queues.

First, you need to create a push queue. In order to do that, **in the default application of your project** (I mean it, I spent couple of hours trying to figure out why it doesn't work), you need to create `queue.yaml` (or `queue.xml` for Java) file, which looks like this:

{% highlight yaml %}
queue:
    - name: my-push-queue
      rate: 1/s
{% endhighlight %}

This is a minimal queues definition file, which sets the name of the queue to `my-push-queue`, in which the messages will be processed once every second. There are bunch of other options, which you can look up in the [official documentation](https://cloud.google.com/appengine/docs/python/config/queueref).

After creating the queue with the redeployment of the default application (or you can use `appcfg.py update_queues` command), you are ready to start adding tasks to you queue. This is pretty similar to all the languages, for example in Python it looks like this:

{% highlight python %}
from google.appengine.api import taskqueue

def add_task():
    task = taskqueue.add(
        queue_name = "my-push-queue",
        url = "/handle_task",
        target = "target_service",
        params = { 'param': value })
    
    return task
{% endhighlight %}

And that's it. The `target` parameter is the name of the service you want to call and `url` is the path to the handler. Once the task is added to the queue, it will be sent to the handler with the rate you had defined in the queue configuration.

There's not much to add about push queues. There are some limits of course. The handlers need to be HTTP endpoints. By default the content is sent as `POST` with the content encoded as form, but you can easily override it. Also, when using automatic scaling, the timeout for the task execution is 10 minutes, while when scaling manually, the timeout is 24 hours. The last thing worth mentioning is probably that the order of the delivery is not guaranteed and you shouldn't be relying on that.

## Pull queues

Pull queues are a bit more complicated type of the queues. Just like with the push queues, the service that adds a task says "I need this to be done". Also, creating the queue is similar, you need to add `queue.yaml` file to your **default project**:

{% highlight yaml %}
queue:
    - name: my-pull-queue
      mode: pull
{% endhighlight %}

Even adding a task looks almost identical:

{% highlight python %}
from google.appengine.api import taskqueue

def add_task():
    task = taskqueue.add(
        queue_name = "my-pull-queue",
        method = 'PULL',
        params = { 'param': value })
    
    return task
{% endhighlight %}

The huge difference is how the tasks are being distributed. Instead of letting GAE take care of everything, you need take care of reading the tasks from your pull queue manually. This is done by leasing the tasks from the queue, which is saying "Hey, queue! Give me some tasks for some time, I'll try processing them". This is done like this:

{% highlight python %}
from google.appengine.api import taskqueue

def handle_tasks():
    q = taskqueue.Queue('my-pull-queue')
    tasks = q.lease_tasks(3600, 100) # 100 tasks for an hour
    # Perform some work with the tasks here
    q.delete_tasks(tasks)
{% endhighlight %}

This last part, deleting the tasks, informs the queue that the tasks have been processed properly and the lease can end. If the tasks will not be deleted after an hour, the lease will end and the tasks will be picked up by other worker.

This approach requires a bit more design in you handler and doesn't provide you the same convenient scaling mechanisms, but is way more powerful than using push queues. You don't have to worry about your timeouts, as you set them on your own, the access management is more granular. Also, your handler doesn't have to be in Google App Engine, or even in Google Cloud - you can utilize services somewhere else using REST API.

Both of the task queues allow you to distribute you work across different services, and both have their applications and tradeoffs. If you need to distribute a single, long-running task, try using push queues. When you publish many small tasks that can be batched, pull queues are your friends. For those use cases that don't fit into any of these two, there's always Google Cloud Pub/Sub - which deserves it's own blog post.