add_source 'https://rubygems.org'

gem "bcrypt"
gem "devise"
gem "devise-jwt"

gem_group :development do
  gem "figaro"
  gem "pry-rails"
  gem "better_errors"
end

gem_group :test, :development do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "standard"
  gem "ruby-progressbar"
  gem "faker"
end


after_bundle do
  # RSPEC
  rails_command "generate rspec:install"
  run "rm -rf test"

  # FACTORY BOT
  File.open("spec/rails_helper.rb", "r+") do |file|
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


  puts "Set up Pry, Figaro, Configs"

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


  puts "Adding: Devise as User"

  run "rails generate devise:install"
  run "rails generate devise User"


  puts "Install Better Error, Error Page"


  puts "Set Up Heroku"

  run "touch Procfile"
  inject_into_file "Procfile" do <<~EOF
    web: bundle exec puma -C config/puma.rb
    release: bash ./release-tasks.sh
    EOF
  end

  run "touch release-tasks.sh"
  inject_into_file "release-tasks.sh" do <<~EOF
    #!/bin/bash

    echo "Running Release Tasks"

    if [ "$RUN_MIGRATIONS_DURING_RELEASE" == "true" ]; then
      echo "Running Migrations"
      bundle exec rails db:migrate
    fi

    if [ "$SEED_DB_DURING_RELEASE" == "true" ]; then
      echo "Seeding DB"
      bundle exec rails db:seed
    fi

    if [ "$RESTART_DB_DURING_RELEASE" == "true" ] && [ "$RAILS_ENV" == "staging" ]; then
      echo "Restarting DB"
      bundle exec rails db:restart_staging
    fi

    if [ "$CLEAR_CACHE_DURING_RELEASE" == "true" ]; then
      echo "Clearing Rails Cache"
      bundle exec rails r "Rails.cache.clear"
    fi

    echo "Done running release-tasks.sh"
    EOF
  end


  run "rm -rf config/puma.rb"
  run "touch config/puma.rb"

  inject_into_file "config/puma.rb" do <<~EOF
    workers Integer(ENV["WEB_CONCURRENCY"] || 2)
    threads_count = Integer(ENV["RAILS_MAX_THREADS"] || 5)
    threads threads_count, threads_count

    preload_app!

    rackup DefaultRackup
    port ENV["PORT"] || 3000
    environment ENV["RACK_ENV"] || "development"

    on_worker_boot do
      ActiveRecord::Base.establish_connection
    end
    EOF
  end

  # db/seeds.rb
  run 'rm -rf db/seeds.rb'
  file 'db/seeds.rb', <<-CODE
    TEMPLATE_CONSTANT = 20

    Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |file|
      require file
    end
  CODE

  # Make seeds folder
  run 'mkdir db/seeds'

  # Create Template Seed
  file 'db/seeds/00_template.rb', <<-CODE
    progressbar = ProgressBar.create(
      title: 'Creating First File',
      total: TEMPLATE_CONSTANT
    )

    TEMPLATE_CONSTANT.times do
      # Enter code here
      progressbar.increment
    end

  CODE


  # Create Summary View
  file 'db/seeds/99_summary.rb', <<-CODE
    models = ActiveRecord::Base.descendants
    results = {}.tap do |result|
      models.each do |model|
        next if model.name == 'ActiveRecord::SchemaMigration'
        next if model.name == 'ActiveRecord::InternalMetadata'
        next if model.name == 'ApplicationRecord'

        result[model.name] = model.count
      end
    end

    puts
    puts
    puts 'Summary'
    puts '-----------------'
    results.each do |k, v|
      puts k.to_s + ": " + v.to_s
    end
  CODE


  inject_into_file "app/controllers/application_controller.rb", after: "class ApplicationController < ActionController::Base" do <<~EOF
      respond_to :json
      include ActionController::MimeResponds
    EOF
  end
  
  rake "rake db:setup"
  
  run 'bundle exec standardrb --fix'

  run "rspec"

  git add: '.'
  git commit: "-a -m 'Initial commit'"
end