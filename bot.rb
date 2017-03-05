require 'facebook/messenger'
require 'open-uri'
require 'json'

include Facebook::Messenger


# SEND API

module Facebook
  module Messenger
    module Incoming
      # Common attributes for all incoming data from Facebook.
      module Common

        def show_typing(is_active)
          payload = {
            recipient: sender,
            sender_action: (is_active)?'typing_on':'typing_off'
          }

          Facebook::Messenger::Bot.deliver(payload, access_token: access_token)
        end

        def mark_as_seen
          payload = {
            recipient: sender,
            sender_action: 'mark_seen'
          }

          Facebook::Messenger::Bot.deliver(payload, access_token: access_token)
        end

        def reply_with_text(text)
          reply(text: text)
        end

        def reply_with_image(image_url)
          reply(
                attachment: {
                    type: 'image',
                    payload: {
                      url: image_url
                    }
                  }
          )
        end

        def reply_with_audio(audio_url)
          reply(
                attachment: {
                    type: 'audio',
                    payload: {
                      url: audio_url
                    }
                  }
          )
        end

        def reply_with_video(video_url)
          reply(
                attachment: {
                    type: 'video',
                    payload: {
                      url: viedo_url
                    }
                  }
          )
        end

        def reply_with_file(file_url)
          reply(
                attachment: {
                    type: 'file',
                    payload: {
                      url: file_url
                    }
                  }
          )
        end

        def ask_for_location(text)
          reply({
            text: text,
            quick_replies:[
              {
                content_type:"location",
              }
            ]
          })
        end 

        def has_attachments?
          attachments != nil
        end 

        def is_location_attachment?
          has_attachments? && attachments.first["type"] == "location"
        end

        def is_image_attachment?
          has_attachments? && attachments.first["type"] == "image"
        end

        def is_video_attachment?
          has_attachments? && attachments.first["type"] == "video"
        end

        def is_audio_attachment?
          has_attachments? && attachments.first["type"] == "audio"
        end

        def is_file_attachment?
          has_attachments? && attachments.first["type"] == "file"
        end

        def location
          coordinates = attachments.first['payload']['coordinates']
          [coordinates['lat'], coordinates['long']] 
        end

        def access_token
          Facebook::Messenger.config.provider.access_token_for(recipient)
        end
      end
    end
  end
end

# END

Bot.on :postback do |postback|

  postback.ask_for_location('Dónde estas ubicado? Dinos y te mostraremos dónde están los puntos de recarga TuLlave más cercanos.')

end

Bot.on :message do |message|

  if message.is_location_attachment?

    message.show_typing(true)

    lat, lng = message.location
  
    open("https://easitp.ylecuyer.xyz/tullave/#{lat}/#{lng}/500") do |data|
      array = JSON.parse(data.string)

      unless array.count > 0
        message.reply_with_text("\u{1F623}")
        message.reply_with_text("No hay puntos de recarga cercanos abiertos a esta hora.")
      else

        elements = []

        array.each do |punto|
          elements << {
            title: punto['name'],
            subtitle: punto['address'],
            buttons: [
              {
                title: "Llegar ahí",
                type: "web_url",
                url: "https://maps.apple.com/?saddr=#{lat},#{lng}&daddr=#{punto["latitude"]},#{punto["longitude"]}", 
              }
            ]
          }
        end
        
        message.reply({
          attachment: {
            type: "template",
            payload: {
              template_type: "list",
              top_element_style: "compact",
              elements: elements
            }
          }
        })

      end

    end

  else
    message.ask_for_location('Dónde estas ubicado? Dinos y te mostraremos dónde están los puntos de recarga TuLlave más cercanos.')
  end


end
