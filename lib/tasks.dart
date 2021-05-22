import 'dart:async';

import 'package:alaket_ios/all_task.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TasksUI extends StatefulWidget {
  final Tasks tasks;
  TasksUI({Key key, this.tasks}) : super(key: key);

  @override
  _TasksUIState createState() => _TasksUIState();
}

class _TasksUIState extends State<TasksUI> with TickerProviderStateMixin {
  String _address;
  Geolocator _geolocator = Geolocator();
  Widget twoColumns(Widget one, Widget two) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [one, two],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setAddressToSearch(widget.tasks.lat, widget.tasks.lng);
  }

  Future<Null> setAddressToSearch(double latitude, double longitude) async {
    List<Placemark> newPlace =
        await _geolocator.placemarkFromCoordinates(latitude, longitude);

    // this is all you need
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    String sth = placeMark.thoroughfare;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;

    String addressFull =
        "${sth} ${name}, ${administrativeArea} ${postalCode}, ${country}";

    setState(() {
      _address = addressFull;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: CachedNetworkImage(
                imageUrl: widget.tasks.image,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                placeholderFadeInDuration: Duration(milliseconds: 500),
                placeholder: (context, url) => Container(
                  color: Colors.grey[300].withOpacity(0.3),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Text(
              widget.tasks.vehicle_type,
              style: TextStyle(fontSize: 20),
            ),
          ),
          twoColumns(
            Text('Заказ: '),
            Expanded(child: Text("№ " + widget.tasks.uidTask)),
          ),
          twoColumns(
            Text('Тип оплаты: '),
            Text(widget.tasks.type_cash),
          ),
          twoColumns(
            Text('Описание: '),
            Text(widget.tasks.description),
          ),
          twoColumns(
            Text('Время: '),
            Text(widget.tasks.time),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              _address ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    child: Text(
                      "₸" + widget.tasks.cash,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.tasks.statusConfirm
                      ? 'Подрядчик найден'
                      : 'Ожидает подрядчика')
                ],
              )
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            color: Colors.grey,
            height: 1.5,
          ),
        ],
      ),
    );
  }
}
