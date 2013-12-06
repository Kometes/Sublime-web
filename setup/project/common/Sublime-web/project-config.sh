#project config script

#server address for SSH
server=foo.com
#server root dir
serverRoot=/mnt/foo
#git repo symlink dir
serverRepo=/repo
#apache dir
apache=/etc/apache2

#List of external projects (comma separated) to push to server during build.
#Each project must have its own root and user dev repos on the server.
#External projects must be located in this project's parent directory.
extProjects=


#this project and each external project are configured separately through associative arrays

#remote repos used by client, uses default if empty
#remote_origin[$project]=origin
#remote_dev[$project]=dev

#Build script to run, uses scripts "Sublime-web/admin/build-*.sh"
#Project can override by creating custom scripts "<project>/Sublime-web/build-*.sh"
#If empty then no build script will be run after pushing to the server.
#build[$project]=

#C++ build settings. The CMake working dir is "<project>/build/<mode>"
#build[$project]=c++
#cmake[$project]=../../src/cmake.sh                     #cmake exec
#cmakeSrc[$project]=../../src                           #location of CMakeLists.txt
#cmakeOpt[$project]="-DCMAKE_INSTALL_PREFIX=../../web"  #options
#cmakeTarget[$project]=install                          #make target, optional

#Python build settings
#build[$project]=python