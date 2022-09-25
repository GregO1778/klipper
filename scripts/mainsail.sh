#!/usr/bin/env bash

#=======================================================================#
# Copyright (C) 2020 - 2022 Dominik Willner <th33xitus@gmail.com>       #
#                                                                       #
# This file is part of KIAUH - Klipper Installation And Update Helper   #
# https://github.com/th33xitus/kiauh                                    #
#                                                                       #
# This file may be distributed under the terms of the GNU GPLv3 license #
#=======================================================================#

set -e

#===================================================#
#================= INSTALL MAINSAIL ================#
#===================================================#

function install_mainsail() {
  ### exit early if moonraker not found
  if [[ -z $(moonraker_systemd) ]]; then
    local error="Moonraker not installed! Please install Moonraker first!"
    print_error "${error}" && return
  fi

  ### checking dependencies
  local dep=(wget nginx)
  dependency_check "${dep[@]}"
  ### detect conflicting Haproxy and Apache2 installations
  detect_conflicting_packages

  status_msg "Initializing Mainsail installation ..."
  ### first, we create a backup of the full klipper_config dir - safety first!
  backup_klipper_config_dir

  ### check for other enabled web interfaces
  unset SET_LISTEN_PORT
  detect_enabled_sites

  ### check if another site already listens to port 80
  mainsail_port_check

  ### ask user to install mjpg-streamer
  local install_mjpg_streamer
  if [[ ! -f "${SYSTEMD}/webcamd.service" ]]; then
    while true; do
      echo
      top_border
      echo -e "| Install MJPG-Streamer for webcam support?             |"
      bottom_border
      read -p "${cyan}###### Please select (y/N):${white} " yn
      case "${yn}" in
        Y|y|Yes|yes)
          select_msg "Yes"
          install_mjpg_streamer="true"
          break;;
        N|n|No|no|"")
          select_msg "No"
          install_mjpg_streamer="false"
          break;;
        *)
          error_msg "Invalid command!";;
      esac
    done
  fi

  ### download mainsail
  download_mainsail

  ### ask user to install the recommended webinterface macros
  install_mainsail_macros

  ### create /etc/nginx/conf.d/upstreams.conf
  set_upstream_nginx_cfg
  ### create /etc/nginx/sites-available/<interface config>
  set_nginx_cfg "mainsail"
  ### nginx on ubuntu 21 and above needs special permissions to access the files
  set_nginx_permissions

  ### symlink nginx log
  symlink_webui_nginx_log "mainsail"

  ### add mainsail to the update manager in moonraker.conf
  patch_mainsail_update_manager

  ### install mjpg-streamer
  [[ ${install_mjpg_streamer} == "true" ]] && install_mjpg-streamer

  fetch_webui_ports #WIP

  ### confirm message
  print_confirm "Mainsail has been set up!"
}

function install_mainsail_macros() {
  while true; do
    echo
    top_border
    echo -e "| It is recommended to have some important macros in    |"
    echo -e "| your printer configuration to have Mainsail fully     |"
    echo -e "| functional and working.                               |"
    blank_line
    echo -e "| The recommended macros for Mainsail can be seen here: |"
    echo -e "| https://docs.mainsail.xyz/configuration#macros        |"
    blank_line
    echo -e "| If you already have these macros in your config file, |"
    echo -e "| skip this step and answer with 'no'.                  |"
    echo -e "| Otherwise you should consider to answer with 'yes' to |"
    echo -e "| add the recommended example macros to your config.    |"
    bottom_border
    read -p "${cyan}###### Add the recommended macros? (Y/n):${white} " yn
    case "${yn}" in
      Y|y|Yes|yes|"")
        select_msg "Yes"
        download_mainsail_macros
        break;;
      N|n|No|no)
        select_msg "No"
        break;;
      *)
        print_error "Invalid command!";;
    esac
  done
  return
}

