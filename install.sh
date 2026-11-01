#!/bin/bash
#
# Installs the quiz module into a Labtainer installation on your own VM.
#
#   ./install.sh               install, or update an earlier install
#   ./install.sh --uninstall   restore the original files
#
# Run it again after update-labtainer.sh, which replaces these files.
#
set -e
here=$(cd "$(dirname "$0")" && pwd)
trunk=${LABTAINER_DIR:-$HOME/labtainer/trunk}
bin=$trunk/scripts/labtainer-student/bin
backup=$bin/.quiz_backup

if [ ! -f "$bin/quiz" ] || [ ! -f "$bin/labutils.py" ]; then
    echo "Labtainer not found at $trunk"
    echo "Set LABTAINER_DIR to your labtainer/trunk directory and try again."
    exit 1
fi

if [ "$1" == "--uninstall" ]; then
    if [ ! -d "$backup" ]; then
        echo "No backup at $backup, nothing to restore."
        exit 1
    fi
    # An update may have replaced either file, so undo only what is still ours.
    if grep -q 'quiz\.json' "$bin/labutils.py"; then
        patch -R -s "$bin/labutils.py" < "$here/labutils_quiz.patch"
        rm -f "$bin/labutils.py.orig"
        touch -r "$backup/labutils.py" "$bin/labutils.py"
    fi
    if grep -q 'MultipleChoice' "$bin/quiz"; then
        cat "$backup/quiz" > "$bin/quiz"
        touch -r "$backup/quiz" "$bin/quiz"
    fi
    rm -rf "$backup"
    echo "Quiz module removed.  Saved quiz responses were not touched."
    exit 0
fi

# update-labtainer.sh skips any file newer than its release copy.  Each changed file keeps
# its original date, otherwise an update would leave an outdated copy in place.
if grep -q 'quiz\.json' "$bin/labutils.py"; then
    echo "labutils.py already includes quiz responses."
else
    if ! command -v patch > /dev/null; then
        echo "The patch command is required: sudo apt-get install patch"
        exit 1
    fi
    if ! patch --dry-run -s "$bin/labutils.py" < "$here/labutils_quiz.patch"; then
        echo "This version of labutils.py does not accept the patch, nothing was changed."
        exit 1
    fi
    mkdir -p "$backup"
    cp -p "$bin/labutils.py" "$backup/"
    patch -s "$bin/labutils.py" < "$here/labutils_quiz.patch"
    rm -f "$bin/labutils.py.orig"
    touch -r "$backup/labutils.py" "$bin/labutils.py"
fi
if ! grep -q 'MultipleChoice' "$bin/quiz"; then
    mkdir -p "$backup"
    cp -p "$bin/quiz" "$backup/"
fi
# writes into the existing file, which keeps it executable
cat "$here/quiz" > "$bin/quiz"
touch -r "$backup/quiz" "$bin/quiz"
echo "Quiz module installed in $bin"
