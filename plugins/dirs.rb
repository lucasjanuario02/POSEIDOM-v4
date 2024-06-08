
require 'rbconfig'
require 'fileutils'

module AppDirs
  class AppDirs
    def initialize(appname: nil, appauthor: nil, version: nil, roaming: false, multipath: false)
      @appname = appname
      @appauthor = appauthor
      @version = version
      @roaming = roaming
      @multipath = multipath
    end

    def user_data_dir
      AppDirs.user_data_dir(@appname, @appauthor, @version, @roaming)
    end

    def site_data_dir
      AppDirs.site_data_dir(@appname, @appauthor, @version, @multipath)
    end

    def user_config_dir
      AppDirs.user_config_dir(@appname, @appauthor, @version, @roaming)
    end

    def site_config_dir
      AppDirs.site_config_dir(@appname, @appauthor, @version, @multipath)
    end

    def user_cache_dir
      AppDirs.user_cache_dir(@appname, @appauthor, @version)
    end

    def user_state_dir
      AppDirs.user_state_dir(@appname, @appauthor, @version)
    end

    def user_log_dir
      AppDirs.user_log_dir(@appname, @appauthor, @version)
    end

    class << self
      def user_data_dir(appname = nil, appauthor = nil, version = nil, roaming = false)
        system = RbConfig::CONFIG['host_os']
        path = case system
               when /mswin|mingw|cygwin/
                 const = roaming ? "CSIDL_APPDATA" : "CSIDL_LOCAL_APPDATA"
                 get_win_folder(const)
               when /darwin/
                 File.expand_path("~/Library/Application Support/")
               else
                 ENV['XDG_DATA_HOME'] || File.expand_path("~/.local/share")
               end
        append_paths(path, appname, appauthor, version)
      end

      def site_data_dir(appname = nil, appauthor = nil, version = nil, multipath = false)
        system = RbConfig::CONFIG['host_os']
        path = case system
               when /mswin|mingw|cygwin/
                 get_win_folder("CSIDL_COMMON_APPDATA")
               when /darwin/
                 File.expand_path("/Library/Application Support")
               else
                 paths = ENV['XDG_DATA_DIRS'] || "/usr/local/share:/usr/share"
                 multipath ? paths.split(":") : paths.split(":").first
               end
        append_paths(path, appname, appauthor, version)
      end

      def user_config_dir(appname = nil, appauthor = nil, version = nil, roaming = false)
        system = RbConfig::CONFIG['host_os']
        path = case system
               when /mswin|mingw|cygwin/
                 user_data_dir(appname, appauthor, nil, roaming)
               when /darwin/
                 File.expand_path("~/Library/Preferences/")
               else
                 ENV['XDG_CONFIG_HOME'] || File.expand_path("~/.config")
               end
        append_paths(path, appname, appauthor, version)
      end

      def site_config_dir(appname = nil, appauthor = nil, version = nil, multipath = false)
        system = RbConfig::CONFIG['host_os']
        path = case system
               when /mswin|mingw|cygwin/
                 site_data_dir(appname, appauthor)
               when /darwin/
                 File.expand_path("/Library/Preferences")
               else
                 paths = ENV['XDG_CONFIG_DIRS'] || "/etc/xdg"
                 multipath ? paths.split(":") : paths.split(":").first
               end
        append_paths(path, appname, appauthor, version)
      end

      def user_cache_dir(appname = nil, appauthor = nil, version = nil, opinion = true)
        system = RbConfig::CONFIG['host_os']
        path = case system
               when /mswin|mingw|cygwin/
                 path = get_win_folder("CSIDL_LOCAL_APPDATA")
                 opinion ? File.join(path, "Cache") : path
               when /darwin/
                 File.expand_path("~/Library/Caches")
               else
                 ENV['XDG_CACHE_HOME'] || File.expand_path("~/.cache")
               end
        append_paths(path, appname, appauthor, version)
      end

      def user_state_dir(appname = nil, appauthor = nil, version = nil, roaming = false)
        system = RbConfig::CONFIG['host_os']
        path = case system
               when /mswin|mingw|cygwin/, /darwin/
                 user_data_dir(appname, appauthor, nil, roaming)
               else
                 ENV['XDG_STATE_HOME'] || File.expand_path("~/.local/state")
               end
        append_paths(path, appname, appauthor, version)
      end

      def user_log_dir(appname = nil, appauthor = nil, version = nil, opinion = true)
        system = RbConfig::CONFIG['host_os']
        path = case system
               when /darwin/
                 File.expand_path("~/Library/Logs")
               when /mswin|mingw|cygwin/
                 path = user_data_dir(appname, appauthor, version)
                 File.join(path, "Logs") if opinion
               else
                 path = user_cache_dir(appname, appauthor, version)
                 File.join(path, "log") if opinion
               end
        append_paths(path, appname, appauthor, version)
      end

      private

      def get_win_folder(csidl_name)
        # Assuming that the necessary gem `win32-dir` is installed
        require 'win32/dir'
        Win32::Dir::CSIDL[csidl_name]
      end

      def append_paths(base, appname, appauthor, version)
        if appname
          path = appauthor ? File.join(base, appauthor, appname) : File.join(base, appname)
          version ? File.join(path, version) : path
        else
          base
        end
      end
    end
  end
end

# Usage example
app_dirs = AppDirs::AppDirs.new(appname: 'MyApp', appauthor: 'MyCompany', version: '1.0')
puts app_dirs.user_data_dir
puts app_dirs.site_data_dir
puts app_dirs.user_config_dir
puts app_dirs.site_config_dir
puts app_dirs.user_cache_dir
puts app_dirs.user_state_dir
puts app_dirs.user_log_dir
