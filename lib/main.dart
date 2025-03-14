import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MainLayout());
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatePage(),
      child: MaterialApp(home: MainPage()),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = TextEditorMain();
        break;
      case 1:
        page = NotesFinished();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = Preferences();
        break;
      default:
        throw UnimplementedError('no widget for $_selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(title: Text('Royal Notes')),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.minWidth >= 600,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.note),
                      label: Text('Saved Notes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Follow-ups'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Preferences'),
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      _selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(child: page),
            ],
          ),
        );
      },
    );
  }
}

class StatePage extends ChangeNotifier {
  var index = -1;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bookingController = TextEditingController();
  final TextEditingController _srController = TextEditingController();
  final TextEditingController _agentController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  List<List> fullNote = [];

  var finalNote = '';
  var name = '';

  void saveNote() {
    index++;

    fullNote.add([
      _bookingController.text,
      _srController.text,
      _agentController.text,
      _typeController.text,
      _detailsController.text,
    ]);

    finalNote =
        "${fullNote[index][1]} ***RSS $name*** ${fullNote[index][3]} ${fullNote[index][2]} ${fullNote[index][4]}"
            .trim();

    _bookingController.clear();
    _srController.clear();
    _agentController.clear();
    _typeController.clear();
    _detailsController.clear();

    notifyListeners();
  }

  saveName() {
    name = _nameController.text;
    _nameController.clear();
    notifyListeners();
  }
}

class TextEditorMain extends StatelessWidget {
  const TextEditorMain({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<StatePage>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking'),
                      TextField(controller: appState._bookingController),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SR'),
                      TextField(controller: appState._srController),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Agent/Guest name'),
                      TextField(controller: appState._agentController),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type of caller'),
                      TextField(
                        controller: appState._typeController,
                        decoration: InputDecoration(labelText: 'CO, DG, TP'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details'),
                  TextField(
                    controller: appState._detailsController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (appState.name == '') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please enter your name',
                              style: GoogleFonts.ubuntu(fontSize: 20.0),
                            ),
                          ),
                        );
                      } else {
                        appState.saveNote();
                        Clipboard.setData(
                          ClipboardData(text: appState.finalNote),
                        ).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Copied to clipboard',
                                style: GoogleFonts.ubuntu(fontSize: 20.0),
                              ),
                            ),
                          );
                        });
                      }
                    },
                    child: Text(
                      'Copy, clear and save',
                      style: GoogleFonts.ubuntu(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotesFinished extends StatelessWidget {
  const NotesFinished({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<StatePage>();
    return ListView(
      children: [
        Text(
          'You have ${appState.fullNote.length} notes',
          style: GoogleFonts.ubuntu(fontSize: 20.0),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        for (var listItem in appState.fullNote)
          Card(
            child: ListTile(
              leading: Icon(Icons.note_add),
              title: Text(
                listItem[1] +
                    " *** RSS ${appState.name} *** " +
                    "${listItem[3]}" +
                    " " +
                    " ${listItem[2]} " +
                    " " +
                    "${listItem[4]}",
                style: GoogleFonts.ubuntu(fontSize: 20.0),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: appState.finalNote)).then(
                  (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copied to clipboard',
                          style: GoogleFonts.ubuntu(fontSize: 20.0),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class FollowUps extends StatelessWidget {
  const FollowUps({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<StatePage>();
    return Placeholder();
  }
}

class Preferences extends StatelessWidget {
  const Preferences({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<StatePage>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter you name', style: GoogleFonts.ubuntu(fontSize: 15.0)),
        SizedBox(height: 20),
        TextField(controller: appState._nameController),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            appState.saveName();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Name saved',
                  style: GoogleFonts.ubuntu(fontSize: 20.0),
                ),
              ),
            );
          },
          child: Text('Submit', style: GoogleFonts.ubuntu(fontSize: 15.0)),
        ),
      ],
    );
  }
}
