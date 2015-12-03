class Projectile
  attr_accessor :x, :y, :angle, :alive, :id
  #--------------------------------------#
  def initialize(origin_object)
    @id=origin_object.id
    @alive = true
    @x, @y = origin_object.x, origin_object.y
    @angle = origin_object.angle
    @speed_modifier = 2
    @image = Gosu::Image.new('assets/projectile1.png')
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
    #@distance_traveled += 1
    kill if @x < 5
    kill if @x > 995
    kill if @y > 695
    kill if @y < 5
  end
  #--------------------------------------#
  def kill
    @alive = false
  end
  #--------------------------------------#
  def dead? #Especificar si esta muerto
    !@alive
  end
  #--------------------------------------#
  def hitbox
    hitbox_x = ((@x - @image.width/2).to_i..(@x + @image.width/2.to_i)).to_a
    hitbox_y = ((@y - @image.width/2).to_i..(@y + @image.width/2).to_i).to_a
    {:x => hitbox_x, :y => hitbox_y}
  end
  #--------------------------------------#
end
