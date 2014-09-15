---
layout: post
title:  "A new way of extracting values in AssertJ collections assertions"
date:   2014-09-13  
---
We've been using [AssertJ](http://www.assertj.org) in [Young Digital Planet](http://www.ydp.eu) in several Java projects already and we love it. It makes our tests much easier to write and read, mainly thanks to ease of writing custom assertions. The automatically generated assertions worked greatly as a basis for testing our domain classes, except for one problem. There often appears a need to assert a list of our entities by one of their field, and then continue on other assertions. The field usually is an enumerated value and looks like this:

{% highlight java %}
public enum Gender {
    FEMALE,
    MALE,
}

public class Person {
    private final String name;
    private final Gender gender;

    // the constructor and (g|s)etters, etc.
}
{% endhighlight %}

Now, when you wanted to make some assertions on the `Person` instances, you had to extract values using `extracting` method. An example would look like this:

{% highlight java %}
Person wilma, betty, pebbles, fred, barney, bambam;
List<Person> persons = Lists.newArrayList(wilma, betty, pebbles, fred, barney, bambam; // guava-style

assertThat(persons).extracting("gender").containsExactly(FEMALE, FEMALE, FEMALE, MALE, MALE, MALE);
{% endhighlight %}

Even though quite handy, extracting by property name sucks badly in terms of object-oriented design. The fundamental reason is that any change in the class `Person` would cause all the test cases to fail due to property of invalid name. While it does not require many changes when you have a couple of test cases, introducing the change in couple hundreds is hell.

You could always write your own assertions for each of the field, but it is a little overkill. Instead of that, I proposed a change in the AssertJ to appear in version 1.7.0. The change introduced a Single Abstract Method (SAM) interface `Extractor` (you could call it functional if you were using Java 8), which handles the extraction of required property, but also can do any other transformation that is required. Thanks to that there's no longer need to write a whole set of assertions, just a small class that extracts the tested property. Now, the previous example would look like this:

{% highlight java %}
public class GenderExtractor implements Extractor<Person, Gender> {

    // do yourself some good and write a factory method
    private GenderExtractor() { }

    public static Extractor<Person, Gender> gender() {
        return new GenderExtractor();
    }

    @Override
    public Gender extract(Person input) {
        return input.getGender();
    }
}

assertThat(persons).extracting(gender()).containsExactly(FEMALE, FEMALE, FEMALE, MALE, MALE, MALE);
{% endhighlight %}

Much prettier, isn't it? But wait, there's more! Since I've been playing a lot with functional stuff (namely Scala), I added one more method that's complementary to `extracting`, and it's called `flatExtracting`. If you see the similiarity between `extracting` and functional `map`, then the `flatExtracting` should be clear to you. In case you do not see correspondence: the `flatExtracting` extracts lists using the `Extractor` implementations, and then concatenates the lists. Just look at the example:

{% highlight java%}
public class ChildrenExtractor implements Extractor<Person, List<Person>> {
    
    // with a factory method    

    @Override
    public List<Person> extract(Person input) {
        return input.getChildren();
    }
}

assertThat(Lists.newArrayList(fred, barney)).flatExtracting(children()).contains(pebbles, bambam);
{% endhighlight %}

In case you used the old `extracting`, fear not! The old methods were left to ensure the backwards compatibility. The change was merged last week, so feel free to get the snapshot version of AssertJ and test the `extracting`. Also, there are some examples in the git repository [here](https://github.com/joel-costigliola/assertj-examples/pull/17).
