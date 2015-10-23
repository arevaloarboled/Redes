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

$servers=[]
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
	data = 'client|'+myip
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
			if !$servers.include?(addr[3]) and tmp[0]!='client'
				$servers.push(tmp[1])
				puts "From addr: '%s', msg: '%s'" % [addr[3], data]
				puts $servers
				$servers.sort
				u1 = UDPSocket.new
				#u1.connect(addr[3],9122)
				data = 'client|'+myip
				u1.send data,0,addr[3],9122
				u1.close
				#u2.send('client|'+myip,0,addr[3],port)
				#broadcast_wakeup
			end
		}
		u2.close
	end
	ts.join		
	#output='nmap '+pp+'* -p 9122'
	#print "#{output}"
end

def client
	loop{
		begin
			if !$servers.empty?
				puts "miow"
				s = TCPSocket.open($servers[0], 9123)
				c1=Thread.new{client_recv(s)}
				c2=Thread.new{client_send(s)}
				c1.join
			end
		rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT,Errno::ENETUNREACH
			$servers.delete_at(0)
		end
	}
	puts "safsafsd"
end

def client_recv(s)
	loop{
		while line = s.gets # Read lines from socket
		  puts line         # and print them
		end
	}
	s.close  
end

def client_send(s)
	loop{
		puts "hola"
		msg=gets
		s.puts(msg)
	}
	puts "sfa"
	s.close
end

def connection
	b=false
	loop{
		if myip==$iplocal
			if b
				broadcast_wakeup
			end
			b=false
			#puts myip
		else
			b=true
			puts "ERROR IN CONNECTION TO INTERNET"
		end
	}
end

$iplocal=myip
ip=pp
puts ip
t1=Thread.new{broadcast}
t2=Thread.new{client}
t3=Thread.new{connection}
#t1.join
loop{
	if myip==$iplocal
		#puts myip
	else
		puts "ERROR IN CONNECTION TO INTERNET"
	end
}
print "miow\n"
