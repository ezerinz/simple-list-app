import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Utama());
}

class Utama extends StatelessWidget {
  const Utama({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
			create: (context) => MyAppState(),
			child: MaterialApp( 
				home: MyApp(),
			),
		);
  }
} 

class MyAppState extends ChangeNotifier {
	List<String> daftar = <String>[];	
	List<String> favorit = <String>[];

	getPrefs(String kunci) async {
		final prefs = await SharedPreferences.getInstance();
		return prefs.getStringList(kunci);
	}

	segarkan() async {
		var tempList = await getPrefs('fav');
		var tempList2 = await getPrefs('daftar');
		favorit = tempList;
		daftar = tempList2;
		notifyListeners();
	}
	
	setPrefs(String kunci, List<String> lst) async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setStringList(kunci, lst);
	}

	void toggleFavorite(int i) {
		var current = daftar[i];
    if (favorit.contains(current)) {
      favorit.remove(current);
    } else {
      favorit.add(current);
    }
		setPrefs('fav', favorit);
    notifyListeners();
  }	

  void toggleDelete(int i) {
    favorit.removeAt(i);
		setPrefs('fav', favorit);
  	notifyListeners();
  }

	void addDaftar(String add) {
		daftar.add(add);
		setPrefs('daftar', daftar);
		notifyListeners();
	}


}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
		Widget plusButton = Container();
    Widget page;
		switch (selectedIndex) {
		  case 0:
		    page = MyWidget();
				plusButton = FloatingActionButton(
					onPressed: () {
						Navigator.push(
							context, 
							MaterialPageRoute(builder: (context) => const Nambah()));
					},
					child: Icon(Icons.add),
				);
		    break;
			case 1:
				page = MyWidget2();
				break;
		  default:
				throw UnimplementedError("no widget for $selectedIndex");
		}

		return Scaffold(
			bottomNavigationBar: 
				NavigationBar(
					destinations: [
						NavigationDestination(
							icon: Icon(Icons.list), 
							label: 'Daftar',
						),
						NavigationDestination(
							icon: Icon(Icons.favorite), 
							label: 'Tertandai',
						),
					],
					selectedIndex: selectedIndex,
					onDestinationSelected: (int index) {
						setState(() {
							selectedIndex = index;
						});
					},
				),
			body: Container(child: page,),
			floatingActionButton: plusButton,
		);

  }
}
class Nambah extends StatefulWidget {
  const Nambah({super.key});

  @override
  State<Nambah> createState() => _NambahState();
}

class _NambahState extends State<Nambah> {
	final myController = TextEditingController();

	@override
	void dispose() {
		myController.dispose();
		super.dispose();
	}

	@override
  Widget build(BuildContext context) {
		var state = context.watch<MyAppState>();
    return Scaffold(
			appBar: AppBar(
				leading: IconButton(
					onPressed: () {
						Navigator.pop(context);
					}, 
					icon: Icon(Icons.arrow_back)
				), 
			),
			body: Center(
				heightFactor: 3.0,
				child: Column(
					children: [
						SizedBox(height: 50,),
						Padding(
							padding: const EdgeInsets.all(40.0),
							child: TextField(
								controller: myController,	
							),
						),
						ElevatedButton(
							onPressed: () { 
									Navigator.pop(context);
									state.addDaftar(myController.text);
								}, 
							child: Text('Tambah')
						)
					]
				)
			)
		); 
  }
}

class MyWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
		var state = context.watch<MyAppState>();
		state.segarkan();
		var entries = state.daftar;
		Widget icon(int index) {
			Widget icon;
			if (state.favorit.contains(entries[index])) {
				icon = Icon(Icons.favorite,);
			}
			else {
				icon = Icon(Icons.favorite_border);
			}

			return icon;
		}
    
  	return SafeArea(child: ListView.separated(
    	padding: const EdgeInsets.all(8),
    	itemCount: entries.length,
    	itemBuilder: (BuildContext context, int index) {
      	return Container(
					height: 50,
        	child: TextButton(
						onPressed: () { 
							state.toggleFavorite(index);
						},
						style: TextButton.styleFrom(
							foregroundColor: Colors.black,
							textStyle: TextStyle(fontWeight: FontWeight.normal)
						), 
						child: Row(
							children: [
								Expanded(
									child: 
										Center(
											child: Text(entries[index]),
										)
								),
								SizedBox(width: 24.2,),
								icon(index)
							],
						),
					),
      	);
    	},
    	separatorBuilder: (BuildContext context, int index) => const Divider(),
		)
  	);

	}
}

class MyWidget2 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
		var state = context.watch<MyAppState>();
		state.segarkan();
		var entries = state.favorit;

  	return SafeArea(child: ListView.separated(
    	padding: const EdgeInsets.all(8),
    	itemCount: entries.length,
    	itemBuilder: (BuildContext context, int index) {
      	return Container(
					height: 50,
        	child:
						Row(
							children: [
								Expanded(
									child: 
										Center(
											child: Text(entries[index]),
										)
								),
								IconButton(
									onPressed: () {
										state.toggleDelete(index);
									}, 
									icon: Icon(Icons.delete),
								)
							],
						)
      	);
    	},
    	separatorBuilder: (BuildContext context, int index) => const Divider(),
		)
  	);
	}
}
