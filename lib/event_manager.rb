puts "Event Manager Initialized."

# contents = File.read("./event_attendees.csv")
# puts contents

lines = File.readlines("./event_attendees.csv")
lines.each do |line|
  next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n"
  columns = line.split(",")
  first_name = columns[2]
  puts first_name
end