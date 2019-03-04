import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Play Time',
      home: RandomWords(),
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  final Set<WordPair> _saved = new Set<WordPair>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name Generator'),
          // Uncoment actions for saved suggestions. As simple as that!
//        actions: <Widget>[
//          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved)
//        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (BuildContext context) {
        final Iterable<ListTile> tiles = _saved.map((WordPair pair) {
          return new ListTile(
            title: new Text(
              pair.asPascalCase,
              style: _biggerFont,
            ),
          );
        },);
        final List<Widget> divided = ListTile.divideTiles(
          tiles: tiles,
          context: context,
        ).toList();
        return new Scaffold(
          appBar: new AppBar(
            title: const Text('Saved Suggestions'),
          ),
          body: new ListView(children: divided),
        );
      }),
    );
  }
}

class CustomTabController extends State<RandomWords> {
  RandomWordsState _rws = new RandomWordsState();
  String _dynamicText = "Dynamic Text";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tabs'),
          bottom: TabBar(
              tabs: [
                Text('Random Names'),
                Text('REST'),
              ],
          ),
        ),
        body: TabBarView(
            children: [
              _rws._buildSuggestions(),
              Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          _makeAPICall();
                        },
                        textColor: Colors.white,
                        child: Text('REST Call'),
                        color: Colors.blue,
                      ),
                      Text('$_dynamicText'),
                    ],
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }

  void _makeAPICall() {
    setState(() {
      FutureBuilder<String>(
        future: _getString(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return Text('');
          } else {
            return CircularProgressIndicator();
          }
        }
      );
    });
  }

  Future<String> _getString() async {
    final response = await http.get('http://10.0.2.2:8000/randomLetters/');
    _dynamicText = response.body;
    return response.body;
  }

}

class RandomWords extends StatefulWidget {
  @override
//  State<StatefulWidget> createState() => new RandomWordsState();
  State<StatefulWidget> createState() => new CustomTabController();
}
