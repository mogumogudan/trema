class PatchPanel < Controller

	def switch_ready( datapath_id )
			make_patch datapath_id
	
	end

	private 

	def make_patch( datapath_id )
		send_flow_mod_delete(
			datapath_id
		)
	end
end

