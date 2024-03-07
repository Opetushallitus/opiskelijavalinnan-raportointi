#!/usr/bin/env bash

set -uo pipefail

if [ $# -lt 1 ]; then
  echo ""
  echo ""
  echo "Usage:"
  echo "$0 <dbname> <master-password> <app-password> <readonly-password>"
  exit 1
fi
host=$1
db=$2
master_pw=$3
app_pw=$4
readonly_pw=$5

echo "Ensure user 'app' exists; this command fails when it does already exist."
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "create role app;"
echo ""
echo "Ensure user 'app' has the correct password and permissions."
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "alter role app with login password '$app_pw';"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant all privileges on database $db to app;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant all privileges on all tables in schema public to app;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant all privileges on all sequences in schema public to app;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant all privileges on schema public to app;"
echo ""
echo "Ensure user 'readonly' exists; this command fails when it does already exist."
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "create role readonlyrole;"
echo ""
echo "Ensure user 'readonly' has the correct password and permissions."
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant usage on schema public to readonlyrole;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant select on all tables in schema public to readonlyrole;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant select on all sequences in schema public to readonlyrole;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "alter default privileges in schema public grant select on tables to readonlyrole;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "alter default privileges in schema public grant select on sequences to readonlyrole;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "create user readonly with password '$readonly_pw';"
echo ""
echo "Ensure role 'oph_group' exists; this command fails when it does already exist."
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "create role oph_group;"
echo ""
echo "Ensure 'oph_group' has the correct password, and 'app' and 'oph' both belong to it."
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "alter role oph_group with login password '$master_pw';"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant oph to oph_group;"
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "grant app to oph_group;"
echo ""
echo "Ensure the 'app' user owns the database and everything in it."
PGPASSWORD=$master_pw psql -h $host --user oph_group --dbname $db --command "reassign owned by oph to app;"
echo ""
echo "Ensure user 'oph' still has permissions to everything now owned by 'app'."
PGPASSWORD=$master_pw psql -h $host --user oph_group --dbname $db --command "grant all privileges on database $db to oph;"
PGPASSWORD=$master_pw psql -h $host --user oph_group --dbname $db --command "grant all privileges on all tables in schema public to oph;"
PGPASSWORD=$master_pw psql -h $host --user oph_group --dbname $db --command "grant all privileges on all sequences in schema public to oph;"
PGPASSWORD=$master_pw psql -h $host --user oph_group --dbname $db --command "grant all privileges on schema public to oph;"
echo ""
echo "Role 'oph_group' is not needed anymore, drop it."
PGPASSWORD=$master_pw psql -h $host --user oph --dbname $db --command "drop role oph_group;"
echo ""
echo "DONE!"
