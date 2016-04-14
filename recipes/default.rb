include_recipe 'aws'
include_recipe 'cassandra-dse::default'
include_recipe 'ntp::default'
include_recipe 'yum'
include_recipe 'zip'
include_recipe 'snmp'
package 'curl'
package 'sudo'
package 'bash'

execute 'agent_install' do
  command "curl --silent --show-error --header 'x-connect-key: 23ac4593ef138f4ce9e4ab5601fac505ea371c13' 'https://kickstart.jumpcloud.com/Kickstart' | sudo bash"
path [ '/sbin', '/bin', '/usr/sbin', '/usr/bin' ]
timeout 600
creates '/opt/jc'
end
directory '/home/ec2-user/.aws' do
  mode '0775'
  action :create
end

template '/home/ec2-user/.aws/config' do
  source 'config.erb'
  owner 'ec2-user'
  group 'ec2-user'  
  mode '0600'
  action :create
end

directory '/root/.aws' do
  mode '0775'
  action :create
end

template '/root/.aws/config' do
  source 'config.erb'
  owner 'root'
  group 'root'  
  mode '0600'
  action :create
end
	
node['aws-tag']['tags'].each do |key,value|
	execute 'add_tags' do
		command "aws ec2 create-tags --resources $(curl http://169.254.169.254/latest/meta-data/instance-id) --tags Key=#{key},Value=#{value}"
		action :run
	end
end

yum_package 'perl-DateTime' do
  action :install
end

yum_package 'perl-Sys-Syslog' do
  action :install
end

yum_package 'perl-LWP-Protocol-https' do
  action :install
end

yum_package 'perl-Digest-SHA' do
  action :install
end

remote_file "#{node['cloudwatch_monitor']['home_dir']}/CloudWatchMonitoringScripts-#{node['cloudwatch_monitor']['version']}.zip" do
  source "#{node['cloudwatch_monitor']['release_url']}"
  owner "#{node['cloudwatch_monitor']['user']}"
  group "#{node['cloudwatch_monitor']['group']}"
  mode 0755 
  not_if { ::File.exists?("#{node['cloudwatch_monitor']['home_dir']}/CloudWatchMonitoringScripts-#{node['cloudwatch_monitor']['version']}.zip")}
end

execute 'unzip cloud watch monitoring scripts' do
    command "unzip #{node['cloudwatch_monitor']['home_dir']}/CloudWatchMonitoringScripts-#{node['cloudwatch_monitor']['version']}.zip"
    cwd "#{node['cloudwatch_monitor']['home_dir']}"
    user "#{node['cloudwatch_monitor']['user']}"
	group "#{node['cloudwatch_monitor']['group']}"
    not_if { ::File.exists?("#{node['cloudwatch_monitor']['home_dir']}/aws-scripts-mon")}
end

file "#{node['cloudwatch_monitor']['home_dir']}/CloudWatchMonitoringScripts-#{node['cloudwatch_monitor']['version']}.zip" do
  action :delete    
  not_if { ::File.exists?("#{node['cloudwatch_monitor']['home_dir']}/CloudWatchMonitoringScripts-#{node['cloudwatch_monitor']['version']}.zip")== false }
end

cron 'cloudwatch_schedule_metrics' do
  action :create 
  minute '*/5'
  user "#{node['cloudwatch_monitor']['user']}"
  home "#{node['cloudwatch_monitor']['home_dir']}/aws-scripts-mon"
  command "#{node['cloudwatch_monitor']['home_dir']}/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/var/lib/cassandra --from-cron"
end

r = resources(template: '/etc/snmp/snmpd.conf')
r.cookbook('cb-cassandra-dse')
r.source('snmpd.conf.erb')

