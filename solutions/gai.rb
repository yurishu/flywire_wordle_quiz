puts "Gai file loaded"

def solve_the_wordle(status_array: [])
    #most vowels
    return WORDS_DICT.sample if status_array.empty?

    stat_last = status_array[status_array.count - 1]

    prob_guess = WORDS_DICT.find do |check_word|
        mask_in_place = ""
        if includes_exclusions(check_word, status_array)
            false
        else
            missing_result = missing_in_place(check_word, stat_last)
            if missing_result[0]
                false
            else
                mask_in_place = missing_result[1]
                in_place_list = missing_result[2]
                check_chars = mask_in_place_string(check_word, mask_in_place)

                !missing_not_in_place(check_chars, stat_last, in_place_list)
            end
        end
    end

    #remainder of vowels
    return 'adieu' if prob_guess.nil? and (status_array.count == 1)
    return '-----' if prob_guess.nil?

    prob_guess
end

def includes_exclusions(check_word, status_array)
    all_exclusions = []
    status_array.each do |results|
        results.each do |letter|
            if letter[1] == RED
                all_exclusions += [letter[0]]
            end
        end
    end

    all_exclusions.uniq!

    includes_exclusion = all_exclusions.any? { |letter| check_word.include?(letter) }

    return includes_exclusion
end

def missing_in_place(check_word, status_array)
    reg_mask = reg_ex_matcher(check_word, status_array)

    return [false, reg_mask[1], []] if reg_mask[2].zero?

    not_in_place = check_word.match(reg_mask[0]).nil?

    return [not_in_place, reg_mask[1], reg_mask[3]]
end

def reg_ex_matcher(guess, last_summary)
    reg_res = ''
    mask = ''
    in_place_count = 0
    in_place_list = []
    guess.chars.each_with_index do |letter, index|
        if last_summary[index][1] == GREEN
            reg_res.concat(last_summary[index][0])
            mask.concat('?')
            in_place_count += 1
            in_place_list += [letter]
        else
            reg_res.concat('.')
            mask.concat('.')
        end
    end

    return [reg_res, mask, in_place_count, in_place_list]
end

def missing_not_in_place(check_chars, stat_last, in_place_list)
    return false if check_chars.empty?

    out_of_place = []
    stat_last.each do |letter|
        if letter[1] == YELLOW
            out_of_place += [letter[0]]
        end
    end

    out_of_place = out_of_place.uniq - in_place_list

    return false if out_of_place.count.zero?

    not_in_place = !out_of_place.all? { |letter| check_chars.include?(letter) }
    return not_in_place
end

def mask_in_place_string(check_word, mask)
    masked_result = []
    mask.chars.each_with_index do |letter, index|
        masked_result += [check_word[index]] if letter == "."
    end
    masked_result.uniq!
    masked_result
end
