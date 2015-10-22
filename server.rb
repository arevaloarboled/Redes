require 'socket'
require 'thread'
def myip
	begin
		return UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
	rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH
		sleep(1)
		return "ERROR!"
	end
end

$clients=[]
$iplocal 

def pp
	my_ip=myip()
	dir=""
	cont=0
	ipp=my_ip.to_s
	ipv=ipp.split(".")
	ip=ipv[0]+"."+ipv[1]+"."+ipv[2]+"."
end

def broadcast_wakeup()
	addr = [pp+'255', 9122]# broadcast address
	#addr = ('255.255.255.255', 33333) # broadcast address explicitly [might not work ?]
	#addr = ['127.0.0.255', 33333] # ??
	u1 = UDPSocket.new
	u1.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
	data = 'server|'+myip
	u1.send(data, 0, addr[0], addr[1])
	u1.close
end

def broadcast()
	broadcast_wakeup
	ts=Thread.new do
		port=9122
		addr = [myip, port]  # host, port
		##BasicSocket.do_not_reverse_lookup = true
		# Create socket and bind to address
		u2 = UDPSocket.new
		u2.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
		u2.bind(addr[0], addr[1])
		loop{
			data, addr = u2.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you #=> ["uuuu", ["AF_INET", 33230, "localhost", "127.0.0.1"]]
			tmp=data.split("|")
			if !$clients.include?(addr[3]) and tmp[0]!='server'
				$clients.push(tmp[1])
				puts "From addr: '%s', msg: '%s'" % [addr[3], data]
				puts $clients
				#u2.send('server|'+myip,0,addr[3],port)
				broadcast_wakeup
			end
		}
		u2.close
	end
	ts.join		
	#output='nmap '+pp+'* -p 9122'
	#print "#{output}"
end

def server
	loop{
		begin
			if !$clients.empty?
				s = TCPSocket.open(9123)
				clien=[]
				loop{
					Thread.start(s.accept) do | client |
						clien.push(client)
						loop{
							msg=client.gets.chomp
							clien.each do | cli |
								unless cli==client
									cli.puts "%s" % [msg]
								end
							end
						}
					end
				}
				s.close  
			end
		rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH
			loop{
				if myip==$iplocal
					break
				end
			}
			broadcast_wakeup
		end
	}
end

$iplocal=myip
ip=pp
puts ip
t1=Thread.new{broadcast}
t2=Thread.new{server}
#t1.join
loop{
	if myip==$iplocal
		#puts myip
	else
		puts "ERROR IN CONNECTION TO INTERNET"
	end
}
print "miow\n"
