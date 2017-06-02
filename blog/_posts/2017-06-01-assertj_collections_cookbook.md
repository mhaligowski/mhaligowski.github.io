---
layout: post
title:  "AssertJ and collections cookbook"
date:   2017-06-01
---

When programming in Java you often end up writing methods returning a collection of objects. They certainly have their place in your application, but testing them can be a little tricky. Depending on the implementation of the underlying collection the order of the elements may be different, the `equals` on collections is not always obvious, and so on. I have come across multiple examples of such cases in my career, and I decided to pick a couple of them and show a way to tackle with AssertJ, the assertions library you should definitely be using.

All the recipes follow the same format. I present a short description, followed by the implementation of the test. The test is always successful, to avoid confusions. Each recipe ends with a short remark, what other situations can this be used for. I'm also using Guava library to create the collections, as vanilla Java doesn't really provide a way to do that.

We could use some Java primitives like `String` or `int` for the sake of test, but in the wild this is not seen very often. Let's say we're making an RPG game, so we're going to have a lot of POJOs, representing different characters and objects in the game. For example, a class representing a monster:

{% highlight java %}
public class Monster {
    private String id;
    private String name;
    
    // constructor for all arguments		
    // getters and setters
    // equals based on id and hashCode
}
		
{% endhighlight %}

The code for both the model and the tests is available as [gist](https://gist.github.com/mhaligowski/a902ed35910b223633c0f187a0cd0947).

## Collection contains an expected element
Let's kick off with the simplest one. You want to be sure that the list returning from one method contains an element (or elements) that is interesting to you. AssertJ allows you to achieve that with `contains` method and its negative counterpart `doesNotContain`. The method checks whether the given elements are in the collection:

{% highlight java %}
assertThat(beasts).contains(direwolf);
assertThat(beasts).contains(werewolf);

// the same
assertThat(beasts).contains(werewolf, direwolf);

assertThat(beasts).doesNotContain(vampire);
{% endhighlight %}

The first two lines check that `direwolf` and `werewolf` belong to `beasts` collection. As you can see in the next line, you can also verify multiple elements.

One thing to remember is that the method does not care neither about all the elements (i.e. it doesn't check whether there are other elements too), nor about the order.

## Collection contains all the elements I am interested in, no matter what is the order
When generating collections, it's pretty often that you don't care about the order of the elements. This is where `containsExactlyInAnyOrder` is useful:

{% highlight java %}
assertThat(beasts).containsExactlyInAnyOrder(direwolf, werewolf);
assertThat(beasts).containsExactlyInAnyOrder(werewolf, direwolf);
{% endhighlight %}

This assumes that the count of the elements is exactly the same, but the order doesn't play any role. You can achieve similar goal using `containsExactlyElementsOf` that takes an `Iterable`, but it's not as elegant.

## Collection contains all the elements I am interested in, in a given order
This is similar to the previous one, bot without `...InAnyOrder` (duh!):

{% highlight java %}
assertThat(beasts).containsExactly(direwolf, werewolf);

// this one is false this time
// assertThat(beasts).containsExactly(werewolf, direwolf);
{% endhighlight %}

## Collection contains only the given elements
This sound similar to the first one, but there's a little twist: we don't cary about the counts, we only care if there are other elements:

{% highlight java %}
List<Monster> group = Lists.newArrayList(direwolf, direwolf, werewolf, werewolf, werewolf);

assertThat(group).containsOnly(direwolf, werewolf);
assertThat(group).containsOnly(werewolf, direwolf);
{% endhighlight %}

This can be useful for example for collection of enumerations that potentially can be repeated multiple times. Remember this doesn't check any order!

## Collection with element appearing only once
This sounds similar to the previous one. Even the method is named similarly: `containsOnlyOnce`. The idea behind that is very different, though. While `containsOnly` checks whether in the collection there are no other elements, this one checks that the given element exists in the collection (just like `contains`), and it appears exactly once:

{% highlight java %}
List<Monster> group = Lists.newArrayList(direwolf, direwolf, werewolf, vampire);

assertThat(group).containsOnlyOnce(vampire);
assertThat(group).containsOnlyOnce(werewolf);

// this one is false
// assertThat(group).containsOnlyOnce(direwolf);
{% endhighlight %}

It sounds like a good idea to have a method that allows you to verify more complex counts, but unfortunately at the moment of writing this post there is no such method.

## Collection of elements with given properties
Now, something cool (it's cool because I wrote that). When you want to check that the collection contains the elements that have given property set to expected value, you can use `extracting` method. With Java 8 lambda function it greatly increases readability:

{% highlight java %}
assertThat(beasts).extracting(Monster::getName)
                  .containsExactly("Direwolf", "Werewolf");
{% endhighlight %}

Supplemental method is `flatExtracting`. It is used for properties that return `List`, and actually merges the lists from the properties.

The recipes describe above are the most common use cases for writing tests of methods that return collections. If you feel that I am missing something, please let me know!
