---
layout: post
title: "Playing with Alfred workflows"
date: 2023-02-11
---

I have been using workflows in Alfred for a while (quick search in my gmail inbox shows I bought powerpack over 5 yrs ago!). I mainly used it as a replacement for the Mac OS Finder feature, which is incredibly poor in comparison. Over the years Alfred was constantly developed, but I never realized how powerful they can be. Last week I finally got around and started playing with the Workflows. This post serves as a documentation of what I was trying to do and what I did to achieve it.

# Idea for a workflow

Since I've been reading "Deep Work" for some time, I figured I could use some help getting focused. I was also inspired by one of the sample workflows provided by Alfred, that basically has a few steps:

1. Start workflow on a particular keyword.
1. Show a system notification informing about the start of the workflow.
1. Pause the execution of the workflow for the particular time.
1. Show another system notification, informing about the finish of the focus period.

Pretty easy, but I wanted to have it a little more extensible and add more features to it. One of the features I really wanted is enabling Background Noises, a new cool feature from Apple.

# MacOS background noises
In one of the recent versions of MacOS (and iOS, for that matter) Apple introduced a new interesting feature: Background Sounds. If you ever were in a noisy surrounding you might have tried using something similar. What it does is play some ambient sounds (ocean, jungle, rain, etc.) independently of your other music players. I had been using that on my iPhone and AirPods Pro for reading sessions in public, to disconnect myself from the surrounding. I had manually tried it for better focus on my Mac, with a great effect. It sounded like a natural extension of the "focus" workflow - start the particular ambient sound when it is time to focus, and finish the focus time is up.

There was one problem with it, though. The function is buried pretty deep in the Accessibility features (both MacOS and iOS), and it seems that Alfred doesn't know yet how to switch that. Thankfully, some digging in the Apple forums gave me a bash-friendly answer on flipping the background sounds on and off:

```
defaults write com.apple.ComfortSounds "comfortSoundsEnabled" -bool "false"
launchctl kill SIGHUP gui/501/com.apple.accessibility.heard
```

The first line enables or disables the Background Sounds (for some reason called ComfortSounds here), the second line restarts the accessibility daemon (I think). Now it was just the matter of connecting it with "Run Script" workflow step in Alfred, et voila! The whole script was ready.

# Steps

This is what my workflow actually does. The screenshot is below:



## Keyword steps

There are two keyword steps that can trigger the workflow, both configured from the workflow. One of them accepts the minutes parameter, the other one provides it by default. I haven't figured out how to override the defaults in this case, but it seems to be working correctly. The default one doesn't accept any parameters, and just propagates the workflow variable to the `query` value.

## First run script: conversion

One thing that annoyed me in the original script was the fact that I had to use seconds. The popular pomodoro timer defaults to 25 minutes, which is 1500 seconds - of course I will forget it. So, I added script in Python that returns the value provided in `query` as seconds. Why Python? Well, I tried fighting with Script Filter first, but it seems that I misunderstood it's purpose. Apparently it's used for replacing the values in-place in the Alfred Window, which is not what I wanted.

## Other run scripts: control the background sounds

This just runs the two bash commands presented earlier, that controls the background noises.

## Delay

Taken right from the original workflow. It just takes a number of seconds that it needs to pause until stops the sounds and shows the end notification.

# Limitations and next steps

The script does it's work now, but I feel there is couple of other things that are limiting:

1. There is no input value verification. It's not a huge issue now, but when I want to share I should probably validate the input.
1. Alfred doesn't check how many instances are running. There is only a single sopund daemon instance, so I would have to store the state somehow. I wonder how other workflows are fixing it.

There are couple of other things I could do, too:

1. The sound just ends abruptly. I wonder if there is an option to play a custom sound (or maybe a system sound) with the end notification.
1. This is pretty far-fetching, but I'd like to know how I'm spending my time in front of the screen. Apparently there's bash utility in MacOS called `screencapture` which, well, captures the screen, including video. I tried playing with it, and ~20 minute movie of my work is around 1GB, so it would probably have to be put out somewhere.
