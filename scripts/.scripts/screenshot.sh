#Screenshot entire screen
screen_dir=$HOME/pictures/screenshots
if [ -d $screen_dir ]
then
	timestamp=$(date +"%y-%m-%d_%T")
        grim "$screen_dir/$timestamp.png"
fi
