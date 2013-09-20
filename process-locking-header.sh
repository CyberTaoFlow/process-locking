# Configure your preferred lock file dir:
LOCKSDIR="/var/lock" 
# Remove ok files created before RM_OLD_OK_TS for SCRIPTNAME_NOARGS
RM_OLD_OK_TS="48 hours ago"	
#
# Nothing below here needs configuration
#

SCRIPTNAME_NOARGS=`echo "$0"|rev|cut -d'/' -f1|rev|sed 's/[[^:alnum:]\-_]//g'`

SCRIPTNAME=`echo "${0}"|rev|cut -d"/" -f1|rev|sed -e "s/\$/$1.$2.$3/"'; s/[[^:alnum:]_\-]//g; s/\.\.*/./g; s/.$//'`
echo "$SCRIPTNAME"
echo "$SCRIPTNAME_NOARGS"
if [ -e "${LOCKSDIR}/${SCRIPTNAME}.ok" ];then
        mv "${LOCKSDIR}/${SCRIPTNAME}.ok" "${LOCKSDIR}/${SCRIPTNAME}.running"
        touch "${LOCKSDIR}/${SCRIPTNAME}.running"
        /usr/bin/logger "Starting $SCRIPTNAME" 
else   
        if [ -e "${LOCKSDIR}/${SCRIPTNAME}.running" ];then
                echo "Exiting because process is already running"
                exit
        else   
                /usr/bin/logger "Creating ${SCRIPTNAME}.ok"
                touch "${LOCKSDIR}/${SCRIPTNAME}.ok"
                echo "Created the ok file - must be first time running."
        	mv "${LOCKSDIR}/$SCRIPTNAME.ok" "${LOCKSDIR}/${SCRIPTNAME}.running"
        	touch "${LOCKSDIR}/${SCRIPTNAME}.running"
        	/usr/bin/logger "Starting ${SCRIPTNAME}" 
        fi
fi

# Clean up old ok files for files begining with SCRIPTNAME_NOARGS and ending with .ok
OK_FILES=`ls -1 "${LOCKSDIR}/${SCRIPTNAME_NOARGS}"*.ok 2>/dev/null`
if [ -n "${OK_FILES}" ]; then
	touch -d "${RM_OLD_OK_TS}" "${LOCKSDIR}/${SCRIPTNAME_NOARGS}.ok-expire"
	echo "${OK_FILES}" | while read FILE; do
		if [ "${FILE}" -ot "${LOCKSDIR}/${SCRIPTNAME_NOARGS}.ok-expire" ]; then
			echo "Removing old ok file: ${FILE}"
			/usr/bin/logger "Removing old ok file: ${FILE}" 
			rm "${FILE}"
		fi
	done
fi
