---
layout: post
title: "Handling dependencies between AppEngine applications in Go"
date: 2017-03-01
---

Google AppEngine is a great way to write a web service (or app) very fast, with minimum concern over operational issues such as deployment, scaling, monitoring etc. It comes with a very convenient set of tools to integrate with other Google Cloud services (Cloud Storage, Cloud Datastore, PubSub), as well as a couple of dedicated solutions, for example for search indexes or creating task queues. If you haven't given it a try, you definitely should.

I recently played with AppEngine when trying to implement a little side project to help me learn some architectural patterns and Go. The idea there was to structure my app as a microservices, each service being a separate AppEngine application. Writing an AppEngine application is very simple, like this one:

{% highlight go %}
package main

import (
    "net/http"
    "encoding/json"
    "fmt"
)

type Site struct {
    SiteId string `json:"site_id"`
    SiteUrl string `json:"site_url"`
}

func init() {
    sites := []Site{
        Site{"someSite", "https://mhaligowski.github.io"},
    }

    http.HandleFunc("/sites", func(w http.ResponseWriter, r *http.Request) {
        if r.Method != http.MethodPut {
            http.Error(w, "Not allowed", http.StatusMethodNotAllowed)
            return
        }

        output, err := json.Marshal(sites)

        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }

        fmt.Fprintf(w, "%s", output)
    })
}
{% endhighlight %}

This was an initial version, not really down any logic, just declaring a model in my application named `Site`, and returning some stub object. The purpose of that piece just to be sure that it's running.

The development of this project went on to a point I wanted to add another service.  The new service would use the `Site` model. I did the thing that was very natural to me, and just tried import the first package:

{% highlight go %}

package main

import (
    "net/http"
    "encoding/json"
    // import the first service
    "github.com/mhaligowski/sites"
    "fmt"
)

func init() {
    http.HandleFunc("/other", func(w http.ResponseWriter, r *http.Request) {
	    // use the Site object from the first service
    })
}

{% endhighlight %}

This looks pretty obvious, but if you try to run the other service, you'll se an error, saying 

```
panic: http: multiple registrations for /```

The reason for that is that in AppEngine you have to define your handlers in `main` or `init` methods. The methods are also called when the package is imported, and since you already configured the HTTP handlers, it refuses to register other handlers. I looked all over the Internet for potential solutions for this problem. One possible solution was to move the common dependency to a separate package. The downside of such solution is that you create a separate package with a single file, potentially in a separate git repository.

Fortunately, I was able to come up with much simpler solution. The original file structure for the project in the repository looked like this:

{% highlight plain_text %}

pkg
|- main.go
|- app.yaml

{% endhighlight %}

I modified the structure in every single AppEngine package to something like this:

{% highlight plain_text %}
pkg
|-appengine
  |-main.go
  |-app.yaml
|-main.go
{% endhighlight %}

Now, the `main.go` file in `appengine` folder was only calling a `Run()` function from the `pkg` package, like this:


{% highlight go %}
package appengine

import "github.com/mhaligowski/sites"

func init() {
	sites.Run()
}
{% endhighlight %}

Thanks to such approach, when I was importing a package, I was not importing any `init()` method, so the HTTP handlers registration was not called. I developed my side project to use 5 services at this point, and I haven't run to a single problem with such approach.