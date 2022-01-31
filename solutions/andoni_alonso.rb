puts "Andoni file loaded"

def solve_the_wordle(status_array: [])
    puts "-- Status: #{status_array}"
    return 'arise' if status_array.empty?

    attempt = 0
    words_used = []
    regex_used = []
    red_letters = []
    status_array.each do |n|
      words_used << n.each.map {|e| e[0]}.join
      regex = n.map do |n|
        if n[1]=="G"
          n[0]
        elsif n[1]=="Y"
          "[^#{n[0]}]+"
        else
          red_letters << n[0]
          '.+'
        end
      end
      regex_used << regex.join
    end
    puts "-- Words used: #{words_used}"
    puts "-- Regex used: #{regex_used}"
    puts "-- Red letters: #{red_letters}"
    green_words = WORDS_DICT - words_used
    puts "00 Green words: #{green_words.count}"

    regex_used.each {|regex| green_words = green_words.uniq.grep(/#{regex}/)}
    puts "-- Green words: #{green_words}"
    puts "-- Green words count: #{green_words.count}"

    red_letters.uniq.each {|red_letter| green_words = green_words.grep_v(Regexp.new(/#{red_letter}/i))}
    puts "+- Green words: #{green_words}"
    puts "+- Green words count: #{green_words.count}"

    okey_letters = status_array[attempt].map{ |n| n[0] if not n[1]=="R"}.compact
    puts "-- Okay letters: #{okey_letters}"
    okey_letters.each {|letter| green_words = green_words.grep(Regexp.new(/#{letter}/i))}
    puts "== Green words: #{green_words}"
    puts "== Green words count: #{green_words.count}"

    o_candidates = green_words.grep(Regexp.new(/o/i))
    l_candidates = green_words.grep(Regexp.new(/l/i))
    t_candidates = green_words.grep(Regexp.new(/t/i))
    n_candidates = green_words.grep(Regexp.new(/n/i))
    h_candidates = green_words.grep(Regexp.new(/h/i))
    c_candidates = green_words.grep(Regexp.new(/c/i))
    best_candidates_group = [t_candidates,l_candidates,o_candidates,h_candidates,n_candidates,c_candidates]
    best_candidates_group = best_candidates_group.reject { |i| i.empty? }
    best_candidates = []
    while best_candidates.empty? and not best_candidates_group.empty? do
      best_candidates = best_candidates_group.inject(:&)
      puts "_-_-_ Bests #{best_candidates_group.size}: #{best_candidates}" if not best_candidates.empty?
      best_candidates_group.pop
    end

    if not best_candidates.empty?
      puts "++ Green words: #{best_candidates}"
      puts "++ Green words count: #{best_candidates.count}"
      word = best_candidates[0]
    else
      word = green_words[0]
    end

    puts "++ Word: #{word}"
    attempt+=1
    return word
end