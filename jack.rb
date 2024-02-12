require_relative 'deck'
require_relative 'card'
require_relative 'player'

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

game = Game.new(8)
game.start
