class Player
  attr_accessor :x, :y, :angle, :score, :lives, :id
  #--------------------------------------#
  def initialize(id)
    @id=id
    @image = Gosu::Image.new("assets/nave1.png")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @alive = true
    @score = 0 #Puntaje
    @lives = 5 #Vida
  end
  #--------------------------------------#

  def warp(x, y)
    @x, @y = x, y
  end
  #--------------------------------------#
  def turn_left
    @angle -= 4.5
  end
  #--------------------------------------#
  def turn_right
    @angle += 4.5
  end
  #--------------------------------------#
  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.4)
    @vel_y += Gosu::offset_y(@angle, 0.4)
  end
  #--------------------------------------#
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 1000
    @y %= 700

    @vel_x *= 0.95
    @vel_y *= 0.95
  end
  #--------------------------------------#
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  #--------------------------------------#
  def kill
		@lives -= 1
		alive = false
		return if lives <= 0
    warp(500,350)
	end
  #--------------------------------------#
  def hitbox
    hitbox_x = ((@x - @image.width/2).to_i..(@x + @image.width/2.to_i)).to_a
    hitbox_y = ((@y - @image.width/2).to_i..(@y + @image.width/2).to_i).to_a
    {:x => hitbox_x, :y => hitbox_y}
  end
  #--------------------------------------#
end
