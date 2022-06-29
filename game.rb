require_relative "player"

class Game
    attr_reader :players, :losses, :dictionary, :letters_count, :words

    def initialize
        @words = File.readlines("dictionary.txt").map(&:chomp)
        number = number_of_players_prompt
        players = names_of_players_prompt(number)
        @players = players
        @losses = set_loss_count(players)
        @letters_count = choose_number_of_letters
        assign_player_guesses(letters_count)
        @secret_word = ""

    end

    def run
        welcome_message
        assign_secret_word(letters_count)


    end

    def assign_secret_word(count)
        eligible_words = words.select {|word| word.length == count}
        @secret_word = eligible_words.sample
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

    def set_loss_count(players)
        losses = Hash.new
        players.each do |player|
            losses[player] = 0
        end
        losses
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