require 'csv'

def clean_zipcodes(zip)
  if zip.nil?
    zip = "00000"
  elsif zip.length > 5
    zip[0..4]
  elsif zip.length < 5
    zip.rjust(5, "0")
  else
    zip
  end
end

puts "EventManager Initialized."

contents = CSV.open('./event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
  name = row[:first_name]
  zip = clean_zipcodes(row[:zipcode])

  puts "#{name} #{zip}"
end