function download_mainsail_macros() {
  local ms_cfg="https://raw.githubusercontent.com/mainsail-crew/MainsailOS/master/src/modules/mainsail/filesystem/home/pi/klipper_config/mainsail.cfg"
  local configs path
  configs=$(find "${KLIPPER_CONFIG}" -type f -name "printer.cfg" | sort)

  if [[ -n ${configs} ]]; then
    for config in ${configs}; do
      path=$(echo "${config}" | rev | cut -d"/" -f2- | rev)
      if [[ ! -f "${path}/mainsail.cfg" ]]; then
        status_msg "Downloading mainsail.cfg to ${path} ..."
        log_info "downloading mainsail.cfg to: ${path}"
        wget "${ms_cfg}" -O "${path}/mainsail.cfg"

        ### replace user 'pi' with current username to prevent issues in cases where the user is not called 'pi'
        log_info "modify mainsail.cfg"
        sed -i "/^path: \/home\/pi\/gcode_files/ s/\/home\/pi/\/home\/${USER}/" "${path}/mainsail.cfg"

        ### write include to the very first line of the printer.cfg
        if ! grep -Eq "^[include mainsail.cfg]$" "${path}/printer.cfg"; then
          log_info "modify printer.cfg"
          sed -i "1 i [include mainsail.cfg]" "${path}/printer.cfg"
        fi
        ok_msg "Done!"
      fi
    done
  else
    log_error "execution stopped! reason: no printer.cfg found"
    return
  fi
}

