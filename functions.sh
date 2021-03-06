# Archlinux Ultimate Install - .bashrc
# by helmuthdu
# OVERALL CONDITIONALS {{{

# TOP 11 COMMANDS {{{
top10() { history | awk '{a[$2]++ } END{for(i in a){print a[i] " " i}}' | sort -rn | head; }
#}}}

# UP {{{
# Goes up many dirs as the number passed as argument, if none goes up by 1 by default
up() {
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [[ -z "$d" ]]; then
        d=..
    fi
    cd $d
}
#}}}

# CONVERT TO ISO {{{
to_iso () {
    if [[ $# == 0 || $1 == "--help" || $1 == "-h" ]]; then
        echo -e "Converts raw, bin, cue, ccd, img, mdf, nrg cd/dvd image files to ISO image file.\nUsage: to_iso file1 file2..."
    fi
    for i in $*; do
        if [[ ! -f "$i" ]]; then
            echo "'$i' is not a valid file; jumping it"
        else
            echo -n "converting $i..."
            OUT=`echo $i | cut -d '.' -f 1`
            case $i in
                *.raw ) bchunk -v $i $OUT.iso;; #raw=bin #*.cue #*.bin
                *.bin|*.cue ) bin2iso $i $OUT.iso;;
                *.ccd|*.img ) ccd2iso $i $OUT.iso;; #Clone CD images
                *.mdf ) mdf2iso $i $OUT.iso;; #Alcohol images
                *.nrg ) nrg2iso $i $OUT.iso;; #nero images
                * ) echo "to_iso don't know de extension of '$i'";;
            esac
            if [[ $? != 0 ]]; then
                echo -e "${R}ERROR!${W}"
            else
                echo -e "${G}done!${W}"
            fi
        fi
    done
}
#}}}

# REMIND ME, ITS IMPORTANT! {{{
# usage: remindme <time> <text>
# e.g.: remindme 10m "omg, the pizza"
remindme() {
    if [[ "$#" -lt 2 ]]; then
        echo -e "Usage: remindme [time] '[message]'"
        echo -e "Example: remindme 50s 'check mail'"
        echo -e "Example: remindme 10m 'go to class'"
        #exit 0 #not enough args
    fi
    if [[ "$#" -gt 2 ]]; then
        echo -e "Usage: remindme [time] '[message]'"
        echo -e "Example: remindme 50s 'check mail'"
        echo -e "Example: remindme 10m 'go to class'"
        #exit 0 #more than enough args
    fi
    if  [[ "$#" == 2 ]]; then
        sleep $1 && notify-send -t 15000 "$2" & echo 'Reminder set'
    fi
}
#}}}


