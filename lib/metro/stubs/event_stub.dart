import 'package:recase/recase.dart';

String eventStub({required ReCase eventName}) => '''
import 'package:nylo_framework/nylo_framework.dart';

class ${eventName.pascalCase}Event implements NyEvent {

  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  handle(dynamic event) async {
   // Handle the event
   
  }
}
''';