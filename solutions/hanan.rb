
def includes_any_char?(str, chars)
  chars.each_char do |char|
    return true if str.include?(char)
  end
  false
end

def get_conform_list(string)
  return string.chars.map.with_index{|c,i| {char: c, index: i} }.
                        select{|c| c[:char] != ' '}
end

def all_places_conform?(word, list)
  return list.all? { |item| word[item[:index]] == item[:char] }
end

def trim_list_by_conform(conform_word, list)
  conform_list = get_conform_list(conform_word)
  new_list = list.select { |word| all_places_conform?(word, conform_list) }
  return new_list
end

def include_all_chars?(word, chars_word)
  return chars_word.chars.all? { |char| word.include?(char) }
end

def trim_list_by_included_letters(list, word_with_included_letters)
  new_list = list.select { |word|  include_all_chars?(word, word_with_included_letters)}
  return new_list
end

def letters_to_include_avoid_places?(word, letters_to_include_avoid_places)
  res = letters_to_include_avoid_places.none? { |char, place| word[place] == char }
  # puts "letters_to_include_avoid_places? #{word} #{letters_to_include_avoid_places} #{res}"
  return res
end

def trim_list_by_letters_to_include_avoid_places(list, letters_to_include_avoid_places)
  new_list = list.select { |word|  letters_to_include_avoid_places?(word, letters_to_include_avoid_places)}
  return new_list
end

def trim_list(list, word, conform_word: nil, included_letters: nil, letters_to_include_avoid_places: nil)
  new_list = list.reject { |list_word| includes_any_char?(list_word, word) }
  new_list = trim_list_by_included_letters(new_list, included_letters) if included_letters
  new_list = trim_list_by_conform(conform_word, new_list) if conform_word
  new_list = trim_list_by_letters_to_include_avoid_places(new_list, letters_to_include_avoid_places) if letters_to_include_avoid_places
  return new_list
end

def merge_conform_words(a, b)
  res = []
  res = a.chars.map.with_index do |char, index|
    (char == ' ' ? b[index] : char)
  end
  return res.join
end

def calc_score(word, list)
  trim_list(list, )
end

def score_letters(list)
  ('a'..'z').map do |letter|
    freq = list.count do |word|
      word.include?(letter)
    end
    [letter, freq]
  end.to_h
end

def score_words(letter_scores, list)

  list.map do |word|
    sum = word.chars.uniq.sum { |char| letter_scores[char] }
    downgrade = word.chars.length - word.chars.uniq.length
    [word, sum - downgrade]
    # [word, sum]
  rescue => e
    puts "word: #{word}"
    raise
  end.sort_by { |word, score| score }.reverse
end

def solve_the_wordle(status_array: input)
  # puts "status_array: #{status_array}"
  letters_to_reject = []
  letters_to_include = []
  letters_to_include_avoid_places = []
  conform_word = '     '
  status_array.each do |step_results|
    letters_to_reject << (step_results.select { |item| item[1] == RED }.map { |item| item[0] })
    letters_to_include << (step_results.select { |item| item[1] == YELLOW }.map { |item| item[0] })
    letters_to_include_avoid_places += (step_results.each_with_index.reduce([]) do |memo, (element, index)|
      memo.push([element[0], index]) if element[1] == YELLOW
      memo
    end)
    new_conform_word = step_results.map { |item| item[1] == GREEN ? item[0] : ' ' }.join
    conform_word = merge_conform_words(conform_word, new_conform_word)
    # puts "conform_word: #{conform_word}"
  end
  letters_to_include_avoid_places = letters_to_include_avoid_places.uniq
  # puts "letters_to_include_avoid_places: #{letters_to_include_avoid_places}"
  letters_to_reject = letters_to_reject.flatten.uniq
  letters_to_include = letters_to_include.flatten.uniq
  conform_word = nil if conform_word == '     '
  possible_words = trim_list(WORDS_DICT, letters_to_reject.join, conform_word: conform_word, included_letters: letters_to_include.join, letters_to_include_avoid_places: letters_to_include_avoid_places)
  # puts "possible_words.length: #{possible_words.length}"
  letter_scores = score_letters(possible_words)
  # puts "letter_scores: #{letter_scores}"
  word_scores = score_words(letter_scores, possible_words)
  # puts "word_scores.first(3): #{word_scores.first(3)}"


  # puts "letters_to_reject: #{letters_to_reject}"
  # puts "letters_to_include: #{letters_to_include}"
  return word_scores.first[0]
end
