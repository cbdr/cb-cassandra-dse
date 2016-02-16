include_recipe 'cassandra-dse::default'

directory 'home/ec2-user/.aws' do
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
