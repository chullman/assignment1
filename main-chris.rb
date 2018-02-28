require 'JSON'
require 'colorize'

json_from_file = File.read("all-riddles.json")

json_results = JSON.parse(json_from_file, object_class: OpenStruct)

json_results.riddleDetails.each_with_index do |riddle, index|

  puts riddle[:question]

  begin
  
  until gets.chomp.downcase.include?(json_results.riddleDetails[index][:answer]) do
    puts "Incorrect! try again".colorize(:red)
  end
  puts "Correct, the answer is: #{json_results.riddleDetails[index][:answer]}".colorize(:green)

  rescue
    puts "Something went wrong, try again!"
  end

end