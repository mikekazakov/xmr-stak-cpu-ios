# xmr-stak-cpu-ios
iOS port of the XMR-STAK-CPU mining software. The port allows to mine Monero cryptocurrency on iPhones and iPads.

Workability of this solution was tested on iOS11 and Xcode9.

Some details about the port are given here: https://kazakov.life/2017/11/01/cryptocurrency-mining-on-ios-devices/

# How to build
0) Prerequisites: Xcode and CocoaPods are installed.
1) Get the source code and its dependencies:
```shell
git clone --recursive https://github.com/mikekazakov/xmr-stak-cpu-ios
cd xmr-stak-cpu-ios
pod install
```
2) Open xmr-stak-cpu-ios.xcworkspace and set the proper signing certificate.
3) Adjust config.txt settings according to your pool and wallet information.
4) Build the app and run it on the device.  
**Ensure you're using the Release configuration, not the Debug!**  
To check it, open in Xcode: Product->Scheme->Edit Scheme...->Run->Info->Build Configuration.
