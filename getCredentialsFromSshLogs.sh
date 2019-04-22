#! /bin/bash

# Gets SSH Credentials from the log file.

# Wait for a login attempt and run the command below
cat /var/log/auth.log | grep "SSH Login Attempt\|Failed password"