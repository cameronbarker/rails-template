puts "Set up Pry, Figaro, Configs"

run "bundle add figaro"
run "bundle add pry-rails --group 'development, test'"

gsub_file "config/application.rb", /(.*config.generators.system_tests.*)/ do <<~EOF
      config.generators do |g|
        g.scaffold_stylesheet false
        g.helper false
        g.assets false
        g.jbuilder false
        g.test_framework :rspec,
          fixtures: false,
          view_specs: false,
          helper_specs: false,
          routing_specs: false,
          controller_specs: false,
          request_specs: false
      end

      config.generators.system_tests = nil
      config.filter_parameters << :password
      EOF
end



# Figaro
run "bundle exec figaro install"

git add: "."
git commit: "-m 'Add Pry, Application.rb, '"