include_recipe 'aws'
include_recipe 'cassandra-dse::default'
include_recipe 'ntp::default'
include_recipe 'yum'
include_recipe 'zip'
include_recipe 'snmp'

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

if node['automated_testing'][''] == 'true'
	
end