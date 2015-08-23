require File.join( File.dirname( __FILE__ ), "spec_helper" )

class RepeaterHub < Controller
	def packet_in dpid, message
		send_flow_mod_add(
			dpid,
			:match => ExactMatch.from(message),
			:actions => ActionOutput.new( OFPP_FLOOD )
		)
		send_packet_out(
			dpid,
			:packet_in => message,
			:actions => ActionOutput.new(OFPP_FLOOD)
		)
	end
end

describe RepeaterHub do
#	it "transports incoming packets to all other ports" do
#		pending "to fix later"
		around do | example |
		network {
			vswitch("switch") { dpid "0xabc" }
			vhost("host1") { promisc "on"; ip "192.168.0.1" }
			vhost("host2") { promisc "on"; ip "192.168.0.2" }
			vhost("host3") { promisc "on"; ip "192.168.0.3" }
			link "switch", "host1"
			link "switch", "host2"
			link "switch", "host3"
		}.run(RepeaterHub){
			example.run
		}
		end

		it "transports incoming packets to all other ports" do
			send_packets "host1", "host2"
		
			expect(vhost( "host2" ).stats( :rx ).n_pkts).to eq 1
			expect(vhost( "host3" ).stats( :rx ).n_pkts).to eq 1
		
		end

		it "add flow entry scattering packets on switchess" do
                        send_packets "host1", "host2"

                        expect(vswitch("switch").flows).to be_truthy
                        expect(vswitch("switch").flows.first.actions).to eq  "FLOOD"

			flow = vswitch("switch").flows.first                
			expect(flow.nw_src).to eq "192.168.0.1"
			expect(flow.nw_dst).to eq "192.168.0.2"

			#expect(vswitch("switch").flows.first.nw_src).to eq "192.168.0.1"
                        #expect(vswitch("switch").flows.first.nw_dst).to eq "192.168.0.2"
		end
end