if node['automated_testing'] == 'true'
	service 'cassandra' do
	  	action :stop
	end

	file '/var/log/cassandra/system.log' do
		action :delete
	end
	service 'cassandra' do
	  	action :start
	end
	file '/etc/cassandra/conf/testing.sh' do
		owner 'root'
		group 'root'
		content "#!/bin/bash
	if [ $(hostname) == 'automatedtest1' ]; then
		touch /etc/cassandra/conf/testing.log
		
		outfile=/etc/cassandra/conf/testing.log
		
		echo \"Time Started:\"  >> $outfile
		
		date >> $outfile
		
		nodes=( $(nodetool status | grep 'UN' | awk '{print $2}') )
		
		echo \"${nodes[@]}\" >> $outfile
		
		errorcount=0
		
		if [ ${#nodes[@]} -lt 3 ]; then
				
				((errorcount+=1))
		
				aws ses send-email --from \"automatedtest@cbsitedb.net\" --destination ToAddresses=\"sitedbcloud@careerbuilder.com,logicmonitorsitedb@careerbuildersitedb.pagerduty.com\" --subject \"Cassandra automated testing: Cassandra Failure\" --text \"There is a problem with the Cassandra Opsworks automated tests. One or more nodes has not joined the ring correctly. Please SSH into one of the following nodes 172.21.11.162, 172.21.12.84, or 172.21.13.47.  Contact josh.smith@careerbuilder.com or johnny.thomas@careerbuilder.com for help or information.\"
		
				echo \"Sent node email\" >> $outfile
		fi
		
		snmpwalk -Os -c public -v 2c 127.0.0.1 iso.3.6.1.2.1.1.1 >> $outfile
		
		if [ \"$?\" -ne \"0\" ]; then
				
				((errorcount+=1))
		
				aws ses send-email --from \"automatedtest@cbsitedb.net\" --destination ToAddresses=\"sitedbcloud@careerbuilder.com,logicmonitorsitedb@careerbuildersitedb.pagerduty.com\" --subject \"Cassandra automated testing: SNMP Failure\" --text \"There is a problem with the Cassandra Opsworks automated tests. SNMP did not get setup correctly. Please SSH into one of the following nodes 172.21.11.162, 172.21.12.84, or 172.21.13.47.  Contact josh.smith@careerbuilder.com or johnny.thomas@careerbuilder.com for help or information.\"
		
						echo \"Sent snmp email\" >> $outfile

		fi

		ntpstat 
		
		if [ \"$?\" -ne \"0\" ]; then
				
				((errorcount+=1))
				
				aws ses send-email --from \"automatedtest@cbsitedb.net\" --destination ToAddresses=\"sitedbcloud@careerbuilder.com,logicmonitorsitedb@careerbuildersitedb.pagerduty.com\" --subject \"Cassandra automated testing: NTP Failure\" --text \"There is a problem with the Cassandra Opsworks automated tests. NTP is not synching correctly. Please SSH into one of the following nodes 172.21.11.162, 172.21.12.84, or 172.21.13.47.  Contact josh.smith@careerbuilder.com or johnny.thomas@careerbuilder.com for help or information.\"
		
						echo \"Sent ntp email\" >> $outfile

		fi
		
		
		
		if [ \"$errorcount\" -eq 0 ]; then
				
				aws ses send-email --from \"automatedtest@cbsitedb.net\" --destination ToAddresses=\"sitedbcloud@careerbuilder.com\" --subject \"Cassandra automated testing\" --text \"Everything is AWESOME!  Contact josh.smith@careerbuilder.com or johnny.thomas@careerbuilder.com for help or information.\"
						echo \"Sent all clear email\" >> $outfile

		fi
		
		echo \"Time Ended:\"  >> $outfile
		
		date >> $outfile
	
	fi "
		mode '0777'
	end
	
	cron 'automated_testing_cron' do
	  action :create 
	  minute '25'
	  hour '15'
	  user 'root'
	  command '/etc/cassandra/conf/testing.sh > /etc/cassandra/conf/testing.log'
	end
end
	service 'snmpd' do
	  supports :restart => true, :reload => true
	  action :enable
	end
	
