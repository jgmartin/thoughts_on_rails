---
layout: post
title: "getting started with octopress"
date: 2012-11-23 00:05
comments: true
categories: 
---

Welcome to my blog, thoughts_on_rails.  I plan to put all sorts of useful stuff here, but we have to start somewhere.  Where better than the blog itself?  So, here's my basic guide to setting up a blog just like this one.

This blog uses a really cool little gem called [Octopress](http://www.octopress.org/) created by [Brandon Mathis](http://brandonmathis.com/).  It's written in Ruby, based on [Jekyll](http://github.com/mojombo/jekyll), and has absolutely nothing at all to do with Rails.  I chose to use Octopress for this blog because of the git-based workflow and easy setup on Heroku.  Here are the basic steps to get up and running, assuming you have a working install of Ruby 1.9.3.

<!--more-->

- Clone the project from Github
{% codeblock %}
git clone git://github.com/imathis/octopress.git octopress
{% endcodeblock %}

- Install bundler (if you don't already have it) and bundle
{% codeblock %}
gem install bundler
bundle install
{% endcodeblock %}

- Install the default theme
{% codeblock %}
rake install
{% endcodeblock %}

- Deploy the skeleton app to Heroku
{% codeblock %}
gem install heroku
heroku create
rake generate
git add .
git commit -m 'initial commit'
git push heroku master
heroku apps:rename your-new-name --app original-app-name
{% endcodeblock %}
This will create the app on Heroku and push up the skeleton you've generated.  The last command is optional and will rename the app to something more memorable than the Heroku default.

- Set up the basics in _config.yml
{% codeblock lang:yaml %}
url: http://www.thoughtsonrails.com
title: thoughts_on_rails
subtitle: a blog about rails and what not
author: James Martin
simple_search: http://google.com/search
description: a blog about ruby, rails, and everything that comes with them
{% endcodeblock %}

- Make some changes to the templates

The templates are pretty self-explanatory, and can be found in the 'source/_layouts' & 'source/_includes' directories.  Sass styles are located in the 'sass' directory.

- Check out the results locally
{% codeblock %}
rake preview
{% endcodeblock %}

The blog will be hosted locally on port 4000.

- Create a new post
{% codeblock %}
rake new_post['hello world']
{% endcodeblock %}

This will create a file called 'YYYY-MM-DD-hello-world.markdown' in 'source/_posts'.  This is where you will create the content of the post itself.  The posts are (by default) written in Markdown format.  In case your not familiar, here are [the basics](http://daringfireball.net/projects/markdown/basics).

- Commit everything and push it back up
{% codeblock %}
git add .
git commit -m 'first post'
git push heroku master
{% endcodeblock %}

And that's all there is to it.  You can check out the [docs](http://octopress.org/docs/) to learn more.



