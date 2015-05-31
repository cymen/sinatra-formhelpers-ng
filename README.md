Sinatra::FormHelpers - Lightweight form helpers for Sinatra
===========================================================

**IMPORTANT: THIS FORK IS NO LONGER MAINTAINED. You can find the maintained version of this gem [here](https://github.com/duijf/sinatra-formhelpers-ng).**

This plugin adds lightweight (3-5 lines each) form helpers to Sinatra that aid with
common form and HTML tags.

    link "google", "http://www.google.com"  # <a href="http://www.google.com">google</a>
    label :person, :first_name              # <label for="person_first_name">First Name</label>
    input :person, :first_name              # <input name="person[first_name]" id="person_first_name" type="text" />

There are also helpers for: form, textarea, submit, image, radio, checkbox, and select

Why Bother?
-----------
After all, you can just write Haml or write your own helpers or hand-code raw HTML or whatever.  Well, here's some considerations:

1. Helpers maintain correct state across form submissions (eg, on errors, form stays filled in)
2. Generate automatic labels, valid CSS ID's, and <code>nested[names]</code> to make ORMs happy
3. No Rails ultra-magic(tm) here. Just fast, simple code.

Usage
-----
With Bundler/Isolate:

    gem 'sinatra-formhelpers-ng'

Then, include it in a Sinatra application:

    require 'sinatra/form_helpers'

If you're subclassing <code>Sinatra::Base</code>, you also need to call <code>helpers</code> manually:

    class MyApp < Sinatra::Base
      helpers Sinatra::FormHelpers
      # ...
    end

Views
-----
In your views, use these helpers to dynamically create form HTML elements.  Here's an example in ERB:

    <p>
      Fill out the below form to sign up.
      For more information, visit our <%= link 'FAQ', '/faq' %>
    </p>

    <%= form('/users', :post) %>

    <%= input(:user, :first_name) %>
    <%= input(:user, :last_name) %>

    <%= input(:user, :email, :size => 40) %>

    <%= password(:user, :password) %>
    <%= password(:user, :confirm_password) %>

    <%= radio(:user, :gender, ['M', 'F']) %>

    <%= submit %>

Unlike the super-magic Rails <code>form\_for</code> method, the <code>form()</code> helper just takes a URL and method. (Note that <code>form()</code> will accept <code>:create</code>, <code>:update</code>, and <code>:delete</code> and include the special <code>\_method</code> hidden param for you.)

To reduce repetition, use <code>fieldset()</code> to prefix fields with a namespace:

    <%= form('/users', :create) %>

    <% fieldset(:user) do |f| %>
      <%= f.input(:first_name) %>
      <%= f.input(:last_name) %>

      <%= f.input(:email, :size => 40) %>

      <%= f.password(:password) %>
      <%= f.password(:confirm_password) %>

      <%= f.radio(:gender, ['M', 'F']) %>
    <% end %>

    <%= submit 'Create account' %>
    <%= submit 'Cancel', :onclick => 'window.location=http://mydomain.com;return false' %>

This will create fields named <code>user[first\_name]</code>, <code>user[last\_name]<code>, and so forth.

Known Bugs
----------
* Currently <code>fieldset</code> does not return a <fieldset> tag properly.


Fixed Bugs
----------
* The state of select tags was not persisted across form submissions.


Authors
-------
* [Initial efforts](https://github.com/twilson63/sinatra-formhelpers) (c) 2009 [Tom Wilson](https://github.com/twilson63).
* [Additional efforts](https://github.com/nateware/sinatra-formhelpers) (c) 2011 [Nate Wiger](http://nateware.com).
* Further efforts (c) 2013 [Cymen Vig](http://blog.cymen.org/).
