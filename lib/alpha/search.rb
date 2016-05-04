module Alpha
  class Search
    attr_reader :data
    def initialize(squares, colors, kings, mx)
      @squares, @colors, @kings = squares, colors, kings
      @mx, @mn = mx, mx ^ 1
    end

    def next_position(duration = 1)
      @moves = Array.new(MAXPLY) { [] }
      @history = Array.new(MAXPLY) { Array.new(6) { Array.new(120) { 0 } } }
      @nodes = Array.new(MAXPLY) { 0 }
      
      @ply, @height = 0, 1
      @clock, @start = 0.0, Time.now
      @roots = generate_roots
      @root = nil
      
      while Time.now < @start + duration && @height < MAXPLY
        @height += 1
        @roots.each do |r|
          make(r.move)
          r.score = -alphabeta(-INF, INF, @height)
          unmake(r.move)
        end
        @clock = (Time.now - @start).round(2)
        @root = @roots.sort!.first
      end
      
      @data = {
        stats: {
          clock: @clock,
          iterations: @height,
          nodes: @nodes.inject(:+),
          npp: @nodes.map.with_index { |n, i| { ply: i, nodes: n } },
          nps: (@nodes.inject(:+).to_f / @clock).round(2)
        }
      }
      if @root
        @data[:root] = @root.to_h
        make(@root.move)
        @roots = generate_roots
        @data[:board] = SQ.map { |i| { piece: PIECES[@colors[i] % 6][@squares[i]], moves: [] } }
        @roots.each { |r| @data[:board][SQ64[r.move.from]][:moves] << { to: SQ64[r.move.to], fen: r.fen } }
        if @roots.length > 0
          @data[:status] = -1
        else
          @data[:status] = @mn
        end
      else
        @data[:status] = @mn
      end
      OpenStruct.new(@data)
    end
    
    
    def alphabeta(alpha, beta, depth)
      @nodes[@ply] += 1
      return evaluate if depth == 0
      generate_moves.each do |m|
        next unless make(m)
        x = -alphabeta(-beta, -alpha, depth - 1)
        unmake(m)
        if x > alpha
          @history[@ply][m.piece][m.to] += (depth + 1) * @height if m.target == EMPTY
          return beta if x >= beta
          alpha = x
        end
      end
      alpha
    end
    
    def each_move(from, piece, color)
      if piece == P
        to = from + DIR[color]
        [to + 1, to - 1].each { |n| yield(from, n, P, @squares[n]) if @colors[n] == color ^ 1 }
        return unless @colors[to] == EMPTY
        yield(from, to, P, EMPTY)
        yield(from, to + DIR[color], P, EMPTY) if @squares[to + DIR[color]] == EMPTY && !(40..80).cover?(from)
      else STEPS[piece].each do |step|
          to = from + step
          while @colors[to] == EMPTY
            yield(from, to, piece, EMPTY)
            break unless SLIDES[piece]
            to += step
          end
          yield(from, to, piece, @squares[to]) if @colors[to] == color ^ 1
        end
      end
    end
    
    def generate_moves
      @moves[@ply].clear.tap do |mvs|
        SQ.select { |sq| @colors[sq] == @mx }.each do |sq|
          each_move(sq, @squares[sq], @mx) do |from, to, piece, target|
            mvs << Move.new(from, to, piece, target).freeze
          end
        end
      end.sort_by! do |m|
        - (m.target == EMPTY ? @history[@ply][m.piece][m.to] : 200_000 + m.target - m.piece)
      end
    end
    
    def evaluate
      score = 0
      SQ.select { |sq| @colors[sq] != EMPTY }.each do |i|
        score += (VAL[@squares[i]] + POS[@squares[i]][FLIP[@colors[i]] * SQ64[i]]) * FLIP[@colors[i]]
      end
      score * FLIP[@mx]
    end
    
    
    def generate_roots
      a = []
      generate_moves.each do |m|
        next unless make(m)
        a << Root.new(m, @mx, -INF, get_fen)
        unmake(m)
      end
      a
    end

    
    def make(m)
      @ply += 1
      @squares[m.from], @colors[m.from] = EMPTY, EMPTY
      @squares[m.to], @colors[m.to] = m.piece, @mx
      @kings[@mx] == m.to if m.piece == K
      @squares[m.to] == Q if m.piece == P && m.to < 30 || m.to > 90
      if in_check?
        swap! && unmake(m)
        return false
      end
      swap!
    end
    
    def unmake(m)
      swap!
      @ply -= 1
      @squares[m.from], @colors[m.from] = m.piece, @mx
      @squares[m.to], @colors[m.to] = m.target, m.target == EMPTY ? EMPTY : @mn
      @kings[@mx] = m.from if m.piece == K
    end
    
    def swap!
      @mx, @mn = @mn, @mx
      true
    end
    
    def in_check?
      k = @kings[@mx]
      8.times do |i|
        return true if @squares[k + STEP[i]] == N && @colors[k + STEP[i]] == @mn
        sq = k + OCTL[i]
        sq += OCTL[i] while @colors[sq] == EMPTY
        next unless @colors[sq] == @mn
        case @squares[sq]
        when Q then return true
        when B then return true if i < 4
        when R then return true if i > 3
        when P then return true if k + DIR[@mx] - 1 == sq || k + DIR[@mx] + 1 == sq
        when K then return true if sq - (k + OCTL[i]) == 0
        end
      end
      false
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
      rows.join
    end
    
    def render
      puts "\n\n   #{@nodes.inject(:+)} nodes @ #{(@nodes.inject(:+).to_f / @clock).round(2)}/sec"
      puts "   #{evaluate} evaluation for #{COLORS[@mx]}\n\n"
      8.times { |i| puts "  #{SQ[(i*8), 8].map { |j| UNICODE[@colors[j] % 6][@squares[j]].center(3, ' ') }.join}" }
    end
    
  end
end