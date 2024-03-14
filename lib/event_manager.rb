require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcodes(zip)
  zip.to_s.rjust(5, "0")[0..4]
end

puts "EventManager Initialized."

contents = CSV.open('./event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
  name = row[:first_name]
  zip = clean_zipcodes(row[:zipcode])

  legislators = civic_info.representative_info_by_address(
    address: zip,
    levels: 'country',
    roles: ['legislatorUpperBody', 'legislatorLowerBody']
  )
  legislators = legislators.officials

  puts "#{name} #{zip} #{legislators}"
end