#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment.rb'
require 'json'

files = Dir.glob("../public/features/create_*.json")
files.each do |file|
  rep = JSON.parse open(file).read
  reportage = ::Reportage.create(:no_reportage => rep['no_reportage'], :string_key => rep['string_key'], :nb_photos => rep['nb_photo'],
                     :prem_photo => rep['prem_photo'], :rep_date => rep['rep_date'],
                     :rep_titre => rep['rep_titre'], :rep_texte => rep['rep_texte'], :signatur => rep['signatur'], :offre => 1)
  if reportage.save
    rang = 0
    rep['ids'].each do |i|
      ::ReportagePhoto.create(:reportage_id => reportage.id, :photo_ms_id => i, :rang => rang)
      rang += 1
    end
    puts "#{Time.now} - Reportage créé => #{file}"
  else
    puts "#{Time.now} - Erreur save => #{file}"
  end
  File.delete(file)
end

files = Dir.glob("../public/features/update_*.json")
files.each do |file|
  rep = JSON.parse open(file).read
  reportage = ::Reportage.where(:no_reportage => rep['no_reportage'], :string_key => rep['string_key']).first
  if reportage.nil?
    reportage = ::Reportage.create(:no_reportage => rep['no_reportage'], :string_key => rep['string_key'], :nb_photos => rep['nb_photo'],
                     :prem_photo => rep['prem_photo'], :rep_date => rep['rep_date'],
                     :rep_titre => rep['rep_titre'], :rep_texte => rep['rep_texte'], :signatur => rep['signatur'], :offre => 1)
    if reportage.save
      rang = 0
      rep['ids'].each do |i|
        ::ReportagePhoto.create(:reportage_id => reportage.id, :photo_ms_id => i, :rang => rang)
        rang += 1
      end
      puts "#{Time.now} - Reportage créé => #{file}"
    else
      puts "#{Time.now} - Erreur save => #{file}"
    end
  else
    ::Reportage.update(reportage.id, :nb_photos => rep['nb_photo'], :prem_photo => rep['prem_photo'],
                       :rep_date => rep['rep_date'], :rep_titre => rep['rep_titre'],
                       :rep_texte => rep['rep_texte'], :signatur => rep['signatur'], :offre => 1)
    ::ReportagePhoto.where(:reportage_id => reportage.id).collect{|p| p.destroy}
    rang = 0
    rep['ids'].each do |i|
      ::ReportagePhoto.create(:reportage_id => reportage.id, :photo_ms_id => i, :rang => rang)
      rang += 1
    end
    puts "#{Time.now} - Reportage mis à jour => #{file}"
  end
  File.delete(file)
end

files = Dir.glob("../public/features/delete_*.json")
files.each do |file|
  rep = JSON.parse open(file).read
  reportage = ::Reportage.where(:no_reportage => rep['no_reportage'], :string_key => rep['string_key']).first
  if reportage.nil?
      puts "#{Time.now} - Erreur effacement => #{file}"
  else
    reportage.destroy
    puts "#{Time.now} - Reportage effacé => #{file}"
  end
  File.delete(file)
end

