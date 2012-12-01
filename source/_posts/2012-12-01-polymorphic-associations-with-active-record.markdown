---
layout: post
title: "polymorphic associations with active record"
date: 2012-12-01 12:01
comments: true
categories: 
---

Model associations are one of the things that every new Ruby on Rails developer must understand in order to effectively use the framework.  The concept behind these relationships is rather simple, and most people have little trouble grasping it once introduced.  One of the sticking points (for me, at least) was polymorphic associations, or associations where a single model can belong to multiple types of other models. 

<!--more-->

Like just about everything else in the Ruby on Rails world, there is a 'Rails way' to do polymorphic associations.  This involves leveraging the support that is built in to Rails' standard ORM, Active Record.  You set up a polymorphic association in very much the same way that you would a typical has_many.

{% codeblock app/models/comment.rb %}
class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
#...
{% endcodeblock %}

{% codeblock app/models/post.rb %}
class Post < ActiveRecord::Base
  has_many :comments, as: :commentable
#...
{% endcodeblock %}

{% codeblock app/models/profile.rb %}
class Profile < ActiveRecord::Base
  has_many :comments, as: :commentable
#...
{% endcodeblock %}

{% codeblock migration lang:ruby %}
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true
      #...
    end
  end
end
{% endcodeblock %}

Here you can see that all we're really doing is passing a couple of parameters to the :has_many and :belongs_to methods.  The migration will generate two columns on the Comments table, 'commentable_id' and 'commentable_type'.  Behind the scenes, Active Record will wire up all of the helper methods that you're used to using with normal associations.

{% codeblock lang:ruby irb %}
post.comments  # get all comments for a post
profile.comments # get all comments for a profile

post.comments.create(params[:post]) # create a new comment for a post
profile.comments.create(params[:post]) # create a new comment for a profile

comment.commentable # get the parent of a comment
{% endcodeblock %}

And there you have it, both posts and profiles can have their own comments.  The obvious limitation here is that, since we're only setting a single foreign key and type, a comment can only belong to one other object at a time.  This may be the desired functionality for some use cases.  Sometimes, however, you'll want to be able to associate a single model with multiple other models of different types at the same time.  We'll look at how to handle something like that in a future post.
