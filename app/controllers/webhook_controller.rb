class WebhookController < ApplicationController

  protect_from_forgery :except => [:callback]
  require 'line/bot'
  require 'net/http'

  def client
   client = Line::Bot::Client.new { |config|
   config.channel_secret = ENV['LINE_CHANNEL_SECRET']
   config.channel_token = ENV['LINE_CHANNEL_TOKEN']
   }
  end

  def callback

    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']

    event = params["events"][0]
    event_type = event["type"]

    #送られたテキストメッセージをinput_textに取得
    input_text = event["message"]["text"]

    events = client.parse_events_from(body)

    events.each { |event|

      case event
        when Line::Bot::Event::Message
          case event.type
            #テキストメッセージが送られた場合、そのままおうむ返しする
            when Line::Bot::Event::MessageType::Text
               message = {
                    type: 'text',
                    text: input_text
                    }

            #画像が送られた場合、適当な画像を送り返す
            #画像を返すには、画像が保存されたURLを指定する。
            #なお、おうむ返しするには、１度AWSなど外部に保存する必要がある。ここでは割愛する
            when Line::Bot::Event::MessageType::Image
              image_url = "https://pbs.twimg.com/profile_images/738991090687172608/DO0kvJ6-.jpg"  #httpsであること
                message = {
                    type: "image",
                    originalContentUrl: image_url,
                    previewImageUrl: image_url
                    }
           end #event.type
           #メッセージを返す
           client.reply_message(event['replyToken'],message)
      end #event
   } #events.each
  end  #def
end
