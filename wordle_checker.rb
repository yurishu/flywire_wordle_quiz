require 'timeout'
load "constants.rb"

def check_wordle_solver(name)
  puts "Start loading #{name}.rb file"
  load "#{name}.rb"

  random_word = WORDS_DICT.sample
  puts "The word to guess is: #{random_word}"

  status_array = []

  6.times do |attempt|
    guessed_word = ""
    begin
      Timeout::timeout(10) do
        guessed_word = solve_the_wordle(status_array: status_array)
      end
    rescue Timeout::Error
      guessed_word = 'TIMED_OUT'
    rescue StandardError => e
      guessed_word = "Error: #{e.message}"
    end
    if guessed_word.nil? || !guessed_word.is_a?(String) || guessed_word.length != 5 || !WORDS_DICT.include?(guessed_word)
      puts "guessed_word is not valid (#{guessed_word}) - attempt #{attempt+1} is wasted"
      status_array << []
      next
    end
    puts "#{name}-#{attempt+1}-#{guessed_word}"

    if guessed_word == random_word
      puts "Congrulations you solved the wordle in #{attempt+1} attempts :-)"
      return (attempt+1)
    end

    attempt_result = []
    guessed_word.chars.each_with_index do |letter, index|
      if letter == random_word[index]
        attempt_result << [letter, GREEN]
      elsif random_word.chars.include?(letter)
        attempt_result << [letter, YELLOW]
      else
        attempt_result << [letter, RED]
      end
    end
    status_array << attempt_result
  end

  return 10
end
