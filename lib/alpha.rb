require_relative 'alpha/constants'
require_relative 'alpha/search'

module Alpha
  Move = Struct.new(:from, :to, :piece, :target)
  
  Root = Struct.new(:move, :color, :score, :fen) do
    include Comparable
    
    def <=>(other)
      other.score <=> score
    end
    
    def to_h
      { from: SQ64[move.from], to: SQ64[move.to], piece: PIECES[color][move.piece], 
        target: PIECES[color % 6][move.target], score: score, fen: fen }
    end
  end
  
  def self.init(fen = INIT_FEN)
    mx, mn = fen.split[1] == 'b' ? 1 : 0, mx ^ 1
    squares, colors = Array.new(120) { -1 }, Array.new(120) { -1 }
    
    fen.split.first.split('/').map do |row| 
      row.chars.map { |sq| sq.ord < 57 ? %w(e) * sq.to_i : sq }
    end.flatten.each_with_index do |sq, i|
      squares[SQ[i]] = PIECES[1].index(sq.downcase)
      colors[SQ[i]] = sq == 'e' ? 6 : sq == sq.downcase ? 1 : 0
    end
    k = squares.select { |i| i == K }.sort_by { |i| colors[i] }
    Search.new(squares, colors, k, mx)
  end
  
  def self.run
    s = init
    while true
      s.advance
      s.render
    end
  end
end
