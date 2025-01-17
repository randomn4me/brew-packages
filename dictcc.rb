class Dictcc < Formula
  desc "A Python script for installing with dict.cc"
  homepage "https://github.com/randomn4me/dictcc"
  url "https://github.com/randomn4me/dictcc/archive/refs/tags/1.8.zip"
  version "1.8"
  sha256 "cd1e52d4e14bec00eb29fe8fca4d9653db57bd026c2be4f325337e1e1415fa25"

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
