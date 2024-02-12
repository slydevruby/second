require_relative 'user'

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
