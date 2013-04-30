require File.expand_path 'spec_helper', File.dirname(__FILE__)

# class Application < Sinatra::Base
#   register Sinatra::FormHelpers
#
#   set :raise_errors, false
#   set :show_exceptions, false
#
#   get '/link' do
#
#   end
# end
#
# class Bacon::Context
#   include Rack::Test::Methods
#   def app
#     Application  # our application
#   end
# end

describe "Sinatra::FormHelpers methods" do
  it "renders an anchor tag" do
    fh.form(:person, :create).should == '<form action="/person" method="POST">'
  end
  it 'renders a form tag' do
    fh.form(:person, :update, :action => "/people/14").should ==
      '<form action="/people/14" method="POST"><input type="hidden" name="_method" value="update" />'
  end
  it 'renders a form tag (2)' do
    fh.form("/people/7", :delete).should ==
      '<form action="/people/7" method="POST"><input type="hidden" name="_method" value="delete" />'
  end
  it 'renders a form tag (3)' do
    fh.form("/people", :create).should ==
      '<form action="/people" method="POST">'
  end
  it 'renders a nested form tag' do
    fh.form(:person, :create) do |f|
      # f.input(:first_name)
      f.input(:last_name)
    end.should == '<form action="/person" method="POST"><fieldset>' +
      # '<input id="person_first_name" name="person[first_name]" type="text" />' +
      '<input id="person_last_name" name="person[last_name]" type="text" />' +
      '</fieldset></form>'
  end
  it 'nests form elements arbitrarily' do
    fh.fieldset(:person) do |n|
      # n.radio(:partners, 1..6)
      n.textarea(:comments, "yo yo yo!")
    end.should == '<fieldset>' +
      # '<input id="person_partners_1" name="person[partners]" type="radio" value="1" /> ' +
      # '<input id="person_partners_2" name="person[partners]" type="radio" value="2" /> ' +
      # '<input id="person_partners_3" name="person[partners]" type="radio" value="3" /> ' +
      # '<input id="person_partners_4" name="person[partners]" type="radio" value="4" /> ' +
      # '<input id="person_partners_5" name="person[partners]" type="radio" value="5" /> ' +
      # '<input id="person_partners_6" name="person[partners]" type="radio" value="6" />' +
      '<textarea id="person_comments" name="person[comments]">yo yo yo!</textarea></fieldset>'
  end
  it 'renders a link tag' do
    fh.link('http://google.com').should == '<a href="http://google.com">http://google.com</a>'
  end
  it 'renders a form label tag' do
    fh.label(:person, :first_name).should == '<label for="person_first_name">First Name</label>'
  end
  it 'renders a form checkbox tag' do
    fh.checkbox(:person, :gender, %w[M F], :join => '<br />').should ==
      '<input id="person_gender_m" name="person[gender][]" type="checkbox" value="M" /><label for="person_gender_m">M</label><br />' +
      '<input id="person_gender_f" name="person[gender][]" type="checkbox" value="F" /><label for="person_gender_f">F</label>'
  end
  it 'renders a minimal text tag' do
    fh.input(:q).should == %q(<input id="q" name="q" type="text" />)
  end
  it 'renders a minimal textarea tag' do
    fh.textarea(:r).should == %q(<textarea id="r" name="r"></textarea>)
  end
  it 'renders a submit tag' do
    fh.submit.should == %q(<input id="button_submit" name="submit" type="submit" value="Submit" />)
    fh.submit("Send!").should == %q(<input id="button_send_" name="submit" type="submit" value="Send!" />)
  end
  it 'renders a reset tag' do
    fh.reset.should == %q(<input id="button_reset" name="reset" type="reset" value="Reset" />)
    fh.reset("Blark").should == %q(<input id="button_blark" name="reset" type="reset" value="Blark" />)
  end
  it 'supports multiple values for checkboxes' do
    fh.params = {:user => {'devices' => ['iPhone', 'iPad'] }}
    fh.checkbox(:user, :devices, ['iPhone', 'iPad', 'iPod', 'iPoop']).should ==
      "<input checked=\"checked\" id=\"user_devices_iphone\" name=\"user[devices][]\" type=\"checkbox\" value=\"iPhone\" /><label for=\"user_devices_iphone\">iPhone</label> <input checked=\"checked\" id=\"user_devices_ipad\" name=\"user[devices][]\" type=\"checkbox\" value=\"iPad\" /><label for=\"user_devices_ipad\">iPad</label> <input id=\"user_devices_ipod\" name=\"user[devices][]\" type=\"checkbox\" value=\"iPod\" /><label for=\"user_devices_ipod\">iPod</label> <input id=\"user_devices_ipoop\" name=\"user[devices][]\" type=\"checkbox\" value=\"iPoop\" /><label for=\"user_devices_ipoop\">iPoop</label>"
  end
