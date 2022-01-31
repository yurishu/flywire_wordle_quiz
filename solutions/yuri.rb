def solve_the_wordle(status_array: [])
    if status_array.length == 0
      initial_load
      return @words_score.first[:word]
    end
    update_state(status_array)
    return @words_score.first[:word]
end

def initial_load
  @possible_words = WORDS_DICT.dup
  calculate_letters_weight
  @words_score = calculate_words_score(@possible_words)
end

def filtered_words_letters(status_array)
  last_guess = status_array.last
  possible_letters = []
  last_guess.each_with_index do |guess, index|
    next if guess.last == "G"
    if guess.last == "Y"
      possible_letters << guess.first
    else
      @letters_weights[index].each{ |letter, count| possible_letters << letter if count > 0 }
    end
  end
  return possible_letters.uniq
end

def calculate_letters_weight
  @letters_weights = [{}, {}, {}, {}, {}]
  POSSIBLE_LETTERS.each do |letter|
    (0..4).each{|pos| @letters_weights[pos][letter] = 0 }
  end
  @possible_words.each do |word|
    letters = word.chars
    (0..4).each{ |pos| @letters_weights[pos][letters[pos]] += 1 }
  end
end

def calculate_words_score(possible_words)
  words_score = []
  possible_words.each do |word|
    score = 0
    word.chars.each_with_index{ |letter, index| score += @letters_weights[index][letter] }
    words_score << { word: word, score: score }
  end
  words_score.sort_by!{ |x| -x[:score]}
  return words_score
end

def update_state(status_array)
  last_guess = status_array.last
  last_guess.each_with_index do |answer, index|
    ans = answer.last
    letter = answer.first
    if ans == "R"
      @possible_words.reject!{ |word| word.include?(letter) }
    elsif ans == "G"
      @possible_words.reject!{ |word| word[index] != letter }
    elsif ans == "Y"
      @possible_words.reject!{ |word| word[index] == letter }
      @possible_words.select!{ |word| word.include?(letter) }
    end
  end
  calculate_letters_weight
  @words_score = calculate_words_score(@possible_words)
end
