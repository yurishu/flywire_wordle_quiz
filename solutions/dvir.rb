puts "Dvir file loaded"


def solve_the_wordle(status_array:)
  if status_array.empty?
    # letters = Hash.new(0)

    # WORDS_DICT.each do |word|
    #   common_letters = word.gsub(/[^a-z]/,'').each_char.with_object(Hash.new(0)) { |c,h| h[c] += 1 }
    #   common_letters.each do |letter, common|
    #     letters[letter] += common
    #   end
    # end
    #
    # word = ''
    # (1..5).each do
    #   max_key = letters.max_by{|k,v| v}.first
    #   letters.delete(max_key)
    #   word += max_key
    # end
    # first_word ||= WORDS_DICT.select { |s| word.chars.all? { |char| s.include?(char) } }.sample


    first_word ||= WORDS_DICT.select { |s| "slate".chars.all? { |char| s.include?(char) } }.sample
    first_word ||= WORDS_DICT.select { |s| "aei".chars.all? { |char| s.include?(char) } }.sample
    first_word ||= WORDS_DICT.sample
    return first_word
  else
    green_array = Array.new(5)
    yellow_hash = {}
    red_letters = ""
    used_words  = []
    status_array.each do |previous_result|
      used_words.push previous_result.map(&:first).join('')
      previous_result.each_with_index do |prev, index|
        case prev.last
          when GREEN
            green_array[index] = prev.first
          when YELLOW
            yellow_hash[prev.first] ||= []
            yellow_hash[prev.first].push(index) unless yellow_hash[prev.first].include?(index)
          when RED
            red_letters += prev.first
          else
            raise "wtf?"
        end
      end
    end

    next_regex = ''
    green_array.each { |letter| letter.nil? ? next_regex += '.' : next_regex += letter }

    # if next_regex == '.....'
    #   available_words = WORDS_DICT.select { |s| "rs".chars.all? { |char| s.include?(char) } }
    # else
    available_words = WORDS_DICT.select { |s| s.match?(next_regex) }
    # end

    available_words.select! { |s| !red_letters.chars.any? { |char| s.include?(char) } }
    available_words.select! { |c| !used_words.include?(c) }


    puts "dvirrrr is 0" if yellow_hash.keys.count == 0 && next_regex == '.....'

    green_array.each { |key| yellow_hash.delete(key) }
    available_words.select! { |s| s.count(yellow_hash.keys.join('')) >= yellow_hash.keys.count } if yellow_hash.keys.count > 0

    # puts yellow_array
    yellow_hash.each do |char, indexes|
      indexes.each do |index|
        available_words.select! { |s| !(s.index(char) == index) }
      end
    end


    # puts "used_words #{used_words}"
    # puts "available_words #{available_words}"
    # puts "next_regex #{next_regex}"
    # puts "green: #{green_array}"
    # puts "yellow #{yellow_array}"
    # puts "red #{red_letters}"

    return available_words.sample
  end

end
