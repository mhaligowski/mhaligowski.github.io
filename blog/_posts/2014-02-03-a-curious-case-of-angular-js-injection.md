---
layout: post
title: "A curious case of dependency injection in Angular JS"
date: 2014-02-03
---

I've been working on my [AngularJS](http://angularjs.org/) application for nearly half a year now (quite intensively for the first four months), when I decided that I want to run it somewhere else except for my local laptop. The solution consisted of two separate layers: REST service in Java (no persistance yet) and a nice AngularJS web app. The deployment of the backend worked like a charm - I had no need for external applications yet, I had continuous testing set on [Travis CI](https://travis-ci.org/), all I had to do was to add one line to automatic Heroku deployment.

Even though the frontend part was a pure HTML+JS solution, it gave me a strange error, which I could not have reproduced on my local machine. The deployment went easily, the application is automagically installed, or rather just copied, to S3. Amazon S3 has rewrites set up so it works just like a web server. I entered the address in the browser, _et voilà_, it works perfectly. I thought that nothing can go wrong with a plain page, but still wanted to test the whole of it. And bang!, the controller in the second page went out with the dreaded "Unknown provider" error.

That gave me a hard time. I thought that something may be wrong with minification process that's a part of building process, so I made the distribution at my local machine and run it directly from the browser. And it worked fine. Then I tried running with Python (FTW!) server:

{% highlight bash %}
$ python -m SimpleHTTPServer
{% endhighlight %} 

And guess what? It still run great! That was becoming more and more frustrating to me. I reminded myself of the DI and minification remarks in AngularJS tutorial - one should include a list of dependencies when defining a component like this:

{% highlight js %}
angular.module.controller('MyController', ['$scope', '$http', function($scope, $http) { ... });
{% endhighlight %}

I did not do that, and that probably is a mistake which I should fix some time. But still, I never used that in my app, and it worked both on local machine, as well as (partially) on S3! I started to looking deeper into the files, and I finally found the reason. Having used the Yeoman template for AngularJS application, I was also using a couple of Grunt plugins. One of them was responsible for minifying the JS files and substituting them in index.html file. Long story short, it turned out that one of my files had changed case in its name. Changing the case fixed the problem immediately.

A couple of lessons learned here. First of all, such situation won't happen if I had continous deployment from the beginning. I am cooking up another post about that, so stay tuned. The second conclusion is that I should have followed the rules given by Angular JS from the beginning. And I really need to find some time to catch that up.

TL;DR: "Unknown provider" error in AngularJS was caused by a typo in a file name.

