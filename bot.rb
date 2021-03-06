require "sinatra/base"

class WhatsAppBot < Sinatra::Base
  enable :sessions
  # This will ensure that webhook requests definitely come from Twilio.
  use Rack::TwilioWebhookAuthentication, ENV.fetch("TWILIO_AUTH_TOKEN", nil), "/bot"

  # When we receive a POST request to the /bot endpoint this code will run.
  post "/bot" do
    incoming = params[:Body]
    if incoming == "clear"
      session.delete
    elsif session[:a] == "1"
      if session[:b] == "1"
        if incoming == "1" && session[:c] == "1" && !session[:d]
          message = NewCustomer.services
        elsif incoming == "2" && session[:c] == "1" && !session[:d]
          message = NewCustomer.program
        elsif incoming == "3" && session[:c] == "1" && !session[:d]
          message = NewCustomer.beneficios
        elsif incoming == "4" && session[:c] == "1" && !session[:d]
          message = NewCustomer.price
        elsif incoming == "5" && session[:c] == "1" && !session[:d]
          message = NewCustomer.app
        elsif ((incoming == "6" || session[:d] == "6") && session[:c] == "1") || ((incoming == "1" || session[:d] == "1") && session[:c] == "2")
          if !session[:d]
            message = Customer.faqs
            session[:d] = incoming
          elsif incoming == "1" && session[:d]
            message = FAQSCustomer.services
          elsif incoming == "2" && session[:d]
            message = FAQSCustomer.account
          elsif incoming == "3" && session[:d]
            message = FAQSCustomer.assist
          elsif incoming == "4" && session[:d]
            message = FAQSCustomer.payment
          elsif incoming == "5" && session[:d]
            message = FAQSCustomer.beneficios
          elsif incoming == "6" && session[:d]
            message = FAQSCustomer.devoluciones
          end
        elsif incoming == "7" && session[:c] == "1" && !session[:d]
          message = NewCustomer.law
        elsif incoming == "8" && session[:c] == "1" && !session[:d]
          message = NewCustomer.support
        elsif (incoming == "9" && session[:c] == "1" && !session[:d]) || (incoming == "3" && session[:c] == "2" && !session[:d])
          session.delete(:c)
          message = Customer.hello
        elsif incoming == "2" && session[:c] == "2" && !session[:d]
          message = "En un momento un asesor le atender??"
        elsif incoming == "1" && !session[:c]
          session[:c] = incoming
          message = Customer.select(Customer.new_customer)
        elsif incoming == "2" && !session[:c]
          session[:c] = incoming
          message = Customer.select(Customer.habitual)
        end
      elsif session[:b] == "2"
        if incoming == "1" && session[:e] == "2" && !session[:f]
          message = Employee.requisitos
        elsif incoming == "2" && session[:e] == "2" && !session[:f]
          message = Employee.garantias
        elsif (incoming == "2" && session[:e] == "1" && !session[:f]) || (incoming == "3" && session[:e] == "2")
          message = "Pronto un asesor le atender??"
        elsif (incoming == "4" && session[:e] == "2" && !session[:f]) || (incoming == "3" && session[:e] == "1" && !session[:f])
          session.delete(:e)
          message = Employee.hello
        elsif (incoming == "1" || session[:f] == "1") && session[:e] == "1"
          if !session[:f]
            message = Employee.faqs
            session[:f] = incoming
          elsif incoming == "1" && session[:f]
            message = FAQSEmployee.gain
          elsif incoming == "2" && session[:f]
            message = FAQSEmployee.account
          elsif incoming == "3" && session[:f]
            message = FAQSEmployee.covid
          elsif incoming == "4" && session[:f]
            message = FAQSEmployee.payment
          elsif incoming == "5" && session[:f]
            message = FAQSEmployee.deudar
          elsif incoming == "6" && session[:f]
            message = FAQSEmployee.dotacion
          end
        elsif incoming == "2" && !session[:e]
          session[:e] = incoming
          message = Employee.select(Employee.new_employee)
        elsif incoming == "1" && !session[:e]
          session[:e] = incoming
          message = Employee.select(Employee.employee)
        end
      elsif incoming == "1" && !session[:b]
        session[:b] = incoming
        message = Customer.hello
      elsif incoming == "2" && !session[:b]
        session[:b] = incoming
        message = Employee.hello
      else
        puts session[:b]
        message = Welcome.wrong
      end
    elsif incoming == "1" && !session[:a]
      session[:a] = incoming
      message = Welcome.accept
    elsif incoming == "2" && !session[:a]
      session[:a] = incoming
      message = Welcome.deny
      session.clear
    else
      message = Welcome.hello
    end
    # TWILIO
    # Initialise a new response object that we will build up.
    response = Twilio::TwiML::MessagingResponse.new
    # Add a message to reply with
    response.message body: message
    # TwiML is XML, so we set the Content-Type response header to text/xml
    content_type "text/xml"
    # Respond with the XML of the response object.
    response.to_xml
  end
