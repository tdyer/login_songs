## Registration and Authentication
- Indentity

	Uniquely indentifies a user. Could be a username, email, api key, 
	etc.
- Credentials

	Used to authenticate a user. Could be a password, pin, public key, encrypted hash.
	
- Registration/Signup
    
    User identity is created with their credentials, email and password in this case.

-  Authentication/Login
    
    User is authenticated using their identity and credentials.

### Passwords
Do not want to store the "plain text" passwords in the DB. Just in case the system is comprimised, cracked.

We only stored hashed passwords. **Never store plain text passwords!!** So that if a malicious user gains access then they cannot obtain passwords. We're going to use the bcrypt gem to hash plain text passwords into a crypto hash. This will done by using this gem's hash_secret method.

BCrypt is just one of many types of ways to generate a hash.

    The general workflow for account registration and authentication in a hash-based account system is as follows:

    1) The password is hashed and stored in the database. At no point is the plain-text (unencrypted) password ever written to the hard drive.
    2) When the user attempts to login, the hash of the password they entered is checked against the hash of their real password (retrieved from the database).
    3) If the hashes match, the user is granted access. If not, the user is told they entered invalid login credentials.

    Steps 3 and 4 repeat everytime someone tries to login to their account.

#### Need to a use a salt to generate crypto hashes.
   
This will prevent common ways of cracking a hash. A *salt* is a random string that makes it more difficult to crack the hash. This salt is feed into the hash algorithim along with the plain text password to produce a cryptographic hash.


## Registration/Signup 

#### Init the DB and add seed the DB with data.
`rake db:drop`

`rake db:reset`

#### Create a User model and run migrations.
`rails g model User email password_digest password_salt`
	
`rake db:migrate`

#### Annotate models with their attributes.

Uses the annotate gem to add comments to models. These comments enumerate the model's attributes. *Some* feel it's not needed.

`annotate`

#### Add the bcrypt gem to the Gemfile and bundle.

`gem 'bcrypt-ruby', '~> 3.0.0'`

#### Add a password attribute to the User model. 

**This will not be persisted in the DB!**

  `attr_accessor :password`

#### Add the method to the User model that will encrypt the password into the DB. 

<pre>
	require "bcrypt" 

	class User < ActiveRecord
	  include BCrypt

	  def encrypt_password
    	if password.present?
      	  self.password_salt = BCrypt::Engine.generate_salt
          self.password_digest = BCrypt::Engine.hash_secret(password, self.password_salt)
        else
          nil
	     end
	  end
	end
	   </pre>

#### Open the rails console and create a user with a password. 
*Notice that the password_digest is empty *until encrypt_password is invoked*. The password_digest is used to authenticate the user.*
	
`u = User.new(email: 'foo@example.com', password: 'foo')`

`u.encrypt_password`

`u.save!`


## Authentication - Login - Sign In

#### Add a User *class* method that will authenticate a user.

   <pre>def self.authenticate(email, password)
      user = self.find_by_email(email)
      if user && user.password_digest == ::BCrypt::Engine.hash_secret(password, user.password_salt)
        user
      else
        nil
      end
     end</pre>

####Authenticate the user. *Success*
`User.authenticate("foo@example.com", "foo") `

##### With the wrong password. *Fails*
`User.authenticate("foo@example.com", "foox")`

#### With the wrong, non-existent, user. *Fails*
User.authenticate("foo2@example.com", "foo")

## Wrap in all in UI
### Registration - Sign up UI
#### Create a Users controller
`touch app/controllers/users_controller.rb`
<pre>
class UsersController < ApplicationController

  # display the signup form
  def new
    @user = User.new
  end

  # process the signup form
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Thanks for signing up"                                
      redirect_to root_url
    else
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

end
</pre>

#### Create a Registration form.
*In app/users/new.html.erb*
<pre>
<%= form_for @user do |f| %>
  <% if @user.errors.any? %>
    &lt;div class='error_messages'&gt;
      &lt;h2&gt;Form is invalid&lt;/h2&gt;
      &ltul&gt;
        <% @user.errors.full_messages.each do |message| %>
          &ltl&gt;<%= message %>&lt/l&gt;
        <% end %>
      &lt;ul&gt;
    &lt;/div&gt;
  <% end %>
  <%= f.label :email %>
  <%= f.text_field :email %><br/>
  <%= f.label :password %>
  <%= f.password_field :password %><br/>
  <%= f.label :password_confirmation %>
  <%= f.password_field :password_confirmation %><br/>
  <%= f.submit "Sign Up" %>
<% end %> 
</pre>

#### Create routes for a User in the route.rb
<pre>resources :user</pre>

#### Fill out the User model. 
*Let's add the password and password confirmation attributes to the User model so the above form works.*
<pre>
require 'bcrypt'

class User < ActiveRecord::Base
  before_save :encrypt_password
  attr_accessor :password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
end
</pre>

### Add a link to sign up in the layout                                      
<pre><%= link_to "Sign Up", new_user_path %></pre>

### Add a user resource and root path.
<pre>resources :users</pre>

#### Register, create, a user.
*Go to http://localhost:3000/users/new fill out the form and submit. It should work!!*

Check that the user was created, and their password digest is populated, in the rails console

## Authentiation - Login UI

### Add a Session Controller

A new *Session* is created every time a user in authenticated. 

*Note that this Session is not backed by the DB. There is no Session model*

`rails g controller Sessions new`

### Create a Login form.
<pre>
&lt;h1&gt;Log in &lt;/h1&gt;                                                               
                                                                               
