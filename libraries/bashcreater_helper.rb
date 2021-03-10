module BashCreater
  module Helper
    include Chef::Mixin::ShellOut
    require 'json'
    def hash_from_json_file(filename)
      json_file = File.read(filename)
      hashed = JSON(json_file)
      return hashed.to_s()
    end
    def list_users
      return `cat /etc/passwd |grep '/home' |cut -d: -f1`
    end
    def list_groups
      return `cat /etc/group |cut -d: -f1`
    end
  end
end
