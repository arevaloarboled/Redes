include Math

class Asteroid
  attr_accessor :x, :y, :angle, :alive, :size
  #--------------------------------------#
  def initialize(size)
    @size = size
    @alive = true
    @image = Gosu::Image.new("assets/Asteroid-#{size}.png")
    @x, @y, @angle = rand(1000), rand(350), rand(360)
    @speed_modifier = 0.1
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
  def smash
    asteroids = case @size
    when 'Large'
        speed = 0.12
        2.times.collect{Asteroid.new('Medium')}
      when 'Medium'
        speed = 0.14
        2.times.collect{Asteroid.new('Small')}
      else
        []
      end
    asteroids.collect {|asteroid| asteroid.setup(@x, @y, rand(0)*speed+0.3) }
  end
  #--------------------------------------#
  def self.spawn(count)
    count.times.collect{Asteroid.new('Large')}
  end
  #--------------------------------------#
  def kill
    @alive = false
    smash
  end
  #--------------------------------------#
  def dead?
    !@alive
  end
  #--------------------------------------#
  def hitbox
    hitbox_x = ((@x - @image.width/2).to_i..(@x + @image.width/2.to_i)).to_a
    hitbox_y = ((@y - @image.width/2).to_i..(@y + @image.width/2).to_i).to_a
    {:x => hitbox_x, :y => hitbox_y}
  end
  #--------------------------------------#
  def points
    case @size
    when 'Large'
      20
    when 'Medium'
      50
    when 'Small'
      100
    else
      0
    end
  end
  #--------------------------------------#

end
