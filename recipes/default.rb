include_recipe 'aws'
include_recipe 'cassandra-dse::default'
include_recipe 'ntp::default'

['root','ec2-user'].each do |u|
	directory 'home/#{u}/.aws' do
	  mode '0775'
	  action :create
	end
	template '/home/#{u}/.aws/config' do
	  source 'config.erb'
	  owner '#{u}'
	  group '#{u}'  
	  mode '0600'
	  action :create
	end
end

node['aws-tag']['tags'].each do |key,value|
	execute 'add_tags' do
		command "aws ec2 create-tags --resources $(curl http://169.254.169.254/latest/meta-data/instance-id) --tags Key=#{key},Value=#{value}"
		action :run
	end
end

#aws_resource_tag node['ec2']['instance_id'] do
#  tags(node['aws-tag']['tags'])
#  action :update
#end

