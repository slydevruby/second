#require 'minitest/autorun'

BlackJack = 21

class PlayingCard
  SUITS = %w(clubs diamonds hearts spades)
  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  #RANKS = %w(10 J Q K A)
  class Deck
    attr_reader :cards
    def initialize(n=1)
      @cards = []
      SUITS.cycle(n) do |s|
        RANKS.cycle(1) do |r|
          @cards << "#{r} of #{s}"
        end
      end
    end

    def pop_sample(total=1)
      temp = @cards.sample(total)
    end
  end
end

def value(card_name, ace_as_1 = false)
  line = card_name.split(" ")[0]
  if /[QJK]/ =~ line[0]
    10
  elsif /[A]/ =~ line[0]
    if ace_as_1 then 1 else 11 end
    else
      line.to_i
    end
  end

  def sum_cards(cards)
    sum = 0
    cards.each do |card|
      sum += value(card)
    end
    if sum > BlackJack 
      sum = 0
      cards.each do |card|
        sum += value(card, true)
      end
    end
    sum
  end

  class Game
    def initialize(bet: 5, max_credit: 200, credit: 100, deck_size: 8)
      @credit = credit
      @max_credit = max_credit
      @bet = bet
      @original_bet = bet
      @deck = PlayingCard::Deck.new(deck_size)
      @hdeck = {:player => [], :dealer => []}
      @val = {:player => 0, :dealer => 0}
    end

    def deal(whom, number)
      temp = @deck.pop_sample(number)
      temp.each { |e| @hdeck[whom].push(e) }
      @val[whom] = sum_cards(@hdeck[whom])
      temp
    end

    def show_cards
      if @hdeck[:player].size > @hdeck[:dealer].size
        base = @hdeck[:player].dup
      else
        base = @hdeck[:dealer].dup
      end

      base.each.with_index do |e, i| 
        puts "#{@hdeck[:player][i]}\t\t #{@hdeck[:dealer][i]}"
      end
      puts "*"*40
      puts "#{@val[:player]}\t\t\t #{@val[:dealer]}"
      puts "*"*40

    end

    def calculate (my_bet)
      show_cards
      @busted = {}
      @busted[:player] = @val[:player] > BlackJack
      @busted[:dealer] = @val[:dealer] > BlackJack
      old_credit = @credit

      if @busted[:player] and !@busted[:dealer]
        @credit -= my_bet
      elsif @busted[:dealer] and !@busted[:player]
        @credit += my_bet
      elsif @busted[:player] and @busted[:dealer]

      else


        if @val[:player].between?(@val[:dealer], BlackJack) #(@val[:player] <= BlackJack) && (@val[:player] > @val[:dealer])
          @credit += my_bet
        elsif @val[:dealer].between?(@val[:player], BlackJack) 
          @credit -= my_bet
        else 
          raise "Somthing wrong"
        end
      end
      puts "="*16
      if old_credit == @credit 
        puts "Fair, #{@credit}"
      elsif old_credit > @credit
        puts "Dealer won, #{@credit}"
      else
        puts "Player won, #{@credit}"
      end
      puts "="*16
    end


    def ask
      print "Credit is #{@credit}, bet #{@bet} [h]it, [s]tand, [d]ouble, [q]uit? "
      line = gets.chomp
      if /h/ =~ line
        :hit
      elsif /s/ =~ line
        :stand
      elsif /q/ =~ line
        :quit
      elsif /d/ =~ line
        :double
      end
    end 

    def take_if_blackjack
      answer = gets.chomp
      if /t/ =~ answer
        @credit += @bet
        true
      else
        false
      end
    end    

    def first_round_won?
      deal(:dealer, 1)  
      deal(:player, 2)
      if @val[:player] == BlackJack 
        show_cards
        puts "\t\t\tBlackjack! "  
        if @val[:dealer].between?(10,11)
          puts "Wanna [t]ake? or [c]ontinue"
          take_if_blackjack
        elsif @val[:dealer] < 10
          @credit += @bet * 3 / 2
          true
        end
      end    
    end


    def start
      loop do

        @hdeck = {:player => [], :dealer => []}
        @val = {:player => 0, :dealer => 0}
        @bet = @original_bet

        break unless @credit.between?(0, @max_credit)

        next if first_round_won?

        show_cards

        answer = ask
        case answer
        when :stand
          deal(:dealer, 1) while @val[:dealer] < 17
          calculate(@bet)
        when :hit
          deal(:player, 1)
          deal(:dealer, 1) while @val[:dealer] < 17
          calculate(@bet)
        when :double
          deal(:player, 1)
          deal(:dealer, 2)
          calculate(@bet * 2)
        else
          puts "End of program"
          break          
        end
      end

      puts "Won Player? #{@credit > 0}"
    end
  end

  # class GameTest < MiniTest::Test
  #   def setup
  #     puts 'test stup'
  #   end

  #   def test_one
  #     puts "test_on"
  #   end
  # end




  game = Game.new(bet: 10)
  game.start






















