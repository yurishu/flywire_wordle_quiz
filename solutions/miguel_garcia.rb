puts 'Miguel Garcia file loaded'

module MGarcia
  LOG_ENABLED = false

  class << self
    attr_accessor :guesser
  end
  self.guesser = nil

  def log(msg)
    puts "[MGarcia] #{msg}" if MGarcia::LOG_ENABLED
  end

  class GuessFeedback
    attr_reader :guess_feedback

    def initialize(guess_feedback)
      @guess_feedback = guess_feedback
      @valid_letters_regexp = valid_letters_regexp
      @needed_letter_regexps = needed_letter_regexps
      @bad_positions_letter_regexp = bad_positions_letter_regexp
    end

    def guess_attemtp_valid?(guess_attempt)
      # First we check the valid letters in our guess attempt
      return false unless @valid_letters_regexp.match(guess_attempt)

      # Secondly, we check we have al least the letters that are in bad positions, but required
      @needed_letter_regexps.each do |needed_letter_regexp|
        return false unless needed_letter_regexp.match(guess_attempt)
      end

      # Next, we ensure we don't have any letter in a known bad position
      return false if @bad_positions_letter_regexp.match(guess_attempt)

      # Finally we discard the guess attempt if it contains any forbidden letter (R's)
      forbidden_letters_regexps.each { |forbidden_regexp| return false if forbidden_regexp.match(guess_attempt) }

      true
    end

    private

    def valid_letters_regexp
      raw_regex = ''

      @guess_feedback.each do |letter_feedback|
        raw_regex += letter_feedback[1] == 'G' ? letter_feedback[0] : '\w{1}'
      end

      Regexp.new(raw_regex)
    end

    def needed_letter_regexps
      regexps = []

      @guess_feedback.each do |letter_feedback|
        regexps << Regexp.new(".*#{letter_feedback[0]}.*") if letter_feedback[1] == 'Y'
      end

      regexps
    end

    def bad_positions_letter_regexp
      # In case the letter feedback doesn't contain any yellow, we return an special regexp
      # than will not match never, no matter the candidate
      return Regexp.new('FFFFFF$£££') if @guess_feedback.select { |letter_feedback| letter_feedback[1] == 'Y' }.empty?

      # If not we build a regex that contains the letters in the wrong positions
      # That will exclude all the candidates with letter in a position we know is wrong
      raw_regex = ''
      @guess_feedback.each do |letter_feedback|
        raw_regex += letter_feedback[1] == 'Y' ? letter_feedback[0] : '\w{1}'
      end

      Regexp.new(raw_regex)
    end

    def forbidden_letters_regexps
      # Return a collection of regexps that we should not match with the candidates: One for forbidden received letter (R)
      regexps = []

      @guess_feedback.each do |letter_feedback|
        regexps << Regexp.new(".*#{letter_feedback[0]}.*") if letter_feedback[1] == 'R'
      end

      regexps
    end
  end

  class FullDictionaryGuesser
    def initialize(last_try, prev_tries, words_dict)
      @prev_tries = prev_tries
      @last_try = MGarcia::GuessFeedback.new(last_try)
      @words_dict = words_dict

      @index = 0
      @candidates = []
      @next_guess_index = 0
    end

    def next_guess
      filter_dictionary

      if @candidates.empty?
        MGarcia.log('WARNING no candidates found after the dictionary indexing attempt!!!')
        @index = 0
        @candidates.clear
        return nil
      end

      guess = @candidates[@next_guess_index]
      @next_guess_index += 1

      guess
    end

    def next_guesser(last_try, prev_tries)
      # If we were interrupted before finishing the dictionary indexation, we must continue
      return self unless filtering_finished?

      if @candidates.empty?
        MGarcia.log('Warning: The candidates set is empty, starting from scratch')
        return FullDictionaryGuesser.new(last_try, prev_tries, @words_dict)
      end

      # If the last feedback is distinct from the previous one, we should re-index based
      # in the most recent feedback in order to discard non valid entries
      if last_try != @last_try.guess_feedback
        MGarcia.log("Creating new guesser from last feedback: #{last_try}")
        return MGarcia::FullDictionaryGuesser.new(last_try, prev_tries, @candidates)
      end

      self
    end

    private

    def filter_dictionary
      return if filtering_finished?

      MGarcia.log("Start to indexing words dictionary at position #{@index}")

      while @index < @words_dict.size
        @candidates << @words_dict[@index] if @last_try.guess_attemtp_valid?(@words_dict[@index])

        # we do in that way to avoid to have to start from scratch in case of timeout
        @index += 1
      end

      MGarcia.log("Fully indexed words dict, found #{@candidates.size} candidates out of #{@words_dict.size} for '#{@last_try.guess_feedback}'")
    end

    def filtering_finished?
      @index >= @words_dict.size
    end
  end
end

def solve_the_wordle(status_array: [])
  include MGarcia

  return WORDS_DICT.sample if status_array.empty?

  last_try = status_array[-1]
  prev_tries = status_array.size > 1 ? status_array[0..status_array.size - 2] : []

  MGarcia.log("Received #{last_try}")

  MGarcia.guesser = if MGarcia.guesser.nil?
                      MGarcia::FullDictionaryGuesser.new(last_try, prev_tries, WORDS_DICT)
                    else
                      MGarcia.guesser.next_guesser(last_try, prev_tries)
                    end

  guess = MGarcia.guesser.next_guess

  guess.nil? ? WORDS_DICT.sample : guess
end
