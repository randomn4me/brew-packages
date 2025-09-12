class MacMpdControls < Formula
  desc "Lightweight command-line MPD client for macOS with media key integration"
  homepage "https://github.com/randomn4me/mac-mpd-controls"
  url "https://github.com/randomn4me/mac-mpd-controls/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "0c74c76a8d8915c70f12b5cb2524f721297e223b3ad41e0142e9ce5cdbeefd9a"
  license "MIT"
  head "https://github.com/randomn4me/mac-mpd-controls.git", branch: "main"

  depends_on xcode: ["14.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "--configuration", "release", "--disable-sandbox", "--product", "MPDControls"
    bin.install ".build/release/MPDControls" => "mac-mpd-controls"

    # Install provided plist file to LaunchAgents directory
    plist_content = File.read("com.github.randomn4me.mac-mpd-controls.plist")
    # Replace placeholder with actual binary path
    plist_content.gsub!("__BINARY_PATH__", opt_bin/"mac-mpd-controls")
    plist_content.gsub!("__HOMEBREW_PREFIX__", HOMEBREW_PREFIX)
    plist_content.gsub!("__HOME__", ENV["HOME"])

    launchagents_dir = Pathname.new(ENV["HOME"])/"Library/LaunchAgents"
    launchagents_dir.mkpath
    (launchagents_dir/"com.github.randomn4me.mac-mpd-controls.plist").write plist_content
  end


  def caveats
    <<~EOS
      Mac MPD Controls has been installed with a LaunchAgent plist file.

      Requirements:
      - macOS 13+
      - MPD server (local or network)
      - Optional: ffmpeg for album art extraction

      A plist file has been installed to:
        ~/Library/LaunchAgents/com.github.randomn4me.mac-mpd-controls.plist

      To load the service (start now and at login):
        launchctl load -w ~/Library/LaunchAgents/com.github.randomn4me.mac-mpd-controls.plist

      To unload the service (stop and disable from login):
        launchctl unload -w ~/Library/LaunchAgents/com.github.randomn4me.mac-mpd-controls.plist

      To start the service manually (one-time):
        launchctl start com.github.randomn4me.mac-mpd-controls

      To stop the service manually:
        launchctl stop com.github.randomn4me.mac-mpd-controls

      Or run directly without the service:
        mac-mpd-controls

      Logs are written to:
        ~/Library/Logs/mac-mpd-controls.log
        ~/Library/Logs/mac-mpd-controls.error.log

      Configure your MPD connection settings as needed.
    EOS
  end

  test do
    system bin/"mac-mpd-controls", "--help"
  end
end
