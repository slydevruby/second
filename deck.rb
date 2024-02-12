require_relative 'card'

# Deck class, creates the desk and shuffles it
class Deck
  SUITS = %w[♥ ♣ ♦ ♠].freeze
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11].freeze
  def initialize(deck_size)
    @cards = []
    SUITS.cycle(deck_size) do |s|
      RANKS.each.with_index do |r, i|
        @cards << Card.new(s, r, VALUES[i])
      end
    end
    @cards.shuffle!
  end

  def deal(count)
    @cards.pop(count)
  end

  def enough_cards?
    if @cards.size.positive?
      true
    else
      puts 'No card left, quit the game'
      false
    end
  end
end
