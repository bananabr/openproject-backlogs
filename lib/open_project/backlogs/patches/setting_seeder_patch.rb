#-- copyright
# OpenProject Backlogs Plugin
#
# Copyright (C)2013-2014 the OpenProject Foundation (OPF)
# Copyright (C)2011 Stephan Eckardt, Tim Felgentreff, Marnen Laibow-Koser, Sandro Munda
# Copyright (C)2010-2011 friflaj
# Copyright (C)2010 Maxime Guilbot, Andrew Vit, Joakim Kolsjö, ibussieres, Daniel Passos, Jason Vasquez, jpic, Emiliano Heyns
# Copyright (C)2009-2010 Mark Maglana
# Copyright (C)2009 Joe Heck, Nate Lowrie
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License version 3.
#
# OpenProject Backlogs is a derivative work based on ChiliProject Backlogs.
# The copyright follows:
# Copyright (C) 2010-2011 - Emiliano Heyns, Mark Maglana, friflaj
# Copyright (C) 2011 - Jens Ulferts, Gregor Schmidt - Finn GmbH - Berlin, Germany
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module OpenProject::Backlogs::Patches::SettingSeederPatch
  def self.included(base) # :nodoc:
    base.prepend InstanceMethods
  end

  module InstanceMethods
    def data
      original_data = super

      unless original_data['default_projects_modules'].include? 'backlogs'
        original_data['default_projects_modules'] << 'backlogs'
      end

      original_data
    end

    def seed_data!
      backlogs_init_setting! unless backlogs_configured?

      super
    end

    module_function

    def backlogs_init_setting!
      Setting[backlogs_setting_name] = backlogs_setting_value
    end

    def backlogs_configured?
      setting = Hash(Setting[backlogs_setting_name])
      setting['story_types'].present? && setting['task_type'].present?
    end

    def backlogs_setting_name
      'plugin_openproject_backlogs'
    end

    def backlogs_setting_value
      {
        "story_types" => backlogs_types.map(&:id),
        "task_type" => backlogs_task_type.try(:id),
        "points_burn_direction" => "up",
        "wiki_template" => ""
      }
    end

    def backlogs_types
      Type.where(name: backlogs_type_names)
    end

    def backlogs_type_names
      [:default_type_feature, :default_type_epic, :default_type_user_story, :default_type_bug]
        .map { |code| I18n.t(code) }
    end

    def backlogs_task_type
      Type.find_by(name: backlogs_task_type_name)
    end

    def backlogs_task_type_name
      I18n.t(:default_type_task)
    end
  end
end
