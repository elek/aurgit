#!/bin/bash

# CONFIG

#working directory
AURCLONE=/home/xx/aurs

#source of the sync
AURSRC=/home/xx/satupad/aur-mirror

mkdir -p $AURCLONE 
# SANITY CHECKS
#[ ! -d $AURCLONE ] && echo "run: git clone /srv/git/aur.git/ $AURGITCLONE"j&& exit 1
#[! -d $AURCLONE ] &&  mkdir -p $AURCLONE

cd $AURCLONE


#rsync -avz --include '/*.tar.gz' --exclude '/*' --exclude '/.git/' --temp-dir '/tmp' --inplace --update --delete 'rsync://aur.archlinux.org/unsupported/*/*/*.tar.gz' . |& tee /tmp/rlog

#rsync from the git repo, as I have no permission to use rsync server
cd $AURSRC
git pull
rsync -avz -P --exclude '/.git/' --temp-dir '/tmp' --inplace --update --delete $AURSRC $AURCLONE |& tee /tmp/rlog

#iterate over the directories
for dir in `ls -1`; do
   DIR=$AURCLONE/$dir
   if [ ! -d $DIR/.git ] ; then
      git init 
   fi
   cd $DIR
   CHANGED=$(git status -s | wc -l)
   if [ $CHANGED -gt 0 ] ; then

      #calculating a good commit message
      export MESSAGE="auto update"
      export NEWVER=$(git diff --no-color  PKGBUILD | grep "+pkgver" | awk 'BEGIN{FS="="}{gsub(/[ \t]+$/, "", $2);print $2}')
      if [ ! -z "$NEWVER" ] ; then
         export MESSAGE="update to version $NEWVER"
      fi
      git add --all 
      git commit -m "$MESSAGE"
   fi
done



