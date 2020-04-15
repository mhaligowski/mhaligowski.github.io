---
layout: post
title: "Make life easier with Guice Private Modules"
date: 2017-05-04
---

Couple of weeks ago I wrote a little [post]({%  post_url 2017-04-13-guice-private-modules %}) on how to use private modules, a tragically overlooked feature of Google Guice. To put it shortly, private modules let you define bindings between your classes, and explicitly define which of the binding will be available for injection.

Why would one care about hiding the classes? After all, it does require extra work, there's a risk of runtime problems rather than compilation time, and it doesn't provide any extra function for the end user of your package. The benefits come in the long run. While your application grows, you keep each module separate, doing exactly one thing.

If it's not clear, let's take a look at an example. This is something that you have probably seen a dozen of times: an application that applies some business logic on a data from some persistent store. The twist is, we will do a separate module (and package) for the business logic part, and a separate module for the data access.

Let's start with the business logic part (I'm omitting imports, constructors etc.):

{% highlight java %}
// CustomerDao.java
package business;

public interface CustomerDao {
    Collection<Customer> getCustomers();
}

// Notifier.java
package business;

public class Notifier {

    private final CustomerDao customerDao;

    void notify(String message) {
	      Collection<Customer> customers = customerDao.getCustomers();
	      
	      for (final Customer c : customers) {
	          // notify
	      }
    }
}

// NotifierModule.java
package business;

public class NotifierModule extends AbstractModule {

    protected void configure() {
        requireBinding(CustomerDao.class);
        bind(Notifier.class).in(Singleton.class);
    }
}

{% endhighlight %}

Notice that the `Notifier` class doesn't know about the details of `CustomerDao` at all. This follows the Dependency Inversion Principle, and allows for easier testing. I'm also using `requireBinding` method, which many developers don't really know about. It is really useful, as before any other operations it performs verification that the required binding is already configured.

Now, let's take a look at the implementation of the `CustomerDao`:

{% highlight java %}

// OracleCustomerDao.java
package oracle;

class OracleCustomerDao implements CustomerDao {
    public Collection<Customer> getCustomers() {
        // some implementation for Oracle database
    }
}

// OracleCustomerDaoModule.java
package oracle;

public class OracleCustomerDaoModule extends PrivateModule {
	
	protected void configure() {
		bind(CustomerDao.class).to(OracleCustomerDao.class).in(Singleton.class);
		expose(CustomerDao.class);
	}
}

{% endhighlight %}

The module here binds the `CustomerDao` interface to the Oracle database implementation, but since it's private, we need to expose it explicitly. Another thing worth noticing is that the implementation of the `CustomerDao` interface is package-private. I don't see many people using package-private classes in Java, but the make development way easier. It's basically saying that these are the internals that are not supposed to be used outside of this package, and there needs to be something else used - in this case, a Guide module.

Finally, we can initialize our application:

{% highlight java %}

public class App {
	public static void main(String[] args) {
		Guice.createInjector(new OracleCustomerDaoModule(), new NotifierModule())
        .getInstance(Notifier.class)
         .notify("Hello");
		}
}
{% endhighlight %}

And that's it! With the private module, we encapsulated the whole package and we are sure that it's not going to be used improperly. It's only concern is how to handle fetching the `Customer` instances, and doesn't care about anything else. Thanks to that, the module can be reused easily.

In the other hand, the `Notifier` doesn't care about the details of the `CustomerDao`, and the module just assumes that it will be provided somewhere in the injector. This allows you to switch the implementation depending on the context, for example for tests, or if you need to provide implementation for another storage type.

I hope I convinced you to give private modules a try. I have been using them for some time, and my software usually ends up being easier to maintain and understand for newcomers. The downside may be a tightly coupling yourself with Guice - it is not a problem if you're not going to distribute some of your modules, but if you want allow other people to use your packages, then you're forcing them to use Guice as well. If that's no concern of yours, I strongly encourage you to use private modules wherever you can.
