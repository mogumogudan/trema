require File.join( File.dirname( __FILE__ ), "spec_helper" )


class LearningSw < Controller

	def start

		@fdb = {}

	end

	def packet_in( datapath_id, message )

			@fdb[ message.macsa ] = message.in_port
			port_no = @fdb[ message.macda ]


		if port_no
			flow_mod datapath_id, message, port_no
			packet_out datapath_id, message, port_no

		else
			flood datapath_id, message
		end

	end

private

	def flow_mod( datapath_id, message, port_no )

		port01 = port_no
		srcmac01 = "00:00:00:00:00:10"
		srcip01 = "192.168.0.10"
		action01 = create_action_from( srcmac01, srcip01, port01 )

		send_flow_mod_add(
			datapath_id,
			:match => ExactMatch.from( message ),
			:actions => action01
#			:actions => SendOutPort.new( port_no )
			
		)
	end

	def packet_out( datapath_id, message, port_no )

		port = port_no
		srcmac02 = "00:00:00:00:00:10"
		srcip02 = "192.168.0.10"
		action02 = create_action_from( srcmac02, srcip02, port )
		
		send_packet_out(
			datapath_id,
			:packet_in => message,
			#:actions => SendOutPort.new( port_no )
			:actions => action02
		)
	end

	def flood( datapath_id, message )
		packet_out datapath_id, message, OFPP_FLOOD
	end

        def create_action_from( srcmac, srcip, port )
		[
                       SetEthSrcAddr.new( srcmac ),
##                        SetIpSrcAddr.new( srcip ),
##                       # ActionOutput.new( port_no )
                        SendOutPort.new( port )
                ]
       end




end


describe LearningSw do
#		pending "to fix later"
		around do | example |
		network {
			vswitch("switch") { datapath_id "0xabc" }
			vhost("host1") { promisc "off"; ip "192.168.0.1"; mac "00:00:00:00:00:01" }
			vhost("host2") { promisc "off"; ip "192.168.0.2"; mac "00:00:00:00:00:02" }
			vhost("host3") { promisc "off"; ip "192.168.0.3"; mac "00:00:00:00:00:03" }
			link "switch", "host1"
			link "switch", "host2"
			link "switch", "host3"
		}.run(LearningSw){
			example.run
		}
		end

		it "add flow entry modifing src mac" do
                        send_packets "host1", "host2"

                        expect(vswitch("switch").flows).to be_truthy
                        expect(vswitch("switch").flows.first.actions).to eq("FLOOD")
#			flow = vswitch("switch").flows.first                
#			expect(flow.nw_src.should).to eq "192.168.0.10"

#			expect(vswitch("switch").flows.).to match(/00:00:00:00:00:10/)
			#expect(vswitch("switch").flows[0].actions).to match(/192.168.0.10/)

		end

		it "transports round-trip packets from host1 to host2 " do
                        send_packets "host1", "host2"
			send_packets "host2", "host1"

                        expect(vhost( "host2" ).stats( :rx ).n_pkts).to eq 1
			expect(vhost( "host1" ).stats( :rx ).n_pkts).to eq 1                        
			expect(vhost( "host3" ).stats( :rx ).n_pkts).to eq 0



                end
end
