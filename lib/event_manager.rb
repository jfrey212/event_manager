require 'csv'

# to_s deals with empty values (nil) -> nil.to_s = ""
# to_s does not affect the non-nil values
# rjust(5, '0') adds leading zeros to short zip codes
# does nothing for zip codes >= 5 digits
# slice [0..4] take the first 5 digits from a long zip code
# does nothing to a code with exactly 5 digits
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

puts 'Event Manager Initialized'

contents = CSV.open(
  '../event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  puts "#{name} #{zipcode}"
end
