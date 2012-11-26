---
layout: post
title: "creating plugins for octopress"
date: 2012-11-26 10:32
comments: true
categories: 
---

Octopress comes with quite a few plugins out of the box, covering everything from categories to video tags.  Plugins are easy to create and can be used to extend Octopress in a variety of ways.  Today we'll learn how to extend the Liquid templating system with new tags of our own.

<!--more-->

For this example we will be creating a tag that allows users to easily embed images hosted on Amazon's S3 service.  To begin, create a plain Ruby file called 's3_image_tag.rb'.

- Define a new Liquid::Tag subclass within the Jekyll module
{% codeblock s3_image_tag.rb %}
module Jekyll
  class S3ImageTag < Liquid::Tag
    # our code will go here
  end
end
{% endcodeblock %}
All Liquid tags are defined as classes inheriting from Liquid::Tag.  Liquid expects this class to respond to a #render message, which we will implement shortly.

- Grab parameters passed in to the tag
{% codeblock s3_image_tag.rb %}
def initialize(tag_name, text, token)
  super
  @text = text.strip
  @text =~ /(\w+\.\w+)(\sbucket:)?(\w*)/i
  @file_name = $1
  @bucket_name = $3.empty? ? Jekyll.configuration({})['aws_bucket'] : $3
end
{% endcodeblock %}
Notice that Liquid will call our initialize method with three parameters: the tag name, the text within the tag itself, and a token.  The part we care about is the text.

First we call super to allow our superclass to perform any necessary initialization.  Next, we grab the passed in text as an instance variable and strip it of leading/trailing whitespace.  We then match the stripped text against a regex to capture the pieces we need.  In this case, we need the file name and the optional bucket parameter.  If the bucket parameter is not supplied we pull a default from the Jekyll configuration loaded from '_config.yml'.

- Define the #render method
{% codeblock s3_image_tag.rb %}
def render(context)
  if @file_name && @bucket_name
    "<img src='https://s3.amazonaws.com/#{@bucket_name}/#{@file_name}'>"
  else
    "Error processing input."
  end
end
{% endcodeblock %}
Here we just check to make sure we have a @file_name and @bucket_name, and if so construct the HTML tag for the desired image.  If either parameter is missing, we return a simple error message.

- Register the new tag
{% codeblock s3_image_tag.rb %}
Liquid::Template.register_tag('s3_image', Jekyll::S3ImageTag)
{% endcodeblock %}
We send the .register_tag message to Liquid::Template, passing in the name of our tag and the class which represents it.  The new tag is now ready to be used in our templates.

- Add s3_image_tag.rb to the '/plugins' directory in your blog project.  Octopress automatically loads all plugins defined within it's 'plugins' subdirectory.

- Define a default bucket in '_config.yml'
{% codeblock _config.yml %}
# ----------------------- #
#   3rd Party Settings    #
# ----------------------- #

# Amazon S3 Images
aws_bucket: thoughts_on_rails
{% endcodeblock %}

- Use the new tag in your templates
{% codeblock _posts/2012-11-27-foo.markdown lang:html %}
Here is an image: {% raw %} {% s3_image foo.jpeg bucket:bar %} {% endraw %}
{% endcodeblock %}

You can find the full example code on my [Github](http://github.com/jmartin2683/s3_image_tag).