<%= form_tag sessions_path do %>                                               
  &lt;p&gt;                                                                          
    <%= label_tag :email %><br />                                              
    <%= text_field_tag :email, params[:email] %>                               
  &lt;/p&gt;                                                                        
  &lt;p&gt;                                                                         
    <%= label_tag :password %>&lt;br/&gt;                                           
    <%= password_field_tag :password %>                                        
  &lt;/p&gt;                                                                        
  &lt;p class="button"><%= submit_tag %&gt; &lt;/p&gt;  
  &lt;p&gt;                                    
<% end %> 
</pre>

#### Add session resource and log_in path to the route.rb.
<pre> get "log_in" => "sessions#new", :as => "log_in" </pre>
<pre> resources :sessions </pre>

#### Add the Session create action.

<pre>
def create
    user = User.authenticate(session_params[:email], session_params[:password])
    if user
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  private

  def session_params
    params.permit(:email, :password)
  end
</pre>

Notice the session[:user_id]. This is provided by Rails to set a value in a browser session. 

A browser session is a hash like structure that is kept in the browser so that state can be retained between HTTP requests. Each time a HTTP Request is sent from the browser it will *also* send the currently logged in user's id to the server.

In this case we are going to store the id of the current user in the browser session. So that the each request this logged in user sends will *also* provide the database id of this user.

Browser cookies are used to implement sessions.

<i>Browser Cookies and Session are another good homework reading topic.</i>


#### Logout.

##### Add logout link to the routes.rb
<pre>get "log_out" => "sessions#destroy", :as => "log_out"</pre>

#####Add delete action to Sessions controller.

This will remove the user id of the current user from the HTTP session.

<pre>
def destroy
  session[:user_id] = nil
  redirect_to root_url, :notice => "Logged out!"
end
</pre>

## Finish up UI
#### Add Flash handling to the layout.
[Rails Flash](http://guides.rubyonrails.org/action_controller_overview.html#the-flash)

[Display Messages in Views](http://guides.rubyonrails.org/v2.3.11/activerecord_validations_callbacks.html#displaying-validation-errors-in-the-view)
<pre>
 <% flash.each do |name, msg| %>
  <%= content_tag :div, msg, :id => "flash#{name}" %>
<% end %>
</pre>

#### Add sign up route.
<pre>get "sign_up" => "users#new", :as => "sign_up"</pre>

### Add current_user method to the ApplicationController

<pre>
helper_method :current_user
  
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
</pre>

#### Create links for login and logout in the layout.
<pre>
<div id="user_nav">
  <% if current_user %>
    Logged in as <%= current_user.email %>
    <%= link_to "Log out", log_out_path %>
  <% else %>
    <%= link_to "Sign up", sign_up_path %> or 
    <%= link_to "Log in", log_in_path %>
  <% end %>
</div>
</pre>

## Add User - Song relationship

#### Create song collection association
<pre>
r g model song_collection user:belongs_to song:belongs_to active:boolean 
</pre>
<pre>
rake db:migrate
</pre>

Add to the SongCollection join model.
<pre>
belongs_to :user
belongs_to :song
</pre>

#### Update user model with song collection 
<pre>
  has_many :song_collections                                                   
  has_many :songs, through: :song_collections
  </pre>

#### Seed a couple of users, songs and song collections.

<pre>
foxy = Song.create(name: 'Foxy', description: "The artist is Oblast", url: 'http://www.youtube.com/watch?v=a_rflWF-iBg')

c_jesus = Song.create(name: 'Chocolate Jesus', description: "The artist is Tom Waits", url: 'http://www.youtube.com/watch?v=m5kHx1itU8c')

ended  = Song.create(name: "Cause we've ended as lovers", description: "The artist is Jeff Beck", url: 'http://www.youtube.c')

golden = Song.create(name: 'Golden Age', description: "The artist is Beck", url: 'http://www.youtube.com/watch?v=Y6zAT15vaFk')


foo = User.create(email: 'foo@example.com', password: 'foo')
bar = User.create(email: 'bar@example.com', password: 'bar')

foo.songs << foxy
foo.songs << golden
foo.save!

bar.songs << c_jesus
bar.save!
  
</pre>

<pre>
rake db:seed
</pre>

#### Check it out in the rails console

#### Add a Song filter.
Based on the currently logged in user, current_user to the SongsController. 

<pre>
def index
  if current_user                                                            
      @songs = current_user.songs                                              
    else                                                                       
      @songs = Song.all                                                        
    end                
end
</pre>

#### Update the current_user method in the ApplicationController.

<pre>
def current_user                                                             
    if session[:user_id]                                                       
      @current_user ||= User.find(session[:user_id])                           
    else                                                                       
      nil                                                                      
    end                                                                        
  end        
</pre>

#### Add an action in the SongsController that will show only *active* songs.

<pre>
                                                                               
  def valid_songs                                                              
    if current_user                                                            
      @songs = current_user.active_songs                                       
    else                                                                       
      @songs = SongCollection.active.map(&:song)                               
    end                                                                        
    render :index                                                              
  end                                                                          
         
</pre>

#### In the SongCollection model add a scope.
<pre>
 scope :active, lambda { where(active: true)}
</pre>

#### In the User model add a method to get active songs for each User.
<pre>
def active_songs                                                             
    self.songs.merge(SongCollection.active)                                    
  end    
</pre>

#### Add a route for valid_songs
<pre>
get "valid_songs" => "songs#valid_songs", :as => "valid_songs" 
</pre>
