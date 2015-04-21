class APNS::DeliverNotification
  include Interactor

  before do
    require_arguments!(:endpoint_arn, :notification)
  end

  def call
    sns = Aws::SNS::Client.new
    sns.publish({
      target_arn: context[:endpoint_arn],
      message_structure: 'json',
      message: {
        platform_key => {
          aps: {
            alert: {
              title: context[:notification].title,
              body: context[:notification].body
            }
          }
        }.merge(context[:notification].metadata).to_json
      }.to_json
    })
  end

  private

  def require_arguments!(*args)
    args.each do |argument|
      context.fail!(message: "Missing required argument: #{argument}") if context[argument].nil?
    end
  end

  def platform_key
    use_sandbox? ? 'APNS_SANDBOX' : 'APNS'
  end

  def use_sandbox?
    !!context[:endpoint_arn].match(/_SANDBOX/)
  end

end
