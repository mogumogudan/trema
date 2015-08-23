#
# Cookbook Name:: trema
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

##MEMO
# 1) To implement "patch panel", lay out "patch-panel.conf" "patch-panel.rb" in the same folder,
#    issue command below
#
#     trema run ./patch-panel.rb
#
#     trema run /apps/show_switch_features/show-switch-features.rb
#
#	telnet 192.168.1.1 and set trema-sv ip at /etc/config/openflow
#	sudo ufw disable
#	trema run ./patch-panel.rb -d
#	trema run /apps/flow_dumper/flow-dumper.rb 
#
#     IP setting as follows     
#     openflow sw: 192.168.50.1, 
#     MAC AIR NIC: 192.168.50.10
#     trema on vagrant: 192.168.50.100
#
#

### install pakages ###

%w{gcc make ruby1.8 rubygems1.8 ruby1.8-dev irb libpcap-dev libsqlite3-dev git sqlite3 libdbi-perl libdbd-sqlite3-perl libwww-Perl }.each do |pkg|
package pkg do
 case pkg
        when "gcc"
                action :install
                #version ""
        when "make"
                action :install
                #version ""
        when "ruby1.8"
                action :install
                #version "1.9.3"
        when "rubygems1.8"
                action :install
                #version ""
        when "ruby1.8-dev"
                action :install
                #version ""
        when "irb"
                action :install
                #version ""
        when "libpcap-dev"
                action :install
                #version ""
        when "libsqlite3-dev"
                action :install
                #version ""
        when "git"
                action :install
                #version ""
        when "sqlite3"
                action :install
                #version ""
        when "libdbi-perl"
                action :install
                #version ""
        when "libdbd-sqlite3-perl"
                action :install
                #version ""
        when "libwww-Perl"
                action :install
                #version ""
 end
end
end

### install trema and rspec###

bash "trema install" do
                user 'root'
                code <<-EOL
                        sudo gem install trema -v 0.3.0
                	git clone https://github.com/trema/apps.git
			sudo gem install rspec	
	EOL
end

