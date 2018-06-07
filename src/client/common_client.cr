require "../vortexdb/**"

# Common client with base functions
class CommonClient
  # Socket to connect
  @socket : HTTP::WebSocket?

  # Server host
  @host : String

  # Server port
  @port : Int32
  
  private def socket!
    @socket.not_nil!
  end

  # Send contract
  private def sendContract(contract : ErContract) : Void
    socket!.send(contract.toBytes)
  end

  def initialize(@host : String, @port : Int32)
  end

  # Open client
  def open : Void
    @socket = HTTP::WebSocket.new(host, ExternalRequestServer::WS_PATH, port)

    @socket.on_binary do |data|
      contract = MsgPackContract.fromBytes(data).as(ErContract)
    end

    @socket.on_close do
      puts "CLOSED"
    end

    spawn do
      @socket.run
    end
  end

  # Create class
  def createClass(name : String, parent : CVClass? = nil) : CVClass
    sendContract(
      NewClassErContract.new(
        name: name,
        parentName: parent.try &.name
      ))
    return CVClass.new(3_i64, "Good")
  end
end