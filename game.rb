require 'gosu'
require './libs/Player.rb'
require './libs/Projectile.rb'
require './libs/Asteroid.rb'

#........................................#
class GameWindow < Gosu::Window

  def initialize
    super(1000, 700, false) #Creacion Pantalla
    @game_in_progress = false
    @menu_principal = false
    self.caption = "Asteroids Redes" #Titulo Pantalla
    @font = Gosu::Font.new(self, "assets/victor-pixel.ttf", 34)
  end

  def setup_game
    @player = Player.new
    @player.warp(500, 350)
    @game_in_progress = true
    @menu_principal = false
    @level = 1 #Nivel dificultad del juego
    @projectiles = []
    @cooldown = 60 #Espacios que recorre una bala antes de podes disparar otra
    @asteroid_count = 3

    @asteroids = Asteroid.spawn(@asteroid_count)
  end

  def Start_Screen
  end
  #--------------------------------------#
  def update

    if Gosu::button_down? Gosu::KbQ #Salir con tecla Q
      close
    end
    if button_down? Gosu:: KbP
      setup_game unless @game_in_progress
    end
    if button_down? Gosu::KbM
      @menu_principal = true
      @game_in_progress = false
    end

    if @player #si existe jugador permite moverlo
      if Gosu::button_down? Gosu::KbSpace then
        if @cooldown < 25 #es el cooldown para que se pueda disparar, solo se puede cuando @cooldown > 25
        else
          @projectiles << Projectile.new(@player)
          @cooldown = 0
        end
      end

      if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
        @player.turn_left
      end
      if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
        @player.turn_right
      end
      if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
        @player.accelerate
      end
      ################--->>>
      @cooldown += 1 #Para el conteo que vuelve a permitir disparar
      @player.move
      @projectiles.each {|projectile| projectile.move}
      @projectiles.reject!{|projectile| projectile.dead?} #no elimina todos los proyectiles que dead? = false

      @asteroids.each {|asteroid| asteroid.move}
      @asteroids.reject!{|asteroid| asteroid.dead?}
      deteccion_colisiones
      level_up if @asteroids.size == 0 
      ################--->>>
    end

  end
  #--------------------------------------#
  def draw

    unless @game_in_progress #Si el no se esta ejecutando muestra el menu
      @font.draw("ASTEROIDS", 260, 220, 50, 3, 3, Gosu::Color::rgb(255, 255, 255))
      @font.draw("Presiona 'p' Para Jugar", 300, 320, 50, 1, 1, Gosu::Color::rgb(13, 123, 255))
      @font.draw("Presiona 'q' Para Salir", 305, 345, 50, 1, 1, Gosu::Color::rgb(13, 123, 255))
    end

    if @player #Si existe jugador lo dibuja

      if @player.lives <= 0
        unless @menu_principal
          @font.draw("GAME OVER", 260, 220, 50, 3.0, 3.0, Gosu::Color::rgb(242,48,65))
          @font.draw("Presiona 'm' Para El Menu", 300, 320, 50, 1, 1, 0xffffffff)
          @font.draw("Presiona 'q' Para Salir", 305, 345, 50, 1, 1, 0xffffffff)
        end
      end

      unless @player.lives <= 0 #Para que cuando muera no muestre mas en la pantalla
        @player.draw unless @player.lives <= 0
        @projectiles.each {|projectile| projectile.draw}
        @asteroids.each {|asteroid| asteroid.draw} #Dibuja todos los asteroides

        @font.draw("PUNTAJE:", 20, 10, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
        @font.draw(@player.score, 170, 10, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
        @font.draw("VIDAS:", 20, 40, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
        @font.draw(@player.lives, 125, 40, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
    		@font.draw("Level: ", 870, 10, 50, 1.0, 1.0, Gosu::Color::rgb(247, 226, 106))
    		@font.draw(@level, 970, 10, 50, 1.0, 1.0, Gosu::Color::rgb(247, 226, 106))
      end

    end
  end
  #--------------------------------------#
  def colision?(obj1, obj2) #deteccion de colisiones entre dos objetos
    hitbox_1, hitbox_2 = obj1.hitbox, obj2.hitbox
    common_x = hitbox_1[:x] & hitbox_2[:x]
    common_y = hitbox_1[:y] & hitbox_2[:y]
    common_x.size > 0 && common_y.size > 0
  end
  #--------------------------------------#
  def deteccion_colisiones
    @asteroids.each do |asteroid|
      if colision?(asteroid, @player)
      	@player.kill
      end
    end
    ################--->>>
    @projectiles.each do |projectile|
      @asteroids.each do |asteroid|
        if colision?(projectile, asteroid)
          projectile.kill
          @player.score += asteroid.points
          @asteroids += asteroid.kill
        end
      end
    end
  end
  #--------------------------------------#
  def level_up
		@asteroid_count += 1
		@level += 1
		@asteroids = Asteroid.spawn(@asteroid_count)
	end
  #--------------------------------------#
end
#........................................#
window = GameWindow.new
window.show
