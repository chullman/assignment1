# To determine operating system (Mac or Windows)
require 'os'
# To play sound effects on a windows machine
if OS.windows?
  require 'win32/sound'
  include Win32
end
# To read and correctly parse in the contents of a json formatted string
require 'json'
# Terminal text colorization
require 'rainbow/refinement'
using Rainbow
require 'rainbow'
Rainbow.enabled = true

require 'artii'


# Reads in the contents of all-riddles.json literally as one big string, brackets and all
json_from_file = File.read("all-riddles.json")

# Interprets the string as a json format, recognising all the brackets and braces, converts it into a Ruby class template,
# instantiates it into json_results as an object and populates the included properties
json_results = JSON.parse(json_from_file, object_class: OpenStruct)


# This will generate an array of a random, unique sequence of numbers which will serve as the index values that we will use to pick riddles at random
# We will pass in the number of riddles written in the json file (i.e. the length) into the parameter max_num
def generate_random_seq(max_num)

  # By nature, the results of .sample will ensure uniqueness by not including the same index value in the array twice
  return (0..max_num-1).to_a.sample max_num
end

# Text passed into this as text_to_display
# In our case, we only want the text "Next question..." to display if the player is not at the last question
# To do this, we check if the very last value in our random index array is equal to the current riddle the player is up to
def display_if_not_at_last_question(random_index_array, cur_value, text_to_display)
  if (random_index_array[-1] != cur_value)
    puts text_to_display
    puts ""
  end
end

# If, for example, there are 3 riddles in total, the array, random_index_array, might look like [2, 0, 1] or [0, 2, 1] etc.
random_index_array = generate_random_seq(json_results.riddleDetails.length)

a = Artii::Base.new
a.asciify('NICE!')
a.asciify('NOPE')


colors = [:aqua, :blueviolet, :orange, :forestgreen, :greenyellow]
puts ""
puts "FUN WITH RIDDLES".chars.map { |char| Rainbow(char).color(colors.sample) }.join
puts ""
puts "There are #{random_index_array.length} questions - for each correct answer you'll score a point!"
puts ""
puts "Get ready to play!"
puts ""

points = 0

# If random_index_array looks like [2, 0, 1] for example, we'll do an each loop through this array from start to end, and use the each number
# to serve as the getting the riddle at the particular numbers (i.e. get riddle at index 2, then at index 0, then at index 1)
random_index_array.each do |value|

  puts json_results.riddleDetails[value][:question].yellow

  begin

    riddle = json_results.riddleDetails[value]

    # A boolean/flag that will be raised if the player chooses to see the answer or skip the question. If true, break out of asking the same question again and go to the next question
    cheat_used = false

    # Loop until the player gets the question right
    print "What is your answer?\n - "
    until gets.chop.downcase.include?(riddle[:answer]) do
      puts a.asciify('NOPE!')
      puts ""
      puts "Sorry, that is incorrect! Do you want to see the answer?".red
      puts "Enter 'y' if yes, 's' to skip or any other key to try again".cyan
      print "What would you like to do?\n - "
      if OS.windows?
        Sound.play("fail-trombone-01.mp3")
      elsif OS.mac?
        pid = fork{ exec 'afplay', "fail-trombone-01.mp3"}
      end
      answer = gets.chomp.downcase
      if answer == "y" || answer == "s"
          cheat_used = true
          if answer == "y"
            puts ""
            puts "The correct answer is '#{riddle[:answer]}'"
            puts ""
          break elsif answer == "s"
          end
          display_if_not_at_last_question(random_index_array, value, "Next question...")
      else
      puts ""
      puts riddle[:question].yellow
      print " - "
      end


      # Break out of the loop if the player decides to see the answer, or skip the question (i.e. the user cheats)
      break if cheat_used

    end

    # If the player didn't cheat...
    if !cheat_used

      # Show the answer
      puts ""
      puts a.asciify('NICE!')
      puts "The answer is: #{riddle[:answer]}\nYou've scored a point!".green
      puts ""
      # Give the player a point
      points += 1

      display_if_not_at_last_question(random_index_array, value, "Next question...\n""")

      # Play a sound effect depending on whether the player is on Windows or Mac
      if OS.windows?
        Sound.play("magic-chime-01.wav")
      elsif OS.mac?
        pid = fork{ exec 'afplay', "magic-chime-01.wav"}
      end
    end

  # If something unexpected happens
  rescue Exception => e
    puts "Something went wrong, please restart the app!"
    # .message should return a string that my provide deatils about what went wrong
    puts e.message
  end


end
puts ""
puts "Thank you for playing. You have scored #{points} points out of #{random_index_array.length}!".green