class PhaseList
  attr_reader :phases
  def initialize(window)
    @window = window
    @phases = JSON.parse(File.read('./phases.json'))
    @phases_names = @phases.keys
    @font = Gosu::Font.new(20)
    @success = 0
    @current_phase = @phases_names.first
  end

  def add_success
    @success += 1

    # if enough tasks were done to complete the phase
    if @success >= @phases[@current_phase]['tasks_to_complete']
      @success = 0
      next_phase_id = @phases_names.index(@current_phase) + 1 
      @window.close_phase
      
      # game is won
      if next_phase_id >= @phases_names.size
        @window.game_win
      else
        next_phase = @phases_names[next_phase_id]
        set_current_phase(next_phase)
      end
    end
  end

  def set_current_phase(phase)
    @current_phase = phase
  end

  def phase
    @current_phase
  end

  def update

  end

  def draw
    offset_x, offset_y, offset_z = 160, 0, 0
    gfx = @window.phase_thumbnail_gfx

    @phases.keys.each_with_index do |phase, i|
      color = Gosu::Color::WHITE
      gfx.draw(offset_x + i * gfx.width, offset_y, offset_z)
      @font.draw_text(@phases[phase]['name'], offset_x + i * gfx.width + 10, offset_y + 5, offset_z, 1, 1, color)
      
      # if this phase was previous to current one, we can check it
      if i < @phases_names.index(@current_phase)
        @font.draw_text("X", offset_x + i * gfx.width + 106, offset_y + 6, offset_z, 1, 1, Gosu::Color::GREEN)
      end
    end
  end
end