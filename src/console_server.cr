require "socket"
require "./vortex_exeption"
require "./command_processor"

# Клиент консоли
class CommandClient
  # Сокет клиента
  getter socket : Socket

  # Конструктор
  def initialize(@socket)    
  end

  # Отправляет строку с переводом строки
  def sendLine(message)
    @socket.send("#{message}\n")
  end
end

# Обрабатывает команды консоли
class ConsoleServer
  # Размер буффера
  BUFFER_SIZE = 4096

  # Сервер
  @server : TCPServer

  # Server port
  getter port : Int32

  # Command processor
  getter commandProcessor : CommandProcessor
  
  def initialize(@port, @commandProcessor)
    @server = TCPServer.new(@port)
    @server.recv_buffer_size = BUFFER_SIZE
  end

  # Process message
  # TODO: method name
  def process(client : CommandClient, message : String) : Void
    cmdList = message.split(" ")
    puts cmdList

    case cmdList[0]
    when "new_class"
      processNewClass(client,cmdList)
    when "new_clattr"
      processNewClassAttribute(client,cmdList)
    when "set_clattr_value"
      processSetClassAttributeValue(client, cmdList)
    when "get_clattr_value"
      processGetClassAttributeValue(client, cmdList)
    when "del_class"
      #processDelete(client, cmdList)
    when "del_clattr"
      #processGetValue(client, cmdList)
    when "del_instance"
      #processSetValue(client, cmdList)
    else
      raise VortexException.new("Unknown command")
    end
  end

  # Process create new class
  # new_class (name)
  def processNewClass(client : CommandClient, cmdList : Array(String)) : Void
    className = cmdList[1]
    parentName = nil    
    parentName = cmdList[2] if cmdList.size > 2
    nclass = @commandProcessor.createClass(className, parentName)    
    #p nclass
    client.sendLine("Class created Id: #{nclass.id} Name: #{nclass.name} ParentName: #{parentName || "null"}")
  end

  # Process create new instance
  def processNewInstance(client : CommandClient, cmdList : Array(String)) : Void
    instanceName = cmdList[2]
    #@commandProcessor.createInstance(instanceName)
  end  

  # Process create new class attribute
  # new_clattr (class) (name) (valueType)
  def processNewClassAttribute(client : CommandClient, cmdList : Array(String)) : Void
    nattr = @commandProcessor.createClassAttribute(cmdList[1], cmdList[2], cmdList[3])
    #p nattr
    client.sendLine("Attribute created ClassName: #{nattr.parentClass.name} AttributeId: #{nattr.id} AttributeName: #{nattr.name} ValueType: #{nattr.valueType}")
  end

  # Set class attribute value
  # set_clattr_value (class) (name) (value)
  def processSetClassAttributeValue(client : CommandClient, cmdList : Array(String)) : Void
    attrWithValue = @commandProcessor.setClassAttributeValueByName(cmdList[1], cmdList[2], cmdList[3])    
    #p attrWithValue
    client.sendLine("ok")    
  end

  # Process get class attribute value
  # get_clattr_value (class) (name)
  def processGetClassAttributeValue(client : CommandClient, cmdList : Array(String)) : Void    
    attrWithValue = @commandProcessor.getClassAttributeValueByName(cmdList[1], cmdList[2])    

    if attrWithValue.nil?
      client.sendLine("null")
    else      
      client.sendLine(attrWithValue.value)
    end    
  end

  # Запускает сервер
  def start : Void
    loop do
      client = @server.accept
      next if client.nil?
      commandClient = CommandClient.new(client)

      spawn do
        loop do
          message = client.gets
          next unless message
          begin
            if message.starts_with?("exit")
              client.close
              break
            end
            process(commandClient, message)
          rescue e : VortexException
            puts e.backtrace
            commandClient.sendLine(e.message!)
          rescue e : Exception
            puts e.backtrace
            commandClient.sendLine("error")
          end
        end
      end
    end
  end
end
