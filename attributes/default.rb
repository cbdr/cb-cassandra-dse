override['cassandra']['jmx_server_hostname'] = node['ipaddress']
override['ntp']['servers'] = ['172.21.1.100', '172.22.1.100', '172.23.1.100', '172.24.1.100']
default['aws-tags']['tags']['Team'] = 'ReplaceMe'
default['aws-tags']['tags']['Ring'] = 'ReplaceMe'
