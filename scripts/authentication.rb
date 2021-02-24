puts "Adding: Devise as User"

run "bundle add devise"
run "rails generate devise"
run "rails generate devise:views"

git add: "."
git commit: "-m 'Devise'"