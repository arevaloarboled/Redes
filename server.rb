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
def broadcast(data)
  begin
   addr = [$dirbroadcast, 9122]# broadcast address
   #addr = ('255.255.255.255', 33333) # broadcast address explicitly [might not work ?]
   #addr = ['127.0.0.255', 33333] # ??
   u1 = UDPSocket.new
   u1.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
   u1.send(data, 0, addr[0], addr[1])
   #puts data
   u1.close
  rescue Exception => e
   puts "broadcast error"
   puts e 
  end
end
$IP=myip()
$socket = TCPServer.open($IP,9123)
#$socket_ali = TCPServer.open("localhost",9123)
$servers=["192.168.250.214","192.168.250.38"]
$dirbroadcast="192.168.250.255"
$clients=[]
$players=[]
$projectiles=[]
$asteroids=[]
$cooldown=[]
$asteriod_count=3
$level=1
$c=0
#$tim=0
$asteroids=Asteroid.spawn($asteriod_count)
# timer=Thread.new do 
#   loop do
#     $time+=1
#   end
# end
portconect=Thread.new do
  s = TCPServer.open($IP,9121)
  loop { 
    begin
      loop { 
        Thread.start(s.accept) do |q|
          q.close()
        end
      }
    rescue Exception => e
      puts e
    end
  }
end
syncro=Thread.new do
  loop { 
    begin
      server = UDPSocket.new
      server.bind($IP,9122)
      BasicSocket.do_not_reverse_lookup = true
      msg, addr=server.recvfrom(2048)
      l=msg.split("|")
      remote_ip=l[0]
      msg=l[1]
      if !($clients.include?(remote_ip)) and msg=="hola"  and  $c<4 then
        #puts "suave "+msg
        $clients.push(remote_ip)
        puts remote_ip
        $players.push(Player.new($c))     
        $players[$clients.index(remote_ip)].warp(500,350)
        $cooldown.push(60)       
        $c+=1
        #broadcast(remote_ip+"|hola")
      end
      if $clients.include?(remote_ip) then
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
       #broadcast(remote_ip+"|"+msg)
      end
      if remote_ip=="update"
        $players=[]
        $asteroids=[]
        $projectiles=[]
        i=1
        while i<l.count
          if l[i]=="pl"
            $players.push(Player.new(l[i+1].ord-47))
            $players[l[i+1].ord-47].x=l[i+2].to_f
            $players[l[i+1].ord-47].y=l[i+3].to_f
            $players[l[i+1].ord-47].angle=l[i+4].to_f
            $players[l[i+1].ord-47].score=l[i+6].to_f
            $players[l[i+1].ord-47].lives=l[i+5].to_f
            i=i+7
            next
          end
          if l[i]=="as"
            $asteroids.push(Asteroid.new("Large"))
            $asteroids[$asteroids.count-1].x=l[i+1].to_f
            $asteroids[$asteroids.count-1].y=l[i+2].to_f
            $asteroids[$asteroids.count-1].angle=l[i+3].to_f
            i=i+4
            next
          end
          if l[i]=="pr"
            $projectiles.push(l[i+1].ord-47)
            $projectiles[$projectiles.count-1].x=l[i+1].to_f
            $projectiles[$projectiles.count-1].y=l[i+2].to_f
            $projectiles[$projectiles.count-1].angle=l[i+3].to_f
            i=i+4
            next
          end
          i+=1
        end             
      end           
      server.close
    rescue Exception => e
      puts e
    end
  }
end
#........................................#

def colision?(obj1, obj2) #deteccion de colisiones entre dos objetos
  hitbox_1, hitbox_2 = obj1.hitbox, obj2.hitbox
  common_x = hitbox_1[:x] & hitbox_2[:x]
  common_y = hitbox_1[:y] & hitbox_2[:y]
  common_x.size > 0 && common_y.size > 0
end
#--------------------------------------#
def deteccion_colisiones
  begin
    $asteroids.each do |asteroid|
      #$players.each do |player|
        $projectiles.each do |projectile|
          if colision?(asteroid, projectile) and $players[projectile.id].lives>0 then
            $players[projectile.id].score += asteroid.points
            projectile.kill
            $asteroids += asteroid.kill
          end
        end
      #end
    end
    $asteroids.each do |asteroid|
      $players.each do |player|
        if colision?(asteroid, player)
          player.kill
          asteroid.kill
        end
      end
    end
    $players.each do |player|
      $projectiles.each do |projectile|
        if colision?(projectile, player) and projectile.id!=player.id
          player.kill
          projectile.kill
        end
      end
    end
  rescue Exception => e
    puts e
  end
