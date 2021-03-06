control 'Templates Existance Single Instance' do
  impact 0.7
  title 'Templates Existance Single Instance'
  desc 'Checks that templates have been correctly created'
  only_if { node.content['appserver']['run_single_instance'] }

  catalina_home = node.content['appserver']['alfresco']['home']
  ssl_enabled = node.content['tomcat']['ssl_enabled']

  describe file('/etc/cron.d/alfresco-cleaner.cron') do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'root' }
    its('content') { should match "#{catalina_home}/logs" }
  end

  describe file("#{catalina_home}/conf/context.xml") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
  end

  describe file("#{catalina_home}/conf/jmxremote.access") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match 'systemsMonitorRole  readonly' }
    its('content') { should match 'systemsControlRole  readwrite create javax.management.monitor.*,javax.management.timer.* unregister' }
  end

  describe file("#{catalina_home}/conf/jmxremote.password") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match 'systemsMonitorRole   changeme' }
    its('content') { should match 'systemsControlRole   changeme' }
  end

  describe file("#{catalina_home}/conf/logging.properties") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match '.level = INFO' }
  end

  describe file("#{catalina_home}/conf/server.xml") do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
    its('content') { should match 'secure=\"true\"' } if ssl_enabled
    its('content') { should match 'Connector port=\"8080\"' }
    its('content') { should_not match 'Connector port=\"8081\"' }
    its('content') { should_not match 'Connector port=\"8090\"' }
  end

  if !node.content['tomcat']['memcached_nodes'].empty? && node.content['appserver']['alfresco']['components'].include?('share')
    describe file("#{catalina_home}/share/conf/Catalina/localhost/share.xml") do
      it { should be_file }
      it { should exist }
      its('owner') { should eq 'tomcat' }
    end
  end

  describe file('/etc/security/limits.d/tomcat_limits.conf') do
    it { should be_file }
    it { should exist }
    its('owner') { should eq 'tomcat' }
  end
end
