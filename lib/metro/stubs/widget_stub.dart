
String widgetStub(String widgetName) => '''
import 'package:flutter/material.dart';

class ${widgetName}Widget extends StatefulWidget {
  @override
  _${widgetName}WidgetState createState() => _${widgetName}WidgetState();
}

class _${widgetName}WidgetState extends State<${widgetName}Widget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
''';