#!/bin/bash
# 2013-10-18 -- Adrien

echo "==BEGIN " `date`
cd /var/www/v2/current

#tools/file_processor/bin/file_processor stop
#tools/media_processor/bin/media_processor stop

echo "--DEBUT Provider.delete_old_images " `date`
script/rails runner -e production 'Provider.delete_old_images'
echo "--FIN Provider.delete_old_images " `date`
echo

echo "--DEBUT Provider.delete_toomany_images " `date`
script/rails runner -e production 'Provider.delete_toomany_images'
echo "--FIN Provider.delete_toomany_images " `date`
echo

echo "--DEBUT index image_core " `date`
/usr/bin/indexer --config /var/www/v2/current/config/production.sphinx.conf --rotate image_core
echo "--FIN index image_core " `date`
echo
echo "--DEBUT index statistic_core " `date`
/usr/bin/indexer --config /var/www/v2/current/config/production.sphinx.conf --rotate statistic_core
echo "--FIN index statistic_core " `date`
echo

echo "--DEBUT Provider.check_controls " `date`
script/rails runner -e production 'Provider.check_controls'
echo "--FIN Provider.check_controls " `date`
echo

echo "--DEBUT SearchStat.purge_adm " `date`
script/rails runner -e production 'SearchStat.purge_adm'
echo "--FIN SearchStat.purge_adm " `date`
echo

echo "--DEBUT Statistic.send_to_pixtrak " `date`
script/rails runner -e production 'Statistic.send_to_pixtrak'
echo "--FIN Statistic.send_to_pixtrak " `date`
echo

#echo "--DEBUT ..." `date`

#echo "--FIN ..." `date`
#echo

#tools/media_processor/bin/media_processor start
#tools/file_processor/bin/file_processor start

echo "==DONE " `date`
