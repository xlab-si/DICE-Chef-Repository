# Cookbook Name:: dmon
# Recipe:: elasticsearch
#
# Copyright 2016, XLAB d.o.o.
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

install_dir = node['dmon']['es']['install_dir']
dmon_user = node['dmon']['user']
dmon_group = node['dmon']['group']

# Configuring VM level setings
bash 'vm' do
  code <<-EOH
    export ES_HEAP_SIZE=#{node['dmon']['es']['core_heap']}
    export ES_USE_GC_LOGGING=yes
    sysctl -w vm.max_map_count=262144
    swapoff -a
    EOH
end

es_tar = "#{Chef::Config[:file_cache_path]}/es.tar.gz"
remote_file es_tar do
  source node['dmon']['es']['source']
  checksum node['dmon']['es']['checksum']
end

poise_archive es_tar do
  destination install_dir
end

# Install Marvel
bash 'install marvel' do
  code <<-EOH
    cd #{install_dir}/bin
    ./plugin install license
    ./plugin install marvel-agent
    EOH
end

template "#{install_dir}/config/elasticsearch.yml" do
  source 'elasticsearch.tmp.erb'
  owner dmon_user
  group dmon_group
  action :create
  variables({
    :clusterName => node['dmon']['es']['cluster_name'],
    :nodeName => node['dmon']['es']['node_name'],
    :esLogDir => "#{node['dmon']['install_dir']}/src/logs"
  })
end

execute 'Setting es permissions' do
  command "chown -R #{dmon_user}:#{dmon_group} #{install_dir}"
end

# Copy init script (Chef does not have copy block for some reason)
remote_file 'Copy ElasticSearch service file' do
  path '/etc/init.d/dmon-es'
  source "file://#{node['dmon']['install_dir']}/src/init/dmon-es"
  owner 'root'
  group 'root'
  mode 0755
end

service 'dmon-es' do
  action [:enable, :start]
end
