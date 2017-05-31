#!/bin/bash

echo "**********************************************************************"
echo "                 Mycroft Plasmoid installation script                 "
echo "                                                                      "
echo "This script will download, build and install the Mycroft core and the "
echo "Mycroft KDE Plasmoid.  Special thanks to AIX for making all of this   "
echo "possible!                                                             "
echo "**********************************************************************"
echo ""
echo ""

# Make sure we are in user's home directory
cd ~

echo "*****************************************************"
echo "Installing git for pulling down source code"
echo "*****************************************************"
sudo zypper install git -y

############################################################################
# Retrieve and build Mycroft
############################################################################

# Pull down mycroft-core
git clone https://github.com/TimothyXL/mycroft-core.git

# Build and install Mycroft:
cd mycroft-core

echo "*****************************************************"
echo "The compiling can take a long time, up to 2 hours."
echo "Go enjoy a movie, we'll finish the install.       "
echo "*****************************************************"
./build_host_setup_opensuse.sh
./dev_setup.sh
cd ..
echo "-----------------------------------------------------"
echo "Whew, finally finished that!  Now on to the Plasmoid "
echo "-----------------------------------------------------"


############################################################################
# Retrieve and build the Plasmoid
############################################################################
# Pull down the Plasmoid code from KDE repos
git clone https://anongit.kde.org/plasma-mycroft.git

# Install all necessary supporting libraries and tools
sudo zypper install -y ki18n-devel knotifications-devel libqt5-qtbase-devel libqt5-qtdeclarative-devel libQtQuick5 libqt5-qtquickcontrols libqt5-qtquickcontrols2 libqt5-qtwebsockets-devel cmake extra-cmake-modules plasma-framework-devel

# Build the Plasmoid
cd plasma-mycroft
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make

# Install the Plasmoid
sudo make install

# Set permissions on new files to allow execution
sudo chmod +x /usr/share/plasma/plasmoids/org.kde.plasma.mycroftplasmoid/contents/code/startservice.sh 
sudo chmod +x /usr/share/plasma/plasmoids/org.kde.plasma.mycroftplasmoid/contents/code/stopservice.sh
sudo chmod +x /usr/share/plasma/plasmoids/org.kde.plasma.mycroftplasmoid/contents/code/pkgstartservice.sh 
sudo chmod +x /usr/share/plasma/plasmoids/org.kde.plasma.mycroftplasmoid/contents/code/pkgstopservice.sh

############################################################################
# Installing Skills Dependencies
############################################################################

# Install all necessary supporting libraries
sudo zypper install python2-dbus-python python2-qt5 python2-sip python2-sip-devel
cp -R /usr/lib/python2.7/site-packages/dbus* /home/$USER/.virtualenvs/mycroft/lib/python2.7/site-packages/
cp /usr/lib64/python2.7/site-packages/_dbus* /home/$USER/.virtualenvs/mycroft/lib/python2.7/site-packages/
cp -R /usr/lib64/python2.7/site-packages/PyQt5* /home/$USER/.virtualenvs/mycroft/lib/python2.7/site-packages/    
cp /usr/lib64/python2.7/site-packages/sip* /home/$USER/.virtualenvs/mycroft/lib/python2.7/site-packages/

# Restart the machine!
echo "Everything is built and ready to go!"
echo "After the machine reboots, you will need to activate it by:"
echo "1) Right-clicking on the desktop and picking 'Add Widget...'"
echo "2) Locating 'Project Mycroft' and dragging that to the desktop"
echo "3) Click on the Plasmoid and press the 'Play' button"
echo "4) Say 'Hey Mycroft, what time is it?'"

read -p "Press the [Enter] key to reboot..."
sudo reboot now