end

describe "Sinatra::FormHelpers in app" do
  it 'renders an anchor tag' do
    app.get '/link' do
      erb "<%= link 'google', 'http://www.google.com', :title => 'Google' %>"
    end

    get '/link'
    last_response.body.should == %q(<a href="http://www.google.com" title="Google">google</a>)
  end

  it 'renders a label tag' do
    app.get '/label' do
      erb "<%= label :person, :first_name %>"
    end

    get '/label'
    last_response.body.should == %q(<label for="person_first_name">First Name</label>)
  end

  it 'renders a label tag with display input' do
    app.get '/hello' do
      erb "<%= label :person, :first_name, 'Hello World'%>"
    end

    get '/hello'
    last_response.body.should == %q(<label for="person_first_name">Hello World</label>)
  end

  it 'renders an input tag type text without @params' do
    app.get '/text' do
      erb "<%= input :person, :first_name %>"
    end

    get '/text'
    last_response.body.should =~ /name="person\[first_name\]"/
    last_response.body.should == %q(<input id="person_first_name" name="person[first_name]" type="text" />)
  end

  it 'accepts an input tag with custom type option' do
    app.get '/input-with-custom-type' do
      erb "<%= input :person, :password, type: 'password' %>"
    end

    get '/input-with-custom-type'
    last_response.body.should == '<input id="person_password" name="person[password]" type="password" />'
  end

  it 'renders an input tag type text with single arg' do
    app.get '/q' do
      erb "<%= input :q %>"
    end

    get '/q'
    last_response.body.should == %q(<input id="q" name="q" type="text" />)
  end

  it 'renders an input tag type text with @params' do
    app.get '/tom' do
      @params = { :person => {"first_name" => "Tom"}}
      erb "<%= input :person, :first_name %>"
    end

    get '/tom'
    last_response.body.should == %q(<input id="person_first_name" name="person[first_name]" type="text" value="Tom" />)
  end

  it 'renders a password tag type password' do
    app.get '/password' do
      erb "<%= password :person, :password %>"
    end

    get '/password'
    last_response.body.should == '<input id="person_password" name="person[password]" type="password" />'
  end

  it 'renders a button tag type button' do
    app.get '/button' do
      erb "<%= button :new %>"
    end

    get '/button'
    last_response.body.should == '<input id="button_new" name="button" type="button" value="new" />'
  end

  it 'renders an textarea tag type text without @params' do
    app.get '/notes' do
      erb "<%= textarea :person, :notes %>"
    end

    get '/notes?person[notes]=Yeppers'
    last_response.body.should == %q(<textarea id="person_notes" name="person[notes]">Yeppers</textarea>)
  end

  it 'renders a textarea tag with @params' do
    app.get '/notes2' do
      @params = { :person => {"notes" => "This is a note"}}
      erb "<%= textarea :person, :notes %>"
    end

    get '/notes2'
    last_response.body.should == %q(<textarea id="person_notes" name="person[notes]">This is a note</textarea>)
  end

  it 'renders a textarea tag with @params' do
    app.get '/img' do
      erb "<%= image '/images/hello.png', :alt => 'Lolcatz' %>"
    end

    get '/img'
    last_response.body.should == '<img alt="Lolcatz" src="/images/hello.png" />'
  end

  it 'renders an input tag with a submit type' do
    app.get '/sub' do
      erb "<%= submit 'Create' %>"
    end

    get '/sub'
    last_response.body.should == '<input id="button_create" name="submit" type="submit" value="Create" />'
  end

  it 'renders an input tag with a submit type with zero args' do
    app.get '/create' do
      erb "<%= submit %>"
    end

    get '/create'
    last_response.body.should == '<input id="button_submit" name="submit" type="submit" value="Submit" />'
  end

  it 'renders an input tag with a checkbox type' do
    app.get '/check' do
      erb "<%= checkbox :person, :active, 'Yes' %>"
    end

    get '/check'
    last_response.body.should ==
      '<input id="person_active_yes" name="person[active]" type="checkbox" value="Yes" /><label for="person_active_yes">Yes</label>'
  end

  it 'renders an input tag with a multiple checkbox type' do
    app.get '/check2' do
      erb "<%= checkbox :person, :eyes, [1,2,3] %>"
    end

    get '/check2'
    last_response.body.should ==
      '<input id="person_eyes_1" name="person[eyes][]" type="checkbox" value="1" /><label for="person_eyes_1">1</label> ' +
      '<input id="person_eyes_2" name="person[eyes][]" type="checkbox" value="2" /><label for="person_eyes_2">2</label> ' +
      '<input id="person_eyes_3" name="person[eyes][]" type="checkbox" value="3" /><label for="person_eyes_3">3</label>'
  end

  it 'renders an input tag with a radio type' do
    app.get '/radio' do
      erb "<%= radio :person, :gender, [['M','Male'],['F','Female'],'Other'] %>"
    end

    get '/radio'
    last_response.body.should ==
      "<input id=\"person_gender_m\" name=\"person[gender]\" type=\"radio\" value=\"M\" /><label for=\"person_gender_m\">Male</label> " +
      "<input id=\"person_gender_f\" name=\"person[gender]\" type=\"radio\" value=\"F\" /><label for=\"person_gender_f\">Female</label> " +
      "<input id=\"person_gender_other\" name=\"person[gender]\" type=\"radio\" value=\"Other\" /><label for=\"person_gender_other\">Other</label>"
  end

  it 'renders a select tag' do
    app.get '/select' do
      erb "<%= select :person, :relationship, ['Friend','CoWorker','Lead'] %>"
    end

    get '/select'
    last_response.body.should == '<select id="person_relationship" name="person[relationship]">' +
      '<option value="Friend">Friend</option><option value="CoWorker">CoWorker</option>' +
      '<option value="Lead">Lead</option></select>'
  end

  it 'renders a select tag with selected option' do
    app.get '/select2' do
      @params = { :person => {"relationship" => "CoWorker"}}
      erb "<%= select :person, :relationship, ['Friend','CoWorker','Lead'] %>"
    end

    get '/select2'
    last_response.body.should == '<select id="person_relationship" name="person[relationship]">' +
      '<option value="Friend">Friend</option><option selected="selected" value="CoWorker">CoWorker</option>' +
      '<option value="Lead">Lead</option></select>'
  end

  it 'renders a hidden tag with single arg' do
    app.get '/hidden' do
      erb "<%= hidden :q %>"
    end

    get '/hidden'
    last_response.body.should == %q(<input id="q" name="q" type="hidden" />)
  end

  it 'renders a hidden tag with value' do
    app.get '/hidden2' do
      erb '<%= hidden :person, :id, :value => 1 %>'
    end

    get '/hidden2'
    last_response.body.should == '<input id="person_id" name="person[id]" type="hidden" value="1" />'
  end

  it 'renders a form tag' do
    app.get '/form' do
      erb "<%= form :person, :create %>"
    end

    get '/form'
    last_response.body.should == %q(<form action="/person" method="POST">)
  end

