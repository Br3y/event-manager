require 'csv'

puts "EventManager Initialized."

contents = CSV.open('./event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
  name = row[:first_name]
  zip = row[:zipcode]

  if zip.nil?
    zip = "00000"
  elsif zip.length > 5
    zip[0..4]
  elsif zip.length < 5
    until zip.length == 5
      zip += "0"
    end
  end
  puts "#{name} #{zip}"
end