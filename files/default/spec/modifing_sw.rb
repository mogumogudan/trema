class ModifingSw < Controller

	def start

		@fdb = {}

	end

	def packet_in( dpid, message )

		@fdb[ message.macsa ] = message.in_port
		port_no = @fdb[ message.macda ]

		#macda = message.dl_dst
#		macsa = "00:00:00:00:00:01"
##		macsa2 = "00:00:00:00:00:04"
#		macdst = "00:00:00:00:00:02"
##		ipsa = "192.168.0.4"
#		ip_DST = "192.168.0.2"
#		ip_SRC = "192.168.0.1"
		#e_TYPE = "0x0800"

		#match_all = ExactMatch.from( message )
		#action = create_action_from( macsa2, ipsa )
		#match_fields = { :nw_src => ip_SRC, :nw_dst => ip_DST, :dl_src => macsa, :dl_dst => macdst }	
		#interface = @interfaces.find_by_port_and_ipaddr( port, daddr )		

flow_mod dpid, message, port_no
packet_out dpid, message, port_no

end

def flow_mod( dpid, message, port_no )

ipsa = "192.168.0.4"
#macsa2 = "00:00:00:00:00:04"		
macsa2 = "00:0B:97:57:07:6B"
action = create_action_from( macsa2, ipsa, port_no )

		send_flow_mod_add(
			#match_fields = Match.new( eth_type: "0x0800"

			dpid,
			:match => ExactMatch.from( message ),
#			:match => Match.from(message),
#			:match => Match.new( match_fields ),
			:actions => action
		)
end

def packet_out( dpid, message, port_no )
		
ipsa = "192.168.0.4"
#macsa2 = "00:00:00:00:00:04"
macsa2 = "00:0B:97:57:07:6B"
action = create_action_from( macsa2, ipsa, port_no )
		
		send_packet_out(
			dpid,
##			:data => message.data,
			:packet_in => message,
			:actions => action
#			:actions => ActionOutput.new( OFPP_FLOOD )
		)
end



#private

	def create_action_from( macsa2, ipsa, port_no )
			#macsa2 = "00:00:00:00:00:03"
			#action = create_action_from( macsa2, macdst, ip_SRC, ip_DST )
			#match_fields = { :nw_src => ip_SRC, :nw_dst => ip_DST, :dl_src => macsa2, :dl_dst => macdst }

	 [	 
			
#			SetEthSrcAddr.new( "00:00:00:00:00:03" ),		
#			SendOutPort.new( OFPP_TABLE )
#			ActionOutput.new( OFPP_FLOOD ),
			SetEthSrcAddr.new( macsa2 ),
#			ActionOutput.from( :packet_in => message ),
			SetIpSrcAddr.new( ipsa ),
#			ActionOutput.new( OFPP_TABLE )
#			SetEthDstAddr.new( macdst ),
			ActionOutput.new( OFPP_FLOOD )
##			SendOutPort.new( port_no )			
#			match_all.new( :dl_src => macsa2  )
#SendOutPort()
#SetEthSrcAddr()
#SetEthDstAddr()
#SetIpSrcAddr()
#SetIpDstAddr()
#SetIpTos()
#SetTransportSrcPort()
#SetTransportDstPort()
#StripVlanHeader()
#SetVlanVid()
#SetVlanPriority()
     	]
	
end

end

