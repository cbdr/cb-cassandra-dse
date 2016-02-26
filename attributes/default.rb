override['cassandra']['jmx_server_hostname'] = node['ipaddress']
override['ntp']['servers'] = ['172.21.1.100', '172.22.1.100', '172.23.1.100', '172.24.1.100']
default['cloudwatch_monitor']['user']              = 'ec2-user'
default['cloudwatch_monitor']['group']             = 'ec2-user'
default['cloudwatch_monitor']['home_dir']          = '/home/ec2-user'
default['cloudwatch_monitor']['version']           = '1.2.1'
default['cloudwatch_monitor']['release_url']       = 'http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip'
default['aws-tags']['tags']['Team'] = 'ReplaceMe'
default['aws-tags']['tags']['Ring'] = 'ReplaceMe'

