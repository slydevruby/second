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
