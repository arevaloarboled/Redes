include Math

class Asteroid
  #--------------------------------------#
  def initialize
    @alive = true
    @image = Gosu::Image.new("assets/Large_Asteroid.png")
    @x, @y, @angle = rand(1000), rand(350), rand(360)
    @speed_modifier = 1
  end
  #--------------------------------------#
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  #--------------------------------------#
  def move
    @x += @speed_modifier*Math.sin(Math::PI/180*@angle)
    @y += -@speed_modifier*Math.cos(Math::PI/180*@angle)
    @x %= 1000
    @y %= 700
  end
  #--------------------------------------#
  def setup(x, y, speed)
    @x, @y, @speed_modifier = x, y, speed
    @angle = rand(360)
    self
  end
  #--------------------------------------#
  def self.spawn(count)
    count.times.collect{Asteroid.new}
  end
  #--------------------------------------#
  def kill
    @alive = false
  end
  #--------------------------------------#
  def hitbox
    hitbox_x = ((@x - @image.width/2).to_i..(@x + @image.width/2.to_i)).to_a
    hitbox_y = ((@y - @image.width/2).to_i..(@y + @image.width/2).to_i).to_a
    {:x => hitbox_x, :y => hitbox_y}
  end
  #--------------------------------------#
end
