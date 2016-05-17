require_relative 'alpha/constants'
require_relative 'alpha/search'
require_relative 'alpha/defs'

module Alpha
  
  class Search
    
    attr_reader :result
    
    def game_over?
      @result && @result != 'none'
    end


    def load_position(fen)
      return false unless fen?(fen)
      
      @squares, @colors = Array.new(120) { NULL }, Array.new(120) { NULL }
      SQ.each { |i| @squares[i], @colors[i] = EMPTY, EMPTY }
      @mx = fen.split[1] == 'w' ? WHITE : BLACK
      @mn = @mx ^ 1
      
      fen.split.first.split('/').map do |row| 
        row.chars.map do |sq| 
          ('1'..'8').cover?(sq) ? %w(e) * sq.to_i : sq 
        end
      end.flatten.each_with_index do |sq, i| 
        @colors[SQ[i]], @squares[SQ[i]] = FEN[sq][0], FEN[sq][1] 
      end
      
      @kings = SQ.select { |sq| @squares[sq] == K }.sort_by { |sq| @colors[sq] }
      @kings.map { |k| @colors[k] }.sort == [0, 1]
    end
    
    
    def data
      {
        board: @board,
        fen: @fen,
        log: @log,
        move: @root ? @root.to_h : {},
        nodes: @nodes,
        check: @check,
        clock: @clock,
        result: @result,
        height: @height
      }
    end
    
    
    def fen?(s)
      /^\s*([rnbqkpRNBQKP1-8]+\/){7}([rnbqkpRNBQKP1-8]+)\s[bw]\s*/.match(s)
    end
    
    
    def get_san(m)
      san = ''
      if m.piece == P
        san += PP[SQ64[m.from]][0] unless m.target == EMPTY
      else
        san += PIECES[0][m.piece]
      end
      san += 'x' if m.target != EMPTY
      san += PP[SQ64[m.to]]
      san += '=Q' if m.piece == P && !(30..90).cover?(m.to)
      san
    end
    
    
    def get_fen
      rows = []
      (21..91).step(10) do |i|
        a = (i...(i + 8)).to_a
        until a.empty?
          e = a.take_while { |k| @colors[k] == EMPTY }.length
          rows << a.shift(e).length unless e == 0
          rows << PIECES[@colors[a.first]][@squares[a.first]] if a.first
          a.shift
        end
        rows << "/" unless i == 91
      end
      "#{rows.join} #{COLORS[@mx]}"
    end
    
    
    def render
      puts "\n"
      puts 8.times.map { |i| SQ[(i*8), 8].map { |j| UNICODE[@colors[j] % 6][@squares[j]].center(3, ' ') }.join }.join("\n")
    end
    
  end
end