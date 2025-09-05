class MpdControl < Formula
  desc "Control MPD with Media Keys under macOS"
  homepage "https://github.com/randomn4me/mac-mpd-control"
  url "https://github.com/randomn4me/mac-mpd-control/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "6d22bcce682972cf216575530ab5eb5660f0086fac48e6faaf999ab014783a54"
  license "MIT"
  head "https://github.com/randomn4me/mac-mpd-control.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "mpc"
  depends_on :macos

  def install
    # Fix CMake minimum version compatibility
    inreplace "CMakeLists.txt", /cmake_minimum_required\s*\(\s*VERSION\s+[0-9.]+\s*\)/, "cmake_minimum_required(VERSION 3.5)"
    
    # Fix hardcoded install paths in CMakeLists.txt
    inreplace "CMakeLists.txt" do |s|
      s.gsub! 'set(PROJECT_INSTALL_BIN_DST_PATH "/usr/local/bin")', 
              "set(PROJECT_INSTALL_BIN_DST_PATH \"${CMAKE_INSTALL_PREFIX}/bin\")"
      s.gsub! 'set(PROJECT_INSTALL_LAUNCHAGENTS_DST_PATH "~/Library/LaunchAgents")',
              "set(PROJECT_INSTALL_LAUNCHAGENTS_DST_PATH \"${CMAKE_INSTALL_PREFIX}/LaunchAgents\")"
    end
    
    # Use the provided install paths via CMake variables  
    system "cmake", "-S", ".", "-B", "build",
                    "-DCMAKE_BUILD_TYPE=Release",
                    "-DCMAKE_INSTALL_PREFIX=#{prefix}"

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def plist_name
    "at.fox21.mpdcontrold"
  end

  service do
    run [opt_bin/"mpdcontrold"]
    keep_alive true
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
    log_path var/"log/mpdcontrold.log"
    error_log_path var/"log/mpdcontrold.error.log"
  end

  def caveats
    <<~EOS
      MPD Control has been installed and will start automatically at login.

      To control a remote MPD server, set the MPD_HOST environment variable
      in the LaunchAgent plist file:
        #{opt_prefix}/LaunchAgents/at.fox21.mpdcontrold.plist

      It's recommended to disable the Remote Control Daemon to prevent conflicts:
        launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist

      To start mpd-control now and at login:
        brew services start mpd-control

      Or, if you don't want background services:
        mpdcontrold
    EOS
  end

  test do
    assert_predicate bin/"mpdcontrold", :exist?
    assert_predicate bin/"mpdcontrold", :executable?
  end
end
