import 'package:vortexdb/common/console/console_client_socket.dart';
import 'package:vortexdb/server/console_server/commands/console_command.dart';

/// Exit from console server
class ExitCommand extends ConsoleCommand {
  /// Command name
  static const Name = 'exit';

  /// Constructor
  ExitCommand() : super(Name, 'Disconnect from console server');

  @override
  Future process(ConsoleClientSocket client, List<String> _) async {
    await client.close();
  }
}
