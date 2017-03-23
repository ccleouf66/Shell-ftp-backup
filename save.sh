#!/bin/bash

########################################  Scripte de sauvgarde  ###################################
##												 												 ##
## Ce script créé une archive des dossiers / fichiers listé dans listeSave.txt dans ./tmp        ##
## Il se connecte au serveur ftp et envoie les fichiers .tar du dossier ./tmp		 			 ##
## Après envoie des fichiers / dossiers il vide le dossier ./tmp								 ##
## Fichier de log -> ./save.txt										 							 ##
###################################################################################################

# récupération de la date et l'heure
todayDate="$(date +%d-%m-%Y)";

#Info du serveur ftp où vont être sauvegarder les données
host="DESTINATION ADDRESS";
user="USER";
passwd="PASSWORD";

# chemin du fichier contenant la liste des fichiers/dossiers à sauvgarder
fileList="./listeSave.txt";

# chemin où sont stockés les archives à envoyer au ftp
dossierArchive="./tmp";

#fichier de log de sauvgarde
fileLog="./save.log";

#addresse email pour envoie du rapport de sauvegarde
mail="email@gmail.com"; 

############################Début de la sauvegarde##########

echo "--------------------Début de la sauvegarde du $todayDate-----------------" >> $fileLog;

# parcours le fichier ligne par ligne 
while read line; do
	nameFile=$(basename $line);

	echo "[$todayDate $(date +%k:%M:%S)] Compression du fichier $line" >> $fileLog;

	# Création de l'archive
	tar -cvf "$dossierArchive/$nameFile$todayDate.tar" "$line" --verbose;
	if [ $? -eq 0 ]; then
		echo "[$todayDate $(date +%k:%M:%S)] Compression du fichier $linge OK" >> $fileLog;
	else
		echo "[$todayDate $(date +%k:%M:%S)] Erreur lors de la compression du fichier $linge" >> $fileLog;
	fi

done < $fileList;

# connexion et envoie vers le serveur ftp

echo "[$todayDate $(date +%k:%M:%S)] ***Connexion au serveur FTP distant***" >> $fileLog;

ftp -pvind $host >> $fileLog << EOT
user $user $passwd

binary

lcd $dossierArchive
mput *.tar

bye
EOT

echo "[$todayDate $(date +%k:%M:%S)] ***Fin de la connexion FTP***" >> $fileLog;

echo "[$todayDate $(date +%k:%M:%S)] Suppression du contenu du dossier tmp" >> $fileLog;

rm -R $dossierArchive/* --verbose;
if [ $? -eq 0 ]; then
                echo "[$todayDate $(date +%k:%M:%S)] Suppression du contenu du dossier tmp OK" >> $fileLog;
        else
                echo "[$todayDate $(date +%k:%M:%S)] Suppression du contenu du dossier tmp KO" >> $fileLog;
        fi

echo "[$todayDate $(date +%k:%M:%S)] Fin de la sauvegarde" >> $fileLog;

mutt -s "Script de sauvgarde" -a $fileLog -- $mail < /dev/null;