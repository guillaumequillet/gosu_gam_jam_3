=begin
  TODO

  tâches :

  - déserbage / arbres => tronconnage + decoupe + broyeur vegetaux
  - fondations à creuser
  - feraillage
  - beton à créer (betonniere)
  - deposer beton dans fondations
  - murs à monter

  crédits :
  son : 
  broumbroum freesound.org 50565__broumbroum__sf3-sfx-menu-validate.wav
  GameAudio freesound.org 220174__gameaudio__spacey-loose.wav
  TiesWijnen freesound.org 413310__tieswijnen__select.mp3
  JustInvoke freesound.org 

  images
  Amigos3D Pixabay.com base title screen
  IlyaYurukin Pixabay.com background image (sera virée avant la fin...)

  Mode d'emploi : 

  il faut dans le dossier gfx / tasks
    pour chaque sous dossier correspondant à une tache
    mettre une image pour chaque "KEY", comme "A.png"

  que reste t-il ?
    créer du contenu (phases, actions à faire) : privilégier du place holder !!!
    faire un écran titre / écran victoire
    trouver une musique, ajouter des bruitages adaptés aux actions ?
=end

require 'json'
require 'gosu'

require_relative './lib/task.rb'
require_relative './lib/task_list.rb'
require_relative './lib/phase_list.rb'

class Window < Gosu::Window
  attr_reader :phase_thumbnail_gfx, :task_thumbnail_gfx, :task_images_gfx
  def initialize
    load_game_variables
    load_resources
    super(@game_variables['window']['width'], @game_variables['window']['height'], @game_variables['window']['fullscreen'])
    self.caption = @game_variables['window']['caption']
    @state = :title

    @sounds[:music].volume = 0.3
    @sounds[:music].play
  end

  def load_game_variables
    @game_variables = JSON.parse(File.read('./game_variables.json'))

    @images = {
      title: Gosu::Image.new('./gfx/title.png', retro: true),
      background: Gosu::Image.new('./gfx/background.png', retro: true),
      win: Gosu::Image.new('./gfx/win.png', retro: true)
    }

    @font = Gosu::Font.new(24)
  end

  def load_resources
    # phase thumbnails loading
    @phase_thumbnail_gfx = Gosu::Image.new('./gfx/phases/template.png')

    # tasks loading
    @task_thumbnail_gfx = {}
    @task_images_gfx = {}
    
    Dir.entries('./gfx/tasks').reject {|fn| ['.', '..'].include?(fn)}.each do |dirname|
      Dir.entries("./gfx/tasks/#{dirname}").select {|fn| fn.include?('.png')}.each do |filename|
        if filename == 'thumbnail.png'
          @task_thumbnail_gfx[dirname] = Gosu::Image.new("./gfx/tasks/#{dirname}/#{filename}")
        else
          @task_images_gfx[dirname] ||= {}
          @task_images_gfx[dirname][filename.slice(0, filename.size - 4)] = Gosu::Image.new("./gfx/tasks/#{dirname}/#{filename}")
        end
      end
    end

    # sound loading
    @sounds = {
      phase_end: Gosu::Sample.new('./sfx/446111__justinvoke__success-jingle.wav'),
      validate: Gosu::Sample.new('./sfx/50565__broumbroum__sf3-sfx-menu-validate.wav'),
      music: Gosu::Song.new('./sfx/retro-action-arcade-music-for-games-free-download.mp3')
    }
  end

  def close_task(score)
    @global_score += score
    @phase_list.add_score(score)
  end

  def close_phase
    @sounds[:phase_end].play(0.3)
    @task_list = TaskList.new(self)
  end

  def start_new_game
    @state = :game
    @global_score = 0
    @task_list = TaskList.new(self)
    @phase_list = PhaseList.new(self)
  end

  def game_win
    @state = :win
  end

  def button_down(id)
    super
    close! if id == Gosu::KB_ESCAPE

    case @state
    when :game
      @task_list.button_down(id)
    when :title, :win
      @sounds[:validate].play(0.3)
      start_new_game
    end
  end

  def update
    case @state
    when :title
      @title_tick ||= 0
      @title_tick += 1
      @title_tick = 0 if @title_tick >= 60
    when :game
      add_new_task
      @task_list.update
    end
  end

  # GAME methods
  def add_new_task
    @last_task ||= Gosu::milliseconds
    if Gosu::milliseconds - @last_task >= @game_variables['time_before_task']
      @task_list.add_task(@phase_list.phase)
      @last_task = Gosu::milliseconds
    end
  end

  def draw_score
    @font.draw_text("Score: #{@global_score}", 420, 440, 1)
  end

  def draw
    case @state
    when :title
      # background
      @images[:title].draw(0, 0, 0)

      # blinking text
      title_scale = 1.25

      @font.draw_text(@title_blink, 0, 0, 0)

      if @title_tick < 30
        @font.draw_text("Press any key to start", 190, 318, 0, title_scale, title_scale)
        @font.draw_text("Press any key to start", 190, 322, 0, title_scale, title_scale)
        @font.draw_text("Press any key to start", 188, 320, 0, title_scale, title_scale)
        @font.draw_text("Press any key to start", 192, 320, 0, title_scale, title_scale)

        @font.draw_text("Press any key to start", 190, 320, 0, title_scale, title_scale, Gosu::Color::BLACK)
      end
    when :game
      @images[:background].draw(0, 0, 0)
      @task_list.draw
      @phase_list.draw
      draw_score
    when :win
      @images[:win].draw(0, 0, 0)
      @font.draw("You WON ! Score : #{@global_score}", 10, 10, 0, 1, 1, Gosu::Color::BLACK)
      @font.draw('Press any key to restart', 270, 463, 0, 0.7, 0.7, Gosu::Color::BLACK)
    end
  end
end

Window.new.show