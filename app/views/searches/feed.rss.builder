xml.instruct! :xml, :version => "1.0"
xml.rss(:version        => "2.0", 
  'xmlns:content' => "http://purl.org/rss/1.0/modules/content/", 
  'xmlns:dc'      => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@saved_search.name)
    xml.description(@saved_search.name)
    xml.link("#{feed_url}?id=#{@feed_id}") 
    xml.lastBuildDate("#{@saved_search.date_last_search.rfc822}")
     
    for media in @medias  
      xml.item do
        xml.title("#{I18n.t 'title'}: #{media.title}")

        link = home_url(:img_id => media.id,:only_path => false)  
       
        xml.link(link)
        xml.guid(link)
        xml.description("<p>#{link_to(abs_image_tag(media.rss_image_location),link) }</p>
                         <p>#{I18n.t 'headline'}: #{media.headline}</p>
                         <p>#{I18n.t 'description'}: #{media.description}</p>
                         <p>#{I18n.t 'reception_date'}: #{media.reception_date}</p>
                         <p>#{I18n.t 'date_created'}: #{media.date_created}</p>
                         <p>#{I18n.t 'category'}: #{media.category}</p>
                         <p>#{I18n.t 'country'}: #{media.country}</p>
                         <p>#{I18n.t 'city'}: #{media.city}</p>
                         <p>#{I18n.t 'creator'}: #{media.creator}</p>
                         <p>#{I18n.t 'source'}: #{media.source}</p>
                         <p>#{I18n.t 'normalized_credit'}: #{media.normalized_credit}</p>
                         <p>#{I18n.t 'instructions'}: #{media.instructions}</p>" )
      end  
    end     
  end
end
