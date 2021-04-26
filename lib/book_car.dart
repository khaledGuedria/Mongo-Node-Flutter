import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class BookCar extends StatefulWidget {

  //var
  String _id; 

  String _make;
  String _model;
  String _image;
  String _description;
  int _quantity;
  //..
  SharedPreferences prefs;
  

  //constructor
  //BookCar(this._id);

  @override
  _BookCarState createState() => _BookCarState();
}

class _BookCarState extends State<BookCar> {

//util
  Future<bool> fetchedCar;
  String getByIdUrl = "http://api:9090/car/";
  String _baseImageURL = "http://api:9090/img/";

//GET
Future<bool> getCar() async {

  widget.prefs = await SharedPreferences.getInstance();


  http.Response response = await http.get(Uri.parse(getByIdUrl + widget.prefs.getString("carID")));
  Map<String, dynamic> carObject = json.decode(response.body);

  widget._make = carObject["make"];
  widget._model = carObject["model"];
  widget._description = carObject["description"];
  widget._image = _baseImageURL + carObject["image"];
  widget._quantity = carObject["quantity"];

  return true;
}

Map<String, dynamic> toMap(){

  return {
    "id": widget.prefs.getString("carID"),
    "model": widget._model,
    "make": widget._make,
    "image": widget._image,
    "description": widget._description,
    "quantity": widget._quantity,

  };

}

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      fetchedCar = getCar();
    }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Booking"),
      ),
      body: FutureBuilder(
        future: fetchedCar,
        builder: (context, snapshot) {
        if(snapshot.hasData){
          return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(this.widget._image),
          SizedBox(
            height: 10,
          ),

          Text("Model :" + this.widget._make + " " + this.widget._model),
          SizedBox(
            height: 10,
          ),

          Text("Description : "),
          Text(this.widget._description),
          SizedBox(
            height: 10,
          ),

          Text("Quantity : " + this.widget._quantity.toString()),
          SizedBox(
            height: 10,
          ),

          Center(
            child: FlatButton(
              child: Text("Book this Car"),
              onPressed: () {
                  http.patch(Uri.parse(getByIdUrl + widget.prefs.getString("carID"))).then((http.Response response){
                    http.get(Uri.parse(getByIdUrl + widget.prefs.getString("carID"))).then((http.Response res){
                      setState(() {
                        widget._quantity = json.decode(res.body)["quantity"];
                      });
                    });
                  });
              },
              ),
          )

      ],);
        } else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        },
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text("Add car to Favorites"),
          onPressed: () async {
            
              //1 open or creare
              Database db = await openDatabase(
              join(await getDatabasesPath(), "cars-database.db"),
              //2 create Table
              onCreate: (Database db, int version) {
                db.execute("CREATE TABLE car (id TEXT PRIMARY KEY, model TEXT, make TEXT, image TEXT, description TEXT, quantity INTEGER);");
              },

              version: 1
            );

              //3 Insert action
              await db.insert("car", toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);

              //4 SELECT ALL
              List<Map<String, dynamic>> maps = await db.query("car");
              print(maps);
          },
        ),
    );
  }
}