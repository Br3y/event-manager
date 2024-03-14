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

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials

    legislator_names = legislators.map(&:name)

    legislator_strings = legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
  
  puts "#{name} #{zip} #{legislator_strings}"
end