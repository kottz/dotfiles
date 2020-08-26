#Screenshots a region 
screen_dir=$HOME/pictures/screenshots
if [ -d $screen_dir ]
then
	timestamp=$(date +"%y-%m-%d_%T")
	slurp | grim -g - "$screen_dir/$timestamp.png"
fi
