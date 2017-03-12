When someone would ask me what is a library I need in each one of my projects in Java, on the top of my list I would put [Google Guice](https://github.com/google/guice). A dependency injection framework, that felt like a breath of fresh air in a field dominated by bloated and explicit Spring Framework. While the latter came a long way since the first release of Guice and improved in many aspects, the Google's library is still much more lightweight and my usual choice.

If you are not familiar with the concept of dependency injection, I recommend you read an excellent book from Uncle Bob Martin, titled [Agile Software Development: Principles, Patterns and Principles](https://www.amazon.com/Software-Development-Principles-Patterns-Practices/dp/0135974445). In a nutshell, dependency injection is an implementation of dependency inversion principle, which states that abstraction should not depend on details, rather the other way around. Guice allows you to do that in a very elegant way with Java code only, and in most cases the basics are enough.

Sometimes in your project you might encounter a situation, when you need to inject a dependency that needs to be constructed for a specific context. A perfect example of such situation is injecting HTTP handlers. Usually handlers behave exactly in the same way, but some of the details may be different between requests. In fact, Guice already tries to solve this problem by providing two annotations: `@RequestScoped` and `@SessionScoped`. The names of the annotations are pretty easy to understand - new instances will be created for each request or each session.

Now, what if you have a little more specific situation, and need you own scope? Fortunately, in this situation, Guice provides a way to implement a custom scope. Unfortunately, let's say [documentation](https://github.com/google/guice/wiki/CustomScopes) in not the most detailed I have ever seen. They even state that it is not recommended to write your own scope, and keeping documentation scarce is a good way to achieve that. I tried to learn and understand how to create my own scope, and I think I managed to at least scratch the surface.

The use case I came up with is that I want a simple greeter, that will return return a String with a greeting. The twist is that the name will be injected to the greeter every single time. The first step will be implementing the annotation for your scope.

{%  highlight java %}
@ScopeAnnotation
@Retention(RUNTIME)
@interface NameScoped {}
{% endhighlight %}

Well, that was easy, wasn't it? If only the whole process was as easy and predictable! The next one is easy in theory, but took me a while to understand what was actually happening. The point is to implement a `Scope` interface, which defines a single method:

{% highlight java %}
class NameScope implements Scope {

    @Override
    public <T> Provider<T> scope(final Key<T> key, final Provider<T> unscoped) {
        return  (Provider<T>) new NameProvider("Joe");
    }
}
{% endhighlight %}

the `scope` method is being called when the injector needs an instance of `T`. In this case, we will always return a provider that look like this:

{% highlight java %}
class NameProvider implements Provider<String> {

    private final String name;

    NameProvider(final String name) {
        this.name = name;
    }

    @Override
    public String get() {
        return this.name;
    }
}
{% endhighlight %}

You implementation of `Scope` interface provides everything that is required by scope, and there should be one instance of your implementation within one injector. Watch out, as these requires proper synchronization across threads. If you take a look at an example provided by Google, you can see that they wrap the object map with `ThreadLocal` object, so that each thread owns another instance of the map.

Now, the scope is ready, finally there is time to implement the greeter. Which as simple as you could expect:

{% highlight java %}
class Greeter {

    @Inject
    private String name;

    String greet() {
        return "Hello, " + name;
    }
}
{% endhighlight %}

All the objects are implemented now, we are ready to to wrap things up in a module:

{% highlight java %}
public class ScopesModule extends AbstractModule {

    @Override
    protected void configure() {
        NameScope scope = new NameScope();

        bindScope(NameScoped.class, scope);

        bind(String.class).in(NameScoped.class);
        bind(Greeter.class);
    }
}
{% endhighlight %}

And now, a quick test to verify it's working:

{% highlight java %}
@Test
    public void should_return_object_with_scoped_value() {
        // given
        final ScopesModule scopesModule = new ScopesModule();
        final Injector injector = Guice.createInjector(scopesModule);

        final Greeter instance = injector.getInstance(Greeter.class);
        assertThat(instance).isNotNull();

        final String greet = instance.greet();
        assertThat(greet).isEqualTo("Hello, Joe");
    }
{% endhighlight %}

The test passes! You can hardly call that an actual scope, as I can't imagine a use case when you need to use a scope that always return the same. If you want an easier way to run this code, I'm also publishing the example as a [gist](https://gist.github.com/mhaligowski/057e2e2a4949063b8d8e347086dfb6d2), so feel free to play with that. All it needs is some dependency management with Guice, JUnit 5 and AssertJ.