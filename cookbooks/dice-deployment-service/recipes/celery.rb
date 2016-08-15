#
# Cookbook Name:: dice-deployment-service
# Recipe:: celery
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

dice_user = node['dice-deployment-service']['app_user']
app_venv = node['dice-deployment-service']['app_venv']
app_folder = node['dice-deployment-service']['app_folder']

service 'celery' do
  action :nothing
end

directory '/var/log/celery' do
  owner dice_user
  group dice_user
  mode 0755
end

template '/etc/init/celery.conf' do
  source 'celery.conf.erb'
  variables({
    'user' => dice_user,
    'venv' => app_venv,
    'app_folder' => app_folder
  })
  notifies :restart, 'service[celery]'
end
