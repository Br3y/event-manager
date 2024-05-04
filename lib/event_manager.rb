puts 'Event Manager Initialized!'

# Iteration 0: Loading a file

# # Read the file contents
# if File.exist?("event_attendees.csv")
#   contents = File.read("event_attendees.csv")
#   puts contents
# else
#   puts "File does not exists"
# end

# # Read the file line by line
# lines = File.readlines("event_attendees.csv")
# lines.each do |line|
#   puts line
# end

# # # Display the first names of all attendees
# lines = File.readlines("event_attendees.csv")
# lines.each_with_index do |line|
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# # Skipping the header row 
# lines = File.readlines("event_attendees.csv")
# # row_index = 0
# lines.each_with_index do |line, index|
#   # next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n"
#   # row_index = row_index + 1
#   # next if row_index == 1
#   next if index == 0 
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# "Look for a solution before building a solution"