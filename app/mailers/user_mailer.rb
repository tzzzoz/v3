class UserMailer < ActionMailer::Base
  default from: "support@pixpalace.com"

  def img_delete(imgs, util, lb)
    @imgs = imgs
    @user = util
    @lb = lb
    mail(:to => "patrick.lamotte@pixpalace.com",
         :subject => "Effacement photos agence",
         :bcc => "support@pixpalace.com")
  end

  def warn_user(imgs, util, lb)
    @imgs = imgs
    @user = util
    @lb = lb
    mail(:to => @user.email,
         :from => "effacements@pixpalace.com",
         :subject => "Effacement photos",
         :bcc => "effacements@pixpalace.com")
  end

  def warn_pplus_user(imgs, util, lb)
      @imgs = imgs
      @user = util
      @lb = lb
      mail(:to => @user.email,
           :subject => "Envoi PP2 - Effacement PP",
           :bcc => "effacements@pixpalace.com")
  end

  def send_yas(prov, t_photos)
    @prov = prov
    @t_photos = t_photos
    mail(:to => "yasmina.guemra@pixpalace.com, info@pixpalace.com, support@pixpalace.com",
         :subject => "photos par agence")
  end

  def ch_controls(mel, ag_name, prov, prova)
    @prov = prov
    @prova = prova
    @ag_name = ag_name
    mail(:to => mel,
         :subject => "PixPalace : contrôles des photos #{ag_name} ",
         :bcc => "support@pixpalace.com, info@pixpalace.com")
  end

  def reservoir(mel, total, photogr)
    @total = total
    @photogr = photogr
    mail(:to => mel,
         :subject => "PixPalace : photos Reservoir photos ")
  end

  def send_stats(stats, mel, date_range, statsbd, statshd, statsdem)
    @stats = stats
    @date_range = date_range
    @statsbd = statsbd
    @statshd = statshd
    @statsdem = statsdem
    mail(:to => mel,
         :subject => "statistiques Pixpalace",
         :bcc => "stats@pixpalace.com")
  end

  def pp_prov_stats(week_range, prov_hd, prov_bd, prov_dem, total_prov_hd, total_prov_bd, total_prov_dem)
        @week_range = week_range
        @prov_hd = prov_hd
        @prov_bd = prov_bd
        @prov_dem = prov_dem
        @total_prov_hd = total_prov_hd
        @total_prov_bd = total_prov_bd
        @total_prov_dem = total_prov_dem
        mail(:to => "info@pixpalace.com, tech@pixpalace.com",
             :subject => "statistiques Agences Pixpalace")
  end

  def prov_3monthsstats(week_range, mois_encours, prov_hd, total_prov_hd, prov_1mois, total_prov_1mois)
        @week_range = week_range
        @mois_encours = mois_encours
        @prov_hd = prov_hd
        @total_prov_hd = total_prov_hd
        @prov_1mois = prov_1mois
        @total_prov_1mois = total_prov_1mois
        mail(:to => "info@pixpalace.com,yasmina.guemra@pixpalace.com,patrick.lamotte@pixpalace.com",
             :subject => "statistiques 3 mois Agences Pixpalace")
  end

  def pp_title_stats(week_range, title_hd, title_bd, title_dem, total_title_hd, total_title_bd, total_title_dem)
      @week_range = week_range
      @title_hd = title_hd
      @title_bd = title_bd
      @title_dem = title_dem
      @total_title_hd = total_title_hd
      @total_title_bd = total_title_bd
      @total_title_dem = total_title_dem
      mail(:to => "info@pixpalace.com,tech@pixpalace.com",
           :subject => "statistiques Titres Pixpalace")
  end

  def pp_hide_stats(week_range, hide_hd, hide_bd, total_hide_hd, total_hide_bd)
      @week_range = week_range
      @hide_hd = hide_hd
      @hide_bd = hide_bd
      @total_hide_hd = total_hide_hd
      @total_hide_bd = total_hide_bd
      mail(:to => "info@pixpalace.com,tech@pixpalace.com",
           :subject => "statistiques Cachees Pixpalace")
  end

  def send_request_to_provider(mail_list, text, ftp, subject, from_user)
    mail_to = PixPalaceMail[I18n.locale.to_sym]
    @hello   = I18n.t 'mail_content.greetings'
    @request = text
    @ftp = ftp
    unless mail_list.blank?
     mail(:from => from_user,
          :to => mail_list,
          :bcc => "contact@pixpalace.com, patrick.lamotte@pixpalace.com",
          :subject => subject)
    end
  end

  def send_validate_form(mail_to,parameters,user)
