class Task
  def initialize(task_list, phase, id)
    @task_list = task_list
    @phase = phase
    @id = id
    @active = false
    @complete = false
    
    # get info from JSON file
    @@task_file ||= load_tasks_file

    # select a random task from current phase
    @name = @@task_file[phase].keys.sample

    # and get info for it
    @duration = @@task_file[phase][@name]['duration']
    @keys = @@task_file[phase][@name]['keys']
    @reward = @@task_file[phase][@name]['reward']
    @penalty = @@task_file[phase][@name]['penalty']
    @sequence = @@task_file[phase][@name]['sequence']
    @thumbnail = @task_list.window.task_thumbnail_gfx[@name]

    # we get sequence of images from the window
    @sequence_images = @task_list.window.task_images_gfx[@name]

    # font loading
    @@font ||= Gosu::Font.new(24)

    # sounds loading
    @@sounds ||= {
      validate: Gosu::Sample.new('./sfx/50565__broumbroum__sf3-sfx-menu-validate.wav'),
      select: Gosu::Sample.new('./sfx/413310__tieswijnen__select.mp3'),
      loose: Gosu::Sample.new('./sfx/220174__gameaudio__spacey-loose.wav')
    }

    # get creation time
    @tick = Gosu::milliseconds
    @offset_timer = 0
    @current_in_sequence = 0
    @sequence_scale = 0.2
    @sequence_scale_step = 0.1
    create_sequence_image
  end

  def button_down(id)
    if @active
      # if the pressed key is the right one
      if Gosu.button_id_to_char(id) == @sequence[@current_in_sequence].downcase
        # we play a sound, increase the sequence and update the sprite        
        @@sounds[:validate].play(0.2)
        @current_in_sequence += 1
        create_sequence_image

        # we set to complete if that was the last key to press
        if @current_in_sequence == @sequence.size
          # we add to the score
          @task_list.window.close_task(true, @reward)
          
          # we complete the task
          @complete = true
          @current_in_sequence = 0
        end
      end
    end
  end

  def completed?
    @complete
  end

  def active?
    @active
  end

  def toggle_active(id)
    @active = (id == @id)

    if @active
      @current_in_sequence = 0
      create_sequence_image
      @@sounds[:select].play(0.3)
    end
  end
  
  def load_tasks_file
    @@task_file = JSON.parse(File.read('./tasks.json'))
  end

  def update
    # we update thumbnail sprite according to timer
    elapsed_time = Gosu::milliseconds - @tick

    # task missed
    if elapsed_time >= @duration
      # we remove from the score
      @task_list.window.close_task(false, -@penalty)
      @complete = true
      @@sounds[:loose].play(0.2)
    # task is not missed, we update the thumbnail display
    else
      ratio = elapsed_time / @duration.to_f
      @offset_timer = -@thumbnail.width * ratio
    end

    if @active
      update_active
    end
  end

  def update_active
    # here we update the task itself

    # update current sequence scale
    step = 0.2
    @sequence_scale += @sequence_scale_step
    @sequence_scale_step = -@sequence_scale_step if @sequence_scale < 0.2 || @sequence_scale > 1.2
  end
  
  def draw(offset_x, offset_y, offset_z)
    x = offset_x
    y = offset_y + @id * @thumbnail.height
    z = offset_z
    
    color = @active ? Gosu::Color::GREEN : Gosu::Color::WHITE

    @@font.draw_text(@id + 1, x, y, z + 0, 1, 1, color) # we rather display 1 instead of 0 for first element
    
    # we clip to to allow to scroll left the sprite as time goes by
    Gosu.clip_to(x + 32, y, @thumbnail.width, @thumbnail.height) { @thumbnail.draw(x + 32 + @offset_timer, y, z) }

    if @active
      draw_active
    end
  end
  
  def draw_active
    # here we display the task itself
    draw_actions
    draw_sequence
    draw_sequence_image
  end

  def create_sequence_image
    text = @keys[@sequence[@current_in_sequence]]
    @image = Gosu::Image.from_text(text, 40, font: Gosu::default_font_name)
  end

  def draw_sequence
    @image.draw_rot(320, 200, 1, 0, 0.5, 0.5, @sequence_scale, @sequence_scale)
    @@font.draw_text(@sequence.join('-'), 255, 370, 0)
  end

  def draw_sequence_image
    @sequence_images[@sequence[@current_in_sequence]].draw(260, 220, 0)
  end

  def draw_actions
    y = 200
    x = 500
    z = 0

    @keys.each do |key, action|
      @@font.draw_text(key, x, y, z, 2, 2)
      @@font.draw_text(action, x, y + 2 * @@font.height, z)
      y += 3 * @@font.height
    end
  end
end