---
layout: post
title:  "Free webhosting with GitHub"
date: 2021-03-09
---

GitHub has been offering [Pages](https://pages.github.com/) as a part of their free offering for a very long time. The main idea behind it is to offer developers, projects and organizations a landing page where they can present information about themselves. This idea is reinforced by GitHub by default trying to build your using [Jekyll](https://jekyllrb.com/), a static site generator (in fact, this website is relying on it!). It doesn't change the fact that GitHub Pages effectively is just a static content serving site!

My last project, [Animal Crossing Tunes Studio](https://actunes.studio), is implemented completely on the browser side, with ReactJS and some Web Audio magic. I didn't want to set up a full-blown project with an engine like Firebase, or another service like Netlify - I just needed a plain, boring web hosting, preferably with no additional cost (I'm already paying for GitHub Pro). And Pages was perfect for this. I created a new branch:

```
git branch gh-pages
```

built the project from my `main` branch, then switched branches and removed all the unnecessary files and moved everything from inside of the `build` directory to the root directory. I was even able to set up the domain pretty easily, with auto-generated and auto-refreshed SSL certificate, so I can serve my website over HTTPS!

Over time I got annoyed with the need for manually rebuilding the website every single time I wanted to publish, so I looked into utilizing another awesome feature from GitHub: [Actions](https://github.com/features/actions). If you don't know what it is, it's basically a workflow triggered by changes in your repository. For my case, I wired it so that every single time I push to the `main` branch the website is being built and published. Most of it is pretty straightforwad, except for a simple way to removing all the unnecessary files. After some hacking, I found a way to achieve it with a single-liner in bash:
```
git ls-files | grep -Ev "^\." | grep -Ev "^CNAME$" | xargs rm -rvf
```

This *might* look a little cryptic, but what it does is:
1. list all the files in the repository (in the gh-pages branch!)
1. filter out the hidden files
1. filter out CNAME file (this is GitHub's domain configuration file, don't touch that!)
1. remove all the remainders.

After this, the build folder contents are ready to be moved to the root and files are ready to be commited. Simple, cheap and effective way to run a minimalistic CI and hosting for a single page application.

Unfortunately, the system is not perfect. One huge issue I have is the lack of option to redirect the requests to a particular file. This is important for React apps that utilize React Router package with browser history. Since the new requests with path (for example `/blog`) won't be redirected to `index.html` file to bbe handled by the router, the result of such request will always be 404 status. There are hacks how to utilize `404.html` file to achieve this functionality, but I think they are pretty ugly - I opted in for using a plain query param instead.

While GitHub Pages is a great hosting option for small projects, it's just it - a hosting option. No fireworks, no advanced configuration, no CDN. But with the features available it's probalby just enough for me, at least for simple frontends that need to do one specific thing.

Check out the [Animal Crossing Tunes Studio](https://actunes.studio)!




