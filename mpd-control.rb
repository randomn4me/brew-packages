class MpdControl < Formula
  desc "Control MPD with Media Keys under macOS"
  homepage "https://github.com/randomn4me/mac-mpd-control"
  url "https://github.com/randomn4me/mac-mpd-control/archive/refs/tags/v0.1.tar.gz"
  sha256 "cbf7db2ff02e957dae343384df8c26e0151b11e46901e40ef7a27b3e47a7aa20"
  license "MIT"
  head "https://github.com/randomn4me/mac-mpd-control.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "mpc"
  depends_on :macos

  def install
    # Fix CMake minimum version compatibility
    inreplace "CMakeLists.txt", /cmake_minimum_required\s*\(\s*VERSION\s+[0-9.]+\s*\)/, "cmake_minimum_required(VERSION 3.5)"
    
    system "cmake", "-S", ".", "-B", "build",
                    "-DCMAKE_BUILD_TYPE=Release",
                    "-DCMAKE_INSTALL_PREFIX=#{prefix}",
                    "-DPROJECT_INSTALL_BIN_DST_PATH=#{bin}",
                    "-DPROJECT_INSTALL_LAUNCHAGENTS_DST_PATH=#{prefix}/LaunchAgents"

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def plist_name
    "at.fox21.mpdcontrold"
  end

  service do
    run [opt_bin/"mpdcontrold"]
    keep_alive true
    environment_variables PATH: "/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
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
