#
# Cookbook Name:: application_ruby
# Provider:: passenger
#
# Copyright 2012, ZephirWorks
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

include Chef::Mixin::LanguageIncludeRecipe

action :before_compile do

  include_recipe "apache2"
  include_recipe "apache2::mod_ssl"
  include_recipe "apache2::mod_rewrite"
  include_recipe "passenger_apache2"

  resource = new_resource
  unless resource.server_aliases
    server_aliases = [ "#{resource.application.name}.#{node['domain']}", node['fqdn'] ]
    if node.has_key?("cloud")
      server_aliases << node['cloud']['public_hostname']
    end
    resource.server_aliases server_aliases
  end

  resource.restart_command do
    directory "#{resource.application.path}/current/tmp" do
      recursive true
    end
    file "#{resource.application.path}/current/tmp/restart.txt" do
      action :touch
    end
  end unless resource.restart_command

end

action :before_deploy do

  resource = @new_resource

  web_app resource.application.name do
    docroot "#{resource.application.path}/current/public"
    template resource.webapp_template || "#{resource.application.name}.conf.erb"
    cookbook resource.cookbook_name.to_s
    server_name "#{resource.application.name}.#{node['domain']}"
    server_aliases resource.server_aliases
    log_dir node['apache']['log_dir']
    rails_env resource.application.environment_name
    extra resource.params
  end

  apache_site "000-default" do
    enable false
  end

end

action :before_migrate do
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end
