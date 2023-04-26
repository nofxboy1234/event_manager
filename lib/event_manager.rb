require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

require 'pry-byebug'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def peak_registration_hours(contents)
  registration_hours = contents.map do |row|
    Time.strptime(row[:regdate], '%m/%d/%y %H:%M').hour
  end
  
  max_registrations = registration_hours.tally.values.max
  
  peak_hours = registration_hours.tally.select do |hour, count| 
    hour if count == max_registrations
  end
end

def peak_registration_days(contents)
  registration_days = contents.map do |row|
    Time.strptime(row[:regdate], '%m/%d/%y %H:%M').strftime('%A')
  end
  
  max_registrations = registration_days.tally.values.max
  
  peak_days = registration_days.tally.select do |day, count| 
    day if count == max_registrations
  end
end

def format_as_phone_number(phone_number)
  # 2062263000
  group_a = phone_number[0, 3]
  group_b = phone_number[3, 3]
  group_c = phone_number[6, 4]
  # '206' '226' '3000'
  group_a.concat('-', group_b, '-', group_c)
  # 206-226-3000
end

def keep_number_characters(phone_number)
  array = phone_number.split('')
  filtered_array = array.filter_map { |element| element if element.to_i.to_s == element }
  filtered_array.join
end

def clean_phone_number(phone_number)
  phone_number = keep_number_characters(phone_number)
  
  if phone_number.size < 10 || phone_number.size > 11
    'bad number'
  elsif phone_number.size == 10
    format_as_phone_number(phone_number)
  elsif phone_number.size == 11 && phone_number[0] == '1'
    format_as_phone_number(phone_number[1..-1])
  elsif phone_number.size == 11 && phone_number[0] != '1'
    'bad number'
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
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

def contents
  # puts '#contents'
  CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
end

puts 'Event Manager Initialized'

peak_hours = peak_registration_hours(contents)
puts "Peak registration hours are: #{peak_hours.keys}"

peak_days = peak_registration_days(contents)
puts "Peak registration days are: #{peak_days.keys}"

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  
  phone_number = clean_phone_number(row[:homephone])
  form_letter = erb_template.result(binding)
  
  save_thank_you_letter(id, form_letter)
end
