name 'cb-cassandra-dse'
maintainer 'Careerbuilder.com'
maintainer_email 'joshua.smith@careerbuilder.com'
license 'Apache 2.0'
description 'Wrapper cookbook to manage Careerbuilder Cassandra nodes on AWS through Opsworks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.4.1'

depends 'cassandra-dse'
depends 'aws'
depends 'ntp'
depends 'yum'
depends 'zip'

provides 'cb-cassandra-dse::default'
