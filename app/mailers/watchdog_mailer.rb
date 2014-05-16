class WatchdogMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.watchdog_mailer.notification.subject
  #
  def notification(watchdog, notifications)
    @notifications = notifications
    @watchdog = watchdog
    mail to: watchdog.user.email,
        subject: "Mon notification",
        from: "watchdog@jbox.batchik.net"
  end
end
