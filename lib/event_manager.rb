require "csv"
require "sunlight/congress"
require "erb"
require "date"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5,"0")[0..4]
end 

def legislators_by_zipcode(zipcode)
	legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end 

def save_thank_you_letters(id,form_letter)
	Dir.mkdir("output") unless Dir.exists?("output")

	filename = "output/thanks_#{id}.html"

	File.open(filename,'w') do |file|
		file.puts form_letter
	end
end 

#clean up phone numbers
def clean_phone(number)
  clean_number = number.gsub(/[^\d]/, "")
  if clean_number.length == 10
    clean_number
  elsif clean_number.length == 11
    if clean_number.start_with?("1")
      clean_number = number[1..-1]
    else
      clean_number = "0000000000"
    end
  else
    clean_number = "0000000000"
  end
end


#find peak hours of registration
def peak_hours(time)
  DateTime.strptime(time, '%m/%d/%Y %H:%M').hour
end

#find peak days of registration
def peak_days(day)
  DateTime.strptime(day, '%m/%d/%y %H:%M').wday
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
	id = row[0]
	name = row[:first_name]
	zipcode = clean_zipcode(row[:zipcode])
	phone = clean_phone(row[:homephone])
	legislators = legislators_by_zipcode(zipcode)
	time = peak_hours(row[:regdate])
	day = peak_days(row[:regdate])

	form_letter = erb_template.result(binding)

	save_thank_you_letters(id,form_letter)
end 