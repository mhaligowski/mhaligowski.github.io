---
layout: post
title: "Unexpected mock verification in Spock"
date: 2014-05-06
---

I've been using [Mockito](https://code.google.com/p/mockito/) for quite a long time now and I consider myself rather fluent at that. Mock verification is not a case that I use often, but I can imagine a case for that. In Mockito I would just write a test like this one:

{% highlight java %}
@Test
public void shouldVerifyTheMock() {
  // given
  SuperDuperUrl mockUrl = mock(SuperDuperUrl.class);
  when(mockUrl.getText()).thenReturn("expectedResult");

  SuperDuperService testObj = new SuperDuperService(mockUrl);

  // when
  String result = testObj.doTheMagic(); // doTheMagic calls the mock

  // then
  assertThat(result).isEqualTo("expectedResult");
  verify(mockUrl).getText();
}
{% endhighlight %}

I'm just checking the result and verifying the call of the mock.

I recently wanted to do something similar in [Spock](https://code.google.com/p/spock/), a fresh-and-all-blinky-test-framework. So, I wrote:

{% highlight groovy %}

def "should do the magic with groovy mock"() {
  given:
  def mockUrl = GroovyMock(URL)
  def expectedString = "whoaaa, it works!"
  mockUrl.text >> expectedString

  def testObj = new SuperDuperService(superDuperObjectWithText: mockUrl)

  when:
  def result = testObj.doTheMagic()

  then:
  1 * mockUrl.text
  result == expectedString
}

{% endhighlight %}

First run, aaaaaand it failed. I thought that the problem was with my mocking the final class, which URL is, but I also tried mocking a non-final class with same effect. After some time I found the answer in the [Spock docs](http://spock-framework.readthedocs.org/en/latest/interaction_based_testing.html#combining-mocking-and-stubbing).

This is the correct version:

{% highlight groovy %}
def "should do the magic with groovy mock [CORRECTLY]"() {
  given:
  def mockUrl = GroovyMock(URL)
  def expectedString = "whoaaa, it works!"

  def testObj = new SuperDuperService(superDuperObjectWithText: mockUrl)

  when:
  def result = testObj.doTheMagic()

  then:
  1 * mockUrl.text >> expectedString // see, that's how you configure the mock!

  and:
  result == expectedString
}
{% endhighlight %}

TL;DR: Stubbing and mocking in Spock example [here](https://gist.github.com/mhaligowski/42d2b54c0fbd65e95d9d).