## SWAP 2 FILENAMES AROUND, IF THEY EXIST {{{
#(from Uzi's bashrc).
swap() {
    local TMPFILE=tmp.$$
    
    [[ $# -ne 2 ]] && echo "swap: 2 arguments needed" && return 1
    [[ ! -e $1 ]] && echo "swap: $1 does not exist" && return 1
    [[ ! -e $2 ]] && echo "swap: $2 does not exist" && return 1
    
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}
#}}}



## FIND AND REMOVED EMPTY DIRECTORIES {{{
fared() {
    read -p "Delete all empty folders recursively [y/N]: " OPT
    [[ $OPT == y ]] && find . -type d -empty -exec rm -fr {} \; &> /dev/null
}
#}}}

## FIND AND REMOVED ALL DOTFILES {{{
farad () {
    read -p "Delete all dotfiles recursively [y/N]: " OPT
    [[ $OPT == y ]] && find . -name '.*' -type f -exec rm -rf {} \;
}
#}}}

# ENTER AND LIST DIRECTORY{{{
function cd() { builtin cd -- "$@" && { [ "$PS1" = "" ] || ls -hrt --color; }; }
#}}}

# SYSTEMD SUPPORT {{{
if which systemctl &>/dev/null; then
    start() {
        sudo systemctl start $1.service
    }
    restart() {
        sudo systemctl restart $1.service
    }
    stop() {
        sudo systemctl stop $1.service
    }
    enable() {
        sudo systemctl enable $1.service
    }
    status() {
        sudo systemctl status $1.service
    }
    disable() {
        sudo systemctl disable $1.service
    }
fi
#}}}

# MKDIR AND CD INTO NEW DIR{{{
mkcd() {
    if [ $# != 1 ]; then
        echo "Usage: mkcd <dir>"
    else
        mkdir -p $1 && cd $1
    fi
}
#}}}


# NVM {{{
if [[ -f "/usr/share/nvm/nvm.sh" ]]; then
    source /usr/share/nvm/init-nvm.sh
fi
#}}}


# VTE {{{
if [[ $TERMINIX_ID ]]; then
    source /etc/profile.d/vte.sh
fi
#}}}

# ANDROID SDK {{{
if [[ -d "/opt/android-sdk" ]]; then
    export ANDROID_HOME=/opt/android-sdk
fi
#}}}

# CHROME {{{
if which google-chrome-stable &>/dev/null; then
    export CHROME_BIN=/usr/bin/google-chrome-stable
fi
#}}}


# BASH HISTORY {{{
# make multiple shells share the same history file
export HISTSIZE=1000            # bash history will save N commands
export HISTFILESIZE=${HISTSIZE} # bash will remember N commands
export HISTCONTROL=ignoreboth   # ingore duplicates and spaces
export HISTIGNORE='&:ls:ll:la:cd:exit:clear:history'
#}}}


# FUNCTIONS {{{
# BETTER GIT COMMANDS {{{
bit() {
    # By helmuthdu
    usage(){
        echo "Usage: $0 [options]"
        echo "  --init                                              # Autoconfigure git options"
        echo "  a, [add] <files> [--all]                            # Add git files"
        echo "  c, [commit] <text> [--undo]                         # Add git files"
        echo "  C, [cherry-pick] <number> <url> [branch]            # Cherry-pick commit"
        echo "  b, [branch] feature|hotfix|<name>                   # Add/Change Branch"
        echo "  d, [delete] <branch>                                # Delete Branch"
        echo "  l, [log]                                            # Display Log"
        echo "  m, [merge] feature|hotfix|<name> <commit>|<version> # Merge branches"
        echo "  p, [push] <branch>                                  # Push files"
        echo "  P, [pull] <branch> [--foce]                         # Pull files"
        echo "  r, [release]                                        # Merge unstable branch on master"
        echo "  u, [release]                                        # undo comit"
        return 1
    }
    case $1 in
        --init)
            local NAME=`git config --global user.name`
            local EMAIL=`git config --global user.email`
            local USER=`git config --global github.user`
            local EDITOR=`git config --global core.editor`
            
            [[ -z $NAME ]] && read -p "Name: " NAME
            [[ -z $EMAIL ]] && read -p "Email: " EMAIL
            [[ -z $USER ]] && read -p "Username: " USER
            [[ -z $EDITOR ]] && read -p "Editor: " EDITOR
            
            git config --global user.name $NAME
            git config --global user.email $EMAIL
            git config --global github.user $USER
            git config --global color.ui true
            git config --global color.status auto
            git config --global color.branch auto
            git config --global color.diff auto
            git config --global diff.color true
            git config --global core.filemode true
            git config --global push.default matching
            git config --global core.editor $EDITOR
            git config --global format.signoff true
            git config --global alias.reset 'reset --soft HEAD^'
            git config --global alias.graph 'log --graph --oneline --decorate'
            git config --global alias.compare 'difftool --dir-diff HEAD^ HEAD'
            if which meld &>/dev/null; then
                git config --global diff.guitool meld
                git config --global merge.tool meld
                elif which kdiff3 &>/dev/null; then
                git config --global diff.guitool kdiff3
                git config --global merge.tool kdiff3
            fi
            git config --global --list
        ;;
        a | add)
            if [[ $2 == --all ]]; then
                git add -A
            else
                git add $2
            fi
        ;;
        b | branch )
            check_branch=`git branch | grep $2`
            case $2 in
                feature)
                    check_unstable_branch=`git branch | grep unstable`
                    if [[ -z $check_unstable_branch ]]; then
                        echo "creating unstable branch..."
                        git branch unstable
                        git push origin unstable
                    fi
                    git checkout -b feature --track origin/unstable
                ;;
                hotfix)
                    git checkout -b hotfix master
                ;;
                master)
                    git checkout master
                ;;
                *)
                    check_branch=`git branch | grep $2`
                    if [[ -z $check_unstable_branch ]]; then
                        echo "creating $2 branch..."
                        git branch $2
                        git push origin $2
                    fi
                    git checkout $2
                ;;
            esac
        ;;
        c | commit )
            if [[ $2 == --undo ]]; then
                git reset --soft HEAD^
            else
                git commit -am "$2"
            fi
        ;;
        C | cherry-pick )
            git checkout -b patch master
            git pull $2 $3
            git checkout master
            git cherry-pick $1
            git log
            git branch -D patch
        ;;
        d | delete)
            check_branch=`git branch | grep $2`
            if [[ -z $check_branch ]]; then
                echo "No branch founded."
            else
                git branch -D $2
                git push origin --delete $2
            fi
        ;;
        l | log )
            git log --graph --oneline --decorate
        ;;
        m | merge )
            check_branch=`git branch | grep $2`
            case $2 in
                --fix)
                    git mergetool
                ;;
                feature)
                    if [[ -n $check_branch ]]; then
                        git checkout unstable
                        git difftool -g -d unstable..feature
                        git merge --no-ff feature
                        git branch -d feature
                        git commit -am "${3}"
                    else
                        echo "No unstable branch founded."
                    fi
                ;;
                hotfix)
                    if [[ -n $check_branch ]]; then
                        # get upstream branch
                        git checkout -b unstable origin
                        git merge --no-ff hotfix
                        git commit -am "hotfix: v${3}"
                        # get master branch
                        git checkout -b master origin
                        git merge hotfix
                        git commit -am "Hotfix: v${3}"
                        git branch -d hotfix
                        git tag -a $3 -m "Release: v${3}"
                        git push --tags
                    else
                        echo "No hotfix branch founded."
                    fi
                ;;
                *)
                    if [[ -n $check_branch ]]; then
                        git checkout -b master origin
                        git difftool -g -d master..$2
                        git merge --no-ff $2
                        git branch -d $2
                        git commit -am "${3}"
                    else
                        echo "No unstable branch founded."
                    fi
                ;;
            esac
        ;;
        p | push )
            git push origin $2
        ;;
        P | pull )
            if [[ $2 == --force ]]; then
                git fetch --all
                git reset --hard origin/master
            else
                git pull origin $2
            fi
        ;;
        r | release )
            git checkout origin/master
            git merge --no-ff origin/unstable
            git branch -d unstable
            git tag -a $2 -m "Release: v${2}"
            git push --tags
        ;;
        *)
            usage
    esac
}
#}}}


