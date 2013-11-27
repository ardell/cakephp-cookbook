#
# Cookbook Name:: cakephp
# Recipe:: default
#
# Copyright 2010, Jason Ardell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node.has_key?("ec2")
  server_fqdn = node.ec2.public_hostname
else
  server_fqdn = node.fqdn
end

include_recipe 'mysql'

remote_file "#{Chef::Config[:file_cache_path]}/cakephp-#{node['cakephp']['version']}.tar.gz" do
  source "http://github.com/cakephp/cakephp/archive/#{node['cakephp']['version']}.tar.gz"
  mode "0644"
end

directory "#{node['cakephp']['dir']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

execute "untar-cakephp" do
  cwd node['cakephp']['dir']
  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/cakephp-#{node['cakephp']['version']}.tar.gz"
  creates "#{node['cakephp']['dir']}/index.php"
end

# Make the CakePHP tmp directory writable
execute "make tmp dir writable" do
  command "chown -R www-data:www-data #{node['cakephp']['dir']}/app/tmp"
end
execute "make tmp dir writable" do
  command "chmod -R 755 #{node['cakephp']['dir']}/app/tmp"
end

execute "mysql-install-cakephp-privileges" do
  command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} < /etc/mysql/cakephp-grants.sql"
  action :nothing
end

template "/etc/mysql/cakephp-grants.sql" do
  path "/etc/mysql/cakephp-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node['cakephp']['db']['user'],
    :password => node['cakephp']['db']['password'],
    :database => node['cakephp']['db']['database']
  )
  notifies :run, resources(:execute => "mysql-install-cakephp-privileges"), :immediately
end


ruby_block "create #{node['cakephp']['db']['database']} database" do
  block do
     %x[mysql -u root -p#{node['mysql']['server_root_password']} -e CREATE DATABASE #{node['cakephp']['db']['database']}"; ]
  end
   not_if "mysql -uroot -p#{node['mysql']['server_root_password']} -e \"SHOW DATABASES LIKE '#{node['cakephp']['db']['database']}'";
  action :create
end

#create if not exists
directory "#{node['cakephp']['dir']}/app/Config/" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
  not_if { File.directory?("#{node['cakephp']['dir']}/app/config/") }
end

#set up template
template "#{node['cakephp']['dir']}/app/Config/database.php" do
  source "database.php.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :database        => node['cakephp']['db']['database'],
    :user            => node['cakephp']['db']['user'],
    :password        => node['cakephp']['db']['password']
  )
end


# Create our user-specific salt
template "#{node['cakephp']['dir']}/app/Config/core.php" do
  source "core.php.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :salt => node['cakephp']['salt'],
    :cipherSeed => node['cakephp']['cipherSeed']
  )
end

web_app "cakephp" do
  template "cakephp.conf.erb"
  docroot "#{node['cakephp']['dir']}/app/webroot"
  server_name server_fqdn
  server_aliases node.fqdn
end
