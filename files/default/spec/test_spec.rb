require File.join( File.dirname( __FILE__ ), "spec_helper" )


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
macsa2 = "00:00:00:00:00:04"		
action = create_action_from( macsa2, ipsa, port_no )

		send_flow_mod_add(
			#match_fields = Match.new( eth_type: "0x0800"

			dpid,
			:match => ExactMatch.from( message ),
#			:match => Match.from(message),
#			:match => Match.new( match_fields ),
			:actions => action
		)

               send_flow_mod_add(
                        #match_fields = Match.new( eth_type: "0x0800"

                        dpid,
#			:data => message.data,
                        :match => Match.from( message ),
#                       :match => Match.from(message),
#                       :match => Match.new( match_fields ),
                        #:actions => action
			:actions => SendOutPort.new( message.in_port )
                )


end

def packet_out( dpid, message, port_no )
		
ipsa = "192.168.0.4"
macsa2 = "00:00:00:00:00:04"
action = create_action_from( macsa2, ipsa, port_no )
		
		send_packet_out(
			dpid,
			:data => message.data,
#			:packet_in => message,
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
#			SendOutPort.new( port_no )			
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

describe ModifingSw do
#		pending "to fix later"
		around do | example |
		network {
			vswitch("switch") { dpid "0xabc" }
			vhost("host1") { promisc "off"; ip "192.168.0.1"; mac "00:00:00:00:00:01" }
			vhost("host2") { promisc "off"; ip "192.168.0.2"; mac "00:00:00:00:00:02" }
			vhost("host3") { promisc "off"; ip "192.168.0.3"; mac "00:00:00:00:00:03" }
			link "switch", "host1"
			link "switch", "host2"
			link "switch", "host3"
		}.run(ModifingSw){
			example.run
		}
		end

		it "add flow entry modifing src mac" do
                        send_packets "host1", "host2"

                        expect(vswitch("switch").flows).to be_truthy
#                        expect(vswitch("switch").flows.first.actions).to eq  "FLOOD"

#			flow = vswitch("switch").flows.first                
#			expect(flow.nw_src).to eq "192.168.0.1"
#			expect(flow.nw_dst).to eq "192.168.0.2"

#			expect(flow.dl_src).to eq "00:00:00:00:00:03"
#			expect(flow.dl_dst).to eq "00:00:00:00:00:02"

			#expect(vswitch("switch").flows.first.nw_src.should).to eq "192.168.0.3"
#                        expect(vswitch("switch").flows.first.nw_dst.should).to eq "192.168.0.2"

			expect(vswitch("switch").flows[0].actions).to match(/00:00:00:00:00:04/)
			expect(vswitch("switch").flows[0].actions).to match(/192.168.0.4/)
			
			#expect(vswitch("switch").flows[0].actions.should).to eq "mod_dl_src:00:00:00:00:00:03/FLOOD"
#			expect(vswitch("switch").flows.first.dl_src.should).to eq "00:00:00:00:00:04"
 #                       expect(vswitch("switch").flows.first.dl_dst.should).to eq "00:00:00:00:00:02"

		end

		it "transports round-trip packets from host1 to host2 " do
                        send_packets "host1", "host2"
			send_packets "host1", "host2"

                        expect(vhost( "host2" ).stats( :rx ).n_pkts).to eq 2
			expect(vhost( "host1" ).stats( :rx ).n_pkts).to eq 2                        
			expect(vhost( "host3" ).stats( :rx ).n_pkts).to eq 0



                end

#		it "transports going back packets from host2 to host1 " do
#                        send_packets "host1", "host2"
#                        send_packets "host1", "host2"
#
#                        expect(vhost( "host2" ).stats( :rx ).n_pkts).to eq 2
#                        expect(vhost( "host3" ).stats( :rx ).n_pkts).to eq 0
#
#
#
#                end


end
