require 'csv'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zipcode)
    if zipcode.nil?
        '00000'
    elsif zipcode.length < 5
        zipcode.rjust(5, '0')
    elsif zipcode.length > 5
        zipcode[0..4]
    else
        zipcode
    end
end

def legislator_by_zipcode(zipcode)

    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zipcode,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        )
        legislators = legislators.officials
        legislator_names = legislators.map do |legislator|
            legislator.name
        end
        legislator_string = legislator_names.join(", ")
        rescue
            'You can find your representatives by visiting www.commoncause.org'
        end

end

def save_thank_you_letter(id, final_personal_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, "w") do |file|
        file.puts final_personal_letter
    end
end

puts "Event Manager Initialized!"

template_letter = File.read('form_letter.html')

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
contents.each do |row|
    id = row[0]
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislator_by_zipcode(zipcode) 

    personal_letter = template_letter.gsub("FIRST_NAME", name)
    final_personal_letter = personal_letter.gsub!("LEGISLATORS", legislators)

    save_thank_you_letter(id, final_personal_letter)

end