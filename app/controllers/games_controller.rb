class GamesController < ApplicationController
  require 'open-uri'
  def generate_grid(grid_size)
    grid = Array.new(grid_size)
    characters = ('a'..'z').to_a.shuffle
    grid.map! do
      characters.sample
    end
    grid
  end

  def attempt_grid_compare(attempt, grid)
    # checks that attempt does not include too many instances of the same letter
    attempt.downcase!
    grid.map! { |i| i.downcase }

    no_duplicates = attempt.chars.all? do |i|
      attempt.count(i) <= grid.count(i)
    end
    # compare the attempt to grid
    attempt.chars.all?(/[#{grid}]/i) if no_duplicates
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    result = {}
    # :score = 0

    # submit the answer to the API, receive a hash
    url = "https://wagon-dictionary.herokuapp.com/#{attempt.downcase}"
    word_check = URI.open(url).read
    word_check_result = JSON.parse(word_check)

    # count time
    time = end_time - start_time
    result[:time] = time

    # check the letters
    if word_check_result["found"] && attempt_grid_compare(attempt, grid)
      result[:score] = (word_check_result["length"] * 2) - (time * 0.1)
      result[:message] = "Well done, the word #{attempt} is wonderful!"
    else
      result[:score] = 0
      if !attempt_grid_compare(attempt, grid)
        result[:message] = "not in the grid"
      elsif !word_check_result["found"]
        result[:message] = "not an english word"
      else
        result[:message] = "No points because no points!"
      end
    end
    result
  end

  def new
    @letters = generate_grid(10)
    # raise
    # display a new random grid and a form
  end

  def score
    word = params['word']
    @letters = params[:letters].delete(' ').chars
    result = run_game(word, @letters, 0, 1)
    @result1 = "The word is: #{word}"
    @result2 = result[:message].to_s
  end
end
