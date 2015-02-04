#!/bin/bash
# 2013-11-07 -- Adrien

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

echo "--DEBUT SearchStat.envoi_pixadmin " `date`
script/rails runner -e production 'SearchStat.envoi_pixadmin'
echo "--FIN SearchStat.envoi_pixadmin " `date`
echo

echo "--DEBUT SearchImageField.envoi_field_searches " `date`
script/rails runner -e production 'SearchImageField.envoi_field_searches'
echo "--FIN SearchImageField.envoi_field_searches " `date`
echo

echo "--DEBUT ProviderForSearchStat.envoi_user_searches " `date`
script/rails runner -e production 'ProviderForSearchStat.envoi_user_searches'
echo "--FIN  ProviderForSearchStat.envoi_user_searches " `date`
echo

#echo "--DEBUT ..." `date`

#echo "--FIN ..." `date`
#echo

#tools/media_processor/bin/media_processor start
#tools/file_processor/bin/file_processor start

echo "==DONE " `date`
