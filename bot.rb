require "sinatra/base"

class WhatsAppBot < Sinatra::Base
  use Rack::TwilioWebhookAuthentication, ENV.fetch("TWILIO_AUTH_TOKEN", nil), "/bot"

  post "/bot" do
    body = params["Body"].downcase
    response = Twilio::TwiML::MessagingResponse.new
    response.message do |message|
      message.body(Welcome.hello) unless body.include?("1") || body.include?("2")
      if body.include?("1")
        message.body(Welcome.accept)
        if body.include?("CLIENTE")
          message.body(Customer.hello)
        end
      end
      message.body(Welcome.deny) if body.include?("2")
    end
    content_type "text/xml"
    response.to_xml
  end
end

module Welcome
  def self.hello
    "¡Hola! Bienvenido al canal de atención de WhatsApp de *Domesticapp*
  Para seleccionar una opción del menú, envía solo el número de la opción a
  través de tu teclado numérico.
  Al utilizar este medio aceptas los términos y condiciones de WhatsApp y te
  responsabilizas de la información que sea compartida a través del mismo, bajo
  las características de seguridad de la aplicación. Si quieres ampliar información
  ingresa aquí: https://www.whatsapp.com/legal
  Para continuar elige:
  1 . Acepto
  2 . No acepto"
  end

  def self.deny
    "Gracias por utilizar el canal de WhatsApp de Domesticapp, puedes
    regresar en cualquier momento"
  end

  def self.accept
    "Bienvenido a Domesticapp! Para seleccionar una opción del menú, envía solo el
     número de la opción a través de tu teclado numérico.
     Seleccione el tipo de atención que desea recibir:
     Atención para el CLIENTE o Atención para el EMPLEADO"
  end
end

module Customer
  def self.hello
    "Bienvenido a Domesticapp. Conoce nuestros servicios asistenciales y la
    labor que desarrollamos por la dignidad laboral"
  end
end
