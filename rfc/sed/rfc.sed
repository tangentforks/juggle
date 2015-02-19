#! /bin/bash
#
# rfc  takes  as its argument a number of a rfc. If it finds a
# matching rfc in the local file system, it displays its  con-
# tents,    otherwise    it    tries    to    get    it   from
# ftp.nic.de:/pub/rfc/, saves it and  then  displays  the contents.

#set -x

# function for output of errormessage, then exit
usage (  ) {
	echo ""
	echo "Usage:"
	echo ""
	echo "rfc rfc-number		takes as its argument a number of a rfc"
	echo "			if that rfc exists then it is copied to stdout"
	echo ""
	echo "rfc -i [rfc|std]	default is rfc; shows rfc or standard index"
	echo ""
	echo "rfc -k keyword		looks keyword up in all index-files and"
	echo "			outputs the matching lines"
	echo ""
	exit 2
}

n=${1-"-index"}
p=${PAGER-"less -s"}
rfcdir=/ftp/pub/networking/rfc
tmp=/tmp/rfctmp.$$

cd $rfcdir

# erstmal checken, ob optionen angegeben wurden

case "$1"
in
       -i)
	    # option i : index zeigen
	    shift
	    val=$1

	    if [ "$1" = "" ]
	    then
		# default bei option i ist rfc, wenn nix angegeben ist
		val=rfc
	    else
		# naechstes argument ansehen, wenn es eines gibt
		shift
	    fi

	    # wenn danach noch argumente kommen -> falsch
	    if [ $# -gt 0 ]
	    then
		usage
	    fi

	    # wenn der parameter fuer die option falsch angegeben wurde
	    file="`ls $rfcdir/$val-index.* 2>/dev/null`"
	    if [ "$file" = "" ]
	    then
		usage 
	    fi

	    # wenn alles geklappt hat, dann den gewuenschten index ausgeben
	    for i in $file
	    do
		case $i
		in
		    *gz | *Z) 	zcat $i | $p ; exit 0;;
		    *) 		cat  $i | $p ; exit 0;;
		esac
	    done;;
       -k)
	    # option k : den index nach einem keyword durchsuchen
	    shift
	    keyword="$1"

	    # checken, ob die option einen parameter bekommen hat
	    if [ "$1" = "" ]
	    then
		# -k muss ein argument haben
		usage 
	    else
		# naechstes argument ansehen, wenn es eines gibt
		shift
	    fi

	    # wenn danach noch argumente kommen -> falsch
	    if [ $# -gt 0 ]
	    then
		usage
	    fi

	    # alle index-files durchsehen, ob das keyword gefunden werden kann
	    # verschiedene schreibweisen beruecksichtigen
	    for i in `ls *index.*`
	    do
		case $i in
		     # falls das dokument gezippt ist
		     *gz|*Z) zcat $rfcdir/${i} > $tmp;;
     
		     # wenn das dokument nicht gezippt ist
		     *) cat $rfcdir/${i} > $tmp;;
		esac

		sed -n -f ~niebuhr/rfc/testsed $tmp | gawk -v key="$keyword" '
		BEGIN	{ 
			gsub( /[ 	]+/, " ", key )
			key1 = tolower( key )
		    }
		    	{ 
			gsub( /[ 	]+/, " " )
			key2 = tolower( $0 )
		    }
		    key2 ~ key1 { 
		    	print ; next 
		    }' | $p 
	    done
	    #rm $tmp
	    exit 0;;

       -*) usage ;;

	# checken, ob statt option eine rfc-nummer angegeben wurde
       *)  rfc=$1
           rfc=`expr $rfc + 0 2>/dev/null`

	   # wenn keine nummer angegeben wurde -> falsch
       	   if [ "$rfc" = "" ]
	   then
	        usage
	   fi;;
esac

# ohne option :  
#
# checken, ob das dokument hier auf dem server liegt

file=""
for suff in .txt.gz .gz .txt.Z .Z .txt ""
do
	[ -r $rfcdir/rfc$n$suff ] && file=$rfcdir/rfc$n$suff && break 2
	[ -r $rfcdir/$n$suff ] && file=$rfcdir/$n$suff && break 2
done

case $file in
    "")		# das dokument gibt es hier nicht, also holen
    		file=`echo "rfc$n.txt"` 
    		echo "$file ist nicht da, ich hole es, bitte warten..."

		if [ $n -le 400 ] 
		then
			path="rfc-0-399"
		else
			no1=`expr $n % 100` 
			no1=`expr $n - $no1` 
			no2=`expr $no1 + 99` 
			path=`echo rfc-$no1-$no2/` 

		fi
		trap "ls -f $rfcdir/$file; exit" 1 2 3 15
		wget -q -t 3 ftp.nic.de:/pub/rfc/$file 

		# wenn es das dokument gibt, dann zeigs
		if [ -e "$rfcdir/$file" ]; then
			$p $rfcdir/$file
		else
			echo "Zu der Zahl $n gibt es kein rfc Dokument" 
		fi;;

    *.gz|*.Z)	# dokument existiert und ist gezippt
    		zcat $file | $p; exit ;;
    *)		# dokument existiert und ist nicht gezippt
    		cat  $file | $p; exit ;;
esac

