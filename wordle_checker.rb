require 'timeout'
load "constants.rb"

def check_wordle_solver(name, random_word)
  puts "Start loading #{name}.rb file"
  load "#{name}.rb"

  puts "The word to guess is: #{random_word}"

  status_array = []

  6.times do |attempt|
    guessed_word = ""
    begin
      Timeout::timeout(10) do
        guessed_word = solve_the_wordle(status_array: status_array.dup)
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

  puts "Failed to solve the wordle :-("
  return 10
end

require 'benchmark'


result = []
const_dictionary = WORDS_DICT.dup
random_words = (1..1000).map{|x| WORDS_DICT.sample }.uniq
random_dictionary = (0...2000).map{ (0...5).map { (97 + rand(26)).chr }.join }.uniq
random_words2 = (1..1000).map{|x| random_dictionary.sample }.uniq

["yuri", "hanan", "miguel_garcia", "sofi", "sacha", "andoni_alonso"].each do |filename|
  WORDS_DICT = const_dictionary.dup
  total_score = 0
  total_time = 0
  random_words.each do |random_word|
    time = Benchmark.measure { total_score += check_wordle_solver("solutions/#{filename}", random_word) }
    total_time += time.real
  end

  WORDS_DICT = random_dictionary.dup
  total_score2 = 0
  total_time2 = 0
  random_words2.each do |random_word|
    time = Benchmark.measure { total_score2 += check_wordle_solver("solutions/#{filename}", random_word) }
    total_time2 += time.real
  end

  score = total_score/random_words.length.to_f
  score2 = total_score2/random_words2.length.to_f

  result << "[real words scenario] #{filename}: score - #{score}, time - #{total_time}"
  result << "[random words scenario] #{filename}: score - #{score2}, time - #{total_time2}"
end
puts result
