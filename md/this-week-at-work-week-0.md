---
title: this week at work. week 0
subtitle: what's been going at work
keywords: new project;lost;confused;mid-level developer;
category: main
author: nikolay
date: March 31, 2024
description: learning how to be the best at what i do. 
---

I've had this job for a couple of years. I started programming at university. And now I want to be the best. I’ve been reading a lot. The last piece of advice I came across was that there is no substitute for deliberate practice. I also read that the statement _“learning X will make you a better programmer”_ is flimsy. The latter rang true but my mind put up a bit of a fight - another excuse to not be coding down the drain. Then I thought about how this hasn’t worked for me just last week. Cut back to me

# writing elm
I was messing around with Elm a couple of months ago. I harboured a lofty goal of reimplementing AG grid (???) and blogging about it. Imagining hundreds of readers gobsmacked at my technological know-how made me feel dizzy.

Impressively, I actually did implement a grid in Elm which took me on the order of 20 hours. I looked at the “grid” (a bunch of unpadded divs which each lit up on hover). Looked at my lock-screen. 23:38 on Sunday evening. I’m going to bed. I succumbed to a dreamless slumber warmed by the promise made to me by the Elm docs — _“Writing Elm will make you a better programmer”_.

Fast forward to the start of last week. I have recently moved teams and I am joining a new project half-way. My mentor, Oleg (fake name just in case) has just welcomed his first child, which cost a little of his technical sharpness (due to lack of sleep) and a lot of optimism about the success of this project. He was never an optimist anyway. The other teammate went over what he needed to build the next screen for the project, then went on holiday. I know you didn’t ask but here is 

# the background
I last worked directly with Oleg 1.5 years ago, fresh out of a year-long probation period at my firm. We shipped a nice project together. Then I was resourced to a different team but not before I, grinning ear to ear, planted my flag firmly on the peak of [Mount Stupid](). After a 1.5 year tumble down the side of Mount Stupid (long story) I was back working with Oleg. I was eager to prove myself.

I was able the ground running and added a CI pipeline and wrote some terraform to IAC most of the deployment. That felt good and Oleg seemed grateful. He already went through multiple design iterations and had a lot of the modules already complete but untested. This registered as a positive in my eyes but not in Oleg’s. Observing his (mild) despair tickled my ego in just the right places and was the first domino to fall in what followed. 

The project is a reporting platform where a user can configure a few parameters which are plugged into a template and a PDF is produced on a schedule. Parameters can be either expressions to refer to relative values (“I need the report today with yesterday’s data”) or handle catch-all terms (“I need the report to cover all the entities I care about always even if the list of entities changes in the background as a result of some other business process”) or plain values (1st December 2013). This idea was expressed in our C# codebase like this:

```csharp
public class ParameterBinding(
  string ParameterName, 
  Value? Value, // wrapper class over string, long, double and DateTime
  string? Expression = null
);
```

When I saw this my brain lights up up:

_“We can’t follow a convention when deciding between an expression and a value!”_

_“String expressions? That’s crazy!”_

_“What about the safety of the type system? What about parsing the arguments! “_

_“This is what Elm prepared me for! ”._

I _did_ hear distant echoes of “We only need to support like 2 expressions”; “They are very simple expressions and don’t have any semantic overlap”; “Go home its 9pm”. But I brushed them aside and many feeble attempts to implement sum-types in C#: `PrimaryExpressionString` and `ExpressionBase` classes, ~10 [lab-book]() pages full of diagrams and __4 days__ later I finally convinced myself that Oleg’s original design does what we need pretty well. 

I confessed: “This already does everything we need it to do, so I am just going to do nothing and move on”, and braced for impact. “Yea, that happens”, said Oleg “wish you came on at the start and we had more documentation instead of having to retro fit it now”. Elm has failed me but me mentor pulled thru.

I took Oleg’s pessimism as an unbiased estimate of the project health, convinced myself that the code was fucked being a “better programmer” with something to prove - I raged fix it. Except it wasn’t broken. I iterated on “solutions” that got went from confusing to adding coupling (gasp)! Anyway

# the lesson(s)
Slow down, ask questions, no amount of elm programming can make you better at making reporting systems. 

When joining new project:
1. beg borrow and steal to build a mental model of how the thing works. E.g get it running on local - click buttons, hit endpoints, read, look.
2. reconstruct the decisions - mental model is not complete without lineage - scroll chat history, read ADRs (or talk to the teammates and write some if they don’t exist)

Unless I can do this next time I am wasting everyone’s time. Notice that asking questions list wasting time. It’s socratic! It should produce artefacts for later and might even make me look good.

# the bonus lesson
One think I haven’t thought about nor have seen mentioned online is knowing the personalities on the team. Good news: everyone is pretty smart to have a career doing this. Regular news: everyone still has strength and weaknesses. I think tuning into those of your teammates and exploiting them can be one of the highest leverage things both for project success.

It’s not rocket science. No matter the seniority, be dependable, look out for people, take stuff of their hands, help them when they need help.  I can reassure Oleg that I can take care of the tests and he can focus on writing the database connector. He can do what he’s good at - thinking of edge cases and designing simple solutions. I can focus on what I am good at which is typing fast, setting up CI and asking annoying questions. Finally

# shoutout to myself
I am proud to say I reached the “errm let’s just do nothing here” conclusion by myself, thanks to the [decision matrices]() I started making recently.

The path ahead on this project is not very clear. Go live is mid July. Will I become a useful contributor or remain an overpaid typist? Will I defy the odds and enact bottom-up organisational change and make everyone adopt ADRs? Can I make friends with the SRE team? Let’s see.
