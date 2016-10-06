#!/usr/bin/env ruby
require 'pry'
require 'open-uri'

def exec_cmd(cmd)
  puts "[#{Time.now}] now running: #{cmd}"
  puts `#{cmd}`
end

exec_cmd('docker-compose stop')
exec_cmd('rm -rf spec/cassettes/*')
exec_cmd('rm -rf spec/files/rancher/data')
exec_cmd('mkdir -p spec/files/rancher/data')
exec_cmd('docker-compose up -d')

server_offline = true
while(server_offline)
  begin
    ok = open('http://localhost:8080/v1').status.include?('OK')
    server_offline = !ok
  rescue
    puts "[#{Time.now}] ... server still offline, sleeping"
  ensure
    sleep(3)
  end
end

%w(deploy_all ls destroy teardown).each do |action|
  cmd = "SLEEP_TIME=5 bundle exec rspec spec --tag action:#{action}"
  exec_cmd(cmd)
end

exec_cmd('docker-compose stop')

exec_cmd('bundle exec rspec')
