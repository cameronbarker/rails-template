puts "Install Better Error, Error Page"
run "bundle add better_errors binding_of_caller"

git add: "."
git commit: "-m 'Better Errors, Error Pages'"
