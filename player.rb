class Player
    attr_reader :name
    attr_accessor :remaining_guesses

    def initialize(name)
        @name = name
        @remaining_guesses = nil
    end

end