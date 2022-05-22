run "bundle add ruby-progressbar faker --group 'development'"

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
  # results.each do |k, v|
  #   puts "#{k}: #{v}"
  # end
CODE


