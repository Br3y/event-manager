require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "date"

puts "Event Manager Initialized!"

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

# Iteration 1: Parsing with CSV

# # Switching over to use the CSV Library
# contents = CSV.open("event_attendees.csv", headers: true)
# contents.each do |row|
#   name = row[2]
#   puts name
# end

# # Accessing columns by their names
# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )
# contents.each do |row|
#   name = row[:first_name]
#   puts name
# end

# # Displaying the zip codes of all attendees
# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zip = row[:zipcode]
#   puts "#{name} #{zip}"
# end

# Iteration 2: Cleaning up our zip codes

# def clean_zipcode(zip)
#   zip.to_s.rjust(5, "0")[0..4]
# end

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zip = clean_zipcode(row[:zipcode])

#   puts "#{name} #{zip}"
# end

# Iteration 3: Using Google's Civic Information

# def clean_zipcode(zipcode)
#   zipcode.to_s.rjust(5, "0")[0..4]
# end

# def legislator_by_zipcode(zipcode)

#   civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
#   civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

#   begin
#     legislators = civic_info.representative_info_by_address(
#       address: zipcode,
#       levels: 'country',
#       roles: ['legislatorUpperBody', 'legislatorLowerBody']
#     )
#     legislators = legislators.officials

#     # legislator_names = legislators.map do |legislator|
#     #   legislator.name
#     # end

#     legislator_names = legislators.map(&:name)

#     legislator_names.join(", ")
#   rescue
#     'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
#   end
# end

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zipcode = clean_zipcode(row[:zipcode])
#   legislators = legislator_by_zipcode(zipcode)

#   puts "#{name} #{zipcode} #{legislators}"
# end

# Iteration 4: Form Letters

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislator_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
    # legislators = legislators.officials

    # legislators = legislators.map(&:name).join(", ")
  rescue StandardError
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id, form_letter)
  FileUtils.mkdir_p("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts form_letter
  end
end

def clean_homephone(phone)
  # verify_phone = phone.gsub(" ", "").gsub(".", "").gsub("-", "").gsub("(", "").gsub(")", "")
  verify_phone = phone.gsub(/[\s.\-()]/, "")

  # if verify_phone.nil?
  #   phone = " - Bad Number"
  # elsif verify_phone.length < 10
  #   phone += " - Bad Number"
  # elsif verify_phone.length == 10
  #   phone += " - Good Number"
  # elsif verify_phone.length >= 11
  #   if verify_phone[0] == "1"
  #     phone += " - Good Number"
  #   else
  #     phone += " - Bad Number"
  #   end
  # elsif verify_phone >= 12
  #   phone += " - Bad Number"
  # end

  phone + case verify_phone.length
          when 0..9
            " - Bad Number"
          when 10
            " - Good Nmber"
          when 11
            verify_phone[0] == "1" ? " - Good Number" : " - Bad Number"
          else
            " - Bad Number"
          end
end

def clean_registration_hours(regdate, registration_hours)
  reg_hour = regdate.hour
  registration_hours[reg_hour] += 1

  peak_reg_hour = registration_hours.max_by { |_hour, count| count }[0]
  peak_reg_hour_count = registration_hours.max_by { |_hour, count| count }[1]

  puts "The peak registration hour is: #{peak_reg_hour} with count of #{peak_reg_hour_count}"
end

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

registration_hours = Hash.new(0)
registration_days = Hash.new(0)
days = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislator_by_zipcode(zipcode)
  phone = clean_homephone(row[:homephone])
  regdate = clean_registration_hours(DateTime.strptime(row[:regdate], "%m/%d/%y %H:%S"), registration_hours)
  regday = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%S").wday

  puts "#{regday} = #{days[regday]}"

  registration_days[regday] += 1

  # personal_letter = template_letter.gsub("FIRST_NAME", name)
  # personal_letter.gsub!('LEGISLATORS', legislators)
  # personal_letter = personal_letter.gsub("LEGISLATORS", legislators)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)

  puts phone

  # puts "#{name} #{zipcode} #{legislators}"
end

peak_reg_days = registration_days.max_by { |_day, count| count }[0]

puts "The peak registration hour is: #{days[peak_reg_days]}"

puts registration_days
