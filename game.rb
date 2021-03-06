require_relative "player"

class Game
    GUESSED_WORDS = []
    GUESSED_LETTERS = []
    attr_reader :players, :dictionary, :letters_count, :words
    attr_accessor :word_revealed, :current_player, :word_fragment, :word_guessed

    def initialize
        @words = File.readlines("dictionary.txt").map(&:chomp)
        welcome_message
        number = number_of_players_prompt
        players = names_of_players_prompt(number)
        @players = players
        @letters_count = choose_number_of_letters
        assign_player_guesses(letters_count)
        @secret_word = ""
        @word_revealed = false
        @current_player = nil
        @word_fragment = "_" * letters_count
        @word_guessed = false
    end

    def assign_current_player
        @current_player = players.first
    end

    def word_guessed?
        word_guessed
    end

    def take_turn
        guess_word?
        unless word_guessed?
            letter = guess_letter 
            check_letter(letter)
        end
    end

    def run
        assign_secret_word(letters_count)
        assign_current_player
        display_turn
        until game_over?
            take_turn
            switch_players unless game_over?
        end
        winner = choose_winner
        winner_message(winner)
        reveal_word
    end

    def choose_winner
        if word_revealed?
            winner = current_player
        elsif remaining_players == 1
            winner = (players.select {|player| player.remaining_guesses > 0}).shift
        else
            winner = nil
        end
    end

    def winner_message(winner)
        if winner == nil
            puts "Nobody wins"
        else
            puts "#{winner.name} wins!"
        end
        sleep 1.5
    end

    def switch_players
        until players[0].remaining_guesses > 0 && players[0] != current_player
            players.rotate!
        end
        assign_current_player
        display_turn
        @word_guessed = false
    end

    def display_turn
        system("clear")
        puts "#{current_player.name}'s turn"
        sleep 1.5
        system("clear")
    end

    def check_word_revealed?
        @word_revealed = true if !word_fragment.include?("_")
        false
    end

    def update_word_fragment(letter)
        indices = []
        @secret_word.each_char.with_index do |char, i|
            if char == letter
                indices << i 
            end
        end
        indices.each do |ind|
            word_fragment[ind] = letter
        end
    end 

    def update_incorrect_letter_guess(letter)
        puts "#{letter} is not in the word"
        sleep 1.5
        current_player.remaining_guesses -= 1
        GUESSED_LETTERS << letter
    end
        
    def check_letter(letter)
        if @secret_word.include?(letter)
            puts "#{letter} is in the word!"
            sleep 1.5
            update_word_fragment(letter)
            check_word_revealed?
            guess_word?
        else
            update_incorrect_letter_guess(letter)
        end
    end

    def guess_word_player_prompt
        system("clear")
        display
        puts "#{current_player.name}, guess word? (y/n):"
        answer = gets.chomp.downcase
        answer
    end

    def guess_word?
        display
        begin
            choice = guess_word_player_prompt
            raise "invalid answer, try again" if !["y","n"].include?(choice)
        rescue => e  
            puts e.message
            sleep 1.5
            retry
        end
        if choice == "n"
            @word_guessed = false
        else
            begin
                puts "#{current_player.name}, enter the word you are guessing:"
                guessed_word = gets.chomp.downcase
                raise "Word has been guessed already. Try again" if GUESSED_WORDS.include?(guessed_word)
            rescue => e    
                puts e.message
                retry
            end

            if guessed_word == @secret_word
                update_correct_word_guess
            else
                update_incorrect_word_guess(guessed_word)
            end
            @word_guessed = true
        end
    end

    def update_correct_word_guess
        puts "Word guessed correctly!"
        sleep 1.5
        @word_revealed = true
    end

    def update_incorrect_word_guess(word)
        puts "Word guessed incorrectly"
        sleep 1.5
        current_player.remaining_guesses -= 1
        GUESSED_WORDS << word
    end

    def guess_letter
        system("clear")
        display
        begin
            puts "#{current_player.name}, choose a letter:"
            letter = gets.chomp.downcase
            letter_rules(letter)
        rescue => e    
            puts e.message
            retry
        end
        letter
    end

    def letter_rules(letter)
        alpha = ("a".."z").to_a
        raise "Letter has been guessed already. Try again" if GUESSED_LETTERS.include?(letter)
        raise "Letter must be one character. Try again" if letter.length != 1
        raise "Letter must be a valid letter. Try again" if !alpha.include?(letter)
        raise "Letter is already in the word. Try again" if word_fragment.include?(letter)
    end

    def word_revealed?
        word_revealed
    end

    def game_over?
        remaining_players == 1 || word_revealed?
    end

    def remaining_players
        players.count {|player| player.remaining_guesses > 0}
    end

    def assign_secret_word(count)
        eligible_words = words.select {|word| word.length == count}
        @secret_word = eligible_words.sample.downcase
    end

    def assign_player_guesses(count)
        players.each do |player|
            player.remaining_guesses = count <= 5 ?  count : 6
        end
    end

    def choose_number_of_letters
        system("clear")
        begin
            puts "Choose the number of letters for the secret word:"
            number_of_letters = gets.chomp.to_i
            raise "Number of letters must be greater than 2" if number_of_letters <= 2
            raise "Number of letters cannot be greater than 20" if number_of_letters > 20
        rescue => e    
            puts e.message
            retry
        end
        number_of_letters
    end

    def welcome_message
        system("clear")
        puts "Welcome to Hangman! The rules are simple, the number of guesses each player gets is equal to the number of letters of the secret word if the number of letters is less than 6. Each player gets 6 guesses for words with 6 or more letters. The word length must be at least 3 and not greater than 20. Good luck!"
        puts ""
        puts "Press any key to continue:"
        press_key_to_continue
    end

    def press_key_to_continue
        key = gets.chomp
        system("clear")
    end

    def number_of_players_prompt
        begin
            puts "Select the number of players:"
            players_selected = gets.chomp.to_i
            raise "Number of players must be greater than 1. Try again" if players_selected <= 1
        rescue => e   
            puts e.message
            retry
        end
        players_selected
    end

    def names_of_players_prompt(number)
        players = Array.new(number)
        players.each_with_index do |player, i|
            puts "Player #{i + 1}, enter your name:"
            name = gets.chomp
            players[i] = Player.new(name)
        end
        players
    end

    def display
        render_word_fragment
        render_player_guesses
        render_guessed_letters
        render_guessed_words
    end

    def render_guessed_letters
        letters_string = GUESSED_LETTERS.join(", ")
        puts "Guessed letters: #{letters_string}"
        puts ""
    end

    def render_guessed_words
        words_string = GUESSED_WORDS.join(", ")
        puts "Guessed words: #{words_string}"
        puts ""
    end

    def render_word_fragment
        puts "Guess the word: #{word_fragment}"
        puts ""
    end

    def render_player_guesses
        puts "Player remaining guesses"
        players.each do |player|
            puts "#{player.name}: #{player.remaining_guesses}"
        end
        puts ""
    end

    private
    def reveal_word
        puts ""
        puts "The secret word is #{@secret_word}!"
    end
end

Game.new.run