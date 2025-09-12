class MacMpdControls < Formula
  desc "Lightweight command-line MPD client for macOS with media key integration"
  homepage "https://github.com/randomn4me/mac-mpd-controls"
  url "https://github.com/randomn4me/mac-mpd-controls/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "f6fa88d5435e8ba53b490570e532b6ee86e3f36d8a501b71ffb40af9706d430b"
  license "MIT"
  head "https://github.com/randomn4me/mac-mpd-controls.git", branch: "main"

  depends_on xcode: ["14.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "--configuration", "release", "--disable-sandbox", "--product", "MPDControls"
    bin.install ".build/release/MPDControls" => "mac-mpd-controls"
  end

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/mac-mpd-controls</string>
        </array>
        <key>KeepAlive</key>
        <true/>
        <key>LimitLoadToSessionType</key>
        <string>Aqua</string>
        <key>EnvironmentVariables</key>
        <dict>
          <key>PATH</key>
          <string>#{HOMEBREW_PREFIX}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin</string>
        </dict>
        <key>StandardOutPath</key>
        <string>#{var}/log/mac-mpd-controls.log</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/mac-mpd-controls.error.log</string>
      </dict>
      </plist>
    EOS
  end

  service do
    run [opt_bin/"mac-mpd-controls"]
    keep_alive true
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
    log_path var/"log/mac-mpd-controls.log"
    error_log_path var/"log/mac-mpd-controls.error.log"
  end

  def caveats
    <<~EOS
      Mac MPD Controls has been installed as a service.

      Requirements:
      - macOS 13+
      - MPD server (local or network)
      - Optional: ffmpeg for album art extraction

      To start mac-mpd-controls now and at login:
        brew services start mac-mpd-controls

      Or run manually without background service:
        mac-mpd-controls

      Configure your MPD connection settings as needed.
    EOS
  end

  test do
    system bin/"mac-mpd-controls", "--help"
  end
end
