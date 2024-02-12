# Card class for a card with a suit, a rank, a value
class Card
  attr_reader :suit, :rank, :value

  def initialize(suit, rank, value)
    @suit = suit
    @rank = rank
    @value = value
  end
end
