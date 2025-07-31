# MLX Audio TTS examples for macOS

This is an example of using MLX Audio to run local TTS models.

Steps to run:

 - Open project in Xcode
 - Copy your required files to relevant Resources folder (Kokoro and Orpheus)
 - Change project signing in "Signing and Capabilities" project settings
 - Run the App

 nSpeak framework is embedeed for Kokoro already.

# Kokoro

 - Required files in Kokoro/Resources folder: 
    - kokoro-v1_0.safetensors
    - Voice json files (already in repo)
 
Implemented and working. Based on [Kokoro TTS for iOS](https://github.com/mlalma/kokoro-ios).  All credit to mlalma for that work!

Uses MLX Swift.  M1 chip or better is requied.
