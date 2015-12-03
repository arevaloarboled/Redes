require 'gosu'
require './libs/Player.rb'
require './libs/Projectile.rb'
require './libs/Asteroid.rb'
require 'socket'
require 'thread'
require 'timeout'
# require 'rubygems'
# require 'net/ping'

#........................................#
def ping(host)
  begin
    #tim=Timeout.timeout(10) do
      s = TCPSocket.open(host, 9121)
      s.close
      return true
    #end
  rescue Errno::ECONNREFUSED
     return true
  rescue Timeout::Error,Errno::ENETUNREACH, Errno::EHOSTUNREACH, StandardError
    return false
  end
  #return true
end
# def checkup?(host)
#     check = Net::Ping::External.new(host)
#     check.ping?
# end
def myip
  begin
    return UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH
    sleep(1)
    return "ERROR!"
  end
end
$servers=["192.168.250.214","192.168.250.38"]
$k=0
$IP=myip()
conexion=Thread.new do
  i=0
  loop do
    #puts ping($servers[i])
    #puts $k
    #puts checkup?($servers[i])
    if ping($servers[i]) then
      if $k!=i
        $k=i
        puts "CHANGE! "+" new server " +$servers[$k]
      end
      i=0        
    else
      i=i+1
      puts "search server"
      if i==$servers.count()
        i=0
      end
    end
  end
end
def recibe(msg)
  tmp=msg
  loop do
    msg=tmp
    begin
      #tim=Timeout.timeout(15) do
        server = TCPSocket.open( $servers[$k], 9123 )
        server.puts(msg)
        msg=server.gets.chomp
        server.close
        break
      #end
    #rescue Exception => e#Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
    rescue Timeout::Error,Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH,Exception=>e
          puts "Error in recibe"
          if e
            puts e
          end
        end
  end
  return msg
end

def envia(msg)
  loop do
    begin
      #tim=Timeout.timeout(15) do
        server = TCPSocket.open( $servers[$k], 9123 )
        server.puts(msg)
        server.close
        break
      #end
    #rescue Exception => e#Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
    rescue Timeout::Error,Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH,Exception=>e
          puts "Error in envia"
          if e
            puts e
          end
        end
  end
end

