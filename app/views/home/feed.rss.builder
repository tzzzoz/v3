xml.instruct! :xml, :version => "1.0"
xml.rss(:version        => "2.0", 
  'xmlns:content' => "http://purl.org/rss/1.0/modules/content/", 
  'xmlns:dc'      => "http://purl.org/dc/elements/1.1/") do
  rhost = 'http://'+request.host_with_port
  xml.channel do
    xml.title(@saved_search.name)
    xml.link("#{feed_url}.rss?saved_search_id=#{@saved_search.id}")
    xml.lastBuildDate("#{@saved_search.date_last_search.rfc822}")
     
    @medias.each do |med|
        lien = rhost + medias_path('ids[]' => med.id)
        xml.item do
            xml.title("#{I18n.t 'title'}: #{med.title}")
            xml.guid(lien)
            xml.description("<p>#{link_to(abs_image_tag(med.rss_image_location), lien) }</p>
                            <p>#{I18n.t 'headline'}: #{med.headline}</p>
                            <p>#{I18n.t 'description'}: #{med.description}</p>
                            <p>#{I18n.t 'reception_date'}: #{med.reception_date}</p>
                            <p>#{I18n.t 'date_created'}: #{med.date_created}</p>
                            <p>#{I18n.t 'category'}: #{med.category}</p>
                            <p>#{I18n.t 'country'}: #{med.country}</p>
                            <p>#{I18n.t 'city'}: #{med.city}</p>
                            <p>#{I18n.t 'creator'}: #{med.creator}</p>
                            <p>#{I18n.t 'source'}: #{med.source}</p>
                            <p>#{I18n.t 'normalized_credit'}: #{med.normalized_credit}</p>
                            <p>#{I18n.t 'instructions'}: #{med.instructions}</p>" )
        end
    end

  end
end
