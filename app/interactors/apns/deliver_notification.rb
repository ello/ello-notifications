class APNS::DeliverNotification
  include Interactor

  before do
    require_arguments!(:endpoint_arn, :notification, :use_sandbox)
  end

  def call
    message_key = context[:use_sandbox] ? 'APNS_SANDBOX' : 'APNS'
    sns = Aws::SNS::Client.new
    sns.publish({
      target_arn: context[:endpoint_arn],
      message_structure: 'json',
      message: {
        message_key.to_sym => {
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

end
