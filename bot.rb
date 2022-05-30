require "sinatra/base"

class WhatsAppBot < Sinatra::Base
  post "/bot" do
    body = params["Body"]

    answer = body.split.first.downcase.strip
    puts session[:answer]
    if ["1"].include? answer
      message = "¡Bienvenido a
      Domesticapp! Para
      seleccionar una opción
      del menú, envía solo el
      número de la opción a
      través de tu teclado
      numérico.
      Seleccione el tipo de
      atención que desea
      recibir"

    elsif ["2"].include? answer
      message = "Gracias por utilizar el
      canal de WhatsApp de
      Domesticapp, puedes
      regresar en cualquier
      momento"
    end

    if !session[:answer]
      message = "¡Hola! Bienvenido al canal de atención de WhatsApp de *Domesticapp*
      Para seleccionar una opción del menú, envía solo el número de la opción a
      través de tu teclado numérico.
      Al utilizar este medio aceptas los términos y condiciones de WhatsApp y te
      responsabilizas de la información que sea compartida a través del mismo, bajo
      las características de seguridad de la aplicación. Si quieres ampliar información
      ingresa aquí: https://www.whatsapp.com/legal
      Para continuar elige:
      1 . Acepto
      2 . No acepto"
      session[:answer] = answer
    end
    response = Twilio::TwiML::MessagingResponse.new
    response.message(body: message)
    content_type "text/xml"
    response.to_xml
  end
end
