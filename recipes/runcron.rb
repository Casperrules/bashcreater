cronjob 'user_and_group_creation' do
  filename "#{node['bashcreater']['script_dir']}/test_bash.sh"
end
