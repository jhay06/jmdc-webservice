<pre>
JMDC Webservice

A. Configs
   A.1 Database.
       1. Edit db_config.json from the "configs" folder
       2. Change "db_host" to your db server host
       3. Change "db_port" to the port of your db_server, set it to 3306 for Default
       4. Change "user" to your db user
       5. Change "password" to your db user password
       6. Change "db_Name" to the db_Name from your database server
   A.2 SMTP (Mail Server Config)
       1. Edit smtp_config.json from the "configs" folder
       2. Change "smtp_username" to username/email address from your smtp server, for GMAIL or Hotmail or Yahoo, you must set it to email address instead of username
       3. Change "smtp_password" to password of the email address used
       4. Change  "smtp_server" to your own smtp mail server or any smtp server 
          * gmail = smtp.gmail.com
          * yahoo = smtp.mail.yahoo.com
          * hotmail =  smtp-mail.outlook.com
       5. Change "smtp_port_tls" if "use_ssl" is false or "smtp_port_ssl" if "use_ssl" is true default tls port is 587, default ssl port is 465
       6. Change "use_ssl" to true/false
B. Database Restore.
  1. Open the restore.sql to any editor
  2. Look for the "Create Definer" lines 
  3. Change all 'jmdc'@'%'  from the lines with "Create Definer" to your database user
  4. Save and Execute it to mysql workbench

C. Running
  1. open terminal / cmd 
  2. cd to webservice path
  3. then run "docker-compose up -d"
</pre>
       
