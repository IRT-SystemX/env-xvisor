#! /usr/bin/env bash
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
# @file scripts/upstreamer.sh
#

set -u
set -e

branch="master"
email="xvisor-devel@googlegroups.com"
cover_letter="0000-cover-letter.patch"

# Determine the error function
which tput &> /dev/null
if [ $? -eq 0 ]; then # tput exists
   err() {
      printf "$(tput setaf 1)ERROR:$(tput sgr0) %s\n" "$@" 1>&2
      exit 1
   }
   msg() {
      printf "$(tput setaf 6)INFO:$(tput sgr0) %s\n" "$@"
   }
   highlight() {
      attr="$1" ; shift
      printf "$(tput setaf "$attr")$(tput bold)%s$(tput sgr0)\n" "$@"
      unset attr
   }
else # tput is not present
   err() {
      echo "*** $*" 1>&2
      exit 1
   }
   msg() {
      echo "$@"
   }
   highlight() {
      shift
      echo "=> $*"
   }
fi

# For fun. Prints an error message and quits
sorry() {
   set +u
   if [ -z "$USER" ]; then
      USER="Dave"
   fi
   set -u
   err "I'm sorry $USER, I can't let you do that... $*"
}

prompt() {
   answer=""
   while [ x"$answer" != x"y" ] && [ x"$answer" != x"n" ]; do
      msg "$* [y/n]"
      read answer
   done
   if [ x"$answer" = x"y" ]; then
      return 0
   fi
   return 1
}

# Must be in top source directory. Just because.
if [ ! -d .git/ ]; then
   err "You must be in the top source directory"
fi

# At this point we heavily rely on prompts. Disable this...
set +e

# Did we rebase first?
prompt "Did you rebase onto mainstream master?";
if [ $? -ne 0 ]; then
   sorry "Just rebase or you will have conflicts"
fi

# Did you compile?
prompt "Did you push your branch and wait for Jenkins to validate?"
if [ $? -ne 0 ]; then
   sorry "Don't even think about submitting code that does not event compile"
fi

# Extract all patches
msg "Extracting patches on branch ${branch}..."
patches=$(git format-patch --signoff --cover-letter -M -C "$branch")
for p in $patches; do # Print the list
   echo "$p"
done

# No patches?
if [ x"$patches" = "x" ]; then
   err "Could not retrieve any patches??? "
      "Your current branch must-not be up-to-date with $branch."
fi

# Warn that we are about to launch an editor
prompt "Will now edit the cover letter. Ready?"
if [ $? -ne 0 ]; then
   sorry "You need to edit the cover letter"
fi
set +u
if [ -z "$EDITOR" ]; then
   EDITOR="nano" ; which "$EDITOR" &> /dev/null
   if [ $? -ne 0 ]; then
      EDITOR="vi" ; which "$EDITOR" &> /dev/null
      if [ $? -ne 0 ]; then
         EDITOR="emacs" ; which "$EDITOR" &> /dev/null
         if [ $? -ne 0 ]; then
            err "Unable to find a valid editor. Please set \$EDITOR"
         fi
      fi
   fi
fi
set -u

# Actual call to the editor
"$EDITOR" "$cover_letter"
if [ $? -ne 0 ]; then
   err "$EDITOR terminated with error $?"
fi

# Recap: what are we sending
msg "Summary: cover letter:"
highlight "2" "$(cat "$cover_letter")"
msg "Summary: patches to be send:"
for p in $patches; do
   highlight "3" "$p"
done

# Confirmation...
highlight "1" "=== DANGER ZONE! PLEASE ANSWER VERY CAREFULLY! ==="
prompt "About to send all patches above to ${email}... Ok?"
if [ $? -ne 0 ]; then
   msg "It's okay, take your time"
   exit 0
else
   prompt "Are you absolutely sure? You are about to send emails worldwide!"
   if [ $? -ne 0 ]; then
      msg "It's okay, take your time"
      exit 0
   fi
fi

# Actually send!
# No "$patches" byt $patches because it is a list!
git send-email --to="$email" $patches

# Clean-up
prompt "Do you wish to remove the patch files?"
if [ $? -eq 0 ]; then
   for p in $patches; do
      msg "Removing $p"
      rm "$p"
   done
fi
