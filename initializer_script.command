if [[ $1 == "" ]]; then
	echo "Please drag and drop a valid CSV into the app."
	exit 1
fi

cd "$(dirname "$0")"

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

rubyinterp/bin/ruby 'initializer.rb' $1
exit 0
