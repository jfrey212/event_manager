require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

# to_s deals with empty values (nil) -> nil.to_s = ""
# to_s does not affect the non-nil values
# rjust(5, '0') adds leading zeros to short zip codes
# does nothing for zip codes >= 5 digits
# slice [0..4] take the first 5 digits from a long zip code
# does nothing to a code with exactly 5 digits
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(number)
  clean_number = number.gsub('(', '').gsub(')', '').gsub('-', '').gsub(' ', '').gsub('.', '')

  if clean_number.length < 10 || clean_number.length > 11
    clean_number = '0000000000'
  elsif clean_number.length == 11 && clean_number[0] == '1'
    clean_number.slice(1..-1)
  elsif clean_number.length == 11 && clean_number[0] != '1'
    clean_number = '0000000000'
  else
    clean_number
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
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

puts 'Event Manager Initialized'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  homephone = clean_phone_number(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end
