---
title: mostly markdown blog
subtitle: how to reinvent the wheel of starting a plain text blog.
keywords: how to start markdown only blog;no javascript blog; html only blog;
category: main
author: nikolay
date: December 31, 2023
description: reinventing the wheel with my own no js blogging set up
---

# what…
It’s the end of 2023 and I [have made a decision](https://en.wikipedia.org/wiki/Robert_Sapolsky). 
Enough playing chicken with the [tech-hiring bubble](https://www.cnn.com/2023/01/22/tech/big-tech-pandemic-hiring-layoffs/index.html) - I owe to myself to be the best code plumber I can be! 
This is not the first time i vowed to give up load-testing Netflix every day after work by rewatching the same show over and over… 
I plan to instead spend some time doing the only thing I enjoy doing - my job… 

✨ programming ✨.

[patio11](https://x.com/patio11?s=20) says that i better leave an [artefact on the internet](https://youtu.be/PtmUJye7t4c?si=o9fpxl33aCjOLZFS&t=1598) of what I get up to. 
Maybe it’s to give value to others, to make the internet a better place. Or to influence my credibility in the eyes of strangers (you!) increasing my chances of selling best-practices courses when I get to the top of the soft/eng blogosphere. Anyway…

The artefacts should:
- be on the internet so that my friends can see why I’ve stopped leaving the house 
- be on the internet so that i can get them back if i spill [grape fanta](https://tiermaker.com/categories/food-and-drink/fanta-flavors-13152) on my laptop
- be _mostly_ markdown for portability
- be _without_ any javscript
- be version controlled

With the requirements out of the way let’s talk technology.

The main goal here is to mitigate as much [rot](https://en.wikipedia.org/wiki/Software_rot) as possible, especially in the likely case that I write 2 blog posts and go back to playing [spider-man 2](https://www.youtube.com/watch?v=gNPy_CO4zqA) every evening. Here’s the breakdown:
| technology                      | should i use it?               | hipster score |
|---------------------------------|--------------------------------|---------------|
| react/vue/svelte/remix/whatever | overkill + i __dislike__ `npm` | 😒             |
| jekyll                          | `gem install`? nah…            | 🙃             |
| hugo                            | `git submodule` nah…           | 🙃             |
| html + css                      | hell yea!                      | 🥳             |

Following this impartial evaluation `html` and `css` are clear winners on the rot front. I am also pleased with the hispter score .

# how
We strayed too far from God’s light - I hope I don’t need to convince you to not edit markup directly.  With that in mind, we’re going to:
1. __take in__ markdown files
2. __convert__ them into html files 
3. __host__ the static files to some provider

A few gotchas with the conversion:
1. `<meta>` tags need to be populated to leave others with a nonzero chance of landing on this blog from a google search
2. images have to be bundled in 

Nice to haves:
1. an RSS feed - for my [open web fighters](https://www.wprssaggregator.com/is-rss-dead/)
2. analytics - for me to languish over on the daily
3. 😎 dark mode (i know, i know… but this is my blog not yours)

# convert
if (big if) i have already written a post in my [local](https://ghostwriter.kde.org/) [editor](https://github.com/marktext/marktext) [of](https://github.com/blackhole89/notekit) [choice](https://obsidian.md/) i can use the fantastic library that is [Pandoc](https://pandoc.org/) to turn each into a standalone html file I can link to from the `index.html`.  

```bash
pandoc "$mdfile" \
       --section-divs \ 
       --toc 
       -s \ 
       --css="../styles.css" \
       -B header.html \
       -A footer.html \ 
       -o "$DEST_DIR/$filename.html"
```

The different options:
- `--section-divs` will wrap everything into a section i can style
- `--toc` will generate a table of contents with links to the relevant headings (nice)
- `-s` tells `pandoc` to make a __standalone file__ i.e `<!DOCTYPE html>` at the top and stuff
* `—css` my styles
* `--B` and `—A` append an __html chunk__ to before and after the converted markdown

I loop over all my markdown and call this and yay! I’ve got a page to look at. If you care about details I link the source code at the end. Let’s get to the nice to haves

## nice to haves
What nicer way to procrastinate on actual complex projects than more plumbing! I want to:
1. parse the content into an RSS feed by hand 
2. scrounge a cheap free tier from smart and industrious people offering an analytics product
3. use [modern CSS](https://chriscoyier.net/2023/06/06/modern-css-in-real-life/) to match the user’s system light/dark mode settings.

### RSS feed
Bad news first. Pandoc does _not_ do RSS. People have built [workarounds](https://github.com/chambln/pandoc-rss) but this is becoming to look more and more like a feature request for my nascent static site generator. Which I would rather __not__ implement in POSIX shell (just the kinda guy I am). I’ll get back to this.

### Analytics
[GoatCounter](https://www.goatcounter.com/) is drag and drop - thank god - I never configured any analytics before. Bummer: It gets blocked by one of my ad-blocks. Easy to unblock but the savvy ad-blocking crowd might come and go from the blog without being noticed. Sad!

### Dark Mode
One personal takeaway from this project - css is ok now. Dark mode turns out to be simple:

```css
@media screen and (prefers-color-scheme: dark) {
	color: white;
	background-color: black;
}
```

Confession: user cannot switch modes at will because that means a button and a button means JavaScript and we’re already at the end of this post and cannot give up now.

# hosting
[Github pages](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site) is okay, more importantly it’s _free_ (for public repositories).

Thanks for reading! Stop by next week to see how I get on with [writing a text editor]().

source code for this website: [https://github.com/nikolay-labs/blog](https://github.com/nikolay-labs/blog)
