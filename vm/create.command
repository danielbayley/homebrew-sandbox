#! /bin/zsh --no-rcs --err-exit --glob-assign --null-glob

source /etc/profile
path+=/usr/libexec

# Defaults
SSD=${1:-64} # GB
RAM=${2:-$((`sysctl -n hw.memsize`/ 1073741824 / 4))} # GB
CPUs=${3:-$((`sysctl -n hw.ncpu`/ 4))}
DPI=160 # HiDPI

glob='/Applications/Install*macOS*.app'
installer=${5:-$~glob(om[1])}
if ((!$#installer)) softwareupdate --fetch-full-installer
installer=${installer:-$~glob}

hdiutil attach -noverify -quiet $installer/Contents/SharedSupport/SharedSupport.dmg
mounted='/Volumes/Shared Support'
xml=$mounted/com_apple_MobileAsset_MacSoftwareUpdate/com_apple_MobileAsset_MacSoftwareUpdate.xml
plistbuddy -c 'print Assets:0:OSVersion' $xml | read version
hdiutil detach -quiet $mounted

read -A <<< $=installer:t:r:l

vm=${4:-$version-${(j - )reply[3,-1]}}

if (anka list | grep --silent $vm) exit 1

anka create --disk-size ${SSD}G --ram-size ${RAM}G --cpu-count $CPUs --app $installer $vm

system_profiler SPDisplaysDataType | awk '/Resolution/{ print $2$3$4 }'| read resolution
# Enable Metal GPU acceleration.
if ((${version%.*} >= 11)) metal=true
anka modify $vm set display -r $resolution -d $DPI ${=metal:+--controller pg}
anka modify $vm sandbox set network-card 0 --type bridge

anka clone $vm $0:A:h:h:t:s/homebrew-/
