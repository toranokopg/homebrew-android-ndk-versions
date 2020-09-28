cask "android-ndk20" do
  version "20b"
  sha256 "4d760db479de1b6e54f5da2fe894a35f120ad4d6ccf4b989254940183ca00c08"

  url "https://dl.google.com/android/repository/android-ndk-r#{version}-darwin-x86_64.zip"
  name "Android NDK"
  homepage "https://developer.android.com/ndk/index.html"

  conflicts_with cask: "crystax-ndk"

  shimscript = "#{staged_path}/ndk_exec.sh"
  preflight do
    FileUtils.ln_sf("#{staged_path}/android-ndk-r#{version}", "#{HOMEBREW_PREFIX}/share/android-ndk")

    IO.write shimscript, <<~EOS
      #!/bin/bash
      readonly executable="#{staged_path}/android-ndk-r#{version}/$(basename ${0})"
      test -f "${executable}" && exec "${executable}" "${@}"
    EOS
  end

  %w[
    ndk-build
    ndk-depends
    ndk-gdb
    ndk-stack
    ndk-which
  ].each { |link_name| binary shimscript, target: link_name }

  uninstall_postflight do
    FileUtils.rm_f("#{HOMEBREW_PREFIX}/share/android-ndk")
  end

  caveats <<~EOS
    You may want to add to your profile:
       'export ANDROID_NDK_HOME="#{HOMEBREW_PREFIX}/share/android-ndk"'
  EOS
end
