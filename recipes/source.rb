#
# Cookbook Name:: logstash
# Recipe:: source
#
# Copyright 2012, John E. Vincent
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

include_recipe "build-essential"
include_recipe "java"
include_recipe "ant"
include_recipe "git"
include_recipe "logstash::default"

package "wget"

logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash']['server']['version']}"

directory "#{node['logstash']['basedir']}/source" do
  action :create
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0755"
end

git "#{node['logstash']['basedir']}/source" do
  repository node['logstash']['source']['repo']
  reference logstash_version
  action :sync
  user node['logstash']['user']
  group node['logstash']['group']
end

execute "build-logstash" do
  cwd "#{node['logstash']['basedir']}/source"
  environment ({'JAVA_HOME' => node['logstash']['source']['java_home']})
  user "root"
  # This variant is useful for troubleshooting stupid environment problems
  # command "make clean && make VERSION=#{logstash_version} --debug > /tmp/make.log 2>&1"
  command "make clean && make VERSION=#{logstash_version}"
  action :run
  creates "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
  not_if "test -f #{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
end
