#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment.rb'
require 'json'

files = Dir.glob("../public/features/upd_*.json")
files.each do |file|
  rep = JSON.parse open(file).read
  reportage = ::Reportage.where(:no_reportage => rep['no_reportage'], :string_key => rep['string_key'], :rep_titre => rep['rep_titre']).first
  if reportage.nil?
    reportage = ::Reportage.create(:no_reportage => rep['no_reportage'], :string_key => rep['string_key'], :nb_photos => rep['nb_photo'],
                     :prem_photo => rep['prem_photo'], :rep_date => rep['rep_date'],
                     :rep_titre => rep['rep_titre'], :rep_texte => rep['rep_texte'], :signatur => rep['signatur'], :offre => 1)
    if reportage.save
      puts "#{Time.now} - Reportage créé => #{file}"
    else
      puts "#{Time.now} - Erreur save => #{file}"
    end
  else
    ::Reportage.update(reportage.id, :nb_photos => rep['nb_photo'], :prem_photo => rep['prem_photo'],
                       :rep_date => rep['rep_date'], :rep_titre => rep['rep_titre'],
                       :rep_texte => rep['rep_texte'], :signatur => rep['signatur'], :offre => 1)
    puts "#{Time.now} - Reportage mis à jour => #{file}"
  end
  File.delete(file)
end

files = Dir.glob("../public/features/destroy_*.json")
files.each do |file|
  rep = JSON.parse open(file).read
  reportage = ::Reportage.where(:no_reportage => rep['no_reportage'], :string_key => rep['string_key'], :rep_titre => rep['rep_titre']).first
  if reportage.nil?
      puts "#{Time.now} - Erreur effacement => #{file}"
  else
    reportage.destroy
    puts "#{Time.now} - Reportage effacé => #{file}"
  end
  File.delete(file)
end

files = Dir.glob("../public/features/photo_destroy_*.json")
files.each do |file|
  rep = JSON.parse open(file).read
  photo = ::ReportagePhoto.where(:reportage_id => rep['reportage_id'], :photo_ms_id => rep['photo_ms_id'], :rang => rep['rang']).first
  if photo.nil?
      puts "#{Time.now} - Erreur effacement => #{file}"
  else
    photo.destroy
    puts "#{Time.now} - Photo effacée => #{file}"
  end
  File.delete(file)
end

files = Dir.glob("../public/features/photo_create_*.json")
files.each do |file|
  rep = JSON.parse open(file).read
  photo = ::ReportagePhoto.create(:reportage_id => rep['reportage_id'], :photo_ms_id => rep['photo_ms_id'], :rang => rep['rang']).first
  puts "#{Time.now} - Photo créée => #{file}"
  File.delete(file)
end