end
# Modules
  module Welcome
    def self.hello
      "??Hola! Bienvenido al canal de atenci??n de WhatsApp de *Domesticapp* " \
        "Para seleccionar una opci??n del men??, env??a solo el n??mero de la opci??n a " \
        "trav??s de tu teclado num??rico. Al utilizar este medio aceptas los t??rminos " \
        "y condiciones de WhatsApp y te responsabilizas de la informaci??n que sea compartida " \
        "a trav??s del mismo, bajo las caracter??sticas de seguridad de la aplicaci??n. Si quieres " \
        "ampliar informaci??n ingresa aqu??: https://www.whatsapp.com/legal
      Para continuar elige:
      1 . Acepto
      2 . No acepto"
    end

    def self.deny
      "Gracias por utilizar el canal de WhatsApp de Domesticapp, puedes " \
        "regresar en cualquier momento"
    end

    def self.accept
      "??Bienvenido a Domesticapp! Para seleccionar una opci??n del men??, "\
        "env??a solo el n??mero de la opci??n a trav??s de tu teclado num??rico. "\
        "Seleccione el tipo de atenci??n que desea recibir
        1 . Cliente
        2 . Empleado"
    end

    def self.wrong
      "Por favor, elige una opci??n valida"
    end
  end

  module Customer
    def self.hello
      "Bienvenido a Domesticapp. Conoce nuestros servicios asistenciales y la "\
        "labor que desarrollamos por la dignidad laboral.
      Seleccione el tipo de cliente que se acomode a su perfil actual:
      1 . Cliente Nuevo
      2 . Cliente Habitual"
    end

    def self.select(tipo)
      "Seleccione la opci??n m??s acorde a sus necesidades o contacta con un "\
        "asesor (soporte) para una atenci??n personalizada:"\
        "#{tipo}"
    end

    def self.new_customer
      "1. Servicios Domesticapp.
      2. Programar un Servicio.
      3. Beneficios.
      4. Nuestro Precios.
      5. App M??vil Domesticapp.
      6. Preguntas Frecuentes.
      7. Ley Vigente.
      8. Hablar con un Asesor.
      9. Atr??s."
    end

    def self.habitual
      "
      1. Preguntas Frecuentes.
      2. Hablar con un Asesor.
      3. Atr??s."
    end

    def self.faqs
      "1. *FAQS Servicios*\n"\
        "2. *FAQS Mi cuenta*\n"\
        "3. *FAQS ASISTENTES*\n"\
        "4. *FAQS PAGOS*\n"\
        "5. *FAQS Beneficios*\n"\
        "6. *FAQS DEVOLUCIONES*"
    end
  end

  module NewCustomer
    def self.services
      "Servicios especializados y de alta calidad por horas, "\
        "d??as y meses para hogares, empresas, hoteles, edificios"\
        "y organizaciones en:
        ??? Limpieza y aseo general
        ??? Cuidado del adulto Mayor
        ??? Acompa??amiento de enfermos
        ??? Ni??eras y atenci??n de la primera infancia
        ??? Mucamas
        ??? Camareros
        ??? Jardineros
        ??? Alba??iler??a
        ??? Cosecheros
        ??? Aux. de bodegas
        ??? Carretilleros
        ???Otros"
    end

    def self.program
      "Programa tus servicios contactando con un asesor o desde tu dispositivo:
      Android: (URL PlayStore)
      Apple: (URL AppStore"
    end

    def self.beneficios
      "Cuando contratas un servicio con Domesticapp gozas de:
      ??? App M??vil de control de tus servicios
      ??? Garant??as y respaldo de ley a los empleados
      ??? Calidad en el servicio
      ??? P??lizas de da??os contra terceros (Te protegemos en todo momento)
      ??? Informaci??n y filtrado de personal
      ??? Anal??tica avanzada
      ??? Soporte en linea 24/7
      ??? Econom??a y ahorro"
    end

    def self.price
      "*Precios Espa??a 2022:*

      *Costo general del servicio x hora:* 16.5 Euros (Todo incluido)

      *Precios Colombia 2022:*

      *Media Jornada:* 68.500 COP (Todo incluido) (4 Hrs. de servicio + 30 min. Alimentaci??n)

      *Jornada Completa:* 94.500 COP (Todo incluido) (8 Hrs. de servicio + 1 Hr. Alimentaci??n)"
    end

    def self.app
      "Desc??rgala en tu m??vil:

      Android: URL PlayStore)
      Apple: (URL AppStore)"
    end

    def self.support
      "Conectando con un asistente"
    end

    def self.law
      "En acto de buena fe para con las leyes ejecutables en cada pa??s se aclara que"\
        "Domesticapp acata cada una de las normas establecidas por los organismos de control"
    end
  end

  module FAQSCustomer
    def self.services
      "1.1.1 ??C??mo puedo programar/cancelar o reagendar un servicio en Domesticapp?\n"\
        "Descarga el aplicativo m??vil de Domesticapp para Colombia, Espa??a y Canad?? y accede al manejo de "\
        "tus servicios en tiempo real. Conoce a tus asistentes, calif??calos y goza de m??ltiples beneficios.\n\n"\
        "1.1.2 ??Qu?? garant??as tengo cuando contrato un servicio con Domesticapp?\n" \
        "TODOS tus servicios est??n protegidos por da??os a terceros con el fin de evitar cualquier altercado, "\
        "adem??s, todos nuestros asistentes cuentan con certificaciones especializadas para sus labores."
    end

    def self.account
      "1.2.1 ??C??mo se maneja mi informaci??n personal?\n"\
        "En Domesticapp tu informaci??n es muy importante para nosotros, nunca divulgaremos tus datos con "\
        "terceros de acuerdo con las pol??ticas internacionales de protecci??n de la informaci??n del usuario.\n\n"\
        "1.2.2 ??Cu??les son los beneficios de contar con una cuenta en Domesticapp?\n"\
        "Cuando te registras en Domesticapp accedes a descuentos, sorteos con tus servicios, adem??s, puedes "\
        "compartir estos regalos al referir a tus amigos y familiares."
    end

    def self.assist
      "1.3.1 ??Con que experiencia cuentan los empleados y asistentes?\n"\
        "TODOS nuestros asistentes y empleados han pasado por un filtro exhaustivo "\
        "bilateral, realizamos un seguimiento del perfil laboral mediante nuestra "\
        'inteligencia artificial "Mile" y posteriormente una evaluaci??n psicol??gica '\
        "donde verificamos uno a uno todos los datos suministrados, antecedentes y por "\
        "supuesto su experticia y experiencia en el oficio. Recuerda que puedes estar al tanto de esta "\
        "informaci??n en tiempo real en el perfil del empleado o asistente de tu inter??s.\n\n"\
        "1.3.2 ??Qu?? ley respalda a los empleados y asistentes?\n"\
        "Acogidos con un compromiso social global, Domesticapp garantiza todas las prestaciones de ley, "\
        "el salario justo y los beneficios laborales vigentes en cada pa??s donde realiza operaciones comerciales a "\
        "cada uno de los miembros de su personal.\n\n"\
        "1.3.3 ??C??mo influye la calificaci??n realizada a los empleados y asistentes que atiendan mis servicios?\n"\
        "Con el animo de realizar una constante mejora de nuestros servicios, incentivamos a nuestros empleados "\
        "y asistentes a siempre satisfacer las necesidades de nuestros clientes y a que estas se vean reflejadas "\
        "seg??n la calificaci??n recibida. Nuestros mejores empleados reciben m??ltiples regalos, beneficios y "\
        "formaciones especiales."
    end

    def self.payment
      "1.4.1 ??Qu?? ocurre si noto una inconsistencia en alguno de mis pagos?\n"\
        "Nuestro sistema de pagos cuenta con tecnolog??a avanzada en seguridad inform??tica y encriptado "\
        "bilateral, sin embargo en caso de presentarse alguna inconsistencia con tus pagos o facturaci??n puedes "\
        "realizar tu reclamo en el chat de soporte 24/7 o en cualquiera de nuestras l??neas de atenci??n presentes "\
        "en www.domesticapp.com.co, nuestro equipo de atenci??n al cliente le dar?? la mayor celeridad a tu requerimiento.\n\n"\
        "1.4.2 ??Existen costos ocultos al programar un servicio con Domesticapp?\n"\
        "En Domesticapp no existe NINGUN costo oculto, evite caer en manos de personas inescrupulosas y no "\
        "suministre nunca pagos a terceros, asistentes o empleados. Realice todos sus pagos UNICA y "\
        "EXCLUSIVAMENTE por nuestros aplicativos o ChatBots Autorizados."
    end

    def self.beneficios
      "1.5.1 ??Cu??les son mis beneficios por estar registrado en Domesticapp?\n"\
        "En Domesticapp encuentras pilares no negociables: Cuidamos tu bolsillo, Protegemos tus "\
        "espacios y garantizamos la m??xima satisfacci??n. Adem??s accedes a beneficios de nuestros aliados solo "\
        "por usar nuestros servicios, restaurantes, teatros, cinemas y dem??s.\n\n"\
        "1.5.2 ??C??mo accedo a mis beneficios en Domesticapp?"\
        "Desde que realizas el registro en Domesticapp accedes a descuentos y beneficios, sistema de "\
        "referidos gana a gana. En nuestras redes sociales encontrar??s informaci??n actualizada de nuestros "\
        "regalos y beneficios de temporada."
    end

    def self.devoluciones
      "1.6.1 ??En que casos puedo acceder a una devoluci??n?\n" \
        "Cuando por eventualidades en nuestros sistemas, incumplimiento de labores u otras variables en el "\
        "servicio, no se cumple a cabalidad con lo establecido dentro de nuestras pol??ticas de calidad.\n\n"\
        "1.6.2 ??C??mo realizo una petici??n de devoluci??n?\n"\
        "En todas nuestras plataformas cuentas con servicio de atenci??n al cliente 24/7, ChatBot de "\
        "respuestas automatizadas y atenci??n v??a email."
    end
  end

  module FAQSEmployee
    def self.gain
      "2.1.1 ??C??mo se calculan mis ganancias estimadas?\n"\
        "En Domesticapp puedes mantenerte al tanto de tus ganancias en todo momento. Recuerda que "\
        "nuestros periodos de nomina son los d??as 5 y 20 de cada mes y all?? se refleja el calculo de horas "\
        "trabajadas en ese periodo y las ganancias totales de estas luego de deducciones de ley y otros ajustes.\n\n"\
        "2.1.2 ??Qu?? pasa si noto alguna irregularidad en el calculo de mis ganancias?\n"\
        'El sistema de "Mis Ganancias" suministra un aproximado de tus honorarios y no debe considerarse '\
        "un estricto de tu nomina o de tus pagos. Si notas alguna irregularidad debes corroborar con tu extracto "\
        "salarial y notificarlo al ??rea encargada. Para ello puedes utilizar cualquier medio de atenci??n disponible "\
        "en nuestras plataformas Domesticapp."
    end

    def self.account
      "2.2.1 ??C??mo solicito un cambio en mi informaci??n personal o profesional?\n"\
        "Si tienes alguna duda, queja o reclamo con respecto a la informaci??n presente en tu perfil "\
        "profesional o en tu cuenta en general puedes comunicarlo mediante el chat de atenci??n 24/7 y "\
        "nuestro equipo evaluara la situaci??n en el menor tiempo posible.\n\n"\
        "2.2.2 ??Qu?? pasa si me siento inconforme con la rese??a presentada por un cliente?\n"\
        "Domesticapp est?? comprometido con la dignidad laboral en todo momento, es por eso que realizamos "\
        "un seguimiento exhaustivo a todas y cada una de las rese??as recibidas por nuestros clientes con el fin de "\
        "mantener un espacio laboral ameno, en caso de que se presente una inconsistencia en la evaluaci??n "\
        "recibida est?? se elimina de forma autom??tica y no afecta tu imagen o perfil profesional."
    end

    def self.covid
      "2.3.1 ??Cu??les son las pol??ticas de Domesticapp con respecto a la Covid-19?\n"\
        "Tenemos un compromiso inmodificable con la salud y el bienestar tanto de nuestros asistentes y "\
        "colaboradores como tambi??n con el de nuestros clientes, por eso Domesticapp se acoge a todas las "\
        "decisiones e instrucciones de sanidad suministradas por los entes reguladores de cada pa??s. Usted NO "\
        "DEBE TRABAJAR si se considera sospechoso a Covid-19 u otros virus, rinovirus o infecciones, esto es por su "\
        "salud y bienestar. Siempre contar?? con todos los protocolos de bioseguridad suministrados por nuestra compa????a\n\n"\
        "2.3.2 ??Qu?? protocolos de bioseguridad debo de cumplir al realizar mis labores profesionales en Domesticapp?\n"\
        "Usted debe acatar todos los protocolos de sanidad que est??n vigentes a la fecha en el lugar "\
        "donde se encuentra laborando, tales como cubrebocas, gel antibacterial y/o distanciamiento "\
        "social. Si considera que se incumple la protecci??n a su salud o se encuentra por fuera de la normativa "\
        "generada por los entes reguladores de salud publica usted est?? en el DERECHO de negarse a prestar "\
        "cualquier servicio laboral y esto no acarreara sanci??n alguna ni se reflejar?? como un incumplimiento de sus "\
        "labores como empleado. Su salud y bienestar es nuestro mayor compromiso"
    end

    def self.payment
      "2.4.1 ??Cu??les son los m??todos y condiciones para el desembolso de mis pagos?\n"\
        "Los cortes de nomina se realizan de forma quincenal, los d??as cinco (5) y veinte (20) de cada mes. "\
        "Los honorarios producto de labores profesionales son consignados de forma puntual a las cuentas bancarias "\
        "detalladas por el empleado con su respectivo comprobante en adjunto. Domesticap no se hace "\
        "responsable de eventualidades como fallas t??cnicas o problemas con la entidad financiera que retrasen el "\
        "periodo natural de los pagos, sin embargo procura evitar siempre este tipo de sucesos. Cualquier "\
        "irregularidad puede ser comunicada en nuestros diferentes canales de atenci??n.\n\n"\
        "2.4.2 ??Qu?? descuentos o deducciones se efect??an en mis pagos?\n"\
        "Domesticapp cumple las normativas locales e internacionales de dignidad laboral, es por eso que "\
        "para garantizar todas las prestaciones y beneficios laborales realiza las deducciones que estipula la ley "\
        "vigente de cada pa??s. Usted puede informarse de esto en los portales y canales del ministerio de trabajo y/o "\
        "protecci??n social de su pa??s. Si usted tiene otros pendientes con la compa????a como prestamos o "\
        "adelantos de nomina estos tambi??n se ver??n reflejados seg??n lo acuerde con el empleador (Tenga "\
        "en cuenta que estos ??ltimos son acuerdos internos entre ambas partes de la relaci??n laboral)."
    end

    def self.deudar
      "2.5.1 ??C??mo puedo acceder a un pr??stamo por calamidad o un adelanto de nomina?\n"\
        "Debe radicar la solicitud por escrito, pidiendo el respectivo formato por cualquiera de los canales de "\
        "atenci??n (Como el chat de soporte 24/7) y especificar de forma detallada los motivos de su petici??n y estar "\
        "de acuerdo con su posterior descuento de nomina. Domesticapp ??nicamente realiza este tipo de "\
        "procedimientos atendiendo a necesidades de forma urgente que puedan presentarse para sus asistentes y "\
        "empleados.\n\n"\
        "2.5.2 ??C??mo se descuentas mis deudas pendientes por prestamos de calamidad o adelanto de nomina?\n"\
        "Domesticapp realiza los descuentos y deducciones autom??ticamente de su pr??xima "\
        "quincena (pago de honorarios) o seg??n lo acordado en el formato de diligenciamiento."
    end

    def self.dotacion
      "2.6.1 ??Cu??l es la dotaci??n para la prestaci??n de mis servicios y cada cuanto debe ser renovada?\n"\
        "Cada servicio cuenta con unas especificaciones dotacionales diferentes y seg??n el pa??s donde se "\
        "desarrolla la actividad. Generalmente la dotaci??n debe ser renovada cada tres (3) o seis (6) meses por el "\
        "empleador y de acuerdo a la reglamentaci??n"
    end
  end

  module Employee
    def self.hello
      "Bienvenido a Domesticapp. Una empresa comprometida con la dignidad laboral\n"\
        "Seleccione la opci??n que m??s se acomode a su perfil:\n1. Empleado Domesticapp\n"\
        "2. Quiero trabajar en Domesticapp"
    end

    def self.select(type)
      "Seleccione la opci??n m??s acorde a sus necesidades o contacta con un "\
        "asesor (soporte) para una atenci??n personalizada:#{type}"
    end

    def self.new_employee
      "\n1. Requisitos\n 2. Garant??as Laborales\n3. Hablar con un Asesor \n 4. Atr??s"
    end

    def self.employee
      "\n1. Dudas Con Mi Empleo\n2. Hablar con un Asesor \n3. Atr??s"
    end

    def self.requisitos
      "Si quieres hacer parte del equipo Domesticapp es necesario que cumplas las
      siguientes condiciones m??nimas:\n"\
      "Encontrarse residiendo en el pa??s en que realizar?? su func??n.\n"\
      "Dos a??os de experiencia certificable en el cargo a dise??ar\n"\
      "Disponibilidad Inmediata\n"\
      "Manejo b??sico de m??vil\n"\
      "Aprobar la Preentrevista disponible en:\n"\
      "https://domesticapp.com.co/vacantes-laborales-domesticapp/\n"\
      "Para cada pa??s en especial."
    end

    def self.garantias
      "Acorde con nuestra pol??tica de dignidad laboral y responsabilidad laboral, "\
        "Domesticapp se acoge a toda la reglamentaci??n vigente para menores de "\
        "edad. Puedes verla en la pagina del gobierno de tu pa??s."
    end

    def self.faqs
      "1. *FAQS Mis Ganancias*\n2. *FAQS Mi cuenta*\n3. *FAQS COVID-19*\n4. *FAQS MIS PAGOS*\n5. *FAQS Deudas*\n6. *FAQS Dotaci??n*"
    end
  end
