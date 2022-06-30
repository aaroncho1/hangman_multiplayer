require_relative "player"

class Game
    attr_reader :players, :dictionary, :letters_count, :words
    attr_accessor :word_revealed, :current_player, :word_fragment

    def initialize
        @words = File.readlines("dictionary.txt").map(&:chomp)
        number = number_of_players_prompt
        players = names_of_players_prompt(number)
        @players = players
        @letters_count = choose_number_of_letters
        assign_player_guesses(letters_count)
        @secret_word = ""
        @word_revealed = false
        @current_player = players.first
        @word_fragment = "_" * letters_count
    end

    def run
        welcome_message
        assign_secret_word(letters_count)
        until game_over?
            guess_word?
            letter = take_turn unless guess_word?
            check_letter(letter)



        end

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
        
    def check_letter(letter)
        if @secret_word.include?(letter)
            puts "#{letter} is in the word!"
            update_word_fragment(letter)



    def guess_word_player_prompt
        system("clear")
        puts "#{current_player.name}, guess word? (y/n):"
        answer = gets.chomp.downcase
        answer
    end

    def guess_word?
        begin
            choice = guess_word_player_prompt
            raise "invalid answer, try again" if ["y","n"].include?(choice)
        rescue => e  
            puts e.message
            sleep 1.5
            retry
        end
        return false if choice == "n"
        guessed_word = gets.chomp.downcase
        if guessed_word == @secret_word
            update_correct_guess
        else
            update_incorrect_guess
        end
        guessed_word
    end

    def update_correct_guess
        puts "Word guessed correctly!"
        word_revealed = true
    end

    def update_incorrect_guess
        puts "Word guessed incorrectly"
        current_player.remaining_guesses -= 1
    end

    def take_turn
        system("clear")
        puts "#{current_player.name}, choose a letter:"
        letter = gets.chomp.downcase
        letter
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
            player.remaining_guesses = count
        end
    end


    def choose_number_of_letters
        system("clear")
        puts "Choose the number of letters for the secret word:"
        number_of_letters = gets.chomp.to_i
        number_of_letters
    end


    def welcome_message
        system("clear")
        puts "Welcome to Hangman! The rules are simple, the number of guesses each player gets is equal to the number of letters of the secret word. Good luck!"
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

end

Game.new.run