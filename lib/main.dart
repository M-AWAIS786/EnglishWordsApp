import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(myapp());
}

class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'English Words',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favourites = [];

  void saveFavorite() {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    notifyListeners();
  }

  void deleteFavorite(WordPair pair) {
    favourites.remove(pair);
    notifyListeners();
  }
}

class FavouritePage extends StatelessWidget {
  FavouritePage({super.key});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    if (appState.favourites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Your Favourite is ${appState.favourites.length}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 400/40),

            children: [

              for (var wordsdata in appState.favourites)
                ListTile(
                  leading: IconButton(
                  onPressed:() => appState.deleteFavorite(wordsdata),
                  color:theme.colorScheme.primary,
                  icon:Icon(Icons.delete_outline),
                  ),
                 title: Text('${wordsdata.asUpperCase}'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
   
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavouritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        body: Row(
          children: [
            SafeArea(
                child: NavigationRail(
              extended: constraints.maxWidth > 600,
              destinations: [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(
                    icon: Icon(Icons.favorite), label: Text('Favorites'))
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
                print('Selected: $value');
              },
            )),
            Expanded(
                child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page)),
          ],
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favourites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Expanded(
           flex: 1,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                for(var wordsdata in appState.favourites)
                ListTile(
                  title:Align(alignment: Alignment.center,child: Text('${wordsdata}')) ,
                )
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
            flex: 2,
            child: Column(children:
            [
              BigCard(
                pair: pair,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      appState.saveFavorite();
                    },
                    icon: Icon(icon),
                    label: Text('Like'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        appState.getNext();
                      },
                      child: Text('Next')),
                ],
              ),
            ],),
          ),
          
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair pair;

  const BigCard({super.key, required this.pair});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MergeSemantics(
          child: Wrap(
            children:[ Text(
              pair.first,
              style: style.copyWith(fontWeight: FontWeight.w200),
            ),
           Text(
            pair.second,
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
        ),
        ),
      ),
    );
  }
}