# ARCHIVE EXTRACTOR {{{
extract() {
    clrstart="\033[1;34m"  #color codes
    clrend="\033[0m"
    
    if [[ "$#" -lt 1 ]]; then
        echo -e "${clrstart}Pass a filename. Optionally a destination folder. You can also append a v for verbose output.${clrend}"
        exit 1 #not enough args
    fi
    
    if [[ ! -e "$1" ]]; then
        echo -e "${clrstart}File does not exist!${clrend}"
        exit 2 #file not found
    fi
    
    if [[ -z "$2" ]]; then
        DESTDIR="." #set destdir to current dir
        elif [[ ! -d "$2" ]]; then
        echo -e -n "${clrstart}Destination folder doesn't exist or isnt a directory. Create? (y/n): ${clrend}"
        read response
        #echo -e "\n"
        if [[ $response == y || $response == Y ]]; then
            mkdir -p "$2"
            if [ $? -eq 0 ]; then
                DESTDIR="$2"
            else
                exit 6 #Write perms error
            fi
        else
            echo -e "${clrstart}Closing.${clrend}"; exit 3 # n/wrong response
        fi
    else
        DESTDIR="$2"
    fi
    
    if [[ ! -z "$3" ]]; then
        if [[ "$3" != "v" ]]; then
            echo -e "${clrstart}Wrong argument $3 !${clrend}"
            exit 4 #wrong arg 3
        fi
    fi
    
    filename=`basename "$1"`
    
    #echo "${filename##*.}" debug
    
    case "${filename##*.}" in
        tar)
            echo -e "${clrstart}Extracting $1 to $DESTDIR: (uncompressed tar)${clrend}"
            tar x${3}f "$1" -C "$DESTDIR"
        ;;
        gz)
            echo -e "${clrstart}Extracting $1 to $DESTDIR: (gip compressed tar)${clrend}"
            tar x${3}fz "$1" -C "$DESTDIR"
        ;;
        tgz)
            echo -e "${clrstart}Extracting $1 to $DESTDIR: (gip compressed tar)${clrend}"
            tar x${3}fz "$1" -C "$DESTDIR"
        ;;
        xz)
            echo -e "${clrstart}Extracting  $1 to $DESTDIR: (gip compressed tar)${clrend}"
            tar x${3}f -J "$1" -C "$DESTDIR"
        ;;
        bz2)
            echo -e "${clrstart}Extracting $1 to $DESTDIR: (bzip compressed tar)${clrend}"
            tar x${3}fj "$1" -C "$DESTDIR"
        ;;
        zip)
            echo -e "${clrstart}Extracting $1 to $DESTDIR: (zipp compressed file)${clrend}"
            unzip "$1" -d "$DESTDIR"
        ;;
        rar)
            echo -e "${clrstart}Extracting $1 to $DESTDIR: (rar compressed file)${clrend}"
            unrar x "$1" "$DESTDIR"
        ;;
        7z)
            echo -e  "${clrstart}Extracting $1 to $DESTDIR: (7zip compressed file)${clrend}"
            7za e "$1" -o"$DESTDIR"
        ;;
        *)
            echo -e "${clrstart}Unknown archieve format!"
            exit 5
        ;;
    esac
}
#}}}
# ARCHIVE COMPRESS {{{
compress() {
    if [[ -n "$1" ]]; then
        FILE=$1
        case $FILE in
            *.tar ) shift && tar cf $FILE $* ;;
            *.tar.bz2 ) shift && tar cjf $FILE $* ;;
            *.tar.gz ) shift && tar czf $FILE $* ;;
            *.tgz ) shift && tar czf $FILE $* ;;
            *.zip ) shift && zip $FILE $* ;;
            *.rar ) shift && rar $FILE $* ;;
        esac
    else
        echo "usage: compress <foo.tar.gz> ./foo ./bar"
    fi
}
#}}}


