#Screenshot entire screen
screen_dir=$HOME/Pictures/screenshots
if [ -d $screen_dir ]
then
	timestamp=$(date +"%y-%m-%d_%T")
        grim "$screen_dir/$timestamp.png"
        notify-send "Screenshot taken"
fi
