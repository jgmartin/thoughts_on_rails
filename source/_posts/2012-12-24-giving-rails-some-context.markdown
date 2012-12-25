---
layout: post
title: "giving rails some context"
date: 2012-12-24 17:59
comments: true
categories: 
---

There has been quite a bit of talk lately around the idea of model decomposition and contexts.  In this post, we'll create a gem that allows you to decompose models into various contexts, and apply only the functionality you need, when you need it.

<!--more-->

It's becoming clear to more and more Ruby developers that we need a method of breaking large models into smaller, more manageable chunks of code.
Rails 4 suggests [concerns](https://gist.github.com/1014971) as one way to deal with the problem.  Personally, I like the idea of using contexts to bundle
up bits of similar code, for both the modularity and to keep models clean.

We're going to write a gem that will allow us to create modules, or 'contexts', that can be applied selectively when creating new instances of ActiveRecord models.
What we're going for is something like this:

{% codeblock app/models/post.rb %}
class User < ActiveRecord::Base
  has_context :buyer, with: Buyer
  has_context :seller, with: [Seller, Payable]
end
{% endcodeblock %}

{% codeblock app/contexts/buyer.rb %}
module Buyer
  def buy_item(item)
    # buy an item
  end
  #...
end
{% endcodeblock %}

{% codeblock app/contexts/seller.rb %}
module Seller
  def inventory
    # list items
  end
  #...
end
{% endcodeblock %}


{% codeblock app/contexts/payable.rb %}
module Payable
  def mark_paid(invoice)
    # mark as paid
  end
  #...
end
{% endcodeblock %}

{% codeblock console lang:ruby %}
user = User.new
user.respond_to?(:buy_item)       #=> false
buyer = User.with_context(:buyer)
buyer.respond_to?(:buy_item)      #=> true

{% endcodeblock %}

The first thing we will need to do is generate a new skeleton gem with Bundler.  Give it whatever name you like.
{% codeblock terminal %}
bundle gem contextual
{% endcodeblock %}


