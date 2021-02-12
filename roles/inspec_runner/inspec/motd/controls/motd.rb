# frozen_string_literal: true
#
title 'Message of the Day (motd)'

control 'motd-1.0' do
  impact 0.7
  title 'Check for a warning'
  desc 'Verify theres a warning'
  tag 'motd'
  ref 'git', url: 'https://github.com/foo'
  
  only_if { os.linux? }
  describe file('/etc/motd') do
    its('content') { should match /For Authorized Use Only/ }
    it { should be_owned_by 'root' }
  end
end
