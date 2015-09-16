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

servers=[]

def pp
	my_ip=myip()
	dir=""
	cont=0
	ipp=my_ip.to_s
	ipv=ipp.split(".")
	ip=ipv[0]+"."+ipv[1]+"."+ipv[2]+"."
end

def broadcast()
	# ts=Thread.new do
	# 	# client = UDPSocket.new
	# 	# client.bind('0.0.0.0', 33333)
	# 	# data, addr = client.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
	# 	# puts "From addr: '%s', msg: '%s'" % [addr.join(','), data]
	# 	s = UDPSocket.new
	# 	s.bind('0.0.0.0',3000)
	# 	loop { 
	# 		print "hola"
	# 		if myip!="ERROR!"
	# 			data, addr = s.recvfrom(1024)
	# 			puts "From addr: '%s', msg: '%s'" % [addr.join(','), data]
	# 			l=data.split(" ")
	# 			servers.push(l[0])
	# 		end
	# 	}
	# end
	# tr=Thread.new do
	# loop { 
	# 		if servers.length ==0
	# 			socket = UDPSocket.open
	# 			socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
	# 			for i in (1..244)
	# 				print "hola"
	# 				socket.send(myip+" server", 0,pp+i.to_s , 3000)
	# 			end
	# 			socket.close
	# 		end
	# }
	# end
	# ts.join		
	output='nmap '+pp+'* -p 9122'
	print "#{output}"
end

ip=pp
puts ip
t1=Thread.new{broadcast}

server = TCPServer.open(9122)  # Socket to listen on port 9122
loop {
	begin
	  client = server.accept       # Wait for a client to connect
	  client.puts(Time.now.ctime)  # Send the time to the client
	  client.puts "Closing the connection. Bye!"
	  client.close                 # Disconnect from the client
	rescue Errno::ECONNRESET
		sleep(1)
		puts "DISCOVERY! CHANNEL!"
	end                         # Servers run forever
}	
print "miow\n"
