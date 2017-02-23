---
layout: post
title: "Dependency Inversion in Go"
date: 2017-02-22
---

I've been playing with [Go](https://golang.org/) language for a couple of months now, and I'm getting more and more excited about it. All my professional career I have considered myself a Java programmer in the first place, proficient enough in other programming languages and technologies. Entering the rather low-level world of Go was a little shock for my object-orientation sense. The structs and interfaces with runtime polymorphism (i.e. a struct implements an interface when it implements all the method an interface defines, without a need for an explicit declaration) make you think about structuring your code a little differently.

For couple of years now, I've been trying to structure my code following SOLID principles. I wanted my code to be understood, tested, extended and maintained easily. These principles were introduced with object-oriented programming in mind, and so most of the reference you find over the Internet is for object-oriented languages like Java, C# o r C++. With slight alterations, it was pretty easy to apply them in Python, Ruby or JavaScript code, even though it felt unnatural at some times. But when I started working on a bit larger side project, and wanted to have it tested properly in Go, I had to take a step back and think a little.

The SOLID principle that is used probably the most widely and gives most benefits when applying is Dependency Inversion Principle. The most in-depth explanation is presented by [Uncle Bob Martin](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod), and it goes like this:

> A. High level modules should not depend upon low level modules. Both should depend upon abstractions.

> B. Abstractions should not depend upon details. Details should depend upon abstractions.

What this means, is that you should not rely on concrete implementations, rather on the interfaces that are defined for these implementations. Take a look at this Java example:

{% highlight java %}

class MyService {
    private RESTService other = new RESTService();
      
    public String doSomeAction() {
        return other.call();
    }
}

class RESTService implements ExternalService {
    @Override
    public String call() {
        // external service call
    }
}
{% endhighlight %}

This class would probably would do its job when run, but it introduces a couple of problems. First, it's pretty hard to write a fast, reliable test for this class. Since it's always relying on the concrete implementation that makes an external call, you can't guarantee the results are always the same, and certainly not controlled by you. Also, if you want to provide another implementation instead of REST service, you can't really do that.

The code above violates the Dependency Inversion Principle: high-level module (`MyService`) depends on a low-level module (`RESTService`), and the `MyService` class depends upon detail (`RESTService`). Fortunately, it is usually easy to fix that problem in Java:

{% highlight java %}

class MyService {
    private ExternalService other;
    
    public MyService(ExternalService service) {
        this.other = service;
    }
      
    public String doSomeAction() {
        return other.call();
    }
}
{% endhighlight %}

Now, the high-level module doesn't depend on low-level module any more, rather on abstraction (`ExternalService` interface), as well as there's no dependency on details.

I got used to the pattern so much I rarely write code in a different way. Especially when you are using a dependency injection library, like [Google Guice](https://github.com/google/guice), your code tends to be well-structured and easy to maintain.

When I started working on my project in Go, I had some trouble writing clean code. I was trying to get the job fast, so my first attempts looked like something like this:

{% highlight go %}

func handleGet(w http.ResponseWriter, r *http.Request) {
    // this is Google Cloud Datastore
    ctx := appengine.NewContext(r)
    query := datastore.NewQuery("Item").Order("-order_sequence")
    
    var items []Item
    _, err := query.GetAll(ctx, &items)
    
    // ... this goes on
}
{% endhighlight %}

I immediately ran into problems when trying to write unit tests for that code. It was bound to use Cloud Datastore implementation, so if I couldn't run the function without access to Google Cloud. I obviously violated Dependency Inversion Principle, and needed to fix that. Fortunately, the awesome types system in Go made it really easy: 

{% highlight go %}
type itemFetcher func(r *http.Request) ([]Item, error)
    
func handleGet(w http.ResponseWriter, r *http.Request, fetch itemFetcher) {    
    var items []Item
    _, err := fetch(r)
    
    // ... this goes on
}

func datastoreFetcher(r *http.Request) ([]Item, error) {
    ctx := appengine.NewContext(r)
    query := datastore.NewQuery("Item").Order("-order_sequence")
    
    var items []Item
    _, err := query.GetAll(ctx, &items)

    return items, err
}
{% endhighlight %}

I was finally able to work test like I was supposed to do in the beginning. The code above uses function types and passes that as a function parameter. The other way would be making a structs, and pass it as a field. It's a little more explicit and I feel like a Java crusader trying to apply Java patterns in Go, but this definitely does the job.