function download_mainsail() {
  local url
  url=$(get_mainsail_download_url)

  status_msg "Downloading Mainsail from ${url} ..."

  if [[ -d ${MAINSAIL_DIR} ]]; then
    rm -rf "${MAINSAIL_DIR}"
  fi

  mkdir "${MAINSAIL_DIR}" && cd "${MAINSAIL_DIR}"

  if wget "${url}"; then
    ok_msg "Download complete!"
    status_msg "Extracting archive ..."
    unzip -q -o ./*.zip && ok_msg "Done!"
    status_msg "Remove downloaded archive ..."
    rm -rf ./*.zip && ok_msg "Done!"
  else
    print_error "Downloading Mainsail from\n ${url}\n failed!"
    exit 1
  fi

  ### check for moonraker multi-instance and if multi-instance was found, enable mainsails remoteMode
  if [[ $(moonraker_systemd | wc -w) -gt 1 ]]; then
    enable_mainsail_remotemode
  fi
}

#===================================================#
#================= REMOVE MAINSAIL =================#
#===================================================#

function remove_mainsail_dir() {
  [[ ! -d ${MAINSAIL_DIR} ]] && return

  status_msg "Removing Mainsail directory ..."
  rm -rf "${MAINSAIL_DIR}" && ok_msg "Directory removed!"
}

function remove_mainsail_config() {
  if [[ -e "/etc/nginx/sites-available/mainsail" ]]; then
    status_msg "Removing Mainsail configuration for Nginx ..."
    sudo rm "/etc/nginx/sites-available/mainsail" && ok_msg "File removed!"
  fi
  if [[ -L "/etc/nginx/sites-enabled/mainsail" ]]; then
    status_msg "Removing Mainsail Symlink for Nginx ..."
    sudo rm "/etc/nginx/sites-enabled/mainsail" && ok_msg "File removed!"
  fi
}

function remove_mainsail_logs() {
  local files
  files=$(find /var/log/nginx -name "mainsail*" 2> /dev/null | sort)

  if [[ -n ${files} ]]; then
    for file in ${files}; do
      status_msg "Removing ${file} ..."
      sudo rm -f "${file}"
      ok_msg "${file} removed!"
    done
  fi
}

function remove_mainsail_log_symlinks() {
  local files
  files=$(find "${KLIPPER_LOGS}" -name "mainsail*" 2> /dev/null | sort)

  if [[ -n ${files} ]]; then
    for file in ${files}; do
      status_msg "Removing ${file} ..."
      rm -f "${file}"
      ok_msg "${file} removed!"
    done
  fi
}

function remove_mainsail() {
  remove_mainsail_dir
  remove_mainsail_config
  remove_mainsail_logs
  remove_mainsail_log_symlinks

  ### remove mainsail_port from ~/.kiauh.ini
  sed -i "/^mainsail_port=/d" "${INI_FILE}"

  print_confirm "Mainsail successfully removed!"
}

#===================================================#
#================= UPDATE MAINSAIL =================#
#===================================================#

function update_mainsail() {
  backup_before_update "mainsail"
  status_msg "Updating Mainsail ..."
  download_mainsail
  match_nginx_configs
  symlink_webui_nginx_log "mainsail"
  print_confirm "Mainsail successfully updated!"
}

#===================================================#
#================= MAINSAIL STATUS =================#
#===================================================#

function get_mainsail_status() {
  local status
  local data_arr=("${MAINSAIL_DIR}" "${NGINX_SA}/mainsail" "${NGINX_SE}/mainsail")

  ### count+1 for each found data-item from array
  local filecount=0
  for data in "${data_arr[@]}"; do
    [[ -e ${data} ]] && filecount=$(( filecount + 1 ))
  done

  if (( filecount == ${#data_arr[*]} )); then
    status="Installed!"
  elif (( filecount == 0 )); then
    status="Not installed!"
  else
    status="Incomplete!"
  fi
  echo "${status}"
}

function get_local_mainsail_version() {
  [[ ! -f "${MAINSAIL_DIR}/.version" ]] && return

  local version
  version=$(head -n 1 "${MAINSAIL_DIR}/.version")
  echo "${version}"
}

function get_remote_mainsail_version() {
  [[ ! $(dpkg-query -f'${Status}' --show curl 2>/dev/null) = *\ installed ]] && return

  local version
  version=$(get_mainsail_download_url | rev | cut -d"/" -f2 | rev)
  echo "${version}"
}

function compare_mainsail_versions() {
  local versions local_ver remote_ver
  local_ver="$(get_local_mainsail_version)"
  remote_ver="$(get_remote_mainsail_version)"

  if [[ ${local_ver} != "${remote_ver}" && ${local_ver} != "" ]]; then
    versions="${yellow}$(printf " %-14s" "${local_ver}")${white}"
    versions+="|${green}$(printf " %-13s" "${remote_ver}")${white}"
    # add moonraker to application_updates_available in kiauh.ini
    add_to_application_updates "mainsail"
  else
    versions="${green}$(printf " %-14s" "${local_ver}")${white}"
    versions+="|${green}$(printf " %-13s" "${remote_ver}")${white}"
  fi

  echo "${versions}"
}

#================================================#
#=========== MAINSAIL THEME INSTALLER ===========#
#================================================#

function print_theme_list() {
  local i=0 theme_list=${1}

  while IFS="," read -r col1 col2 col3 col4; do
    if [[ ${col1} != "name" ]]; then
      printf "| ${i}) %-51s|\n" "[${col1}]"
    fi
    i=$(( i + 1 ))
  done <<< "${theme_list}"
}

function ms_theme_installer_menu() {
  local theme_list theme_author theme_repo theme_name theme_note theme_url
  local theme_csv_url="https://raw.githubusercontent.com/mainsail-crew/docs/master/_data/themes.csv"
  theme_list=$(curl -s -L "${theme_csv_url}")

  top_border
  echo -e "|     ${red}~~~~~~~~ [ Mainsail Theme Installer ] ~~~~~~~${white}     |"
  hr
  echo -e "| ${cyan}A preview of each Mainsail theme can be found here:${white}   |"
  echo -e "| https://docs.mainsail.xyz/theming/themes              |"
  blank_line
  echo -e "| ${yellow}Important note:${white}                                       |"
  echo -e "| Installing a theme from this menu will overwrite an   |"
  echo -e "| already installed theme or modified custom.css file!  |"
  hr
  print_theme_list "${theme_list}"
  echo -e "|                                                       |"
  echo -e "| R) [Remove Theme]                                     |"
  back_footer

  while IFS="," read -r col1 col2 col3 col4; do
    theme_name+=("${col1}")
    theme_note+=("${col2}")
    theme_author+=("${col3}")
    theme_repo+=("${col4}")
  done <<< "${theme_list}"

  local option
  while true; do
    read -p "${cyan}Install theme:${white} " option
    if (( option > 0 &&  option < ${#theme_name[@]} )); then
      theme_url="https://github.com/${theme_author[${option}]}/${theme_repo[${option}]}"
      ms_theme_install "${theme_url}" "${theme_name[${option}]}" "${theme_note[${option}]}"
      break
    elif [[ ${option} == "R" || ${option} == "r" ]]; then
      ms_theme_delete
      break
    elif [[ ${option} == "B" || ${option} == "b" ]]; then
      advanced_menu
      break
    else
      error_msg "Invalid command!"
    fi
  done
  ms_theme_installer_menu
}

function ms_theme_install() {
  read_kiauh_ini "${FUNCNAME[0]}"

  local theme_url
  local theme_name
  local theme_note
  theme_url=${1}
  theme_name=${2}
  theme_note=${3}

  local folder_arr
  local folder_names="${multi_instance_names}"
  local target_folders=()

  IFS=',' read -r -a folder_arr <<< "${folder_names}"

  ### build theme target folder array
  if (( ${#folder_arr[@]} > 1 )); then
    for folder in "${folder_arr[@]}"; do
      ### instance names/identifier of only numbers need to be prefixed with 'printer_'
      if [[ ${folder} =~ ^[0-9]+$ ]]; then
        target_folders+=("${KLIPPER_CONFIG}/printer_${folder}")
      else
        target_folders+=("${KLIPPER_CONFIG}/${folder}")
      fi
    done
  else
    target_folders+=("${KLIPPER_CONFIG}")
  fi

  if (( ${#target_folders[@]} > 1 )); then
    top_border
    echo -e "| Please select the printer you want to apply the theme |"
    echo -e "| installation to:                                      |"
    for (( i=0; i < ${#target_folders[@]}; i++ )); do
      folder=$(echo "${target_folders[${i}]}" | rev | cut -d "/" -f1 | rev)
      printf "|${cyan}%-55s${white}|\n" " ${i}) ${folder}"
    done
    bottom_border

    local target re="^[0-9]*$"
    while true; do
      read -p "${cyan}###### Select printer:${white} " target
      ### break while loop if input is valid, else display error
      [[ ${target} =~ ${re} && ${target} -lt ${#target_folders[@]} ]] && break
      error_msg "Invalid command!"
    done
  fi

  [[ -d "${target_folders[${target}]}/.theme" ]] && rm -rf "${target_folders[${target}]}/.theme"

  status_msg "Installing '${theme_name}' to ${target_folders[${target}]} ..."
  cd "${target_folders[${target}]}"

  if git clone "${theme_url}" ".theme"; then
    ok_msg "Theme installation complete!"
    [[ -n ${theme_note} ]] && echo "${yellow}###### Theme Info: ${theme_note}${white}"
    ok_msg "Please remember to delete your browser cache!\n"
  else
    error_msg "Theme installation failed!\n"
  fi
}

function ms_theme_delete() {
  local theme_folders target_folders=()
  theme_folders=$(find "${KLIPPER_CONFIG}" -mindepth 1 -type d -name ".theme" | sort)

  ### build target folder array
  for folder in ${theme_folders}; do
    target_folders+=("${folder}")
  done

  if (( ${#target_folders[@]} == 0 )); then
    status_msg "No Themes installed!\n"
    return
  elif (( ${#target_folders[@]} > 1 )); then
    top_border
    echo -e "| Please select the printer you want to remove the      |"
    echo -e "| theme installation from.                              |"
    for (( i=0; i < ${#target_folders[@]}; i++ )); do
      folder=$(echo "${target_folders[${i}]}" | rev | cut -d "/" -f2 | rev)
      printf "|${cyan}%-55s${white}|\n" " ${i}) ${folder}"
    done
    bottom_border

    local target re="^[0-9]*$"
    while true; do
      read -p "${cyan}###### Select printer:${white} " target
      ### break while loop if input is valid, else display error
      [[ ${target} =~ ${re} && ${target} -lt ${#target_folders[@]} ]] && break
      error_msg "Invalid command!"
    done
  fi

  status_msg "Removing ${target_folders[${target}]} ..."
  rm -rf "${target_folders[${target}]}" && ok_msg "Theme removed!\n"

  return
}

#================================================#
#=================== HELPERS ====================#
#================================================#

function get_mainsail_download_url() {
  local tags latest_tag latest_url stable_tag stable_url url
  tags=$(curl -s "${MAINSAIL_TAGS}" | grep "name" | cut -d'"' -f4)

  ### latest download url including pre-releases (alpha, beta, rc)
  latest_tag=$(echo "${tags}" | head -1)
  latest_url="https://github.com/mainsail-crew/mainsail/releases/download/${latest_tag}/mainsail.zip"

  ### get stable mainsail download url
  stable_tag=$(echo "${tags}" | grep -E "^v([0-9]+\.?){3}$" | head -1)
  stable_url="https://github.com/mainsail-crew/mainsail/releases/download/${stable_tag}/mainsail.zip"

  read_kiauh_ini "${FUNCNAME[0]}"
  if [[ ${mainsail_install_unstable} == "true" ]]; then
    url="${latest_url}"
    echo "${url}"
  else
    url="${stable_url}"
    echo "${url}"
  fi
}

function mainsail_port_check() {
  if [[ ${MAINSAIL_ENABLED} == "false" ]]; then

    if [[ ${SITE_ENABLED} == "true" ]]; then
      status_msg "Detected other enabled interfaces:"

      [[ ${FLUIDD_ENABLED} == "true" ]] && \
      echo -e "   ${cyan}● Fluidd - Port: ${FLUIDD_PORT}${white}"

      if [[ ${FLUIDD_PORT} == "80" ]]; then
        PORT_80_BLOCKED="true"
        select_mainsail_port
      fi
    else
      DEFAULT_PORT=$(grep listen "${KIAUH_SRCDIR}/resources/mainsail" | head -1 | sed 's/^\s*//' | cut -d" " -f2 | cut -d";" -f1)
      SET_LISTEN_PORT=${DEFAULT_PORT}
    fi
    SET_NGINX_CFG="true"

  else
    SET_NGINX_CFG="false"
  fi
}

