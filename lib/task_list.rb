class TaskList
  attr_reader :window
  def initialize(window)
    @window = window
    @tasks = []
    @max_tasks = 10
    @max_tasks.times { @tasks.push nil } 
  end
  
  def add_task(phase)
    # we must have one available spot
    return if @tasks.index(nil).nil?

    # we add a new task at first available spot
    i = @tasks.index(nil)
    @tasks[i] = Task.new(self, phase, i)
  end

  def button_down(id)
    check_for_task_key(id)
    check_for_sequence_key(id)
  end

  def check_for_task_key(id)
    pressed_key = case id
    when Gosu::KB_0, Gosu::KB_NUMPAD_0
      10
    when Gosu::KB_1, Gosu::KB_NUMPAD_1
      1
    when Gosu::KB_2, Gosu::KB_NUMPAD_2
      2
    when Gosu::KB_3, Gosu::KB_NUMPAD_3
      3
    when Gosu::KB_4, Gosu::KB_NUMPAD_4
      4
    when Gosu::KB_5, Gosu::KB_NUMPAD_5
      5
    when Gosu::KB_6, Gosu::KB_NUMPAD_6
      6
    when Gosu::KB_7, Gosu::KB_NUMPAD_7
      7
    when Gosu::KB_8, Gosu::KB_NUMPAD_8
      8
    when Gosu::KB_9, Gosu::KB_NUMPAD_9
      9
    end

    if pressed_key.is_a?(Integer) && pressed_key >= 1 && pressed_key <= @tasks.size
      @tasks.select {|task| !task.nil?}.each {|task| task.toggle_active(pressed_key - 1)} # we offset the ID by 1 to display "1" instead of "0"
    end
  end

  def check_for_sequence_key(id)
    @tasks.select {|task| !task.nil?}.each.select {|task| task.active?}.each {|task| task.button_down(id)}
  end

  def update
    # we set to nil any Id where task is completed
    for i in 0...@tasks.size
      if !@tasks[i].nil? && @tasks[i].completed?
        @tasks[i] = nil
      end
    end
    @tasks.select {|task| !task.nil?}.each {|task| task.update}
  end

  def draw
    @tasks.select {|task| !task.nil?}.each {|task| task.draw(0, 64, 0)}

    # @font ||= Gosu::Font.new(20)
    # @font.draw_text(@tasks[0].inspect, 10, 400, 0) # for DEBUG Purpose
  end
end