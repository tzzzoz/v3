class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if user.send_activation_mail
      UserMailer.deliver_signup_notification(user)
    end
  end

  def after_save(user)
    if user.send_activation_mail
      UserMailer.deliver_activation(user) if user.recently_activated?
    end
  end
end
