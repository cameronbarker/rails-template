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

git add: "."
git commit: "-m 'Staging Set Up'"