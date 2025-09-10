class MacMpdControls < Formula
  desc "Lightweight command-line MPD client for macOS with media key integration"
  homepage "https://github.com/randomn4me/mac-mpd-controls"
  url "https://github.com/randomn4me/mac-mpd-controls/archive/refs/tags/v0.1.tar.gz"
  sha256 "2256fe916eeeb995a2bfaf8f5443c0eb8aabf016d41c9d1c99b0adecc40f1a80"
  license "MIT"
  head "https://github.com/randomn4me/mac-mpd-controls.git", branch: "main"

  depends_on xcode: ["14.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "--configuration", "release", "--disable-sandbox"
    bin.install ".build/release/mac-mpd-controls"
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
