override['cassandra']['jmx_server_hostname'] = node['ipaddress']
override['ntp']['servers'] = ['172.21.1.100', '172.22.1.100', '172.23.1.100', '172.24.1.100']
default['cloudwatch_monitor']['user']              = 'ec2-user'
default['cloudwatch_monitor']['group']             = 'ec2-user'
default['cloudwatch_monitor']['home_dir']          = '/home/ec2-user'
default['cloudwatch_monitor']['version']           = '1.2.1'
default['cloudwatch_monitor']['release_url']       = 'http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip'
default['aws-tags']['tags']['Team'] = 'ReplaceMe'
default['aws-tags']['tags']['Ring'] = 'ReplaceMe'
default['automated_testing'] = 'false'
default['scalyr']['key'] = '0tWblZ3N8JLMSLGzNIZtbf5BhAVZAtp_/8mT02VvVrrI-'
default['al_agents']['agent']['registration_key'] =    '5c778343b61cfecf542700aa385f99c30123b32057c0fe17c8'
override['cassandra']['local_jmx'] = false
#This is a comment
