MBBS
====

Multi Backup Batch System
-----------------------------------------------------------------------------------------

 MBBS - Multi Backup Batch System

  purpose: Make multiples backups and send an email with a report.
           Only uses backups through tar,zip and mysqldump
           To configure fill a tsv (tab separate values) with all targets to backup.
           One backup at each line with 8 parameters:
           Each parameters must be spearated by the character \t (tab)
           parameters:
           tool \t source \t  parameters \t name \t extension \t target \t emails \t files
           --
           tool: tar, zip, mysqldump
           source: file or dir to backup (only matters for tar or zip)
           parameters: extra parameters for the tool
           name : name to be used in the middle of the backup file name
           extension: zip,tar,tar.bz2,tar.gz
                      zip: the backup file will be <backup_filename>.zip
                      tar: the backup file will be <backup_filename>.tar
                      tar.bz2: the backup file will be <backup_filename>.tar.bz2
                      tar.gz: the backup file will be <backup_filename>.tar.gz
           target: diretory where to save the backup file
           emails: <email_to>,<email_to>,...;<email_cc>,<email_cc>,...;<email_bcc>,<email_bcc>,...
           files: preserved onlye last <files>

 example:
 tar /home/jonh/bin	v bin	tar.bz2	/home/john/Backups/	jonh\@somedomain.somewhere;admin\@somedomain.somewhere	3
 - use tool tar with parameters -cjf due extension tar.bz2
 - backup the dir "/home/jonh/bin"
 - add extraparameter v .i.e tar -cjvf
 - the filename will be <date_backup>_<hour_backup>_bin.tar.bz2 because the name is "bin"
 - the backup will be placed in "/home/john/Backups/"
 - the report will be send To: jonh\@somedomain.somewhere and Cc: admin\@somedomain.somewhere
 - after the backup preserve only the last "files"
           
  using perl+sendmail/postfix+tar+mysqldump

  version: 0.1 (2014)

  Jose Luis Faria, jose@di.uminho.pt,joseluisfaria@gmail.com
  Universidade do Minho, Braga, Portugal

-----------------------------------------------------------------------------------------
