ATTEMPTED_WORDS = []
GREEN_LETTERS = {}
YELLOW_LETTERS = {}
RED_LETTERS = []

def solve_the_wordle(status_array)
    first_word = ""
    status_array = status_array[:status_array]

    if status_array.flatten.empty?
        while first_word.chars.uniq.length != 5
            first_word = WORDS_DICT.sample
        end
        ATTEMPTED_WORDS << first_word
        return first_word
    end

    last_attempt = status_array.last
    populate_arrays_of_letters(last_attempt)
    word = get_next_word_attempt

    return word
end

def populate_arrays_of_letters(last_attempt)
    last_attempt.each_with_index do |result, index|
        letter = result[0]
        color_hint = result[1]

        case color_hint
        when GREEN
            GREEN_LETTERS[index] = letter
        when RED
            RED_LETTERS << letter
        when YELLOW
            yellow_letters = []
            yellow_letters << letter
            YELLOW_LETTERS[index] = yellow_letters
        end
    end
end

def get_next_word_attempt
    word_to_guess = '*****'
    most_likely_words = []

    potential_words = filter_by_green_letters(word_to_guess)
    return potential_words.first if potential_words.length == 1

    potential_words = potential_words.empty? ? WORDS_DICT.dup : potential_words
    filter_by_red_letters(potential_words)
    return potential_words.first if potential_words.length == 1

    most_likely_words = filter_by_yellow_letters(potential_words, word_to_guess, most_likely_words)
    potential_words = potential_words - ATTEMPTED_WORDS
    most_likely_words.each do |word|
        if potential_words.include?(word)
            ATTEMPTED_WORDS << word
            return word
        end
    end

    word_attempt = potential_words.select{ |word| word.chars.uniq.length == 5  }.first if potential_words.length > 1
    word_attempt ||= potential_words.first
    ATTEMPTED_WORDS << word_attempt
    return word_attempt
end

def filter_by_green_letters(word_to_guess)
    potential_words = []

    unless GREEN_LETTERS.empty?
        word_to_guess.each_char.with_index do |_char, index|
            unless GREEN_LETTERS[index].nil?
                word_to_guess[index] = GREEN_LETTERS[index]
            end
        end
        word_to_guess = word_to_guess.gsub("*", "\.")
        potential_words = WORDS_DICT.dup.select{ |word| word.match(/#{word_to_guess}/) }
    end

    return potential_words.uniq
end

def filter_by_yellow_letters(potential_words, word_to_guess, most_likely_words)
    unless YELLOW_LETTERS.empty?
        YELLOW_LETTERS.each do |index, letters|
            potential_words.reject!{ |word| letters.include?(word[index]) }
        end
        most_likely_words = get_most_likely_words(word_to_guess, most_likely_words, potential_words)
    end
    return most_likely_words
end

def filter_by_red_letters(potential_words)
    unless RED_LETTERS.empty?
        RED_LETTERS.each do |letter|
            potential_words.reject!{ |word| word.include?(letter) }
        end
    end
end

def get_most_likely_words(word_to_guess, most_likely_words, potential_words)
    word_to_guess_dup = word_to_guess.dup

    if word_to_guess_dup.split("").select{ |char| char == "*"}.count < 3
        word_to_guess_dup.each_char.with_index do |char, index|
            if char == '*'
                filtered_yellow_letters = YELLOW_LETTERS.select{ |key, _v| key != index }.values.flatten.uniq
                break if filtered_yellow_letters.empty?
                filtered_yellow_letters.each do |letter|
                    word_to_guess_dup[index] = letter
                    word_to_guess_dup = word_to_guess_dup.gsub("*", "\.")
                    most_likely_words << potential_words.select{ |word| word.match(/#{word_to_guess_dup}/) }
                    word_to_guess_dup = word_to_guess.dup
                end
            end
        end
    end
    return most_likely_words.flatten
end
