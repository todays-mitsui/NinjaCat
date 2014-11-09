require_relative './AddressableTry'

class LinkMap
  def initialize url
    @root = url
    @map = Hash.new
  end

  def store url_hash
    from = url_hash[:from]
    to   = url_hash[:to]
    puts "store #{from} => #{to}"
    if @map.has_key?(to)
      @map[to][:origin] << from unless @map[to][:origin].include?(from)
    else
      @map[to] = Hash.new
      if Addressable::URI.parse(to).try
        @map[to][:is_alive] = true
      else
        @map[to][:is_alive] = false
      end
      @map[to][:origin] = [from]
    end
  end 
end
