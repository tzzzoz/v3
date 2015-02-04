#! /bin/bash
# Nathalie - 2013-11-12 - v2

features_folder="/var/www/v2/current/public/features"
file_type="*.json"
servers_copy=('webFR' 'webFR2' 'test1' 'master1' 'master2' 'express' 'parisien' 'condenast' 'lepoint' 'editis' 'demo' 'bollore' 'mondadori' 'hommell' 'hachettea' 'marieclaire' 'nouvelobs' 'unieditions' 'figaro' 'humanite' 'rampazzo' 'moniteur' 'bayard' 'marianne' 'vmmagazines' 'lemonde' 'jeuneafrique' 'prisma')
servers_send=('webFR' 'webFR2' 'test1' 'master1' 'master2' 'express' 'parisien' 'condenast' 'lepoint' 'editis' 'demo' 'mondadori' 'hommell' 'hachettea' 'nouvelobs' 'unieditions' 'figaro' 'humanite' 'rampazzo' 'moniteur' 'marianne' 'vmmagazines' 'lemonde' 'jeuneafrique' 'prisma')

#check if new json files are waiting to be sent to servers
if [ -n "$(ls $features_folder/$file_type 2> /dev/null)" ]; then

   #copy json file(s) into each server folder
   for f in $features_folder/$file_type
 	do
	for server in ${servers_copy[*]}
		do
		cp $f $features_folder/$server/
	done	
	rm $f
   done
fi

#check each server folder to send json files not sent yet (still in the server folder)
for server in ${servers_send[*]}
	do
	if [ -n "$(ls $features_folder/$server/$file_type 2> /dev/null)" ]; then
		for f in $features_folder/$server/$file_type
			do
			date +"%Y-%m-%d %T - " | tr -d '\n';scp $f v2@$server:$features_folder && echo "${f##*/} sent to $server" && mv $features_folder/$server/${f##*/} $features_folder/$server/sent/ 
		done
	fi
done

#servers with access by tunnel
#bollore
if [ -n "$(ls $features_folder/bollore/$file_type 2> /dev/null)" ]; then
	for f in $features_folder/bollore/$file_type
            do
            date +"%Y-%m-%d %T - " | tr -d '\n';scp -P2171 $f v2@localhost:$features_folder && echo "${f##*/} sent to bollore" && mv $features_folder/bollore/${f##*/} $features_folder/bollore/sent/ 
        done
fi
#marieclaire
if [ -n "$(ls $features_folder/marieclaire/$file_type 2> /dev/null)" ]; then
        for f in $features_folder/marieclaire/$file_type
            do
            date +"%Y-%m-%d %T - " | tr -d '\n';scp -P2261 $f v2@localhost:$features_folder && echo "${f##*/} sent to marieclaire" && mv $features_folder/marieclaire/${f##*/} $features_folder/marieclaire/sent/
        done
fi
#bayard
if [ -n "$(ls $features_folder/bayard/$file_type 2> /dev/null)" ]; then
        for f in $features_folder/bayard/$file_type
            do
            date +"%Y-%m-%d %T - " | tr -d '\n';scp -P2361 $f v2@localhost:$features_folder && echo "${f##*/} sent to bayard" && mv $features_folder/bayard/${f##*/} $features_folder/bayard/sent/
        done
fi

