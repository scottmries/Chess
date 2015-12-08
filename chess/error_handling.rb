class ChessError < StandardError

end

class QuitGame < ChessError

  def initialize
    @message = "You can't fire me, I quit!"
  end

end
