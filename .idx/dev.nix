# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.jdk21
    pkgs.unzip
    pkgs.wget
  ];
  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        # The following script is a one-time setup to download and install the Android SDK and emulator.
        android-sdk-setup = ''
          # Set environment variables for Android SDK
          export ANDROID_HOME=$HOME/Android/Sdk
          export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

          # Create the SDK directory
          mkdir -p $ANDROID_HOME

          # Download and unzip command-line tools
          wget --quiet --output-document=cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
          unzip -q cmdline-tools.zip
          mv cmdline-tools $ANDROID_HOME/cmdline-tools/latest
          rm cmdline-tools.zip

          # Accept all SDK licenses
          yes | sdkmanager --licenses > /dev/null

          # Install platform-tools, emulator, and the system image
          sdkmanager "platform-tools" "emulator" "system-images;android-34;google_apis;x86_64"

          # Create an Android Virtual Device (AVD)
          echo "no" | avdmanager create avd -n "flutter_emulator" -k "system-images;android-34;google_apis;x86_64" -d "pixel_8"
        '';
      };
      # To run something each time the workspace is (re)started, use the `onStart` hook
      onStart = {
        # The following starts the Android emulator in the background.
        start-android-emulator = ''
          export ANDROID_HOME=$HOME/Android/Sdk
          export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
          
          # Start the emulator
          emulator -avd flutter_emulator -no-window -no-snapshot -no-audio -no-boot-anim -camera-back none -camera-front none -qemu -vnc :2,to=5902,password,name=android-vnc &
        '';
      };
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"];
          manager = "flutter";
        };
      };
    };
  };
}
