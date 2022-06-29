require 'player'

class Game
    def initialize
        words = File.readlines("dictionary.txt").map(&:chomp)
        number = number_of_players_prompt
        names_of_players_prompt(number)
    end

    def number_of_players_prompt
        puts "Select the number of players:"
        begin
            players_selected = gets.chomp.to_i
            raise "Number of players must be greater than 1" if players_selected <= 1
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

Game.new