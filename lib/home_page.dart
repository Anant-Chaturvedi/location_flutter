// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

bool addressTap = false;
String? address;

Size? mq;
bool isSelected = false;
String? _selectedOccupation;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); 
    print(position.latitude); 

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });


  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Test App",
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: Icon(
              Icons.menu,
              color: Colors.grey.shade600,
              size: 20,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.note_add_sharp,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.cloud,
                  color: Colors.black,
                  size: 20,
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Send'),
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: const Color.fromARGB(255, 7, 39, 221),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Fetch me',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                    )
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.only(
                      left: mq!.width * .04, top: mq!.height * .03),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Details',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  )),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mq!.width * .04, vertical: mq!.height * .02),
                child: Container(
                  height: mq!.height * .07,
                  width: mq!.width * .9,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: mq!.width * .13,
                        child: IconButton(
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                            ),
                            onPressed: () {}),
                      ),
                      SizedBox(
                        width: mq!.width * .6,
                        child: addressTap
                            ? Text(
                                '$address',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              )
                            : const Text('Current Address'),
                      ),
                      Container(
                        child: IconButton(
                            onPressed: () {
                              get(Uri.parse(
                                      "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$long&format=json"))
                                  .then((value) {
                                final data = jsonDecode(value.body);

                                setState(() {
                                  address = data['display_name'];
                                  addressTap = true;
                                });
                              });
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            )),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: mq!.height * .07,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq!.width * .05),
                  child: TextField(
                    decoration: InputDecoration(
                        hintStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        hintText: 'Enter your Destination',
                        prefixIcon: const Icon(
                          Icons.flag,
                          color: Colors.red,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(
                      left: mq!.width * .04, top: mq!.height * .05),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Pick Up',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Time',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: mq!.height * .04,
                          width: mq!.width * .3,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 223, 229, 231),
                              borderRadius: BorderRadius.circular(10)),
                          child: TabBar(
                            indicator: BoxDecoration(
                                color: const Color.fromARGB(255, 7, 39, 221),
                                borderRadius: BorderRadius.circular(10)),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            // padding: EdgeInsets.all(8),

                            tabs: const [
                              Tab(
                                text: 'AM',
                              ),
                              Tab(
                                text: 'PM',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade500),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        SizedBox(
                            width: mq!.width * .1,
                            height: mq!.height * .04,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8, top: 5),
                              child: const TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '11',
                                  hintStyle: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )),
                        const Text('-'),
                        SizedBox(
                            width: mq!.width * .1,
                            height: mq!.height * .04,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8, top: 5),
                              child: const TextField(
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintTextDirection: TextDirection.rtl,
                                    hintStyle: TextStyle(fontSize: 14),
                                    hintText: '12'),
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                  padding: EdgeInsets.only(
                      left: mq!.width * .04, top: mq!.height * .03),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Order Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )),
              OrderInfo(),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mq!.width * .05, vertical: mq!.height * .04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$48.80',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(mq!.width * .9, mq!.height * .06),
                    elevation: 0,
                    primary: const Color.fromARGB(255, 7, 39, 221),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ]),
          )),
    );
  }
}

//radio buttons(i.e. chip buttons) for occupation selections
class OrderInfo extends StatefulWidget {
  const OrderInfo({Key? key}) : super(key: key);

  @override
  State<OrderInfo> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  // final _occupationList = const ['Job', 'Business', 'Unemployed'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: mq!.width * .04, right: mq!.width * .04, top: mq!.height * .03),
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        spacing: 10,
        children: [
          //field for job
          ChoiceChip(
            elevation: 0,
            backgroundColor: Colors.grey.shade200,
            selectedColor: Color.fromARGB(255, 7, 39, 221),
            // padding: const EdgeInsets.symmetric(horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: Text('Daily necessities',
                style: TextStyle(
                    color: _selectedOccupation == 'Daily necessities'
                        ? Colors.white
                        : Colors.black,
                    fontSize: 12)),
            selected: _selectedOccupation == 'Daily necessities',
            onSelected: (selected) {
              setState(() {
                _selectedOccupation = selected ? 'Daily necessities' : '';
              });
            },
          ),

          //field for business
          ChoiceChip(
            elevation: 0,
            backgroundColor: Colors.grey.shade200,
            selectedColor: Color.fromARGB(255, 7, 39, 221),
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: Text('Food',
                style: TextStyle(
                    color: _selectedOccupation == 'Food'
                        ? Colors.white
                        : Colors.black)),
            selected: _selectedOccupation == 'Food',
            onSelected: (selected) {
              setState(() {
                _selectedOccupation = selected ? 'Food' : '';
              });
            },
          ),

          //field for unemployment
          ChoiceChip(
            elevation: 0,
            backgroundColor: Colors.grey.shade200,
            selectedColor: Color.fromARGB(255, 7, 39, 221),
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: Text('Document',
                style: TextStyle(
                    color: _selectedOccupation == 'Document'
                        ? Colors.white
                        : Colors.black)),
            selected: _selectedOccupation == 'Document',
            onSelected: (selected) {
              setState(() {
                _selectedOccupation = selected ? 'Document' : '';
              });
            },
          ),
          ChoiceChip(
            elevation: 0,
            backgroundColor: Colors.grey.shade200,
            selectedColor: Color.fromARGB(255, 7, 39, 221),
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: Text('Clothing',
                style: TextStyle(
                    color: _selectedOccupation == 'Clothing'
                        ? Colors.white
                        : Colors.black)),
            selected: _selectedOccupation == 'Clothing',
            onSelected: (selected) {
              setState(() {
                _selectedOccupation = selected ? 'Clothing' : '';
              });
            },
          ),
          ChoiceChip(
            elevation: 0,
            backgroundColor: Colors.grey.shade200,
            selectedColor: Color.fromARGB(255, 7, 39, 221),
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: Text('Digital Product',
                style: TextStyle(
                    color: _selectedOccupation == 'Digital Product'
                        ? Colors.white
                        : Colors.black)),
            selected: _selectedOccupation == 'Digital Product',
            onSelected: (selected) {
              setState(() {
                _selectedOccupation = selected ? 'Digital Product' : '';
              });
            },
          ),
          ChoiceChip(
            elevation: 0,
            backgroundColor: Colors.grey.shade200,
            selectedColor: Color.fromARGB(255, 7, 39, 221),
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            label: Text('Other',
                style: TextStyle(
                    color: _selectedOccupation == 'Other'
                        ? Colors.white
                        : Colors.black)),
            selected: _selectedOccupation == 'Other',
            onSelected: (selected) {
              setState(() {
                isSelected = true;
                _selectedOccupation = selected ? 'Other' : '';
              });
            },
          ),
        ],
      ),
    );
  }
}
