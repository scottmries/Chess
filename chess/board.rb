class Board

  attr_reader :grid

  def initialize
    # [:square_color, :piece]
    @grid = Array.new(8) { Array.new(8) }

    # grid.each_index do |row|
    #   grid[row].each_index do |col|
    #     (row + col) % 2 == 0 ? grid[row][col]= [:white, nil] : grid[row][col] = [:black, nil]
    #   end
    # end

    populate_grid
  end

  def populate_grid
    self.grid[1].each_index{|i| self.grid[1][i] = Pawn.new(:black, self)}
    self.grid[6].each_index{|i| self.grid[6][i] = Pawn.new(:white, self)}

    self.grid[0][0], self.grid[0][7] = Rook.new(:black, self), Rook.new(:black, self)
    self.grid[7][0], self.grid[7][7] = Rook.new(:white, self), Rook.new(:white, self)
    self.grid[0][1], self.grid[0][6] = Knight.new(:black, self), Knight.new(:black, self)
    self.grid[7][1], self.grid[7][6] = Knight.new(:white, self), Knight.new(:white, self)
    self.grid[0][2], self.grid[0][5] = Bishop.new(:black, self), Bishop.new(:black, self)
    self.grid[7][2], self.grid[7][5] = Bishop.new(:white, self), Bishop.new(:white, self)
    self.grid[0][3], self.grid[7][3] = Queen.new(:black, self), Queen.new(:white, self)
    self.grid[0][4], self.grid[7][4] = King.new(:black, self), King.new(:white, self)
  end

  def [](pos)
    x,y = pos
    grid[x][y]
  end

  # def inspect
  #   output = grid.map do |row|
  #     row.map {|square| square.first == :black ? "B" : "W"}.join
  #   end
  #   puts output
  # end

  def piece_color(pos)
    square_contents = self[pos]
    return square_contents.color if square_contents.is_a?(Piece)
    nil
  end

  private

  attr_writer :grid
end
