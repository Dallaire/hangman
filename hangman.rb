require 'yaml'

class Game
  attr_accessor :random_word, :game_over, :guess, :guesses_left, :display

  def initialize
    @game_over = false
    @guesses_left = 5
    @display = []
    @incorrect = []
    random_word
    create_display
    show_display
    run
  end

  def random_word
    words = []
    File.open("5desk.txt") do |file|
      lines=file.readlines()
      lines.map do |string|
        word=string.strip
        words << word if (word.length > 4 && word.length <13)
      end
    end
    @random_word = words[Random.rand(0...words.length)].split("")
  end

  def create_display
    @random_word.map do |lt|
      lt = "_"
      @display << lt
    end
  end

  def show_display
    puts @display.join
    puts "Incorrect letters: #{@incorrect.join(",")}"
    puts "Guesses left: #{@guesses_left}"
  end

  def check_if_over
    again = !nil
    if @display == @random_word
      @game_over = true
      puts "You guessed #{@random_word.join} and won!"
      again = nil
    elsif @guesses_left == 0
      @game_over = true
      puts "You made to many incorrect guesses and lost!"
      puts "The word was #{@random_word.join}"
      again = nil
    end

    while again == nil
      puts "Play again? (Y/N)"
      again = gets.chomp.upcase
      case again
      when "Y"
        Game.new
      when "N"
        puts "Goodbye!"
      else
        puts "Invalid answer"
        again = nil
      end
    end
  end

  def guess
    @guess=nil
    while @guess==nil
      puts ""
      puts "Guess a letter please"
      input=gets.chomp.downcase
      if ("a".."z").include?(input) && !@incorrect.include?(input)
        @guess=input
      else
        puts "That was not a valid guess"
      end
    end
    puts "The guess is #{@guess}"

    if @random_word.include?(@guess)
      @random_word.each_with_index do |lt, i|
        @display[i] = lt if lt == @guess
      end
    else
      @incorrect << @guess
      @guesses_left -= 1
    end
  end

  def save
    save = nil
    while save == nil
      puts "Save the game? (Y/N)"
      save = gets.chomp.upcase
      case save
      when "Y"
        File.open("saved_game.yaml", "w").write(Psych.dump(self))
        puts "Game saved!"
      when "N"
        break
      else
        save = nil
        puts "Indvalid answer"
      end
    end
  end

  def run
    while !@game_over
      save
      guess
      show_display
      check_if_over
    end
  end

  puts "Hangman: Now without hanging!"
  save=nil
  while save == nil
    puts "Load a saved game? (Y/N)"
    input = gets.chomp.upcase
    case input
    when "Y"
      puts "loading..."
      begin           #handles no saved game case
        save = Psych.load(File.open("saved_game.yaml"))
        save.show_display
        save.run
      rescue
        puts "No saved game! Starting a new game"
        Game.new
      end
    when "N"
      save = !nil
      puts "New game"
      Game.new
    else
      puts "Invalid answer"
    end
  end

end
