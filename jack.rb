# User
class User
  attr_reader :name, :cards

  def initialize(name, balance = 100)
    @name = name
    @balance = balance
    @cards = []
  end

  def <<(obj)
    @cards.push(obj)
    @cards.flatten!
  end

  def reset
    @cards = []
  end

  def bet(val)
    @balance -= val
  end

  def refund(val)
    @balance += val
  end

  def points
    sum = 0
    @cards.each do |c|
      if sum <= 21
        sum += c.value
      elsif c.value == 11
        sum += 1
      end
    end
    sum
  end

  def show_balance
    puts "#{name}, balance: #{@balance}"
  end

  def show_cards
    print "  #{name} cards: ["
    @cards.each { |c| print "#{c.rank}#{c.suit} " }
    puts "] points: #{points}"
  end

  def enough_balance?
    if @balance.zero?
      puts "#{name} not enough balance"
      false
    else
      true
    end
  end
end

# Player
class Player < User
  def move?
    print 'Want to [s]kip move, [a]dd a cart, or any key to open cards? '
    case gets.chomp
    when /s/
      :skip
    when /a/
      :add
    else
      :open
    end
  end
end

# Dealer
class Dealer < User
  def show_cards(hide = true)
    if hide
      puts "  #{name} cards: [****]"
    else
      super()
    end
  end
end

# BlackJack game
class Game
  BLACKJACK = 21
  BET = 10
  DECK_SIZE = 1
  def initialize(deck_size = 1)
    @deck = Deck.new(deck_size)
    print 'Input your name: '
    @player = Player.new(gets.chomp.capitalize!)
    @dealer = Dealer.new('Dealer')
    @players = [@player, @dealer]
  end

  def start
    loop do
      round1
      round2
      open_and_check

      break unless @player.enough_balance? && @dealer.enough_balance?
      break unless @deck.enough_cards?

      print 'Wanna play again ([q] - to quit) ? '
      break if /q/ =~ gets.chomp
    end
  end

  private

  def round1
    puts '*' * 15
    @players.each do |player|
      player.reset
      player << @deck.deal(2)
      player.show_cards
      player.bet(BET)
    end
  end

  def round2
    loop do
      case @player.move?
      when :add
        @player << @deck.deal(1) if @player.cards.size == 2
        @dealer << @deck.deal(1) if @dealer.points < 17
      when :skip
        @dealer << @deck.deal(1) if @dealer.points < 17
      when :open
        break
      end
      break if @player.cards.size == 3 || @dealer.cards.size == 3
    end
  end

  def check_winner?
    if @player.points.between?(@dealer.points + 1, BLACKJACK)
      @player
    elsif @dealer.points.between?(@player.points + 1, BLACKJACK)
      @dealer
    elsif @player.points > BLACKJACK && @dealer.points <= BLACKJACK
      @dealer
    elsif @dealer.points > BLACKJACK && @player.points <= BLACKJACK
      @player
    elsif @dealer.points > BLACKJACK && @player.points > BLACKJACK
      nil
    elsif @dealer.points == @player.points
      nil
    else
      raise 'Invalid check'
    end
  end

  def open_and_check
    @player.show_cards
    @dealer.show_cards(false)
    winner = check_winner?
    if winner
      winner.refund(2 * BET)
      puts "The winner is #{winner.name}"
    else
      @players.each { |p| p.refund(BET) }
      puts 'Fair'
    end

    @players.each(&:show_balance)
  end
end

# Card class for a card with a suit, a rank, a value
class Card
  attr_reader :suit, :rank, :value

  def initialize(suit, rank, value)
    @suit = suit
    @rank = rank
    @value = value
  end
end

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

game = Game.new(8)
game.start
