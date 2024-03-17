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

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager Initialized.'

template_letter = File.read('../form_letter.erb')
erb_template = ERB.new(template_letter)

contents = CSV.open('./event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zip = clean_zipcodes(row[:zipcode])

  phone = row[:homephone]

  legislators = legislators_by_zipcode(zip)

  form_letter = erb_template.result(binding)
  
  if phone.nil?
    phone = 'bad number'
  elsif phone.length < 10
    phone += " - bad number"
  elsif phone.length == 11
    if phone[0] == "1"
      phone = "#{phone[1..-1]}"
    else
      phone += ' - bad number'
    end
  elsif phone.gsub(/\D/, "").length > 11
    phone += ' - bad number'
  end
  puts phone
  save_thank_you_letter(id, form_letter)
end
