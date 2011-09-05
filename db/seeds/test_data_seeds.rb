require 'factory_girl_rails'

print "Creating seeded users... "
10000.times do
  Factory(:user)
end
puts "done!"


