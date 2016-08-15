#
# Cookbook Name:: dice-deployment-service
# Recipe:: nginx
#
# Copyright 2016, XLAB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

app_folder = node['dice-deployment-service']['app_folder']
app_socket = node['dice-deployment-service']['app_socket']

package 'nginx'

service 'nginx' do
  action :nothing
end

template '/etc/nginx/sites-available/dice-deployment-service' do
  source 'dice-deployment-service.erb'
  variables({
    'app_folder' => app_folder,
    'app_socket' => app_socket
  })
  notifies :restart, 'service[nginx]'
end

link '/etc/nginx/sites-enabled/default' do
  to '/etc/nginx/sites-available/default'
  action :delete
  notifies :restart, 'service[nginx]'
end

link '/etc/nginx/sites-enabled/dice-deployment-service' do
  to '/etc/nginx/sites-available/dice-deployment-service'
  notifies :restart, 'service[nginx]'
end
