def solve_the_wordle(status_array: [])
  if status_array.empty?
    @word_space = []
    @word_space.replace(WORDS_DICT)
  else
    filter_reds(status_array)
    filter_greens(status_array)
    filter_yellows(status_array)
  end

  histogram = generate_histogram
  weighted_words = generate_weights(histogram)

  guess = weighted_words.max_by{|k,v| v}.first
  @word_space.delete(guess)
  return guess
end

def generate_histogram
  histogram = Hash.new{|h,k| h[k]=0}
  @word_space.each do |word|
    word.each_char{|c| histogram[c] += 1}
  end

  word_count = @word_space.count
  return histogram.map{|k,v| [k, Float(v)/word_count]}.to_h
end

def generate_weights(histogram)
  weighted_words = {}
  @word_space.each do |word|
    weighted_words[word] = word.split("").uniq.sum{|c| histogram[c]}
  end
  return weighted_words
end

def filter_reds(status_array)
  red_letters = status_array.last.select{|letter_hit| letter_hit.last == RED}.map(&:first)
  @word_space.reject!{|w| red_letters.any?{|l| w.include? l}}
end

def filter_greens(status_array)
  status_array.last.each_with_index do |letter_hit, i|
    next if letter_hit.last != GREEN
    @word_space.reject!{|w| w[i] != letter_hit.first}
  end
end

def filter_yellows(status_array)
  status_array.last.each_with_index do |letter_hit, i|
    next if letter_hit.last != YELLOW
    @word_space.reject!{|w| w[i] == letter_hit.first || !w.include?(letter_hit.first)}
  end
end