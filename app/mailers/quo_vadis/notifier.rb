module QuoVadis
  class Notifier < ActionMailer::Base

    # Sends an email to <tt>user</tt> with a link to a page where they
    # can change their password.
    def change_password(user)
      @username = user.username
      @url = change_password_url user.token
      mail :to => user.email, :from => QuoVadis.from, :subject => QuoVadis.subject_change_password
    end

    # Sends an email to <tt>user</tt> with a link to a page where they
    # can choose their username and password.
    #
    # `data` - hash of data to pass to view via instance variables.  A key of `:foo`
    #          will be available via `@foo`.  `:from` and `:subject` are deleted from
    #          the hash and used to override `QuoVadis#from` and `#subject_invitation`.
    def invite(user, data = {})
      @user = user
      @url = invitation_url user.token
      
      from    = data.delete(:from)    || QuoVadis.from
      subject = data.delete(:subject) || QuoVadis.subject_invitation
      
      data.each { |k,v| instance_variable_set :"@#{k}", v }
      mail :to => user.email, :from => from, :subject => subject
    end

  end
end
