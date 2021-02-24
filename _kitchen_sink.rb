# New commit
git add: "."
git commit: "-m 'Initial commit'"

# Template: RSPEC, FactoryBot, Standard
run "rails app:template LOCATION='scripts/testing'"

# Set up Configs
run "rails app:template LOCATION='scripts/configs'"

# Install: Devise
run "rails app:template LOCATION='scripts/authentication'"

# Install: Errors
run "rails app:template LOCATION='scripts/errors'"

# Set Up Heroku
run "rails app:template LOCATION='scripts/'heroku"

# Marketing Pages and SEO"
run "rails app:template LOCATION='scripts/marketing'"

# Set up staging site
run "rails app:template LOCATION='scripts/staging'"

# Template: HAML
run "rails app:template LOCATION='scripts/haml'"

puts "Set Up DB"
rails_command("db:create")
rails_command("db:migrate")
git add: "."
git commit: "-m 'DB Set Up'"


