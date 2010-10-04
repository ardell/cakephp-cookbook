#
# Author:: Jason Ardell (<ardell@gmail.com>)
# Cookbook Name:: cakephp
# Attributes:: cakephp
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

# General settings
default[:cakephp][:version] = "1.3.4"
default[:cakephp][:dir] = "/var/www/cakephp"
default[:cakephp][:db][:database] = "cakephpdb"
default[:cakephp][:db][:user] = "cakephpuser"

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:cakephp][:db][:password] = secure_password
default[:cakephp][:salt] = secure_password