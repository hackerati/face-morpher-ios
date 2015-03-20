# TBFaceMorpher
using face morpher on ios

*Make sure you don't follow XCode's "Update settings automatically" because it will mess up compilation. Don't touch anything except for src code. 

*note to self: the stable version of of_v0.8.4_ios_release was not compiling correctly on iPhone 6 and iPhone 6+ for Architecture problems. Geoff Scott recommended that I look at https://github.com/Ssawa/Tattered which was compiling fine. After working out the kinks of that project (you can use project generator to create a clean project with your addons you want, setting Architecture levels in Build Settings, setting build sdk target, etc), I got this to work


folder structure is of_v0.8.4_ios_release --> apps --> myApps --> /TBFaceMorpher
