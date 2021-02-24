puts "Install HAML and convert"
run "bundle add haml haml-rails"
git add: "."
git commit: "-m 'Haml'"

run "bundle add erb2haml --group 'development'"
rake "haml:replace_erbs"
git add: "."
git commit: "-m 'HAML Conversion'"