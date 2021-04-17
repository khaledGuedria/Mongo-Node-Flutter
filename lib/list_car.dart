import 'package:flutter/material.dart';
import 'package:my_app/book_car.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/book_car.dart';

class ListCar extends StatefulWidget{
  //var
  String fetchAllURL = "http://localhost:9090/car/";
  String _baseImageURL = "http://localhost:9090/img/";

  //constructor
  ListCar();


  
  @override
  _ListCarState createState() => _ListCarState();
}



class _ListCarState extends State<ListCar> {

  //var
  List<CarView> cars = [];

  Future<bool> fetchedCar;

  Future<bool> fetchCar() async {

    http.Response response = await http.get(Uri.parse(widget.fetchAllURL));
    List<dynamic> carsFromServer = json.decode(response.body);

    for (var item in carsFromServer) {
      cars.add(CarView(item["_id"], item["make"], item["model"], widget._baseImageURL + item["image"]));
    }

    print('############## ' + carsFromServer.toString());
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
    // TODO: implement build
    return FutureBuilder(
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
    );
  }
}

class CarView extends StatelessWidget {
  
  //var
  String _id;
  String _make;
  String _model;
  String _image;
  //String _description;
  //int _quantity;

  CarView(this._id, this._make, this._model, this._image);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
        onTap: () async {
          //Navigator.pushNamed(context, "/add");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("carID", _id);
          Navigator.pushNamed(context, "/booking");
        },
        child: Card (
        child: Row (
          children: [
            Image.network(this._image, width: 120,),
            Container(
                child: Column(
                children: [
                    Text(this._make),
                    Text(this._model),
              ],
              ),
            margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
            )


        ],
        ),
        ),
    );
  }

}