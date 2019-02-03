#!/bin/bash
#
# This script checks if a PostgreSQL server is healthy running on localhost. It will
# return:
# "HTTP/1.x 200 OK\r" (if postgres is running smoothly)
# - OR -
# "HTTP/1.x 500 Internal Server Error\r" (else)
#
# The purpose of this script is make haproxy capable of monitoring PostgreSQL properly
#
 
export PGHOST='localhost'
export PGUSER='{{ vmdb_user|default("root") }}'
export PGPASSWORD='{{ vmdb_password }}'
export PGPORT='{{ vmdb_port|default(5432) }}'
export PGDATABASE='{{ vmdb_database|default("vmdb_production") }}'
export PGCONNECT_TIMEOUT=10
 
SLAVE_CHECK="SELECT pg_is_in_recovery()"
WRITABLE_CHECK="SHOW transaction_read_only"
 
return_ok()
{
    echo -e "HTTP/1.1 200 OK\r\n"
    echo -e "Content-Type: text/html\r\n"
    echo -e "Content-Length: 56\r\n"
    echo -e "\r\n"
    echo -e "<html><body>PostgreSQL master is running.</body></html>\r\n"
    echo -e "\r\n"
 
    unset PGUSER
    unset PGPASSWORD
    exit 0
}
 
return_fail()
{
    echo -e "HTTP/1.1 503 Service Unavailable\r\n"
    echo -e "Content-Type: text/html\r\n"
    echo -e "Content-Length: 48\r\n"
    echo -e "\r\n"
    echo -e "<html><body>PostgreSQL is *down* or is not a master.</body></html>\r\n"
    echo -e "\r\n"
 
    unset PGUSER
    unset PGPASSWORD
    exit 1
}
 
# check if in recovery mode (that means it is a 'slave')
SLAVE=$(psql -qt -c "$SLAVE_CHECK" 2>/dev/null)
if [ $? -ne 0 ]; then
    return_fail;
elif echo $SLAVE | egrep -i "(t|true|on|1)" 2>/dev/null >/dev/null; then
    return_fail;
fi
 
# check if writable (then we consider it as a 'master')
READONLY=$(psql -qt -c "$WRITABLE_CHECK" 2>/dev/null)
if [ $? -ne 0 ]; then
    return_fail;
elif echo $READONLY | egrep -i "(f|false|off|0)" 2>/dev/null >/dev/null; then
    return_ok "master"
fi
 
return_ok "none";
