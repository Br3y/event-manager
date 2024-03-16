require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcodes(zip)
  zip.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'EventManager Initialized.'

template_letter = File.read('../form_letter.erb')
erb_template = ERB.new(template_letter)

contents = CSV.open('./event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|

  name = row[:first_name]

  zip = clean_zipcodes(row[:zipcode])

  legislators = legislators_by_zipcode(zip)

  form_letter = erb_template.result(binding)
  
  puts form_letter
end
