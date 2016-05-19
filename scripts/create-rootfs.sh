#! /usr/bin/env sh
#
# This file is part of Xvisor Build Environment.
# Copyright (C) 2016 Institut de Recherche Technologique SystemX
# Copyright (C) 2016 OpenWide
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this Xvisor Build Environment. If not, see
# <http://www.gnu.org/licenses/>.
#
# @author Jean Guyomarc'h (jean.guyomarch@openwide.fr)
# @file scripts/create-rootfs.sh
#

err() {
   echo "*** $@" 1>&2
}

fatal() {
   ret="$1" ; shift
   err "$@"
   exit "$ret"
}

if [ $(id -u) -ne 0 ] && [ $(id -g) -ne 0 ]; then
   fatal 127 "You need to run this script as root"
fi

# Make the getopt strictly POSIX
export POSIXLY_CORRECT=1

#
ARGS=$(getopt -o a::bc: --long arga::,argb,argc: -n 'test.sh' -- "$@")
eval set -- "$ARGS"

while true ;do
   case 
done
