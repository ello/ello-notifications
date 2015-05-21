class Notification
  include ActiveModel::Model

  attr_accessor :title,
                :body,
                :metadata

  def metadata
    @metadata ||= {}
  end
end
