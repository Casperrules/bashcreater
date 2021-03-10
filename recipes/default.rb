#
# Cookbook:: bashcreater
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require_relative "../libraries/bashcreater_helper"

helper = Class.new.extend(BashCreater::Helper)

# create required directory

directory '/etc/chef-demo' do
  action :create
end

directory '/etc/chef-demo/out' do
  action :create
end

hash_values = helper.hash_from_json_file("/home/json_files/test1.json")

# testing if it works
# file '/home/test_json_from_file.txt' do
#  content hash_values
#  action :create
# end


# take username and group names from an external json file provided while running chef-client
template "#{node['bashcreater']['script_dir']}/test_bash.sh" do
  source 'adder.sh.erb'
  owner 'root'
  group 'root'
  mode '777'
#  variables(
#	:user_name => node['my_attributes']['user_name'],
#	:group_name => node['my_attributes']['group_name']
#       )
  variables(
    :user_name => hash_values['my_attributes']['user_name'],
    :group_name => hash_values['my_attributes']['group_name']
)
  action :create
  not_if "grep #{node['my_attributes']['group_name']} /etc/group || #{node['my_attributes']['user_name']} /etc/passwd"
  notifies :run, 'cronjob[user_and_group_creation]', :immediately
end

file '/etc/chef-demo/out/users.txt' do
  content helper.list_users
  subscribes :create, "template[#{node['bashcreater']['script_dir']}/test_bash.sh]", :immediately
end

file '/etc/chef-demo/out/groups.txt' do
  content helper.list_groups
  subscribes :create, "template[#{node['bashcreater']['script_dir']}/test_bash.sh]", :immediately
end

# create a cron task to run user and group creation
include_recipe 'bashcreater::runcron'

execute 'deleter' do
  command "find /etc/chef-demo/out -name *.* -mmin +59 -delete"
end
