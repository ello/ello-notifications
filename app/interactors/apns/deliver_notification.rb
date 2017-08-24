class APNS::DeliverNotification
  include Interactor

  before do
    require_arguments!(:endpoint_arn, :notification)
  end

  def call
    Rails.logger.debug "Delivering notification: #{context[:notification].inspect}, #{aps_options.inspect}"
    SnsService.deliver_notification(
      context[:endpoint_arn], {
      platform_key => { aps: aps_options }.merge(context[:notification].metadata).to_json
    })
    ApnsDeliveryMetric.track_delivery_success
  rescue SnsService::ServiceError => e
    ApnsDeliveryMetric.track_delivery_failure
    context.fail!(message: e.message)
  end

  private

  def require_arguments!(*args)
    args.each do |argument|
      context.fail!(message: "Missing required argument: #{argument}") if context[argument].nil?
    end
  end

  def aps_options
    { badge: context[:notification].badge_count }.tap do |opts|
      if context[:notification].include_alert?
        opts[:content_mutable] = true
        opts[:category] = aps_category
        opts[:alert] = {
          title: context[:notification].title,
          body: context[:notification].body
        }
      end
    end
  end

  def aps_category
    case context[:notification].metadata[:type]
    when 'comment_mention', 'repost', 'post_mention'
      'co.ello.COMMENT_CATEGORY'
    when 'post_comment', 'post_comment_to_watcher',
         'repost_comment_to_original_author', 'repost_comment_to_repost_author'
      'co.ello.POST_CATEGORY'
    when 'follower', 'post_watch', 'post_love',
         'repost_watch_to_original_author', 'repost_watch_to_repost_author',
         'repost_love_to_original_author', 'repost_love_to_repost_author'
      'co.ello.USER_CATEGORY'
    when 'invite_redemption'
      'co.ello.USER_MESSAGE_CATEGORY'
    when 'artist_invite_submission_approved'
      'co.ello.ARTIST_INVITE_SUBMISSION_CATEGORY'
    else
      ''
    end
  end

  def platform_key
    use_sandbox? ? 'APNS_SANDBOX' : 'APNS'
  end

  def use_sandbox?
    !!context[:endpoint_arn].match(/_SANDBOX/)
  end

end
