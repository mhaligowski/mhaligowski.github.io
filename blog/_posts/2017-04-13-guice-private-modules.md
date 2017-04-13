---
layout: post
title: "Encapsulation in Guice with Private Modules"
date: 2017-04-13
---

A couple of weeks ago I was talking about the Reuse/Release Principle, which states that the unit of reuse is also the unit of release - whatever you want others to reuse, you need to release with a predictable schedule. The rule doesn't tell much about the code itself, different languages and frameworks will require different approaches to achieving that. On one hand you want to package all the classes that are meant to be reused, on the other hand you don't want the consumers hurt themselves with lower levels of abstractions or depend on something that is likely to change in the future.

Over the development of several projects I figured that the most convenient way to structure you code is using [Google Guice](https://github.com/google/guice). It is a [Dependency Inversion](https://en.wikipedia.org/wiki/Dependency_inversion_principle) container, that's way easier to pick up than the more popular Spring Framework. Unfortunately, since it's so easy to pick up, many developers do not try to learn more about Guice. This leads to medium-sized projects with a single module, with ridiculous number of dependencies defined, and with very few reusable components. One thing that helps to keep you project easier to comprehend and maintain reusable modules is to use private modules. 

The default way to create modules in Guice is to extend from `AbstractModule` class, and bind everything in `configure()` method, like this:

{% highlight java %}

import com.google.inject.AbstractModule;

// Example from Guice Javadoc
public class MyModule extends AbstractModule {
   protected void configure() {
     bind(Service.class).to(ServiceImpl.class).in(Singleton.class);
     bind(CreditCardPaymentService.class);
     bind(PaymentService.class).to(CreditCardPaymentService.class);
     bindConstant().annotatedWith(Names.named("port")).to(8080);
   }
}

{% endhighlight %}

Private modules are very similar in usage, which makes the transition extremely easy. The only difference in their API is the `expose(Class<?> clazz)` method and the `@Exposed` annotation. You can use them to explicitly allow injector to bind the given implementation outside of the current module.

{% highlight java %}

import com.google.inject.PrivateModule;
import com.google.inject.Provides;
import com.google.inject.Exposed;

// Example from Guice Javadoc
public class MyPrivateModule extends PrivateModule {
   protected void configure() {
     bind(Service.class).to(ServiceImpl.class).in(Singleton.class);
     bind(CreditCardPaymentService.class);
     bind(PaymentService.class).to(CreditCardPaymentService.class);
     
     expose(Service.class);
   }
}

@Provides  
@Exposed
public Foo foo() {
    return new Foo();
}
{% endhighlight %}

The `MyPrivateModule` exposes `Service` and `Foo` classes, which means that only these two injections will be possible in the injector. If you try to get other objects bound in the module, Guice will refuse to get you the object like this:

{% highlight java %}

Guice.createInjector(new MyPrivateModule()).getInstance(PaymentService.class);

{% endhighlight %}

As you can see, private modules are easy to use in terms of the changes in your code. They are not much more complicated than regular modules, but give you much better encapsulation of classes of your modules. Applying the private modules is a whole different story, and I intend to do a separate post on that.
