require 'gosu'
require './libs/Player.rb'
require './libs/Projectile.rb'
require './libs/Asteroid.rb'
#require './libs/socket.rb'
require 'thread'
require 'socket'
require 'timeout'


def myip
  begin
    return UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH
    sleep(1)
    return "ERROR!"
  end
end

$socket = TCPServer.open("192.168.0.19",9123)
#$socket_ali = TCPServer.open("localhost",9123)
$servers=["192.168.0.21","192.168.0.19"]
$clients=[]
$players=[]
$projectiles=[]
$asteroids=[]
$cooldown=[]
$asteriod_count=3
$level=1
$c=0
$asteroids=Asteroid.spawn($asteriod_count)
#$server=Thread.new do 
#........................................#

def colision?(obj1, obj2) #deteccion de colisiones entre dos objetos
  hitbox_1, hitbox_2 = obj1.hitbox, obj2.hitbox
  common_x = hitbox_1[:x] & hitbox_2[:x]
  common_y = hitbox_1[:y] & hitbox_2[:y]
  common_x.size > 0 && common_y.size > 0
end
#--------------------------------------#
def deteccion_colisiones
  $asteroids.each do |asteroid|
    $players.each do |player|
      $projectiles.each do |projectile|
        if colision?(asteroid, player) then
          player.kill
          asteroid.kill
        end
        if colision?(projectile,player) and projectile.id!=player.id  then
          $players[projectile.id]+=200
          projectile.kill
          player.kill
        end  
        if colision?(asteroid,player) then
          $players[projectile.id]+=asteroid.points
          projectile.kill
          $asteroids+=asteroid.kill
        end
      end
    end
  end
  ################--->>>
  # $projectiles.each do |projectile|
  #   $asteroids.each do |asteroid|
  #     if colision?(projectile, asteroid)
  #       projectile.kill
  #       $players[0].score += 20
  #       #@asteroids += asteroid.kill
  #     end
  #   end
  # end
end
#--------------------------------------#
t=Time.now
tread=Thread.new do
  k=0
  loop do
    if k==65000 then
      #puts "se lanzo"
      begin
        i=0
        while i < $cooldown.count() 
          $cooldown[i]+=1
          i=i+1
        end 
        i=0
        while i < $players.count() 
          $players[i].move()
          #puts $players[i].y.to_s
          i=i+1
        end 
        i=0
        while i < $projectiles.count() 
          $projectiles[i].move()
          if $projectiles[i].alive==false then
            $projectiles.delete_at(i)
          end
          i=i+1
        end 
        i=0
        while i < $asteroids.count()
          $asteroids[i].move()
          if $asteroids[i].alive==false then
            $asteroids.delete_at(i)
          end 
          i=i+1
        end
      rescue Exception => e
        puts e
      end 
      #puts "D:"
      # $cooldown.each {|cool| cool += 1}  #Para el conteo que vuelve a permitir disparar
      # $players.each {|play| play.move}
      # $projectiles.each {|projectile| projectile.move}
      # $projectiles.reject!{|projectile| projectile.dead?} #no elimina todos los proyectiles que dead? = false

      # $asteroids.each {|asteroid| asteroid.move}
      deteccion_colisiones
      #puts "hola"
      i=0
      loop do
        begin
          if $servers[i]!=myip
            server = TCPSocket.open( $servers[i], 9123 )
            server.puts("update")
            $clients=[]
            $players=[]
            $projectiles=[]
            $asteroids=[]
            $cooldown=[]
            $asteriod_count=3
            $level=1
            $c=0
            $asteroids
            msg=server.gets.chomp
            l=msg.split("|")
            i=0
            while i<l.count 
              if l[i]=="cl"
                $clients.push(l[i+1])
                $players.push(Player.new($c))
                $c+=1
                $players[$players.count()-1].x=l[i+2].to_f
                $players[$players.count()-1].y=l[i+3].to_f
                $players[$players.count()-1].angle=l[i+4].to_f
                $cooldown.push(0)
                #$players[$players.count()-1].x=l[i+1].to_f
                i=i+5
                next
              end
              if l[i]=="asn"
                $asteriod_count=l[i+1].to_d
                i=i+2
                next
              end
              if l[i]=="as"
                $asteroids.push(Asteroids.new(l[i+1]))
                $asteroids[$asteroids.count()-1].x=l[i+2].to_f
                $asteroids[$asteroids.count()-1].y=l[i+3].to_f
                $asteroids[$asteroids.count()-1].angle=l[i+4].to_f
                i=i+5
                next
              end
              if l[i]=="pr"
                $projectiles.push(Projectile.new(l[i+1].to_f))                
                $projectiles[$projectiles.count()-1].x=l[i+2].to_f
                $projectiles[$projectiles.count()-1].y=l[i+3].to_f
                $projectiles[$projectiles.count()-1].angle=l[i+4].to_f
                i=i+5
                next
              end
              i=i+1
            end
            server.close
            break
          elsif $servers[i]==myip
            break             
          end
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
          server.close
          i+=1
          if i==$servers.count then
            i=0
          end
        end
      end
      k=0
    end
    k=k+1
  end
