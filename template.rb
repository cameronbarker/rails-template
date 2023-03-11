add_source 'https://rubygems.org'

gem "bcrypt"
gem "devise"
gem "haml"
gem "haml-rails"

gem_group :development do
  gem "figaro"
  gem "pry-rails"
  gem "better_errors"
  gem "binding_of_caller"
  gem "erb2haml"
end

gem_group :test, :development do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "standard"
  gem "ruby-progressbar"
  gem "faker"
end


after_bundle do
  rails_command "db:create"
  
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


  puts "Adding: Devise as User"

  run "rails generate devise:install"
  run "rails generate devise User"
  run "rails generate devise:views"


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


  # Figaro


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


  puts "Marketing: SEO"

  # Landing Page
  generate(:controller, "static index")
  route "root to: 'static#index'"

  # SEO
  run "touch app/views/layouts/_seo.haml"
  inject_into_file "app/views/layouts/_seo.haml" do <<~EOF
    %title= meta_title
    %meta{name:"description", content:"\#{meta_description}"}

    %link{href:  "/seo/apple-icon-57x57.png", rel:  "apple-touch-icon", sizes:  "57x57"}
    %link{href:  "/seo/apple-icon-60x60.png", rel:  "apple-touch-icon", sizes:  "60x60"}
    %link{href:  "/seo/apple-icon-72x72.png", rel:  "apple-touch-icon", sizes:  "72x72"}
    %link{href:  "/seo/apple-icon-76x76.png", rel:  "apple-touch-icon", sizes:  "76x76"}
    %link{href:  "/seo/apple-icon-114x114.png", rel:  "apple-touch-icon", sizes:  "114x114"}
    %link{href:  "/seo/apple-icon-120x120.png", rel:  "apple-touch-icon", sizes:  "120x120"}
    %link{href:  "/seo/apple-icon-144x144.png", rel:  "apple-touch-icon", sizes:  "144x144"}
    %link{href:  "/seo/apple-icon-152x152.png", rel:  "apple-touch-icon", sizes:  "152x152"}
    %link{href:  "/seo/apple-icon-180x180.png", rel:  "apple-touch-icon", sizes:  "180x180"}
    %link{href:  "/seo/android-icon-192x192.png", rel:  "icon", sizes:  "192x192", type:  "image/png"}
    %link{href:  "/seo/favicon-32x32.png", rel:  "icon", sizes:  "32x32", type:  "image/png"}
    %link{href:  "/seo/favicon-96x96.png", rel:  "icon", sizes:  "96x96", type:  "image/png"}
    %link{href:  "/seo/favicon-16x16.png", rel:  "icon", sizes:  "16x16", type:  "image/png"}
    %link{href:  "/seo/manifest.json", rel:  "manifest"}
    %meta{content:  "#ffffff", name:  "msapplication-TileColor"}
    %meta{content:  "/seo/ms-icon-144x144.png", name:  "msapplication-TileImage"}
    %meta{content:  "#ffffff", name:  "theme-color"}

    -# Facebook Open Graph data
    %meta{property:"og:title", content:"\#{meta_title}"}
    %meta{property:"og:type", content:"website"}
    %meta{property:"og:url", content:"\#{request.original_url}"}
    %meta{property:"og:image", content:"\#{meta_image}"}
    %meta{property:"og:image:width", content:"681"}
    %meta{property:"og:image:height", content:"682"}
    %meta{property:"og:description", content:"\#{meta_description}"}
    %meta{property:"og:site_name", content:"\#{meta_title}"}

    -# Twitter Card data
    %meta{name:"twitter:card", content:"summary_large_image"}
    %meta{name:"twitter:site", content:"\#{meta_title}"}
    %meta{name:"twitter:title", content:"\#{meta_title}"}
    %meta{name:"twitter:description", content:"\#{meta_description}"}
    %meta{name:"twitter:image:src", content:"\#{meta_image}"}

    -# Google Item Scope
    %meta{ itemscope: "", itemtype: "http://schema.org/Article" }
    %meta{ itemprop: "name", content:"\#{meta_title}" }
    %meta{ itemprop: "description", content:"\#{meta_description}" }
    %meta{ itemprop: "title", content: "\#{meta_title}" }
    %meta{ itemprop: "image", content: "\#{meta_image}" }
    EOF
  end


  run "touch app/helpers/meta_tags_helper.rb"

  inject_into_file "app/helpers/meta_tags_helper.rb" do <<~EOF
    module MetaTagsHelper
      def meta_title
        content_for(:seo_meta_title) || "DEFAULT TITLE"
      end

      def meta_description
        content_for(:seo_meta_description) || "DEFAULT DESCRIPTION"
      end

      def meta_image
        # Placed in public folder
        content_for(:seo_meta_image) || "\#{ENV["SITE_URL"]}/seo/meta_image.png"
      end
    end
    EOF
  end

  gsub_file "app/views/layouts/application.html.erb", /(.*%title .*)/, "    = render 'layouts/seo'"


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



  puts "Set up staging site"

  run 'touch config/environments/staging.rb'
  inject_into_file "config/environments/staging.rb" do <<~EOF
    # Just use the production settings
    require File.expand_path("../production.rb", __FILE__)

    Rails.application.configure do
      # Here override any defaults
      config.serve_static_files = true
    end
    EOF
  end

  inject_into_file "app/controllers/application_controller.rb", after: "class ApplicationController < ActionController::Base" do <<~EOF
    
      before_action :staging_http_authenticate
      def staging_http_authenticate
        return unless Rails.env.staging?

        authenticate_or_request_with_http_basic do |username, password|
          username == "username" && password == "password"
        end
      end
    EOF
  end


  puts "Install HAML and convert"
  rake "haml:replace_erbs"
  
  rake "rake db:setup"
  
  run 'bundle exec standardrb --fix'

  run "rspec"

  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