#   it 'renders a form_for style tag' do
#     app.get '/form_for' do
#       erb <<-EndTemplate
# <% form(:person, :create) do |f| %>
#   <%= f.input(:login) %>
#   <%= f.password(:password) %>
#   <%= submit %>
# <% end %>
# EndTemplate
#     end
#
#     get '/form_for'
#     last_response.body.should == %q(<form action="/person" method="POST">)
#   end

  it 'renders a fieldset group' do
    app.get '/fieldset' do
      erb <<-EndTemplate
<% fieldset(:user) do |f| %>
  <%= f.input(:first_name) %>
  <%= f.input(:last_name) %>

  <%= f.input(:email, :size => 40) %>

  <%= f.password(:password) %>
  <%= f.password(:confirm_password) %>

  <%= f.radio(:gender, ['M', 'F']) %>
<% end %>
<%= submit %>
EndTemplate
end

    get '/fieldset'
    last_response.body.should ==
      "  <input id=\"user_first_name\" name=\"user[first_name]\" type=\"text\" />\n  <input id=\"user_last_name\" name=\"user[last_name]\" type=\"text\" />\n\n  <input id=\"user_email\" name=\"user[email]\" size=\"40\" type=\"text\" />\n\n  <input id=\"user_password\" name=\"user[password]\" type=\"password\" />\n  <input id=\"user_confirm_password\" name=\"user[confirm_password]\" type=\"password\" />\n\n  <input id=\"user_gender_m\" name=\"user[gender]\" type=\"radio\" value=\"M\" /><label for=\"user_gender_m\">M</label> <input id=\"user_gender_f\" name=\"user[gender]\" type=\"radio\" value=\"F\" /><label for=\"user_gender_f\">F</label>\n<input id=\"button_submit\" name=\"submit\" type=\"submit\" value=\"Submit\" />"
  end
end