#    puts '*'*200, parameters.inspect, '*'*200
#    puts '*'*200, Request.request_URI.inspect, '*'*200
    #setup_email(nil,mail_to)
    #@subject += "formulaire de validation"
    @user = user
    @edition = parameters[:edition]
    @title_edition = parameters[:title_edition]
    @publication_edition = parameters[:publication_edition]
    @presse = parameters[:presse]
    @title_presse = parameters[:title_presse]
    @num_presse = parameters[:num_presse]
    @title_pub_presse = parameters[:title_pub_presse]
    @num_pub_presse = parameters[:num_pub_presse]
    @emission_tv = parameters[:emission_tv]
    @diffusion_tv = parameters[:diffusion_tv]
    @cinema = parameters[:cinema]
    @film = parameters[:film]
    @diffusion_cinema = parameters[:diffusion_cinema]
    @video = parameters[:video]
    @illu_contenu_video = parameters[:illu_contenu_video]
    @illu_contenant_video = parameters[:illu_contenant_video]
    @internet = parameters[:internet]
    @publicitaire = parameters[:publicitaire]
    @expo_salon = parameters[:expo_salon]
    @other = parameters[:other]
    @exemplaires = parameters[:exemplaires]
    @diffusion = parameters[:diffusion]
    @nclient = parameters[:nclient]
    @legal_name = parameters[:legal_name]
    @service = parameters[:service]
    @adresse = parameters[:adresse]
    @postal_code = parameters[:postal_code]
    @city = parameters[:city]
    #@country = parameters[:country]
    #@email = parameters[:email]
    #@tva = parameters[:tva]
    #@body[:user]= user
    @bnf_files = parameters[:bnf_files]

    mail(:to => mail_to,
         :subject => "Pixpalace formulaire de validation BNF")

  end

  def send_bnf_form(mail_to, parameters, user, title_name)
    @edition = parameters[:edition]
    @title_edition = parameters[:title_edition]
    @publication_edition = parameters[:publication_edition]
    @presse = parameters[:presse]
    @title_presse = parameters[:title_presse]
    @num_presse = parameters[:num_presse]
    @title_pub_presse = parameters[:title_pub_presse]
    @num_pub_presse = parameters[:num_pub_presse]
    @emission_tv = parameters[:emission_tv]
    @diffusion_tv = parameters[:diffusion_tv]
    @cinema = parameters[:cinema]
    @film = parameters[:film]
    @diffusion_cinema = parameters[:diffusion_cinema]
    @video = parameters[:video]
    @illu_contenu_video = parameters[:illu_contenu_video]
    @illu_contenant_video = parameters[:illu_contenant_video]
    @internet = parameters[:internet]
    @publicitaire = parameters[:publicitaire]
    @expo_salon = parameters[:expo_salon]
    @other = parameters[:other]
    @exemplaires = parameters[:exemplaires]
    @diffusion = parameters[:diffusion]
    @nclient = parameters[:nclient]
    @legal_name = parameters[:legal_name]
    @service = parameters[:service]
    @adresse = parameters[:adresse]
    @postal_code = parameters[:postal_code]
    @city = parameters[:city]
    @bnf_files = parameters[:bnf_files]

    @user = user
    @title_name = title_name


     mail(:to => mail_to,
          :bcc => "patrick.lamotte@pixpalace.com",
          :subject => "Pixpalace formulaire de validation BNF")

   end

  def dw_video_user(imgs, util)
     @imgs = []
     imgs.each do |i, v|
       attachments.inline[i]= File.read("public#{v}")
       @imgs << i
     end
     @user = util
     mail(:to => @user.email,
          :subject => "Demande de videos",
          :bcc => "contact@pixpalace.com,support@pixpalace.com")
  end

  def dw_user(imgs, vignettes, util, prov_name, prov_email, operation)
     @imgs = imgs
     imgs.each do |i|
       attachments.inline[i]= File.read("public#{vignettes[i]}")
     end
     @prov_name  = prov_name
     @user = util
     @op = operation
     mail(:to => @user.email,
          :subject => "PixPalace : votre demande (#{@op})",
          :bcc => "contact@pixpalace.com,tech@pixpalace.com",
          :reply_to => prov_email)
  end

  def send_afp_stats(stats, mel)
     @stats = stats
     stats.each do |i|
       attachments.inline[i.image.original_filename]= File.read("public#{i.image.thumb_location}")
     end
     mail(:to => mel,
          :subject => "20Minutes : Stats AFP")
  end

  def dw_provider(imgs, vignettes, prov_name, prov_email, util, operation)
     @imgs = imgs
     imgs.each do |i|
       attachments.inline[i]= File.read("public#{vignettes[i]}")
     end
     @prov_name  = prov_name
     @user = util
     @op = operation
     mail(:from => @user.email,
          :to => prov_email,
          :subject => "PixPalace : demande (#{@op})",
          :bcc => "contact@pixpalace.com,tech@pixpalace.com")
  end

  def dw_akamedia(imgs, util)
     @vids = imgs.keys
     @vids.each do |i|
       attachments.inline[i]= File.read("public#{imgs[i]}")
     end
     @user = util
     mail(:from => @user.email,
          :to => "technical.support@akamedia.net",
          :subject => "PixPalace : demande de videos",
          :bcc => "contact@pixpalace.com,support@pixpalace.com")
  end

  def dw_mov(imgs, util, p_name, p_mail)
     @vids = imgs.keys
     @vids.each do |i|
       attachments.inline[i]= File.read("public#{imgs[i]}")
     end
     @prov_name = p_name
     @user = util
     mail(:from => @user.email,
          :to => p_mail,
          :subject => "PixPalace : demande de videos",
          :bcc => "contact@pixpalace.com,support@pixpalace.com")
  end

  def password_reset_instructions(user)
    setup_email(user, user.email, ['info@pixpalace.com', 'support@pixpalace.com'])
    @subject       += I18n.t 'password_reset_instructions'
  end

end