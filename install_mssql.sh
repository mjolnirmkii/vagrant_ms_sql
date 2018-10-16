#!/bin/bash

MSSQL_SA_PASSWORD=Password1
MSSQL_PID=evaluation
SQL_INSTALL_USER=systemmssql
SQL_INSTALL_USER_PASSWORD=Password1

echo "VAGRANT_INSTALLER: Installing MicroSoft SQL Server 2017 for Linux..."

echo "VAGRANT_INSTALLER: Adding Microsoft repositories..."
sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo
sudo curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo

echo "VAGRANT_INSTALLER: Installing SQL Server..."
sudo yum install -y mssql-server

echo "VAGRANT_INSTALLER: Running mssql-conf setup..."
sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD MSSQL_PID=$MSSQL_PID /opt/mssql/bin/mssql-conf -n setup accept-eula

echo "VAGRANT_INSTALLER: Installing mssql-tools and unixODBC developer..."
sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel

echo "VAGRANT_INSTALLER: Adding SQL Server tools to your path..."
echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

echo "VAGRANT_INSTALLER: Restarting SQL Server..."
sudo systemctl restart mssql-server

echo "VAGRANT_INSTALLER: Creating user $SQL_INSTALL_USER..."
sudo /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD \
    -Q "CREATE LOGIN [$SQL_INSTALL_USER] WITH PASSWORD=N'$SQL_INSTALL_USER_PASSWORD', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON; ALTER SERVER ROLE [sysadmin] ADD MEMBER [$SQL_INSTALL_USER]"
echo "VAGRANT_INSTALLER: Creating business database schema..."
sudo /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -Q "CREATE DATABASE primarydata"
sudo /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P $MSSQL_SA_PASSWORD -Q "CREATE DATABASE businessdata"

echo "VAGRANT_INSTALLER: Microsoft SQL Server 2017 installation... Done..."