class GameWindow < Gosu::Window

  def initialize(update_interval=33)
    @update_interval=update_interval
    super(1000, 700, false) #Creacion Pantalla
    @game_in_progress = false
    @menu_principal = false
    self.caption = "Asteroids Redes" #Titulo Pantalla
    @font = Gosu::Font.new(self, "assets/victor-pixel.ttf", 34)
  end

  def setup_game
    begin
      envia("hola")
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH
      puts "error en la conexion..."
    end
    puts "lol"
    #@player = Player.new
    #@player.warp(500, 350)
    @game_in_progress = true
    @menu_principal = false
    @level = 1 #Nivel dificultad del juego
    #@projectiles = []
    #@cooldown = 60 #Espacios que recorre una bala antes de podes disparar otra
    #@asteroid_count = 3

    #@asteroids = Asteroid.spawn(@asteroid_count)
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

    if @game_in_progress #si existe jugador permite moverlo
      if Gosu::button_down? Gosu::KbSpace then
        #if @cooldown < 25 #es el cooldown para que se pueda disparar, solo se puede cuando @cooldown > 25
        #else
        #  @projectiles << Projectile.new(@player)
        #  @cooldown = 0
        #end
        envia("space")
      end
      if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
        envia("left")
        #@player.turn_left
      end
      if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
        envia("right")
        #@player.turn_right
      end
      if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpUp then
        envia("up")
        #@player.accelerate
      end
      msg=recibe("update")
      $ll=msg
      ################--->>>
      #@cooldown += 1 #Para el conteo que vuelve a permitir disparar
      #@player.move
      #@projectiles.each {|projectile| projectile.move}
      #@projectiles.reject!{|projectile| projectile.dead?} #no elimina todos los proyectiles que dead? = false

      #@asteroids.each {|asteroid| asteroid.move}
      #deteccion_colisiones
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

    #if @player #Si existe jugador lo dibuja

      # if @player.lives <= 0
      #   unless @menu_principal
      #     @font.draw("GAME OVER", 260, 220, 50, 3.0, 3.0, Gosu::Color::rgb(242,48,65))
      #     @font.draw("Presiona 'm' Para El Menu", 300, 320, 50, 1, 1, 0xffffffff)
      #     @font.draw("Presiona 'q' Para Salir", 305, 345, 50, 1, 1, 0xffffffff)
      #   end
      # end

      #unless @player.lives <= 0 #Para que cuando muera no muestre mas en la pantalla
      if @game_in_progress

        #msg=recibe("update")
        #puts msg
        l=$ll.split('|')
        i=0
        while i<l.count() do
          if l[i]=="pl"
            if l[i+5].to_f>0
              Gosu::Image.new("assets/nave"+(l[i+1].ord-47).to_s+".png").draw_rot(l[i+2].to_f,l[i+3].to_f,1,l[i+4].to_f)
            end
            if l[i+1].to_f == 0.0
              @font.draw("PUNTAJE:", 10, 10, 50, 1.0, 1.0, Gosu::Color::rgb(255, 255, 255))
              @font.draw(l[i+6].to_s, 210, 10, 50, 1.0, 1.0, Gosu::Color::rgb(255, 255, 255))
              @font.draw("VIDAS:", 10, 40, 50, 1.0, 1.0, Gosu::Color::rgb(255, 255, 255))
              @font.draw(l[i+5].to_s, 150, 40, 50, 1.0, 1.0, Gosu::Color::rgb(255, 255, 255))
            elsif l[i+1].to_f == 1.0
              @font.draw("PUNTAJE:", 710, 10, 50, 1.0, 1.0, Gosu::Color::rgb(0, 177, 204))
              @font.draw(l[i+6].to_s, 910, 10, 50, 1.0, 1.0, Gosu::Color::rgb(0, 177, 204))
              @font.draw("VIDAS:", 780, 40, 50, 1.0, 1.0, Gosu::Color::rgb(0, 177, 204))
              @font.draw(l[i+5].to_s, 910, 40, 50, 1.0, 1.0, Gosu::Color::rgb(0, 177, 204))
            elsif l[i+1].to_f == 2.0
              @font.draw("PUNTAJE:", 10, 620, 50, 1.0, 1.0, Gosu::Color::rgb(255, 231, 51))
              @font.draw(l[i+6].to_s, 210, 620, 50, 1.0, 1.0, Gosu::Color::rgb(255, 231, 51))
              @font.draw("VIDAS:", 10, 650, 50, 1.0, 1.0, Gosu::Color::rgb(255, 231, 51))
              @font.draw(l[i+5].to_s, 150, 650, 50, 1.0, 1.0, Gosu::Color::rgb(255, 231, 51))
            else
              @font.draw("PUNTAJE:", 710, 620, 50, 1.0, 1.0, Gosu::Color::rgb(199, 23, 0))
              @font.draw(l[i+6].to_s, 910, 620, 50, 1.0, 1.0, Gosu::Color::rgb(199, 23, 0))
              @font.draw("VIDAS:", 780, 650, 50, 1.0, 1.0, Gosu::Color::rgb(199, 23, 0))
              @font.draw(l[i+5].to_s, 910, 650, 50, 1.0, 1.0, Gosu::Color::rgb(199, 23, 0))
            end

            i=i+7
            next
          end
          if l[i]=="as"
            Gosu::Image.new("assets/Large_Asteroid.png").draw_rot(l[i+1].to_f,l[i+2].to_f,1,l[i+3].to_f)       
            i=i+4
            next
          end
          if l[i]=="pr"
            Gosu::Image.new("assets/projectile"+(l[i+1].ord-47).to_s+".png").draw_rot(l[i+2].to_f,l[i+3].to_f,1,l[i+4].to_f)       
            i=i+5        
            next
          end
          i=i+1
        end
      end
        # @player.x=l[1].to_f
        # @player.y=l[2].to_f
        # @player.angle=l[3].to_f
        #puts @player.x
        #@player.draw #unless @player.lives <= 0
        #@projectiles.each {|projectile| projectile.draw}
        #@asteroids.each {|asteroid| asteroid.draw} #Dibuja todos los asteroides

        #@font.draw("PUNTAJE:", 20, 10, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
        #@font.draw(@player.score, 170, 10, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
        #@font.draw("VIDAS:", 20, 40, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
        #@font.draw(@player.lives, 125, 40, 50, 1.0, 1.0, Gosu::Color::rgb(48, 162, 242))
    		#@font.draw("Level: ", 870, 10, 50, 1.0, 1.0, Gosu::Color::rgb(247, 226, 106))
    		#@font.draw(@level, 970, 10, 50, 1.0, 1.0, Gosu::Color::rgb(247, 226, 106))
      #end

    #end
  end
end
#........................................#
window = GameWindow.new()
window.show
