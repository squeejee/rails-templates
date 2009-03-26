# Template for building out a new Floxee directory
# http://floxee.org


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
END

# Install plugins as git submodules
plugin 'twitter_auth', :git => 'git://github.com/mbleigh/twitter-auth.git', :submodule => true
plugin 'floxee', :git => 'git://github.com/squeejee/floxee.git', :submodule => true
plugin 'haml', :git => "git://github.com/nex3/haml.git"
plugin 'cucumber', :git => "git://github.com/aslakhellesoy/cucumber.git"


# Install all gems
gem 'twitter', :lib => 'twitter', :version => '~> 0.4.2', :source => 'http://gems.github.com'
gem 'rsl-stringex', :lib => "stringex", :source => "http://gems.github.com"
gem 'mislav-will_paginate', :version => '~> 2.3.6', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'jchris-couchrest', :lib => 'couchrest', :version => '~> 0.22', :source => "http://gems.github.com"
gem 'chriseppstein-compass', :lib => 'compass', :version => '~> 0.5.4', :source => "http://gems.github.com"

# Initialize submodules
git :submodule => "init"

rake('gems:install', :sudo => true)
rake('gems:unpack')

route "map.root :controller => :main"

# Set up session language initializer
initializer 'internationalization.rb', <<-CODE
I18n.default_locale = :'en-US'
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

initializer 'floxee.rb', <<-CODE
require 'compass'
# If you have any compass plugins, require them here.
Compass.configuration do |config|
  config.project_path = RAILS_ROOT
  config.sass_dir = "vendor/plugins/floxee/app/stylesheets"
  config.css_dir = "public/stylesheets/compiled/floxee"
end
Compass.configure_sass_plugin!
CODE

file 'app/stylesheets/ie.sass', <<-END
// IE specific styles here
END

file 'app/stylesheets/print.sass', <<-END
// print specific styles here
END

file 'app/stylesheets/screen.sass', <<-END
@import ../../vendor/plugins/floxee/app/stylesheets/screen.sass

// app styles here
END

run "mkdir -p public/stylesheets/compiled/floxee"

# set up couchdb settings
file "config/floxee.yml", <<-YAML
development:
  server: http://127.0.0.1:5984/#{@root.split('/').last}
test:
  server:http://127.0.0.1:5984/#{@root.split('/').last}_test
production:
  server: http://127.0.0.1:5984/#{@root.split('/').last}
YAML

# Set up user model and run migrations
generate("twitter_auth", "--oauth")

run "rake floxee:sync "
#run "rake floxee:bootstrap"

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'Initial commit'"

# Success!
puts "\n\n*********\n\nWe're done, flock yeah!\n\n"
puts "Be sure to update your Twitter API creds in config/twitter_auth.yml"
puts "See http://twitter.com/oauth_clients for more info"
puts "Create your db as specified in config/database.yml and run 'rake db:migrate'\n\n"
