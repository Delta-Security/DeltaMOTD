#!/usr/bin/env bash
trim() {
  local s2 s="$*"
  until s2="${s#[[:space:]]}"; [ "$s2" = "$s" ]; do s="$s2"; done
  until s2="${s%[[:space:]]}"; [ "$s2" = "$s" ]; do s="$s2"; done
  echo "$s"
}

_delta_DISTRONAME=$(awk '/DISTRIB_ID=/' /etc/*-release | sed 's/DISTRIB_ID=//' | tr '[:upper:]' '[:lower:]')
_delta_CPUCLOCK="$(lscpu | sed -n 's/CPU max MHz:[ \t]*//p')"
_delta_STORAGEUSED=$(df -Pk . | sed 1d | grep -v used | awk '{ print $3 "\t" }')
_delta_STORAGE=$(df -Pk . | sed 1d | grep -v used | awk '{ print $1 "\t" }')
_delta_STORAGE=$(trim "$_delta_STORAGE")
_delta_STORAGEFREE=$(df -Pk . | sed 1d | grep -v used | awk '{ print $4 "\t" }')
echo "DeltaShell ($(basename $SHELL) on ${_delta_DISTRONAME^} ($(uname -s)) $(uname -r))"
curl --silent https://motd.deltasec.systems/ascii_name
printf "\n"
echo "* Website: https://deltasec.systems"
echo "* Proxmox: https://proxmox.deltasec.systems"
echo "* Discord: https://discord.deltasec.systems (Coming soon)"
printf "\n"
echo "* ANNOUNCEMENTS"
echo "  - Delta's Discord server is under construction! Stay tuned for updates."
echo "  - Migrations are currently underway for our servers in BHS. They will be back online soon."
echo "  - Emily requests that Announcements includes 'tom big gae'."
printf "\n"
echo "* SYSTEM STATS"
free | grep Mem | echo "   * RAM: $(printf "%.0f" $(awk '{print $3/$2 * 100.00}'))% ($(free -h | grep Mem | awk '{print $3}')B/$(free -h | grep Mem | awk '{print $2}')B used)"
mpstat | echo "   * CPU: $(awk '$12 ~ /[0-9.]+/ { print 100 - $12"%" }') ($(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')c/$(grep -c ^processor /proc/cpuinfo)t $(lscpu | sed -nr '/Model name/ s/  / /g; s/.*:\s*(.*) @ .*/\1/p') @ $(echo "scale=2; ${_delta_CPUCLOCK%.*} / 1000" | bc)GHz)"
echo "   * DISK: $(echo "scale=2; $_delta_STORAGEUSED / $((_delta_STORAGEUSED + _delta_STORAGEFREE)) * 100" | bc)% used on $_delta_STORAGE ($(echo "scale=2; $_delta_STORAGEUSED / 1024 / 1024" | bc)GiB/$(echo "scale=2; ($_delta_STORAGEFREE + $_delta_STORAGEUSED) / 1024 / 1024" | bc)GiB)"