# Template for building out a new Floxee directory
# http://floxee.org
app_name = ask("What is your application called?")
puts "That's a great name!\n"
yes?("Think of that all by yourself? (yes/no)\n")
puts "\nBefore this generator runs you will need to register #{app_name} for OAuth at http://twitter.com/oauth_clients, then enter the consumer key and secret below:\n\n"
consumer_key = ask("OAuth Consumer Key:")
consumer_secret = ask("OAuth Consumer Secret:")

puts "Some system processes currently still use basic authentication. What Twitter account would you like to use for the system account?\nWe recommend creating an account just for the app and getting whitelisted here:\nhttp://twitter.com/help/request_whitelisting"
twitter_username = ask("System Twitter username:")
twitter_password = ask("System Twitter password:")

# Delete unnecessary files
run "rm public/index.html"

# Set up git repository
git :init

# Copy database.yml for distribution use
run "cp config/database.yml config/database.yml.example"

# Snag the latest jQuery
run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"

# Set up .gitignore files
run %{find . -type d -empty | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
coverage/*
log/*.log
db/*.db
db/*.sqlite3
db/schema.rb
tmp/**/*
doc/api
doc/app
config/database.yml
coverage/*
log/*.log
config/database.yml
db/schema.sql
public/images/.DS_Store
public/images/icons/.DS_Store
public/stylesheets/compiled/floxee/screen.css
.DS_Store
public/plugin_assets
nbproject
public/.htaccess
tmp
vendor/.DS_Store
_projfiles_
*.swp
lib/basecamp.rb
config/initializers/site_keys.rb
config/twitter_auth.yml
config/floxee.yml
END

# Install plugins as git submodules
plugin 'twitter_auth', :git => 'git://github.com/squeejee/twitter-auth.git', :submodule => true
plugin 'floxee', :git => 'git://github.com/squeejee/floxee.git', :submodule => true
plugin 'haml', :git => "git://github.com/nex3/haml.git"
plugin 'cucumber', :git => "git://github.com/aslakhellesoy/cucumber.git"
plugin 'friendly_id', :git => "git://github.com/norman/friendly_id.git"

# Install all gems
#gem 'jnunemaker-twitter', :lib => 'twitter', :version => '~> 0.4.2', :source => 'http://gems.github.com'
gem 'rsl-stringex', :lib => "stringex", :source => "http://gems.github.com"
gem 'mislav-will_paginate', :version => '~> 2.3.6', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'jchris-couchrest', :lib => 'couchrest', :version => '~> 0.22', :source => "http://gems.github.com"
gem 'chriseppstein-compass', :lib => 'compass', :source => "http://gems.github.com"
gem 'hayesdavis-grackle', :lib => 'grackle', :source => 'http://gems.github.com'  

# Initialize submodules
git :submodule => "init"

if yes?("Run rake gems:install? (yes/no)")
  rake('gems:install', :sudo => true)
  rake('gems:unpack')
end

route "map.root :controller => 'main'"

# Set up session language initializer
initializer 'internationalization.rb', <<-CODE
I18n.load_path += Dir[Rails.root.join('vendor', 'plugins', 'floxee', 'config', 'locales', '*.{rb,yml}')]
CODE


# set up compass for sass goodness
initializer 'compass.rb', <<-CODE
require 'compass'
# If you have any compass plugins, require them here.
Compass.configuration do |config|
  config.project_path = RAILS_ROOT
  config.sass_dir = "app/stylesheets"
  config.css_dir = "public/stylesheets/compiled"
end
Compass.configure_sass_plugin!
CODE

file 'app/stylesheets/ie.sass', <<-END
@import ../../vendor/plugins/floxee/app/stylesheets/ie.sass
// IE specific styles here
END

file 'app/stylesheets/print.sass', <<-END
@import ../../vendor/plugins/floxee/app/stylesheets/print.sass
// print specific styles here
END

file 'app/stylesheets/screen.sass', <<-END
@import ../../vendor/plugins/floxee/app/stylesheets/screen.sass

// app styles here
END

run "mkdir -p public/stylesheets/compiled/floxee"

file 'config/floxee.yml.example', <<-YAML
development:
  username: 
  password: 
test:
  username: 
  password: 
production:
  username: 
  password: 
YAML

file 'config/floxee.yml', <<-YAML
development:
  username: "#{twitter_username}"
  password: "#{twitter_password}"
test:
  username: "#{twitter_username}"
  password: "#{twitter_password}"
production:
  username: "#{twitter_username}"
  password: "#{twitter_password}"
YAML

file 'config/twitter_auth.yml.example', <<-YAML
development:
  strategy: oauth
  oauth_consumer_key: 
  oauth_consumer_secret: 
  base_url: "http://twitter.com"
  api_timeout: 10
  remember_for: 14 # days
  oauth_callback: "http://localhost:3000/oauth_callback"
test:
  strategy: oauth
  oauth_consumer_key: 
  oauth_consumer_secret: 
  base_url: "http://twitter.com"
  api_timeout: 10
  remember_for: 14 # days
  oauth_callback: "http://localhost:3000/oauth_callback"
production:
  strategy: oauth
  oauth_consumer_key: 
  oauth_consumer_secret: 
  base_url: "http://twitter.com"
  api_timeout: 10
  remember_for: 14 # days
YAML

file 'config/twitter_auth.yml', <<-YAML
development:
  strategy: oauth
  oauth_consumer_key: "#{consumer_key}"
  oauth_consumer_secret: "#{consumer_secret}"
  base_url: "http://twitter.com"
  api_timeout: 10
  remember_for: 14 # days
  oauth_callback: "http://localhost:3000/oauth_callback"
test:
  strategy: oauth
  oauth_consumer_key: "#{consumer_key}"
  oauth_consumer_secret: "#{consumer_secret}"
  base_url: "http://twitter.com"
  api_timeout: 10
  remember_for: 14 # days
  oauth_callback: "http://localhost:3000/oauth_callback"
production:
  strategy: oauth
  oauth_consumer_key: "#{consumer_key}"
  oauth_consumer_secret: "#{consumer_secret}"
  base_url: "http://twitter.com"
  api_timeout: 10
  remember_for: 14 # days
YAML


# grab our migrations and assets
run "rake floxee:sync "
#run "rake floxee:bootstrap"

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'Initial commit'"

# Success!
puts "\n\n*********\n\nWe're done, flock yeah!\n\n"
puts "See http://twitter.com/oauth_clients for more info"
puts "Create your db as specified in config/database.yml and run 'rake db:migrate'\n\n"