end
#--------------------------------------#
def level_up
  $asteroid_count += 1
  $level += 1
  $asteroids = Asteroid.spawn(@asteroid_count)
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
        if $asteroids.count==0
          $asteriod_count+=1
          $asteroids=Asteroid.spawn($asteriod_count)
        end
      rescue Exception => e
        puts "thread error"
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
      # if $tim<1000000
      #   msg=""
      #   i=0
      #   while i<$clients
      #     msg+="cl|"
      #     msg+=$clients[i]+"|"
      #     msg+=$players[i].x.to_s+"|"
      #     msg+=$players[i].y.to_s+"|"
      #     msg+=$players[i].angle.to_s+"|"
      #     i+=1
      #   end
      #   i=0
      #   while i<$clients
      #     msg+="cl|"
      #     msg+=$clients[i]+"|"
      #     msg+=$players[i].x.to_s+"|"
      #     msg+=$players[i].y.to_s+"|"
      #     msg+=$players[i].angle.to_s+"|"
      #     i+=1
      #   end
      #   msg+="asn|"+$asteroid_count.to_s+"|"
      #   i=0
      #   while i<$projectiles
      #     msg+="cl|"
      #     msg+=$proyectiles[i].id.to_s+"|"
      #     msg+=$proyectiles[i].x.to_s+"|"
      #     msg+=$proyectiles[i].y.to_s+"|"
      #     msg+=$proyectiles[i].angle.to_s+"|"
      #     i+=1
      #   end
      #   broadcast(msg)
      # else
      #   begin
      #     Timeout.timeout(1) do
      #       server = UDPSocket.new
      #       server.bind($IP,9122)
      #       BasicSocket.do_not_reverse_lookup = true
      #       msg, addr=server.recvfrom(2048)
      #       server.close
      #       puts msg
      #       $clients=[]
      #       $players=[]
      #       $projectiles=[]
      #       $asteroids=[]
      #       $cooldown=[]
      #       $asteriod_count=3
      #       $level=1
      #       $c=0
      #       l=msg.split("|")
      #       i=0
      #       while i<l.count 
      #         if l[i]=="cl"
      #           $clients.push(l[i+1])
      #           $players.push(Player.new($c))
      #           $c+=1
      #           $players[$players.count()-1].x=l[i+2].to_f
      #           $players[$players.count()-1].y=l[i+3].to_f
      #           $players[$players.count()-1].angle=l[i+4].to_f
      #           $cooldown.push(0)
      #           #$players[$players.count()-1].x=l[i+1].to_f
      #           i=i+5
      #           next
      #         end
      #         if l[i]=="asn"
      #           $asteriod_count=l[i+1].to_d
      #           i=i+2
      #           next
      #         end
      #         if l[i]=="as"
      #           $asteroids.push(Asteroids.new(l[i+1]))
      #           $asteroids[$asteroids.count()-1].x=l[i+2].to_f
      #           $asteroids[$asteroids.count()-1].y=l[i+3].to_f
      #           $asteroids[$asteroids.count()-1].angle=l[i+4].to_f
      #           i=i+5
      #           next
      #         end
      #         if l[i]=="pr"
      #           $projectiles.push(Projectile.new(l[i+1].to_f))                
      #           $projectiles[$projectiles.count()-1].x=l[i+2].to_f
      #           $projectiles[$projectiles.count()-1].y=l[i+3].to_f
      #           $projectiles[$projectiles.count()-1].angle=l[i+4].to_f
      #           i=i+5
      #           next
      #         end
      #         i=i+1
      #       end
      #     end
      #   rescue Timeout::Error, Errno::ETIMEDOUT,Errno::ENETUNREACH,Exception=>e
      #     puts "Error in gets udp syncronize"
      #     if e
      #       puts e
      #     end
      #   end
      # end
      k=0
    end
    k=k+1
  end
end
loop do
  begin
    Thread.start($socket.accept) do |client|
      begin
        #$tim=0
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
          broadcast(remote_ip+"|hola")
        end
        if $clients.include?(remote_ip) then
           if msg=="update" then
              #puts "upaaaa"
              #puts $player[0].x.to_s
              msg=""
              begin
                $players.each{|i| 
                  #if i.lives>0 then
                    msg+="pl|"+i.id.to_s+"|"+i.x.to_s+"|"+i.y.to_s+"|"+i.angle.to_s+"|"+i.lives.to_s+"|"+i.score.to_s+"|"
                  #end
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
              #broadcast("update|"+msg)
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
               broadcast(remote_ip+"|"+msg)
           end           
        end
      rescue Exception => e
        puts "thread client error"
        puts e
      end
      client.close
    end
  rescue Exception => e
    puts e
  end
end