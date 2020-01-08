#!/bin/bash

print_help () {
	echo
	echo "Usage:"
	echo
	if [ -z "$1" ]; then
		echo "hookline [command] <arg1> ..."
		echo
		echo "Commands:"
		echo
		echo "    help  "
		echo "    add   "
		echo "    cat   "
		echo "    del   "
		echo "    stat  "
		echo "    start "
		echo "    stop  "
		echo "    tail  "
		echo

	elif [ "$1" == "help" ]; then
		if [ -z "$2" ]; then
			echo "    hookline help <command>"
			echo
			echo "    Get help on a specific command"
			echo

		elif [ "$2" == "add" ]; then
			echo "    hookline add <alias> <source> <target>"
			echo
			echo "    Adds a new syncer by alias"
			echo

		elif [ "$2" == "cat" ]; then
			echo "    hookline cat <alias>"
			echo
			echo "    Displays the lsyncd config by alias"
			echo

		elif [ "$2" == "del" ]; then
			echo "    hookline del <alias>"
			echo
			echo "    Removes a syncer by alias"
			echo

		elif [ "$2" == "killall" ]; then
			echo "    hookline killall"
			echo
			echo "    Stops all syncers"
			echo
		fi

		elif [ "$2" == "stat" ]; then
			echo "    hookline stat"
			echo
			echo "    Get the status of all syncers"
			echo

		elif [ "$2" == "start" ]; then
			echo "    hookline start <alias>"
			echo
			echo "    Starts a syncer by alias"
			echo

		elif [ "$2" == "stop" ]; then
			echo "    hookline stop <alias>"
			echo
			echo "    Stops a syncer by alias"
			echo

		elif [ "$2" == "tail" ]; then
			echo "    hookline tail"
			echo
			echo "    Tail the log file"
			echo

		fi
	fi
}

hl_dir="$HOME/.hookline"
hl_configs_dir="$hl_dir"
hl_runtime_dir="$hl_dir"

if [ -e "$hl_dir/config" ]; then
	. "$hl_dir/config"
fi

if [ ! -d "$hl_dir" ]; then
	mkdir "$hl_dir"
fi

if [ ! -d "$hl_configs_dir" ]; then
	mkdir "$hl_configs_dir"
fi

if [ ! -d "$hl_runtime_dir" ]; then
	mkdir "$hl_runtime_dir"
fi

if [ "$#" == 0 ]; then
	print_help
	exit -1

elif [ "$1" == "help" ]; then
	print_help $1 $2

elif [ "$1" == "add" ]; then
	if [ ! "$#" == 4 ]; then
		print_help help $1
		exit -1
	fi

	opt="{ checksum = true, update = true, times = false, perms = false, links = true, cvs_exclude = true, _extra = { "--chmod=ugo=rwX" } }"

	echo "sync {"                                 >  "$hl_configs_dir/$2.cfg"
	echo "    default.rsync,"                     >> "$hl_configs_dir/$2.cfg"
	echo "    delay   = 1,"                       >> "$hl_configs_dir/$2.cfg"
	echo "    source  = \"$3\","                  >> "$hl_configs_dir/$2.cfg"
	echo "    target  = \"$4\","                  >> "$hl_configs_dir/$2.cfg"
	echo "    delete  = false,"                   >> "$hl_configs_dir/$2.cfg"
	echo "    exclude = {\"node_modules/\"},"     >> "$hl_configs_dir/$2.cfg"
	echo "    rsync   = $opt"                     >> "$hl_configs_dir/$2.cfg"
	echo "}"                                      >> "$hl_configs_dir/$2.cfg"

	echo "0" > "$hl_runtime_dir/$2.pid"

elif [ "$1" == "killall" ]; then
	for i in `ls -1 "$hl_runtime_dir/"*.pid 2>/dev/null`; do
		pid=`cat "$i"`

		if [ ! "$pid" == "0" ]; then
			cmd=`ps -l $pid | awk '{ print $14 }' | tail -1`

			if [ "$cmd" == "lsyncd" ]; then
				kill $pid
			fi
		fi

		echo "0" > "$hl_runtime_dir/$2.pid"
	done

elif [ "$1" == "cat" ]; then
	if [ ! "$#" == 2 ]; then
		print_help help $1
		exit -1
	fi

	cat "$hl_configs_dir/$2.cfg"

elif [ "$1" == "del" ]; then
	if [ ! "$#" == 2 ]; then
		print_help help $1
		exit -1
	fi

	$0 stop $2

	rm "$hl_configs_dir/$2.cfg"
	rm "$hl_runtime_dir/$2.pid"

elif [ "$1" == "stat" ]; then
	for i in `ls -1 "$hl_configs_dir/"*.cfg 2>/dev/null`; do
		stat="off"

		aid=`basename "$i" | sed 's/.cfg$//'`
		pid=`cat "$hl_runtime_dir/$aid.pid" 2>/dev/null`

		if [ ! "$pid" == "0" ] && [ ! "$pid" == "" ]; then
			cmd=`ps -l $pid | awk '{ print $14 }' | tail -1`

			if [ -z "$cmd" ]; then
				stat="off"

			elif [ "$cmd" == "lsyncd" ]; then
				stat="on"

			else
				echo "0" > "$hl_runtime_dir/$aid.pid"
			fi
		fi

		echo -e "[$stat]\t\t$aid"
	done

elif [ "$1" == "start" ]; then
	if [ ! "$#" == 2 ]; then
		print_help help $1
		exit -1
	fi

	lsyncd -pidfile "$hl_runtime_dir/$2.pid" -logfile "$hl_runtime_dir/hookline.log" "$hl_configs_dir/$2.cfg"

elif [ "$1" == "stop" ]; then
	if [ ! "$#" == 2 ]; then
		print_help help $1
		exit -1
	fi

	pid=`cat "$hl_runtime_dir/$2.pid"`

	if [ ! "$pid" == "0" ]; then
		cmd=`ps -l $pid | awk '{ print $14 }' | tail -1`

		if [ "$cmd" == "lsyncd" ]; then
			kill $pid
		fi
	fi

	echo "0" > "$hl_runtime_dir/$2.pid"

elif [ "$1" == "tail" ]; then
	tail -f "$hl_runtime_dir/hookline.log"

elif [ "$1" == "install" ]; then
	sudo cp $0 /usr/bin/hookline
	sudo chmod 755 /usr/bin/hookline

fi
