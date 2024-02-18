#!/bin/bash

function is_root {
  [ "${EUID:-$(id -u)}" -eq 0 ];
}

if ! is_root; then
  echo -e "\x1B[31m[ERROR] This script requires root privileges."
  exit 1
fi

function latest-version {
  local NAME="${1}"
  local VERSION_REGEX
  local AVAILABLE_VERSIONS

  VERSION_REGEX="[0-9]+(\.[0-9]+)*"
  AVAILABLE_VERSIONS=$(apt-cache search --names-only "^${NAME}-${VERSION_REGEX}$" | grep -Po "${VERSION_REGEX}" | xargs -n1 | sort -Vr)

  echo "${AVAILABLE_VERSIONS}" | head -1
}

function add-alternative {
  local NAME="${1}"
  local VERSION="${2}"
  local FILEPATH

  FILEPATH="/usr/bin/${NAME}"

  if [ -f "${FILEPATH}-${VERSION}" ]; then
    update-alternatives --install "${FILEPATH}" "${NAME}" "${FILEPATH}-${VERSION}" "$(echo "${VERSION}" | grep -Po "^[0-9]+")"
  else
    echo -e "\x1B[31m[ERROR] ${FILEPATH}-${VERSION} does not exist."
    exit 1
  fi
}

function set-alternative {
  local NAME="${1}"
  local VERSION="${2}"
  local FILEPATH

  FILEPATH="/usr/bin/${NAME}"

  update-alternatives --set "${NAME}" "${FILEPATH}-${VERSION}"
}

echo -e "\x1B[01;93mInstalling or updating llvm tools...\n\u001b[0m"

apt install lsb-release wget software-properties-common gnupg -y

bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" '' all

echo -e "\u001b[35m\n--\n\u001b[0m"

for TOOL in clang clang++ clang-format clang-tidy clangd; do
  VERSION=$(latest-version "${TOOL}")

  if [ -z "${VERSION}" ]; then
    echo -e "\x1B[31m[ERROR] Could not find latest version of ${TOOL}.\x1B[0m"
    exit 1
  fi

  add-alternative "${TOOL}" "${VERSION}"
  set-alternative "${TOOL}" "${VERSION}"

  echo -e "\x1B[01;93mNow, the updated version of ${TOOL} is: \u001b[0m${VERSION}\n\u001b[0m"
done
