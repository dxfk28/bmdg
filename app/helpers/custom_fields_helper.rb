# encoding: utf-8
#
# Redmine - project management software
# Copyright (C) 2006-2016  Jean-Philippe Lang
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

module CustomFieldsHelper

  CUSTOM_FIELDS_TABS = [
    {:name => 'IssueCustomField', :partial => 'custom_fields/index',
     :label => :label_issue_plural},
    {:name => 'TimeEntryCustomField', :partial => 'custom_fields/index',
     :label => :label_spent_time},
    {:name => 'ProjectCustomField', :partial => 'custom_fields/index',
     :label => :label_project_plural},
    {:name => 'VersionCustomField', :partial => 'custom_fields/index',
     :label => :label_version_plural},
    {:name => 'DocumentCustomField', :partial => 'custom_fields/index',
     :label => :label_document_plural},
    {:name => 'UserCustomField', :partial => 'custom_fields/index',
     :label => :label_user_plural},
    {:name => 'GroupCustomField', :partial => 'custom_fields/index',
     :label => :label_group_plural},
    {:name => 'TimeEntryActivityCustomField', :partial => 'custom_fields/index',
     :label => TimeEntryActivity::OptionName},
    {:name => 'IssuePriorityCustomField', :partial => 'custom_fields/index',
     :label => IssuePriority::OptionName},
    {:name => 'DocumentCategoryCustomField', :partial => 'custom_fields/index',
     :label => DocumentCategory::OptionName}
  ]

  def render_custom_fields_tabs(types)
    tabs = CUSTOM_FIELDS_TABS.select {|h| types.include?(h[:name]) }
    render_tabs tabs
  end

  def custom_field_type_options
    CUSTOM_FIELDS_TABS.map {|h| [l(h[:label]), h[:name]]}
  end

  def custom_field_title(custom_field)
    items = []
    items << [l(:label_custom_field_plural), custom_fields_path]
    items << [l(custom_field.type_name), custom_fields_path(:tab => custom_field.class.name)] if custom_field
    items << (custom_field.nil? || custom_field.new_record? ? l(:label_custom_field_new) : custom_field.name) 

    title(*items)
  end

  def render_custom_field_format_partial(form, custom_field)
    partial = custom_field.format.form_partial
    if partial
      render :partial => custom_field.format.form_partial, :locals => {:f => form, :custom_field => custom_field}
    end
  end

  def custom_field_tag_name(prefix, custom_field)
    name = "#{prefix}[custom_field_values][#{custom_field.id}]"
    name << "[]" if custom_field.multiple?
    name
  end

  def custom_field_tag_id(prefix, custom_field)
    "#{prefix}_custom_field_values_#{custom_field.id}"
  end

  # Return custom field html tag corresponding to its format
  def custom_field_tag(prefix, custom_value)
    custom_value.custom_field.format.edit_tag self,
      custom_field_tag_id(prefix, custom_value.custom_field),
      custom_field_tag_name(prefix, custom_value.custom_field),
      custom_value,
      :class => "#{custom_value.custom_field.field_format}_cf"
  end

  # Return custom field name tag
  def custom_field_name_tag(custom_field)
    title = custom_field.description.presence
    css = title ? "field-description" : nil
    content_tag 'span', custom_field.name, :title => title, :class => css
  end
  
  # Return custom field label tag
  def custom_field_label_tag(name, custom_value, options={})
    required = options[:required] || custom_value.custom_field.is_required?
    content = custom_field_name_tag custom_value.custom_field

    content_tag "label", content +
      (required ? " <span class=\"required\">*</span>".html_safe : ""),
      :for => "#{name}_custom_field_values_#{custom_value.custom_field.id}"
  end

  # Return custom field tag with its label tag
  def custom_field_tag_with_label(name, custom_value, options={})
    custom_field_label_tag(name, custom_value, options) + custom_field_tag(name, custom_value)
  end

  # Returns the custom field tag for when bulk editing objects
  def custom_field_tag_for_bulk_edit(prefix, custom_field, objects=nil, value='')
    custom_field.format.bulk_edit_tag self,
      custom_field_tag_id(prefix, custom_field),
      custom_field_tag_name(prefix, custom_field),
      custom_field,
      objects,
      value,
      :class => "#{custom_field.field_format}_cf"
  end

  # Return a string used to display a custom value
  def show_value(custom_value, html=true)
    format_object(custom_value, html)
  end

  # Return a string used to display a custom value
  def format_value(value, custom_field)
    format_object(custom_field.format.formatted_value(self, custom_field, value, false), false)
  end

  # Return an array of custom field formats which can be used in select_tag
  def custom_field_formats_for_select(custom_field)
    Redmine::FieldFormat.as_select(custom_field.class.customized_class.name)
  end

  # Yields the given block for each custom field value of object that should be
  # displayed, with the custom field and the formatted value as arguments
  def render_custom_field_values(object, &block)
    object.visible_custom_field_values.each do |custom_value|
      formatted = show_value(custom_value)
      if formatted.present?
        yield custom_value.custom_field, formatted
      end
    end
  end

  # Renders the custom_values in api views
  def render_api_custom_values(custom_values, api,role_ids,tracker_id,old_status_id,user)
    api.array :custom_fields do
      custom_values.each do |custom_value|
        custom_field = custom_value.custom_field
        if user.present? && user.admin?
           can_edit = true
        elsif user.present? && Member.where(user_id:user.id,project_id:custom_value.customized.project_id).present?
          member = Member.where(user_id:user.id,project_id:custom_value.customized.project_id).first
          role_ids = member.roles.pluck(:id)
          rule = WorkflowPermission.where(field_name:custom_field.id,tracker_id:tracker_id,old_status_id:old_status_id,role_id:role_ids).pluck(:rule).uniq
          can_edit = rule.include?('readonly') ? false : true
        else
          can_edit = false
        end
        attrs = {:id => custom_value.custom_field_id, :name => custom_field.name,
          :is_mobile => custom_field.is_mobile, :is_check => custom_field.is_check, 
          :field_format => custom_field.field_format, :is_required => custom_field.is_required,
          :regexp => custom_field.regexp,:min_length => custom_field.min_length,
          :max_length => custom_field.max_length,:can_edit => can_edit,:is_zichan => custom_field.is_zichan,
          :is_changsuo => custom_field.is_changsuo, :is_zaiku => custom_field.is_zaiku, :is_feiqi => custom_field.is_feiqi,
          :is_huishou => custom_field.is_huishou, :si_ruku => custom_field.si_ruku, :is_zifafang => custom_field.is_zifafang,
          :is_shiwufafang => custom_field.is_shiwufafang, :is_bumenpd => custom_field.is_bumenpd, :zhengze => custom_field.zhengze
        }
        attrs.merge!(:all_values => custom_value.custom_field.possible_values) if custom_value.custom_field.field_format == 'list'
        attrs.merge!(:multiple => true) if custom_value.custom_field.multiple?
        api.custom_field attrs do
          if custom_value.value.is_a?(Array)
            api.array :value do
              custom_value.value.each do |value|
                api.value value unless value.blank?
              end
            end
          else
            api.value custom_value.value
          end
        end
      end
    end unless custom_values.empty?
  end

  def edit_tag_style_tag(form, options={})
    select_options = [[l(:label_drop_down_list), ''], [l(:label_checkboxes), 'check_box']]
    if options[:include_radio]
      select_options << [l(:label_radio_buttons), 'radio']
    end
    form.select :edit_tag_style, select_options, :label => :label_display
  end
end
