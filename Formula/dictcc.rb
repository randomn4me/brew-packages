class Dictcc < Formula
  desc "A Python script for installing with dict.cc"
  homepage "https://github.com/randomn4me/dictcc"
  url "https://github.com/randomn4me/dictcc/archive/refs/tags/1.9.zip"
  version "1.9"
  sha256 "7759db76b0a4bd8b34b1e92e68b049c73377942053b1866dceb84014dd7d6fb5"

  depends_on "python@3.10" # Ensure Python 3.10 or later is available

  def install
    # Rename and install the script as "dictcc"
    libexec.install "dictcc.py" => "dictcc"

    # Write the requirements file
    (libexec/"requirements.txt").write <<~EOS
      requests
      tabulate
      beautifulsoup4
    EOS

    # Install Python dependencies in libexec
    system "python3", "-m", "pip", "install", "--prefix=#{libexec}", "-r", libexec/"requirements.txt"

    (bin/"dictcc").write <<~EOS
      #!/bin/bash
      PYTHONPATH=#{libexec}/lib/python3.10/site-packages exec python3 #{libexec}/dictcc "$@"
    EOS

    chmod 0755, bin/"dictcc"
  end

  test do
    # Test if the command runs successfully
    system "dictcc", "--help"
  end
end