function select_mainsail_port() {
  if [[ ${PORT_80_BLOCKED} == "true" ]]; then
    echo
    top_border
    echo -e "|                    ${red}!!!WARNING!!!${white}                      |"
    echo -e "| ${red}You need to choose a different port for Mainsail!${white}     |"
    echo -e "| ${red}The following web interface is listening at port 80:${white}  |"
    blank_line
    [[ ${FLUIDD_PORT} == "80" ]] && echo "|  ● Fluidd                                             |"
    blank_line
    echo -e "| Make sure you don't choose a port which was already   |"
    echo -e "| assigned to another webinterface!                     |"
    blank_line
    echo -e "| Be aware: there is ${red}NO${white} sanity check for the following  |"
    echo -e "| input. So make sure to choose a valid port!           |"
    bottom_border

    local new_port re="^[0-9]+$"
    while true; do
      read -p "${cyan}Please enter a new Port:${white} " new_port
      if [[ ${new_port} =~ ${re} && ${new_port} != "${FLUIDD_PORT}" ]]; then
        select_msg "Setting port ${new_port} for Mainsail!"
        SET_LISTEN_PORT=${new_port}
        break
      else
        if [[ ! ${new_port} =~ ${re}  ]]; then
          error_msg "Invalid input!"
        else
          error_msg "Port already taken! Select a different one!"
        fi
      fi
    done
  fi
}

