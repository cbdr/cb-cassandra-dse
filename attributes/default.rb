override['cassandra']['jmx_server_hostname'] = node['ipaddress']
default['cloudwatch_monitor']['user']              = "ec2-user"
default['cloudwatch_monitor']['group']             = "ec2-user"
default['cloudwatch_monitor']['home_dir']          = "/home/ec2-user"
default['cloudwatch_monitor']['version']           = "1.2.1"
default['cloudwatch_monitor']['release_url']       = "http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O"
