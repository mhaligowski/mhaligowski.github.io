---
layout: post
title:  "Top 5 tools for rapid web app development"
date:   2017-06-16
---

Starting up has never been easier, but it's easy to forget yourself and start shaving a yak instead of getting things done. I've been there so many times, I decided to settle for a toolkit that allows me to start (and fail) fast, without spending a single cent, with a limited amount of time. The 5 tools I want to present now are the absolute minimum with which I tend to start every new project.

The list contains mostly the applications that are helpful in setting up landing pages and very limited MVPs. You won't find here backend solutions or languages that will help you build application with a killer performance. Usually the solution there is to go with whatever is the cheapest, but the end user does not see the end result anyway.

## ReactJS for setting up the source code
In 2017 building for the Web means writing a lot of Javascript. Sure, you can do your project in vanilla JS, but if you want to move fast, you need to rely on a framework. And among the incredible noise of numerous Javascript frameworks, libraries, MVVC pattern implementations, template processors and other inventions, there is one choice that you can't go wrong with: [_React_](https://facebook.github.io/react/) from Facebook team. The main goal was to build a framework that will be fast and light for the browser, and the developers achieved that by implementing a virtual DOM, so that the actual changes in the site happen way less often. The model turned out to be versatile enough to be used for [React Native](https://facebook.github.io/react-native), allowing to write the same JS code for iOS and Android apps. This is a topic for another post though, so let's just take a look what makes React so powerful.

First of all, React is surprisingly easy to learn. This is mainly thanks to the perfect documentation with lots of examples, but also to the simplicity of the project itself. If you had been working with AngularJS, you may be startled by how limited React seems in comparison. Fear not, this limitation actually allows you to focus on the behavior of your app, instead of figuring out the order of rendering and the dependency injection of components. Another thing is tooling built around React. Starting with phenomenal [`create-react-app`](https://github.com/facebookincubator/create-react-app) (official project template and configuration), through multiple tools for different tasks, it quickly turns out that most of the problems for web app development have already been solved and all one has to do is `yarn add` (or `npm install`). All of that means that creating new application with React is incredibly fast.

## Semantic UI for making it look stunningly
Creating a compelling design for your website used to be a dire chore back in a day. As a developer I wanted to concentrate on how my software works, not on such dull tasks like ensuring that everything is displayed as expected on different browsers. Things changed a lot when Twitter released [Bootstrap](http://getbootstrap.com) and other CSS systems started emerging. I was finally able to create an interface that looks correctly, without spending too much time on that. And none of these CSS systems feels as complete as [_Semantic UI_](https://semantic-ui.com/).

The main difference between Semantic UI and other similar solutions is that Semantic UI's main tenet is that your website should be built in hierarchical structures of reusable components. This led to a library of over 50 components, which not only provide basic solutions like typography or forms, but also many widgets used is modern web apps, like feeds, user cards etc. The default theme is clean and pleasant to see, and theming is incredibly easy - there are even demos that show you how to make your site look like Twitter or GitHub!

The final thing that makes Semantic UI my choice for app development is how well-supported it is. The default way to use it is to install the source files with `npm`, but the integrations provided (and supported!) mean development time reduced to minimum. Of course, there is also React integration, and I haven't yet met a thing I would need that wouldn't be provided.

## Netlify to host your site
Google's acquisition of `divbase.io` left a hole in my heart. The promising startup provided exactly what I needed, free of charge as long as you do not exceed liberal limits and do not need more advanced features. A perfect mix anyone trying to quickly wrap up an MVP for a new project. Once Divbase was shut down (as far as I understand it was incorporated into Firebase as Firebase Hosting), I tried a couple of similar solutions, finally settling on cloud storage solutions like Amazon S3 or Google Cloud Storage. Until I learned about [_Netlify_](https://www.netlify.com/).

_Netlify_ basically allows you to host your site (or more like web application). It's free version offers everything that you need to set up an initial version, including your own custom domains and SSL certificates from Let's Encrypt, something I never managed to set up properly on cloud storage hosting. And with it's nice CLI setting up your site is a matter of minutes.

Even though the free option should be enough for many solutions,  the basic plan costs measly 9$/month, and offers features that will make your development even easier, like form handling and proxy rules (no more setting up an API just for handling a single call!). This is great for the first milestone of your application.

## Google Analytics for capturing what's happening
[_Google Analytics_](https://analytics.google.com/) is the standard solutions for capturing basic analytics about your web applications. And it's not difficult to understand why it is. It's incredibly easy to set up, and provides multiple features and analysis out of the box. With GA on board, you should be able to answer most of the questions about your users you can have in early stage.

One thing that makes GA awesome is the support. If you don't have much experience in digital marketing (like myself), the resources for learning provided by Google are priceless. There are video courses for both beginners and advanced users, and a huge knowledge database for those that need more.

Google Analytics is the first choice, but you may need a little more sophisticated tool, and `Mixpanel` is probably the solution I would look at first. Compared with other services it offers a generous free option, perfect if you are starting up and don't want to spend dollars on things that you might not really need.

## Mailgun for sending and receiving emails

No matter what kind of application you are building, if you are going to have customers, you'll need some email service to communicate with them. A good hosted choice seem to be whatever email provided by your domain operator, but these usually have hideous user interface and generally lack in possibilities. You can go with [Google GSuite](https://gsuite.google.com/)( (or Microsoft Office 365), but these are very oriented for the business users.

[_Mailgun_](https://www.mailgun.com/) turned out to be surprisingly convenient to use. The pricing plan makes your first 10000 in each month free, so scaling up is very cheap. In the same time it is very developer oriented, so it's API is super simple to use. Moreover, they provide SDKs for popular environments, so that you don't even have to write a special REST layer.

The killer feature is configuration of the email accounts. This means you don't have to set up a full blown email server in order to receive emails from you customers, you can forward it to the email of your choice - even your GMail account. It doesn't even have to be another email address - you can make your email wrapped into JSON an be called to an external REST service (or serverless endpoint). One feature I might be missing though, is better email marketing management, or at least I haven't found it yet.

This concludes the list. I know it's pretty limited, but it is enough to build your landing page or even MVP in a matter of hours and have it available for your customers.