puts "Template: RSPEC, FactoryBot, Standard"

run "spring stop"

run "bundle add rspec-rails factory_bot_rails standard --group 'development, test'"

# RSPEC
rails_command "generate rspec:install"
run "rm -rf test"

# FACTORY BOT
File.open(Rails.root.join("spec/rails_helper.rb"), "r+") do |file|
  lines = file.each_line.to_a
  config_index = lines.find_index("RSpec.configure do |config|\n")
  lines.insert(config_index + 1, "  config.include FactoryBot::Syntax::Methods\n")
  file.rewind
  file.write(lines.join)
end

# STANDARD
run "touch .standard.yml"
inject_into_file ".standard.yml" do <<~EOF
fix: true               # default: false
parallel: true          # default: false
format: progress        # default: Standard::Formatter

ignore:                 # default: []
  - 'db/seeds.rb'
EOF
end
run 'bundle exec standardrb --fix'

git add: "."
git commit: "-m 'Rspec, FactorBot, Standard'"