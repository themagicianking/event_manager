require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_phone_number(phone_number)
  if phone_number.length < 10
    phone_number = nil
  elsif phone_number.length == 11 && phone_number[0] == 1
    phone_number.to_s.rjust[1..10]
  elsif phone_number.length == 11
    phone_number = nil
  else
  end
  return phone_number
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def save_time_data(peak_time, marketing_letter)
  filename = "output/marketing.html"

  File.open(filename, 'w') do |file|
    file.puts marketing_letter
  end
end

puts 'Event Manager Initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
marketing_letter = File.read('marketing_data.erb')

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end