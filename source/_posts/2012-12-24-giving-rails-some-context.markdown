---
layout: post
title: "giving rails some context"
date: 2012-12-24 17:59
comments: true
categories: 
---

There has been quite a bit of talk lately around the idea of model decomposition and DCI roles.  In this post, we'll look at one way to break up bloated models and include only what you need, when you need it.

<!--more-->

It's becoming clear to more and more Rails developers that we need a method of breaking large models into smaller, more manageable chunks of code.
Rails 4 suggests [concerns](https://gist.github.com/1014971) as one way to deal with the problem.  Personally, I like the idea of using contexts to bundle
up bits of similar code, for both the modularity and to keep models clean.

We're going to write a gem that will allow us to create modules, or 'contexts', that can be applied selectively when creating new instances of Active Record models.
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

The code to accomplish this is pretty simple.

{% codeblock lib/contextual.rb %}
module Contextual

  extend ActiveSupport::Concern

  module ClassMethods
    mattr_accessor :contexts

    self.contexts = {}
    def has_context(name, opts={})
      self.contexts[name] = [opts[:using]].flatten
    end

    def with_context(name)
      value = new
      value.singleton_class.send(:attr_accessor, :context)
      modules = self.contexts[name]
      value.context = {name => modules}
      modules.each do |m|
        value.extend m
      end
      value
    end
  end
end

ActiveRecord::Base.send(:include, Contextual)
{% endcodeblock %}

We begin by extending ActiveSupport::Concern, which saves us the trouble of manually extending the including class with the ClassMethods module.
Inside of said module, we define a :context property and set it to an empty hash.  This will be our list of available contexts.

Next we define a 'Class Macro' method, .has_context, that will allow the assignment of new contexts.  It takes a name and options hash as arguments.
The method just assigns the value of opts[:using] to the contexts hash under the key of the given name, making sure the assigned value is a flat array.

The next method, .with_context, is the instance factory.  It first creates a new instance, then calls send on it's eigenclass, passing in :attr_accessor and :context as arguments.
This has the effect of creating a :context property on this instance alone.

The next couple of lines just grab the list of modules for the given context name and assigns the current context.  Then it's just a matter of looping over the modules and including them in the instance's eigenclass one at a time.

So, we have everything working the way we want.  We can define a bunch of context modules, group and name them, and include them as necessary in new instances.  Of course this was just quickly thrown together for the purpose of demonstration, but the idea of decomposition and applying 'roles' or context to model instances is a powerful one.
We've been employing similar ideas at work for some time now and it has managed to keep our model code very concise and understandable.

The only downside that I've noticed is negated by a decent text editor, and that is navigating the source.  Sometimes it can be a bit difficult to figure out just where a method is defined with all these modules everywhere, so a 'jump to definition' button is priceless.

You can check out the full source code on my [Github](https://github.com/jmartin2683/contextual), or try it out with 'gem install contextual_models'.



