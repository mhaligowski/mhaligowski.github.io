---
layout: post
title: "Mockito and constructor + field injection"
date: 2014-05-30
---

As mentioned in a previous post, I'm using [Mockito](https://code.google.com/p/mockito/) extensively. It's a superb framework that helps writing unit test a lot.

Recently, I came across a problem when trying to write a test for a legacy Spring class, that used injection in both constructor and field. In Guice, the class would like like this:

{% highlight java %}
package io.mhlg.assisteddemo.service;

import com.google.inject.assistedinject.Assisted;
import io.mhlg.assisteddemo.domain.Money;

import javax.inject.Inject;

class InternetPayment implements Payment {
    @Inject
    private InternetDataSender internetDataSender;
    @Inject
    private InternetDataPreparer internetDataPreparer;

    private final Money money;

    @Inject
    public InternetPayment(@Assisted Money money) {
        this.money = money;
    }

    @Override
    public String sendThePayment() {
        String theMessage = internetDataPreparer.prepareMessage(money);

        return internetDataSender.sendTheDataViaInternet(theMessage);
    }

}
{% endhighlight %}

This isn't an often case, but I can imagine a situation when that would be used.

Trying to test such a class with Mockito can be tricky. It turns out that when using `@InjectMocks` annotation, Mockito injects mocks only to the constructor, leaving the fields undefined. In order to test it properly, one needs to initialize the class with the constructor parameter and Mockito by hand:

{% highlight java %}
package io.mhlg.assisteddemo.service;

import static org.assertj.core.api.Assertions.assertThat;

import io.mhlg.assisteddemo.domain.Money;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import static org.mockito.Mockito.when;

public class InternetPaymentTest {

    @InjectMocks
    private InternetPayment testObj;

    @Mock
    private InternetDataPreparer internetDataPreparer;

    @Mock
    private InternetDataSender internetDataSender;
    private Money someMoney;

    @Before
    public void setUp() throws Exception {
        someMoney = Money.createMoney(100, "USD"); // you can use mock(Money.class) here instead
        testObj = new InternetPayment(someMoney);
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testSendThePayment() throws Exception {
        // given
        final String somePreparedMessage = "some message";
        when(internetDataPreparer.prepareMessage(someMoney)).thenReturn(somePreparedMessage);

        final String someReturningMessage = "return message";
        when(internetDataSender.sendTheDataViaInternet(somePreparedMessage)).thenReturn(someReturningMessage);

        // when
        final String result = testObj.sendThePayment();

        // then
        assertThat(result).isEqualTo(someReturningMessage);
    }
}
{% endhighlight %}