end
loop do
  Thread.start($socket.accept) do |client|
    begin
      #puts "me llego :3"
      msg=client.gets.chomp
      sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
      #puts "mesagge: '%s' from: '%s' " % [msg,remote_ip]
      if !($clients.include?(remote_ip)) and msg=="hola"  and  $c<4 then
        #puts "suave "+msg
        $clients.push(remote_ip)
        puts remote_ip
        $players.push(Player.new($c))     
        $players[$clients.index(remote_ip)].warp(500,350)
        $cooldown.push(60)       
        $c+=1
      end
      if $clients.include?(remote_ip) then
         if msg=="update" then
            #puts "upaaaa"
            #puts $player[0].x.to_s
            msg=""
            begin
              $players.each{|i| 
                if i.lives>0 then
                  msg+="pl|"+i.id.to_s+"|"+i.x.to_s+"|"+i.y.to_s+"|"+i.angle.to_s+"|"
                end
              }
              #puts msg
              pl=$projectiles
              pl.each{|ii| msg+="pr|"+ii.id.to_s+"|"+ii.x.to_s+"|"+ii.y.to_s+"|"+ii.angle.to_s+"|"}
              $asteroids.each{|iii| msg+="as|"+iii.x.to_s+"|"+iii.y.to_s+"|"+iii.angle.to_s+"|"}
            rescue Exception => e
              puts e
            end
            #puts msg
            #puts msg  
            client.puts msg
         else
             if msg=="up" then
              $players[$clients.index(remote_ip)].accelerate()
              #puts "up"+$players[$clients.index(remote_ip)].y.to_s
             end
             if msg=="left" then
              $players[$clients.index(remote_ip)].turn_left()
             end
             if msg=="right" then
              $players[$clients.index(remote_ip)].turn_right()
             end
             if msg=="space" then
              if $cooldown[$clients.index(remote_ip)] >= 25 then
                $projectiles.push(Projectile.new($players[$clients.index(remote_ip)]))
                $cooldown[$clients.index(remote_ip)]=0
                #puts $projectiles.count()
              end
             end
         end           
      end
      if $servers.include?(remote_ip) then
        if msg=="update"
          msg=""
          i=0
          while i<$clients
            msg+="cl|"
            msg+=$clients[i]+"|"
            msg+=$players[i].x.to_s+"|"
            msg+=$players[i].y.to_s+"|"
            msg+=$players[i].angle.to_s+"|"
            i+=1
          end
          i=0
          while i<$clients
            msg+="cl|"
            msg+=$clients[i]+"|"
            msg+=$players[i].x.to_s+"|"
            msg+=$players[i].y.to_s+"|"
            msg+=$players[i].angle.to_s+"|"
            i+=1
          end
          msg+="asn|"+$asteroid_count.to_s+"|"
          i=0
          while i<$projectiles
            msg+="cl|"
            msg+=$proyectiles[i].id.to_s+"|"
            msg+=$proyectiles[i].x.to_s+"|"
            msg+=$proyectiles[i].y.to_s+"|"
            msg+=$proyectiles[i].angle.to_s+"|"
            i+=1
          end
          client.puts(msg)
        end
      end
    rescue Exception => e
      puts e
    end
      client.close
    end
end
#  end

# class GameWindow < Gosu::Window

#   def initialize
#     super(1000, 700, false) #Creacion Pantalla
#     @game_in_progress = false
#     @menu_principal = false
#     self.caption = "Asteroids Redes" #Titulo Pantalla
#     @font = Gosu::Font.new(self, "assets/victor-pixel.ttf", 34)
#   end

#   def setup_game
#     #@player[]# = Player.new
#     #@player.warp(500, 350)
#     @game_in_progress = true
#     @menu_principal = false
#     @level = 1 #Nivel dificultad del juego
#     #@$projectiles = []
#     @cooldown = 60 #Espacios que recorre una bala antes de podes disparar otra
#     #@asteroid_count = 3

#     #@asteroids = Asteroid.spawn(@asteroid_count)
#   end

#   def Start_Screen
#   end
#   #--------------------------------------#
#   def update

#     # if Gosu::button_down? Gosu::KbQ #Salir con tecla Q
#     #   close
#     # end
#     # if button_down? Gosu:: KbP
#     #   setup_game unless @game_in_progress
#     # end
#     # if button_down? Gosu::KbM
#     #   @menu_principal = true
#     #   @game_in_progress = false
#     # end

#     # if @player #si existe jugador permite moverlo
#     #   if Gosu::button_down? Gosu::KbSpace then
#     #     if @cooldown < 25 #es el cooldown para que se pueda disparar, solo se puede cuando @cooldown > 25
#     #     else
#     #       @$projectiles << Projectile.new(@player)
#     #       @cooldown = 0
#     #     end
#     #   end

#     #   if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
#     #     @player.turn_left
#     #   end
#     #   if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
#     #     @player.turn_right
#     #   end
#     #   if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
#     #     @player.accelerate
#     #   end
#     #   ################--->>>
#     #   @cooldown += 1 #Para el conteo que vuelve a permitir disparar
#       unless $player.empty?
#          $player[0].move
#       end
#       # @$projectiles.each {|projectile| projectile.move}
#       # @$projectiles.reject!{|projectile| projectile.dead?} #no elimina todos los proyectiles que dead? = false

#       # @asteroids.each {|asteroid| asteroid.move}
#       # deteccion_colisiones
#       ################--->>>
#     end

#   end

#   #--------------------------------------#
# #end
# #........................................#
# window = GameWindow.new
# window.show
