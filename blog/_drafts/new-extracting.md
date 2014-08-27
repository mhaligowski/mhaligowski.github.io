---
layout: post
title:  "A new way of extracting values in AssertJ collections assertions"
date:   2014-08-18  
---
We've been using AssertJ in Young Digital Planet in several Java projects already. It makes our tests much easier to write and read, mainly thanks to ease of writing custom assertions. The automatically generated assertions worked greatly as a basis for testing our domain classes, except for one problem. There often appears a need to assert a list of our entities by one of their field (usually an enumerated value), like this:

{% highlight java %}
public enum Gender {
    FEMALE,
    MALE,
}

public class Person {
    private final String name;
    private final Gender gender;

    // the constructor and (g|s)etters
}
{% endhighlight %}

Now, when you wanted to make some assertions on the `Person` objects, you had to extract values using `extracting` method. An example would look like this:

{% highlight java %}
Person wilma, betty, pebbles, fred, barney, bambam;
List<Person> persons = Lists.newArrayList(wilma, betty, pebbles, fred, barney, bambam; // guava-style

assertThat(persons).extracting("gender").containsExactly(FEMALE, FEMALE, FEMALE, MALE, MALE, MALE);
{% endhighlight %}

Even though quite handy, extracting by property name sucks badly. The fundamental reason is that any change in the class `Person` would cause all the test cases to fail due to property of invalid name. While it does not require many changes when you have a couple of test cases, introducing the change in couple hundreds is hell.

You could always write your own assertions, but it is a little overkill. Instead of that, I proposed a change in the AssertJ to appear in version 1.7.0. The change introduced a single-method interface `Extractor` (you could probably name that a functional in Java 8), which handles the extraction of required property. Thanks to that it is no longer required to write a whole set of assertions, just a small class that extracts the tested property. Now, the previous example would look like this:

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

