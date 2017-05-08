---
layout: post
title:  "Exceptions testing in Java and AssertJ"
date:   2017-05-08
categories: java testing assertj
---

As long as I have been writing tests and seeing other write them, Java exceptions were a problem for many programmers, including those more experienced ones. When exception is being thrown, it stops the execution of the code going up to the top of the execution stack, or until is being handled. In unit test environments, this usually means that the execution of the given test is stopped, and whatever code runs after the exception is not going to be executed. This means that the most obvious way to verify the exception is to do that in the `catch` block:

{% highlight java %}
// easy exception handling
@Test
public void test_and_validate_exception() throws Exception {
	// given
	MyService testObject = new MyService();
	
	// when-then
	try {
	  testObject.throwAnException();
  } catch (Exception ex) {
    assertTrue(ex instanceof NullPointerException);
  }
  
  fail("Expected exception not thrown");
}
{% endhighlight %}

The code does exactly what it's supposed to do - verifies that some `NullPointerException` is being thrown from the method. It's valid, but I still don't like it. It introduces some logic to the validation, something that should be avoided in tests. In simple example like the one above it's usually not a problem, but with larger number and more complex tests it can obfuscate the purpose.

One way to handle that is to add parameters to `@Test` annotation. This is pretty straightforward:

{% highlight java %}
// this is for JUnit 4+, in TestNG it's expectedExceptions
@Test(expected = NullPointerException.class)
public void test_and_validate_exception() throws Exception {
	// given
	MyService testObject = new MyService();
	
	// when-then
  testObject.throwAnException();
}
{% endhighlight %}

Now, this is way better. The test doesn't contain any logic for catching the exception in order to verify that. This is still not perfect, though. Your tests should be divided into three sections: given-when-then, in that order. It ensures that whoever reads the test understands what is happening, and what the system under test is supposed to do. Not to mention that you don't have access to the actual exception object, so you can't verify the message or the underlying cause of the exception.

Thankfully, later versions of Unit allow you to use the [rules mechanism](http://junit.org/junit4/javadoc/4.12/org/junit/Rule.html). They provide wrappers over the tests, allowing you to modify the execution of the particular test. You can implement your own rules, but Unit provides a couple of them pre-implemented. One of them is [`ExpectedException`](http://junit.org/junit4/javadoc/4.12/org/junit/rules/ExpectedException.html) which, as you would have probably guessed, expects an exception. With that, the next step in our example looks like this:

{% highlight java %}
// needs to be public
@Rule
public ExpectedException thrown = ExpectedException.none();

@Test
public void test_and_validate_exception() throws Exception {
	// given
	MyService testObject = new MyService();
	
	// expect
	thrown.expect(NullPointerException.class);
	
	// when
  testObject.throwAnException();
}
{% endhighlight %}

Now, all the logic of the test is explicitly stated in the test, and with `ExpectedException` you can check the class, the message and the underlying cause. The only thing that bothers me, is having to state the requirements for the exception before  the tested method. This disturbs the flow I had mentioned earlier.

For a long time, one could do a better job by importing external libraries, like (`catch-exception`)[https://github.com/Codearte/catch-exception]. The rescue comes in [AssertJ](http://joel-costigliola.github.io/assertj/), one of my favorite Java libraries (I have even pushed some commits a couple of years ago!). The solution was possible thanks to lambda expressions that came in Java 8, and looks like this:

{% highlight java %}
@Test
public void test_and_validate_exception() throws Exception {
	// given
	MyService testObject = new MyService();
	
	// expect
  Throwable thrown = catchThrowable(() -> { testObject.throwAnException() });
	
	// when
	assertThat(thrown).isInstanceOf(NullPointerException.class)
	                  .hasNoCause()
	                  .withStackTraceContaining("NullPointerException");              
}

{% endhighlight %}

Pure perfection! I feel sorry for myself for using JUnit extensions for so long, while the perfect solution was just under my nose! As you can see, there is a proper execution with the result, and a set of verifications after that. There is no inversion of execution, so you can do other validations, for example verify that a mock was (or wasn't) called.

Before the AssertJ exceptions handling, it was hard to convince someone not to use the plain `try-catch` solution. But now I can't why anyone would need to be convinced. The AssertJ approach is far superior, and I'm looking forward to start using that in all my projects.
