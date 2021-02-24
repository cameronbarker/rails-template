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

git add: "."
git commit: "-m 'Heroku Config'"