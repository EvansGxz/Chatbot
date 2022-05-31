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
          message = "En un momento un asesor le atenderá"
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
          message = "Pronto un asesor le atenderá"
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
      "¡Hola! Bienvenido al canal de atención de WhatsApp de *Domesticapp* " \
        "Para seleccionar una opción del menú, envía solo el número de la opción a " \
        "través de tu teclado numérico. Al utilizar este medio aceptas los términos " \
        "y condiciones de WhatsApp y te responsabilizas de la información que sea compartida " \
        "a través del mismo, bajo las características de seguridad de la aplicación. Si quieres " \
        "ampliar información ingresa aquí: https://www.whatsapp.com/legal
      Para continuar elige:
      1 . Acepto
      2 . No acepto"
    end

    def self.deny
      "Gracias por utilizar el canal de WhatsApp de Domesticapp, puedes " \
        "regresar en cualquier momento"
    end

    def self.accept
      "¡Bienvenido a Domesticapp! Para seleccionar una opción del menú, "\
        "envía solo el número de la opción a través de tu teclado numérico. "\
        "Seleccione el tipo de atención que desea recibir
        1 . Cliente
        2 . Empleado"
    end

    def self.wrong
      "Por favor, elige una opción valida"
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
      "Seleccione la opción más acorde a sus necesidades o contacta con un "\
        "asesor (soporte) para una atención personalizada:"\
        "#{tipo}"
    end

    def self.new_customer
      "1. Servicios Domesticapp.
      2. Programar un Servicio.
      3. Beneficios.
      4. Nuestro Precios.
      5. App Móvil Domesticapp.
      6. Preguntas Frecuentes.
      7. Ley Vigente.
      8. Hablar con un Asesor.
      9. Atrás."
    end

    def self.habitual
      "
      1. Preguntas Frecuentes.
      2. Hablar con un Asesor.
      3. Atrás."
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
        "días y meses para hogares, empresas, hoteles, edificios"\
        "y organizaciones en:
        ‣ Limpieza y aseo general
        ‣ Cuidado del adulto Mayor
        ‣ Acompañamiento de enfermos
        ‣ Niñeras y atención de la primera infancia
        ‣ Mucamas
        ‣ Camareros
        ‣ Jardineros
        ‣ Albañilería
        ‣ Cosecheros
        ‣ Aux. de bodegas
        ‣ Carretilleros
        ‣Otros"
    end

    def self.program
      "Programa tus servicios contactando con un asesor o desde tu dispositivo:
      Android: (URL PlayStore)
      Apple: (URL AppStore"
    end

    def self.beneficios
      "Cuando contratas un servicio con Domesticapp gozas de:
      ‣ App Móvil de control de tus servicios
      ‣ Garantías y respaldo de ley a los empleados
      ‣ Calidad en el servicio
      ‣ Pólizas de daños contra terceros (Te protegemos en todo momento)
      ‣ Información y filtrado de personal
      ‣ Analítica avanzada
      ‣ Soporte en linea 24/7
      ‣ Economía y ahorro"
    end

    def self.price
      "*Precios España 2022:*

      *Costo general del servicio x hora:* 16.5 Euros (Todo incluido)

      *Precios Colombia 2022:*

      *Media Jornada:* 68.500 COP (Todo incluido) (4 Hrs. de servicio + 30 min. Alimentación)

      *Jornada Completa:* 94.500 COP (Todo incluido) (8 Hrs. de servicio + 1 Hr. Alimentación)"
    end

    def self.app
      "Descárgala en tu móvil:

      Android: URL PlayStore)
      Apple: (URL AppStore)"
    end

    def self.support
      "Conectando con un asistente"
    end

    def self.law
      "En acto de buena fe para con las leyes ejecutables en cada país se aclara que"\
        "Domesticapp acata cada una de las normas establecidas por los organismos de control"
    end
  end

  module FAQSCustomer
    def self.services
      "1.1.1 ¿Cómo puedo programar/cancelar o reagendar un servicio en Domesticapp?\n"\
        "Descarga el aplicativo móvil de Domesticapp para Colombia, España y Canadá y accede al manejo de "\
        "tus servicios en tiempo real. Conoce a tus asistentes, califícalos y goza de múltiples beneficios.\n\n"\
        "1.1.2 ¿Qué garantías tengo cuando contrato un servicio con Domesticapp?\n" \
        "TODOS tus servicios están protegidos por daños a terceros con el fin de evitar cualquier altercado, "\
        "además, todos nuestros asistentes cuentan con certificaciones especializadas para sus labores."
    end

    def self.account
      "1.2.1 ¿Cómo se maneja mi información personal?\n"\
        "En Domesticapp tu información es muy importante para nosotros, nunca divulgaremos tus datos con "\
        "terceros de acuerdo con las políticas internacionales de protección de la información del usuario.\n\n"\
        "1.2.2 ¿Cuáles son los beneficios de contar con una cuenta en Domesticapp?\n"\
        "Cuando te registras en Domesticapp accedes a descuentos, sorteos con tus servicios, además, puedes "\
        "compartir estos regalos al referir a tus amigos y familiares."
    end

    def self.assist
      "1.3.1 ¿Con que experiencia cuentan los empleados y asistentes?\n"\
        "TODOS nuestros asistentes y empleados han pasado por un filtro exhaustivo "\
        "bilateral, realizamos un seguimiento del perfil laboral mediante nuestra "\
        'inteligencia artificial "Mile" y posteriormente una evaluación psicológica '\
        "donde verificamos uno a uno todos los datos suministrados, antecedentes y por "\
        "supuesto su experticia y experiencia en el oficio. Recuerda que puedes estar al tanto de esta "\
        "información en tiempo real en el perfil del empleado o asistente de tu interés.\n\n"\
        "1.3.2 ¿Qué ley respalda a los empleados y asistentes?\n"\
        "Acogidos con un compromiso social global, Domesticapp garantiza todas las prestaciones de ley, "\
        "el salario justo y los beneficios laborales vigentes en cada país donde realiza operaciones comerciales a "\
        "cada uno de los miembros de su personal.\n\n"\
        "1.3.3 ¿Cómo influye la calificación realizada a los empleados y asistentes que atiendan mis servicios?\n"\
        "Con el animo de realizar una constante mejora de nuestros servicios, incentivamos a nuestros empleados "\
        "y asistentes a siempre satisfacer las necesidades de nuestros clientes y a que estas se vean reflejadas "\
        "según la calificación recibida. Nuestros mejores empleados reciben múltiples regalos, beneficios y "\
        "formaciones especiales."
    end

    def self.payment
      "1.4.1 ¿Qué ocurre si noto una inconsistencia en alguno de mis pagos?\n"\
        "Nuestro sistema de pagos cuenta con tecnología avanzada en seguridad informática y encriptado "\
        "bilateral, sin embargo en caso de presentarse alguna inconsistencia con tus pagos o facturación puedes "\
        "realizar tu reclamo en el chat de soporte 24/7 o en cualquiera de nuestras líneas de atención presentes "\
        "en www.domesticapp.com.co, nuestro equipo de atención al cliente le dará la mayor celeridad a tu requerimiento.\n\n"\
        "1.4.2 ¿Existen costos ocultos al programar un servicio con Domesticapp?\n"\
        "En Domesticapp no existe NINGUN costo oculto, evite caer en manos de personas inescrupulosas y no "\
        "suministre nunca pagos a terceros, asistentes o empleados. Realice todos sus pagos UNICA y "\
        "EXCLUSIVAMENTE por nuestros aplicativos o ChatBots Autorizados."
    end

    def self.beneficios
      "1.5.1 ¿Cuáles son mis beneficios por estar registrado en Domesticapp?\n"\
        "En Domesticapp encuentras pilares no negociables: Cuidamos tu bolsillo, Protegemos tus "\
        "espacios y garantizamos la máxima satisfacción. Además accedes a beneficios de nuestros aliados solo "\
        "por usar nuestros servicios, restaurantes, teatros, cinemas y demás.\n\n"\
        "1.5.2 ¿Cómo accedo a mis beneficios en Domesticapp?"\
        "Desde que realizas el registro en Domesticapp accedes a descuentos y beneficios, sistema de "\
        "referidos gana a gana. En nuestras redes sociales encontrarás información actualizada de nuestros "\
        "regalos y beneficios de temporada."
    end

    def self.devoluciones
      "1.6.1 ¿En que casos puedo acceder a una devolución?\n" \
        "Cuando por eventualidades en nuestros sistemas, incumplimiento de labores u otras variables en el "\
        "servicio, no se cumple a cabalidad con lo establecido dentro de nuestras políticas de calidad.\n\n"\
        "1.6.2 ¿Cómo realizo una petición de devolución?\n"\
        "En todas nuestras plataformas cuentas con servicio de atención al cliente 24/7, ChatBot de "\
        "respuestas automatizadas y atención vía email."
    end
  end

  module FAQSEmployee
    def self.gain
      "2.1.1 ¿Cómo se calculan mis ganancias estimadas?\n"\
        "En Domesticapp puedes mantenerte al tanto de tus ganancias en todo momento. Recuerda que "\
        "nuestros periodos de nomina son los días 5 y 20 de cada mes y allí se refleja el calculo de horas "\
        "trabajadas en ese periodo y las ganancias totales de estas luego de deducciones de ley y otros ajustes.\n\n"\
        "2.1.2 ¿Qué pasa si noto alguna irregularidad en el calculo de mis ganancias?\n"\
        'El sistema de "Mis Ganancias" suministra un aproximado de tus honorarios y no debe considerarse '\
        "un estricto de tu nomina o de tus pagos. Si notas alguna irregularidad debes corroborar con tu extracto "\
        "salarial y notificarlo al área encargada. Para ello puedes utilizar cualquier medio de atención disponible "\
        "en nuestras plataformas Domesticapp."
    end

    def self.account
      "2.2.1 ¿Cómo solicito un cambio en mi información personal o profesional?\n"\
        "Si tienes alguna duda, queja o reclamo con respecto a la información presente en tu perfil "\
        "profesional o en tu cuenta en general puedes comunicarlo mediante el chat de atención 24/7 y "\
        "nuestro equipo evaluara la situación en el menor tiempo posible.\n\n"\
        "2.2.2 ¿Qué pasa si me siento inconforme con la reseña presentada por un cliente?\n"\
        "Domesticapp está comprometido con la dignidad laboral en todo momento, es por eso que realizamos "\
        "un seguimiento exhaustivo a todas y cada una de las reseñas recibidas por nuestros clientes con el fin de "\
        "mantener un espacio laboral ameno, en caso de que se presente una inconsistencia en la evaluación "\
        "recibida está se elimina de forma automática y no afecta tu imagen o perfil profesional."
    end

    def self.covid
      "2.3.1 ¿Cuáles son las políticas de Domesticapp con respecto a la Covid-19?\n"\
        "Tenemos un compromiso inmodificable con la salud y el bienestar tanto de nuestros asistentes y "\
        "colaboradores como también con el de nuestros clientes, por eso Domesticapp se acoge a todas las "\
        "decisiones e instrucciones de sanidad suministradas por los entes reguladores de cada país. Usted NO "\
        "DEBE TRABAJAR si se considera sospechoso a Covid-19 u otros virus, rinovirus o infecciones, esto es por su "\
        "salud y bienestar. Siempre contará con todos los protocolos de bioseguridad suministrados por nuestra compañía\n\n"\
        "2.3.2 ¿Qué protocolos de bioseguridad debo de cumplir al realizar mis labores profesionales en Domesticapp?\n"\
        "Usted debe acatar todos los protocolos de sanidad que estén vigentes a la fecha en el lugar "\
        "donde se encuentra laborando, tales como cubrebocas, gel antibacterial y/o distanciamiento "\
        "social. Si considera que se incumple la protección a su salud o se encuentra por fuera de la normativa "\
        "generada por los entes reguladores de salud publica usted está en el DERECHO de negarse a prestar "\
        "cualquier servicio laboral y esto no acarreara sanción alguna ni se reflejará como un incumplimiento de sus "\
        "labores como empleado. Su salud y bienestar es nuestro mayor compromiso"
    end

    def self.payment
      "2.4.1 ¿Cuáles son los métodos y condiciones para el desembolso de mis pagos?\n"\
        "Los cortes de nomina se realizan de forma quincenal, los días cinco (5) y veinte (20) de cada mes. "\
        "Los honorarios producto de labores profesionales son consignados de forma puntual a las cuentas bancarias "\
        "detalladas por el empleado con su respectivo comprobante en adjunto. Domesticap no se hace "\
        "responsable de eventualidades como fallas técnicas o problemas con la entidad financiera que retrasen el "\
        "periodo natural de los pagos, sin embargo procura evitar siempre este tipo de sucesos. Cualquier "\
        "irregularidad puede ser comunicada en nuestros diferentes canales de atención.\n\n"\
        "2.4.2 ¿Qué descuentos o deducciones se efectúan en mis pagos?\n"\
        "Domesticapp cumple las normativas locales e internacionales de dignidad laboral, es por eso que "\
        "para garantizar todas las prestaciones y beneficios laborales realiza las deducciones que estipula la ley "\
        "vigente de cada país. Usted puede informarse de esto en los portales y canales del ministerio de trabajo y/o "\
        "protección social de su país. Si usted tiene otros pendientes con la compañía como prestamos o "\
        "adelantos de nomina estos también se verán reflejados según lo acuerde con el empleador (Tenga "\
        "en cuenta que estos últimos son acuerdos internos entre ambas partes de la relación laboral)."
    end

    def self.deudar
      "2.5.1 ¿Cómo puedo acceder a un préstamo por calamidad o un adelanto de nomina?\n"\
        "Debe radicar la solicitud por escrito, pidiendo el respectivo formato por cualquiera de los canales de "\
        "atención (Como el chat de soporte 24/7) y especificar de forma detallada los motivos de su petición y estar "\
        "de acuerdo con su posterior descuento de nomina. Domesticapp únicamente realiza este tipo de "\
        "procedimientos atendiendo a necesidades de forma urgente que puedan presentarse para sus asistentes y "\
        "empleados.\n\n"\
        "2.5.2 ¿Cómo se descuentas mis deudas pendientes por prestamos de calamidad o adelanto de nomina?\n"\
        "Domesticapp realiza los descuentos y deducciones automáticamente de su próxima "\
        "quincena (pago de honorarios) o según lo acordado en el formato de diligenciamiento."
    end

    def self.dotacion
      "2.6.1 ¿Cuál es la dotación para la prestación de mis servicios y cada cuanto debe ser renovada?\n"\
        "Cada servicio cuenta con unas especificaciones dotacionales diferentes y según el país donde se "\
        "desarrolla la actividad. Generalmente la dotación debe ser renovada cada tres (3) o seis (6) meses por el "\
        "empleador y de acuerdo a la reglamentación"
    end
  end

  module Employee
    def self.hello
      "Bienvenido a Domesticapp. Una empresa comprometida con la dignidad laboral\n"\
        "Seleccione la opción que más se acomode a su perfil:\n1. Empleado Domesticapp\n"\
        "2. Quiero trabajar en Domesticapp"
    end

    def self.select(type)
      "Seleccione la opción más acorde a sus necesidades o contacta con un "\
        "asesor (soporte) para una atención personalizada:#{type}"
    end

    def self.new_employee
      "\n1. Requisitos\n 2. Garantías Laborales\n3. Hablar con un Asesor \n 4. Atrás"
    end

    def self.employee
      "\n1. Dudas Con Mi Empleo\n2. Hablar con un Asesor \n3. Atrás"
    end

    def self.requisitos
      "Si quieres hacer parte del equipo Domesticapp es necesario que cumplas las
      siguientes condiciones mínimas:\n"\
      "Encontrarse residiendo en el país en que realizará su funcón.\n"\
      "Dos años de experiencia certificable en el cargo a diseñar\n"\
      "Disponibilidad Inmediata\n"\
      "Manejo básico de móvil\n"\
      "Aprobar la Preentrevista disponible en:\n"\
      "https://domesticapp.com.co/vacantes-laborales-domesticapp/\n"\
      "Para cada país en especial."
    end

    def self.garantias
      "Acorde con nuestra política de dignidad laboral y responsabilidad laboral, "\
        "Domesticapp se acoge a toda la reglamentación vigente para menores de "\
        "edad. Puedes verla en la pagina del gobierno de tu país."
    end

    def self.faqs
      "1. *FAQS Mis Ganancias*\n2. *FAQS Mi cuenta*\n3. *FAQS COVID-19*\n4. *FAQS MIS PAGOS*\n5. *FAQS Deudas*\n6. *FAQS Dotación*"
    end
  end
