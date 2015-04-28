#
# Copyright 2015, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider'
require 'chef/resource'
require 'poise'
require 'poise_application/service_mixin'

require 'poise_application_ruby/ruby_mixin'


module PoiseApplicationRuby
  module Resources
    # (see Unicorn::Resource)
    # @since 4.0.0
    module Unicorn
      class Resource < Chef::Resource
        include PoiseApplication::ServiceMixin
        include PoiseApplicationRuby::RubyMixin
        provides(:application_unicorn)

        attribute(:port, kind_of: [String, Integer], default: 80)
      end

      class Provider < Chef::Provider
        include PoiseApplication::ServiceMixin
        include PoiseApplicationRuby::RubyMixin
        provides(:application_unicorn)

        private

        # Find the path to the config.ru. If the resource path was to a
        # directory, apparent /config.ru.
        #
        # @return [String]
        def configru_path
          @configru_path ||= if ::File.directory?(new_resource.path)
            ::File.join(new_resource.path, 'config.ru')
          else
            new_resource.path
          end
        end

        # (see PoiseApplication::ServiceMixin#service_options)
        def service_options(resource)
          super
          resource.command("unicorn --port #{new_resource.port} #{configru_path}")
        end
      end
    end
  end
end
