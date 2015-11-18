require 'gosu'
require './libs/Player.rb'
require './libs/Projectile.rb'
require './libs/Asteroid.rb'
#require './libs/socket.rb'
require 'thread'
require 'socket'

#........................................#

#$socket = TCPServer.open("localhost",9123)
client = UDPSocket.new
client.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
client.bind("192.168.250.38", 9123)
$clients=[]
$player=[]
$projectiles=[]
$asteroids=[]
#$server=Thread.new do 
t=Time.now
$c=0
tread=Thread.new do
  loop do
    #puts ((Time.now-t)*1000).to_i
    #if ((Time.now-t)*1000).to_i%1==0
      #puts "tik!"
    #if $c==6
      if !($player.empty?)
        $player[0].move
      end
    #  $c=0
    #end
    #$c=$c+1
  end
end
loop do
  #Thread.start($socket.accept) do |client|
      #puts "me llego :3"
      msg,addr=client.recvfrom(1024)
      #sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
      #puts "mesagge: '%s' from: '%s' " % [msg,remote_ip]
      remote_ip=addr[3]
      if !($clients.include?(remote_ip)) and msg=="hola" then
        #puts "suave "+msg
        $clients.push(remote_ip)
        $player.push(Player.new)     
        $player[$clients.index(remote_ip)].warp(500,350)       
      end
      if $clients.include?(remote_ip) 
         if msg=="update"
            #puts "upaaaa"
            #puts $player[0].x.to_s
            msg="pl|"+$player[0].x.to_s+"|"+$player[0].y.to_s+"|"+$player[0].angle.to_s
            #puts msg
            #client.puts msg
            client.send msg,0,$addr[3],9123
         else
             if msg=="up" 
              $player[$clients.index(remote_ip)].accelerate
             end
             if msg=="left" 
              $player[$clients.index(remote_ip)].turn_left
             end
             if msg=="right" 
              $player[$clients.index(remote_ip)].turn_right
             end
         end           
      end
      #client.close
    #end
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
