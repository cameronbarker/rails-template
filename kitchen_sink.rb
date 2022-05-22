# New commit
git add: "."
git commit: "-m 'Initial commit'"

git checkout: "-b kitchen-sink"

# Template: RSPEC, FactoryBot, Standard
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/testing.rb'"

# Add Seeding setup
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/seeding.rb'"

# Set up Configs
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/configs.rb'"

# ISSUE
# Install: Authentication
# run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/authentication.rb'"

# ISSUE
# Install: Errors
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/errors.rb'"

# Set Up Heroku
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/heroku.rb'"

# Marketing Pages and SEO"
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/marketing.rb'"

# ISSUE
# Set up staging site
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/staging.rb'"

# Template: HAML
run "rails app:template LOCATION='https://raw.githubusercontent.com/cameronbarker/ruby-snippets/main/scripts/haml.rb'"

puts "Set Up DB"
rails_command("db:create")
rails_command("db:migrate")
git add: "."
git commit: "-m 'DB Set Up'"