# FILE & STRINGS RELATED FUNCTIONS {{{
## FIND A FILE WITH A PATTERN IN NAME {{{
ff() { find . -type f -iname '*'$*'*' -ls ; }
#}}}
## FIND A FILE WITH PATTERN $1 IN NAME AND EXECUTE $2 ON IT {{{
fe() { find . -type f -iname '*'$1'*' -exec "${2:-file}" {} \;  ; }
#}}}
## MOVE FILENAMES TO LOWERCASE {{{
lowercase() {
    for file ; do
        filename=${file##*/}
        case "$filename" in
            */* ) dirname==${file%/*} ;;
            * ) dirname=.;;
        esac
        nf=$(echo $filename | tr A-Z a-z)
        newname="${dirname}/${nf}"
        if [[ "$nf" != "$filename" ]]; then
            mv "$file" "$newname"
            echo "lowercase: $file --> $newname"
        else
            echo "lowercase: $file not changed."
        fi
    done
}
#}}}



## FINDS DIRECTORY SIZES AND LISTS THEM FOR THE CURRENT DIRECTORY {{{
dirsize () {
    du -shx * .[a-zA-Z0-9_]* 2> /dev/null | egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
    egrep '^ *[0-9.]*M' /tmp/list
    egrep '^ *[0-9.]*G' /tmp/list
    rm -rf /tmp/list
}
#}}}

# start setting from notebook acer
# function top() {
#     synclient TapButton1=1
# }
#  top

# end setting from notebook acer

function killport() {
    fuser -k 4000/tcp
    kill $(sudo lsof -t -i:4000)
}

# NVM SUPPORT {{{
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#}}}


# COMPLETION {{{
complete -cf sudo
if [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
fi
#}}}

# CONFIG {{{
export PATH=/usr/local/bin:$PATH
if [[ -d "$HOME/bin" ]] ; then
    PATH="$HOME/bin:$PATH"
fi
# RUBY {{{
if which ruby &>/dev/null; then
    GEM_DIR=$(ruby -r rubygems -e 'puts Gem.user_dir')/bin
    if [[ -d "$GEM_DIR" ]]; then
        export PATH=$GEM_DIR:$PATH
    fi
fi
#}}}

# NVM {{{
if [[ -f "/usr/share/nvm/nvm.sh" ]]; then
    source /usr/share/nvm/init-nvm.sh
fi
#}}}


# VTE {{{
if [[ $TERMINIX_ID ]]; then
    source /etc/profile.d/vte.sh
fi
#}}}


# ANDROID SDK {{{
if [[ -d "/opt/android-sdk" ]]; then
    export ANDROID_HOME=/opt/android-sdk
fi
#}}}


# CHROME {{{
if which google-chrome-stable &>/dev/null; then
    export CHROME_BIN=/usr/bin/google-chrome-stable
fi
#}}}


# EDITOR {{{
if which vim &>/dev/null; then
    export EDITOR="vim"
    elif which emacs &>/dev/null; then
    export EDITOR="emacs -nw"
else
    export EDITOR="nano"
fi
#}}}


# FUNCTIONS {{{
# BETTER GIT COMMANDS {{{
bit() {
    # By helmuthdu
    usage(){
        echo "Usage: $0 [options]"
        echo "  --init                                              # Autoconfigure git options"
        echo "  a, [add] <files> [--all]                            # Add git files"
        echo "  c, [commit] <text> [--undo]                         # Add git files"
        echo "  cls, [clear]                                        # Delete unstable all"
        echo "  C, [cherry-pick] <number> <url> [branch]            # Cherry-pick commit"
        echo "  b, [branch] feature|hotfix|<name>                   # Add/Change Branch"
        echo "  d, [delete] <branch>                                # Delete Branch"
        echo "  l, [log]                                            # Display Log"
        echo "  m, [merge] feature|hotfix|<name> <commit>|<version> # Merge branches"
        echo "  p, [push] <branch>                                  # Push files"
        echo "  P, [pull] <branch> [--foce]                         # Pull files"
        echo "  r, [release]                                        # Merge unstable branch on master"
        return 1
    }
    case $1 in
        --init)
            local NAME=`git config --global user.name`
            local EMAIL=`git config --global user.email`
            local USER=`git config --global github.user`
            local EDITOR=`git config --global core.editor`
            
            [[ -z $NAME ]] && read -p "Name: " NAME
            [[ -z $EMAIL ]] && read -p "Email: " EMAIL
            [[ -z $USER ]] && read -p "Username: " USER
            [[ -z $EDITOR ]] && read -p "Editor: " EDITOR
            
            git config --global user.name $NAME
            git config --global user.email $EMAIL
            git config --global github.user $USER
            git config --global color.ui true
            git config --global color.status auto
            git config --global color.branch auto
            git config --global color.diff auto
            git config --global diff.color true
            git config --global core.filemode true
            git config --global push.default matching
            git config --global core.editor $EDITOR
            git config --global format.signoff true
            git config --global alias.reset 'reset --soft HEAD^'
            git config --global alias.graph 'log --graph --oneline --decorate'
            git config --global alias.compare 'difftool --dir-diff HEAD^ HEAD'
            if which meld &>/dev/null; then
                git config --global diff.guitool meld
                git config --global merge.tool meld
                elif which kdiff3 &>/dev/null; then
                git config --global diff.guitool kdiff3
                git config --global merge.tool kdiff3
            fi
            git config --global --list
        ;;
        a | add)
            if [[ $2 == --all ]]; then
                git add -A
            else
                git add $2
            fi
        ;;
        cls| clear)
            git add .
            git checkout -f
            
        ;;
        b | branch )
            check_branch=`git branch | grep $2`
            case $2 in
                feature)
                    check_unstable_branch=`git branch | grep unstable`
                    if [[ -z $check_unstable_branch ]]; then
                        echo "creating unstable branch..."
                        git branch unstable
                        git push origin unstable
                    fi
                    git checkout -b feature --track origin/unstable
                ;;
                hotfix)
                    git checkout -b hotfix master
                ;;
                master)
                    git checkout master
                ;;
                *)
                    check_branch=`git branch | grep $2`
                    if [[ -z $check_unstable_branch ]]; then
                        echo "creating $2 branch..."
                        git branch $2
                        git push origin $2
                    fi
                    git checkout $2
                ;;
            esac
        ;;
        c | commit )
            if [[ $2 == --undo ]]; then
                git reset --soft HEAD^
            else
                git commit -am "$2"
            fi
        ;;
        C | cherry-pick )
            git checkout -b patch master
            git pull $2 $3
            git checkout master
            git cherry-pick $1
            git log
            git branch -D patch
        ;;
        d | delete)
            check_branch=`git branch | grep $2`
            if [[ -z $check_branch ]]; then
                echo "No branch founded."
            else
                git branch -D $2
                git push origin --delete $2
            fi
        ;;
        l | log )
            git log --graph --oneline --decorate
        ;;
        m | merge )
            check_branch=`git branch | grep $2`
            case $2 in
                --fix)
                    git mergetool
                ;;
                feature)
                    if [[ -n $check_branch ]]; then
                        git checkout unstable
                        git difftool -g -d unstable..feature
                        git merge --no-ff feature
                        git branch -d feature
                        git commit -am "${3}"
                    else
                        echo "No unstable branch founded."
                    fi
                ;;
                hotfix)
                    if [[ -n $check_branch ]]; then
                        # get upstream branch
                        git checkout -b unstable origin
                        git merge --no-ff hotfix
                        git commit -am "hotfix: v${3}"
                        # get master branch
                        git checkout -b master origin
                        git merge hotfix
                        git commit -am "Hotfix: v${3}"
                        git branch -d hotfix
                        git tag -a $3 -m "Release: v${3}"
                        git push --tags
                    else
                        echo "No hotfix branch founded."
                    fi
                ;;
                *)
                    if [[ -n $check_branch ]]; then
                        git checkout -b master origin
                        git difftool -g -d master..$2
                        git merge --no-ff $2
                        git branch -d $2
                        git commit -am "${3}"
                    else
                        echo "No unstable branch founded."
                    fi
                ;;
            esac
        ;;
        p | push )
            git push origin $2
        ;;
        P | pull )
            if [[ $2 == --force ]]; then
                git fetch --all
                git reset --hard origin/master
            else
                git pull origin $2
            fi
        ;;
        r | release )
            git checkout origin/master
            git merge --no-ff origin/unstable
            git branch -d unstable
            git tag -a $2 -m "Release: v${2}"
            git push --tags
        ;;
        *)
            usage
    esac
}
#}}}