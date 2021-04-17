import 'package:flutter/material.dart';
import 'package:my_app/list_car.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {

  //var
  //String _baseImageURL = "http://192.168.1.9:9090/img/";
  List<CarView> cars = [];
  Future<bool> fetchedCar;

  Future<bool> fetchCar() async {

    Database db = await openDatabase(
              join(await getDatabasesPath(), "cars-database.db"),
            );

    List<dynamic> carsFromDatastorage = await db.query("car");

    for (var item in carsFromDatastorage) {
      cars.add(CarView(item["id"], item["make"], item["model"], item["image"]));
    }

    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchedCar = fetchCar();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
      ),
      body: FutureBuilder(
      future: fetchedCar,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ListView.builder (
          itemBuilder: (BuildContext context, int index) {
          return cars[index];
          },
          itemCount: cars.length,
          );
        } else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ),
    );
  }
}