class Make<%= @target_class.table_name.camelize %>Revisable < ActiveRecord::Migration
  def self.up<% @revisable_columns.each do |column_name,column_type,default| %>
    add_column :<%= @target_class.table_name -%>, :<%= column_name -%>, :<%= column_type -%><%= ", :default => #{default}" unless default.blank? -%>
  <% end %>
  end

  def self.down<% @revisable_columns.each do |column_name,_| %>
    remove_column :<%= @target_class.table_name -%>, :<%= column_name -%>
  <% end %>
  end
end
