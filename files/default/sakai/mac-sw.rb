class PatchPanel < Controller
	def start
		@patch = []
			#File.open( "./mac-sw.conf" ).each_line do | each |
			#if /^(\d+)\s+(\d+)$/=~ each
			#if /^(\.*)\s+(\.*)$/=~ each
				#@patch << [ $1.to_s, $2.to_s ]
			@patch << [ "b0:c7:45:5f:52:14", "cc:7e:e7:5e:56:a0" ]		
			#end
		#end
	end

	def switch_ready( datapath_id )
		@patch.each do | mac_a, mac_b |
			make_patch datapath_id, mac_a, mac_b
		end
	end

	private 

	def make_patch( datapath_id, mac_a, mac_b )
		send_flow_mod_add(
			datapath_id,
			:match => Match.new( :in_port => 1, :dl_type => 0x0800, :nw_proto => 1, :dl_src => mac_a, :dl_dst => mac_b, :nw_src => "192.168.1.2/24", :nw_dst => "192.168.1.200/24" ), 
			#:match => Match.new( :dl_src => mac_a ),
			:actions => SendOutPort.new( 3 )
		)
		#send_flow_mod_add(
                #        datapath_id,
                #        :match => Match.new( :dl_type => 0x0800, :dl_dst => mac_b ),
			#:match => Match.new( :dl_dst => mac_b ),
                #        :actions => SendOutPort.new( 3 )
                #)
		send_flow_mod_add(
			datapath_id,
			:match => Match.new( :in_port => 3, :dl_type => 0x0800, :nw_proto => 1, :dl_src => mac_b, :dl_dst => mac_a, :nw_src => "192.168.1.200/24", :nw_dst => "192.168.1.2/24" ),
			#:match => Match.new( :dl_src => mac_b ),
			:actions => SendOutPort.new( 1 )
		)
		#send_flow_mod_add(
                #        datapath_id,
	#		:match => Match.new( :dl_type => 0x0800, :dl_dst => mac_a ),                        
			#:match => Match.new( :dl_dst => mac_a ),
                #        :actions => SendOutPort.new( 1 )
                #)
	end
end

