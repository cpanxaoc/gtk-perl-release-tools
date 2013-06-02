#!/bin/sh

# Copyright (c)2013 by Brian Manning.  License terms are listed at the
# bottom of this file
#
# Create the "release deadline" e-mail

### OUTPUT COLORIZATION VARIABLES ###
START="["
END="m"

# text attributes
NONE=0; BOLD=1; NORM=2; BLINK=5; INVERSE=7; CONCEALED=8

# background colors
B_BLK=40; B_RED=41; B_GRN=42; B_YLW=43
B_BLU=44; B_MAG=45; B_CYN=46; B_WHT=47

# foreground colors
F_BLK=30; F_RED=31; F_GRN=32; F_YLW=33
F_BLU=34; F_MAG=35; F_CYN=36; F_WHT=37

# some shortcuts
MSG_DELETE="${BOLD};${F_YLW};${B_RED}"
MSG_DRYRUN="${BOLD};${F_WHT};${B_BLU}"
MSG_VERBOSE="${BOLD};${F_WHT};${B_GRN}"
MSG_INFO="${BOLD};${F_BLU};${B_WHT}"

### MAIN SCRIPT ###
# what's my name?
SCRIPTNAME=$(basename $0)
# path to the perl binary

# set quiet mode by default, needs to be set prior to the getops call
QUIET=0

### SCRIPT SETUP ###
# BSD's getopt is simpler than the GNU getopt; we need to detect it
# BSD's getopt is simpler than the GNU getopt; we need to detect it
if [ -x /usr/bin/uname ]; then
    OSDETECT=$(/usr/bin/uname -s)
elif [ -x /bin/uname ]; then
    OSDETECT=$(/bin/uname -s)
else
    echo "ERROR: can't run 'uname -s' command to determine system type"
    exit 1
fi

if [ $OSDETECT = "Darwin" ]; then
    ECHO_CMD="builtin echo"
elif [ $OSDETECT = "Linux" ]; then
    ECHO_CMD="builtin echo -e"
else
    ECHO_CMD="echo"
fi

# these paths cover a majority of my test machines
for GETOPT_CHECK in "/opt/local/bin/getopt" "/usr/local/bin/getopt" \
    "/usr/bin/getopt";
do
    if [ -x "${GETOPT_CHECK}" ]; then
        GETOPT_BIN=$GETOPT_CHECK
        break
    fi
done

# did we find an actual binary out of the list above?
if [ -z "${GETOPT_BIN}" ]; then
    echo "ERROR: getopt binary not found, script can't execute; exiting...."
    exit 1
fi
# Use short options if we're using Darwin's getopt
if [ $OSDETECT = "Darwin" -a $GETOPT_BIN = "/usr/bin/getopt" ]; then
    GETOPT_TEMP=$(${GETOPT_BIN} hvr:d: $*)
else
# Use short and long options with GNU's getopt
    GETOPT_TEMP=$(${GETOPT_BIN} -o hvr:d: \
        --long help,verbose,release-date:,deadline-date: \
        -n "${SCRIPTNAME}" -- "$@")
fi

# if getopts exited with an error code, then exit the script
#if [ $? -ne 0 -o $# -eq 0 ] ; then
if [ $? != 0 ] ; then
    echo "Run '${SCRIPTNAME} --help' to see script options" >&2
    if [ $OSDETECT = "Darwin" -a $GETOPT_BIN = "/usr/bin/getopt" ]; then
        echo "WARNING: 'Darwin' OS and system '/usr/bin/getopt' detected;" >&2
        echo "WARNING: Only short options (-h, -e, etc.) will work" >&2
        echo "WARNING: with system '/usr/bin/getopt' under 'Darwin' OS" >&2
    fi
    exit 1
fi

function show_help () {
cat <<-EOF

    ${SCRIPTNAME} [options]

    SCRIPT RELEASE_DATES
    -h|--help           Displays this help message
    -v|--verbose        Nice pretty output messages
    -r|--release-date   Date of the GTK release
    -d|--deadline-date  Deadline date for submissions for Gtk2-Perl releases
    NOTE: Long switches do not work with BSD systems (GNU extension)

EOF
}

# Note the quotes around `$TEMP': they are essential!
# read in the $TEMP variable
eval set -- "$GETOPT_TEMP"

# read in command line options and set appropriate environment variables
# if you change the below switches to something else, make sure you change the
# getopts call(s) above
while true ; do
    case "$1" in
        # show the script options
        -h|--help)
            show_help
            exit 0;;
        # don't output anything (unless there's an error)
        -q|--quiet)
            QUIET=1
            shift;;
        # output pretty messages
        -v|--verbose)
            QUIET=0
            shift;;
        # date of the GTK release
        -r|--release-date)
            RELEASE_DATE=$2;
            shift 2;;
        # deadline date for Gtk2-Perl submissions
        -d|--deadline-date)
            DEADLINE_DATE=$2;
            shift 2;;
        # handle the separator between options and files
        --) shift;
            break;;
        # we shouldn't get here; die gracefully
        *)
            echo "ERROR: unknown option '$1'" >&2
            echo "ERROR: use --help to see all script options" >&2
            exit 1
            ;;
    esac
done

### SCRIPT MAIN LOOP ###
if [ "x${RELEASE_DATE}" = "x" ]; then
    echo "ERROR: missing --release-date argument"
    exit 1
fi

if [ "x${DEADLINE_DATE}" = "x" ]; then
    echo "ERROR: missing --deadline-date argument"
    exit 1
fi

if [ $QUIET -eq 0 ]; then
    # run the script
    $ECHO_CMD
    $ECHO_CMD "=-= Generate Release E-mail =-="
    $ECHO_CMD "- Release date: ${RELEASE_DATE}"
    $ECHO_CMD "- Deadline date: ${DEADLINE_DATE}"
fi

echo
echo
echo "Subject line: Next release deadline: ${DEADLINE_DATE} at 00:00 UTC"
echo
echo
# generate a date for checking for errors
cat <<-EOF
Hi folks,

Checking the Gnome release calendar[1], the next release of Gnome
libraries will take place on ${RELEASE_DATE}.  I'm going to set the
deadline for code submissions for April's release of Gtk2-Perl modules
to be ${DEADLINE_DATE} at 00:00 UTC.

Please have all code submissions into the Gtk2-Perl maintainers before
the above deadline; please allow time for the maintainers to audit and
test code submissions.  If you have your favorite RT ticket[2][3] or
Gnome bug tracker bug[4] that you would like looked at, don't be
afraid to bring it up for discussion here on the mailing list.

Once the above deadline date arrives, I will begin packaging any
new code in the Gtk2-Perl git repos.  Once packaged, I will distribute
it to the appropriate places, and post the release announcements shortly
thereafter.

If you have any questions about the above, please ask.

Thanks,

Brian

[1] https://live.gnome.org/ThreePointNine
[2] https://rt.cpan.org/Public/Dist/ByMaintainer.html?Name=XAOC
[3] https://rt.cpan.org/Public/Dist/ByMaintainer.html?Name=TSCH
[4] https://bugzilla.gnome.org/browse.cgi?product=gnome-perl
EOF

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

# vi: set filetype=sh shiftwidth=4 tabstop=4
# end of line
