#/usr/bin/env bash
# should really consider using the config file and getting the DB from there
LINE=$(grep database_file ~/.timetrap.yml 2>/dev/null || echo "database-file: ~/.timetrap.db")

TT_DB=$(echo $LINE | cut -d' ' -f2)

_tt_completions()
{
	SHEETS=`echo select distinct sheet from entries order by sheet asc | sqlite3  $TT_DB`
	IDS=`echo select distinct id from entries order by id asc | sqlite3 $TT_DB`
	OTHER="-h --help -y --yes -r --round"
	
	if [[ $COMP_CWORD -eq 1 ]]; then
		COMPREPLY=($(compgen -W "archive backend configure display edit in kill list now out resume sheet today yesterday week month" -- "${COMP_WORDS[1]}"))
	else
		let "last = COMP_CWORD - 1"
		case "${COMP_WORDS[1]}" in
			a|archive)
				COMPREPLY=($(compgen -W "$SHEETS -s --start -e --end -g --grep" -- "${COMP_WORDS[$COMP_CWORD]}"))
   				;;

			d|display)
				if [[ ${COMP_WORDS[$last]} =~ ^(-f|--format)$ ]]; then
					COMPREPLY=($(compgen -W "ical csv json ids factor text" -- "${COMP_WORDS[$COMP_CWORD]}"))
				elif ! [[ ${COMP_WORDS[$last]} =~ ^(-s|--start|-e|--end|-f|--format|-g|--grep)$ ]]; then
					COMPREPLY=($(compgen -W "$SHEETS all full -v --ids -s --start -e --end -f --format -g --grep" -- "${COMP_WORDS[$COMP_CWORD]}"))
   				fi
				;;

			e|edit)
				if [[ ${COMP_WORDS[$last]} =~ ^(-i|--id)$ ]]; then
					COMPREPLY=($(compgen -W "$IDS" -- "${COMP_WORDS[$COMP_CWORD]}"))
				elif [[ ${COMP_WORDS[$last]} =~ ^(-m|--move)$ ]]; then
					COMPREPLY=($(compgen -W "$SHEETS" -- "${COMP_WORDS[$COMP_CWORD]}"))
				else
					COMPREPLY=($(compgen -W "-m --move -i --id -s --start -e --end -z --append" -- "${COMP_WORDS[$COMP_CWORD]}"))
				fi
				;;

			i|in)
				COMPREPLY=($(compgen -W "-a --at" -- "${COMP_WORDS[$COMP_CWORD]}"))
				;;
			k|kill)
				if [[ ${COMP_WORDS[$last]} =~ ^(-i|--id)$ ]]; then
					COMPREPLY=($(compgen -W "$IDS" -- "${COMP_WORDS[$COMP_CWORD]}"))
				else
					COMPREPLY=($(compgen -W "-i --id $SHEETS" -- "${COMP_WORDS[$COMP_CWORD]}"))
				fi
				;;
			o|out)
				if ! [[ ${COMP_WORDS[$last]} =~ ^(-a|--at)$ ]]; then
					COMPREPLY=($(compgen -W "-a --at $SHEETS" -- "${COMP_WORDS[$COMP_CWORD]}"))
				fi
				;;
			r|resume)
				if [[ ${COMP_WORDS[$last]} =~ ^(-i|--id)$ ]]; then
					COMPREPLY=($(compgen -W "$IDS" -- "${COMP_WORDS[$COMP_CWORD]}"))
				elif ! [[ ${COMP_WORDS[$last]} =~ ^(-a|--at)$ ]]; then
					COMPREPLY=($(compgen -W "-i --id -a --at" -- "${COMP_WORDS[$COMP_CWORD]}"))
				fi
				;;
			s|sheet)
				COMPREPLY=($(compgen -W "- $SHEETS" -- "${COMP_WORDS[$COMP_CWORD]}"))
				;;
			t|today|y|yesterday)
				if [[ ${COMP_WORDS[$last]} =~ ^(-f|--format)$ ]]; then
					COMPREPLY=""
				else
					COMPREPLY=($(compgen -W "-i --ids -f --format $SHEETS all" -- "${COMP_WORDS[$COMP_CWORD]}"))
				fi
				;;
			*)
				;;
		esac
	fi
}

complete -F _tt_completions tt