function enable_mainsail_remotemode() {
  [[ ! -f "${MAINSAIL_DIR}/config.json" ]] && return

  status_msg "Setting instance storage location to 'browser' ..."
  sed -i 's|"instancesDB": "moonraker"|"instancesDB": "browser"|' "${MAINSAIL_DIR}/config.json"
  ok_msg "Done!"
}

function patch_mainsail_update_manager() {
  local patched="false"
  local moonraker_configs
  moonraker_configs=$(find "${KLIPPER_CONFIG}" -type f -name "moonraker.conf" | sort)

  for conf in ${moonraker_configs}; do
    if ! grep -Eq "^\[update_manager mainsail\]$" "${conf}"; then
      ### add new line to conf if it doesn't end with one
      [[ $(tail -c1 "${conf}" | wc -l) -eq 0 ]] && echo "" >> "${conf}"

      ### add Mainsails update manager section to moonraker.conf
      status_msg "Adding Mainsail to update manager in file:\n       ${conf}"
      /bin/sh -c "cat >> ${conf}" << MOONRAKER_CONF

[update_manager mainsail]
type: web
channel: stable
repo: mainsail-crew/mainsail
path: ~/mainsail
MOONRAKER_CONF

    fi

    patched="true"
  done

  if [[ ${patched} == "true" ]]; then
    do_action_service "restart" "moonraker"
  fi
}
