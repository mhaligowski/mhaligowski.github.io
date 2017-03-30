---
layout: post
title: "Package Principles I: Reuse/Release Principle"
date: 2017-03-29
---

No matter what programming language or technology you are using in your day-to-day work, at some point you probably came across the teachings of Robert C. Martin (also known as [Uncle Bob](https://butunclebob.com)). He wrote down the principles of keeping your code clean and readable in an excellent ["Clean Code"](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) book, and defined principles for class design in object-oriented programming called SOLID, after first letters of five principles. If you haven't had a chance to apply them in your work, I highly recommend to give it a try. It will make your software easier to maintain, and in consequence faster to develop and more fun to work on.

The class-level principles (SOLID) are the most popular and widely adopted. Just to quickly summarize them:

1. **Single Responsibility Principle** states that a class should do exactly one thing,
2. **Open/Closed Principle** tells us that we should make our classes hard to modify, but easy to extend,
3. **Liskov's Substitutability Principle** assures that extending types are compatible with super types,
4. **Interface Segregation Principle** tells us to keep the interfaces (or public methods) small, and it's better to provide bunch of small interfaces rather than fewer large ones,
5. **Dependency Inversion Principle** states that the dependencies in the class should be provided, rather than created by the class itself.

They are pretty easy to follow when understood correctly, but even when applied they can lead to nasty organization of your code and code that is hard to maintain - you probably have seen Java packages with dozens of classes inside. This is where package-level principles enter. Six principles help us decide what to put in your packages (*package* is defined as a single binary deliverable, like a *jar* file), and what the interactions between the packages should look like.

The first principle, **Release/Reuse Equivalency** states that everything that is going to be reused, needs to be released and tracked. This doesn't have much to do with writing the code, applying algorithms or data structures, but how to structure your software into smaller components. It requires the maintainer to organize the releases, provide a way to migrate from one version to another and, if for some reason user is unable to migrate to newer version right away, support the older version.

When you apply the principle, you have to consider the consequences of supporting the package. The first intuition is to structure your components into multiple very small modules - after all, when you need to reuse one of them, you'll be ready, right? This approach leads to hell with managing the releases of multiple packages. You have to notify the user, ensure that none of the changes are breaking and support the old version for some time.

So, why not going to the opposite side of the spectrum and make your complete application a package? You don't want your users drag all the burden of your full software, including things that are not meant to be reused, such as logging systems or some authentication. This means that the released package should only contain classes that are meant to be reused. And this is exactly what the equivalency between reused and released tells about. Be sure that only those things that are supposed to be reused are released in a software package, and be sure that you don't add things that are not supposed to be reused.

The one thing to consider is what is going to be reused together in the package you release. Think of it as a Single Responsibility Principle for packages - the package you release should with intention to be reused should contain only those classes are needed in the same context. Don't make some users of your package to use only some part of the functionality.

I'm still trying to wrap my head about the Reuse/Release Equivalency, and still thinking about an example, and will revisit this once I find (or figure out) something appropriate.

