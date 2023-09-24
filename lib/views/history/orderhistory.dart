import 'dart:convert';

import 'package:chai/widgets/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/responsive.dart';
import '../apicalls/restapi.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({Key? key}) : super(key: key);

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: OrderHistoryList(),
      desktop: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: OrderHistoryList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderHistoryList extends StatefulWidget {
  const OrderHistoryList({Key? key}) : super(key: key);

  @override
  State<OrderHistoryList> createState() => _OrderHistoryListState();
}

class _OrderHistoryListState extends State<OrderHistoryList> {
  List orderHistory = [];
  final dateController =
      TextEditingController(text: 'selected date appear here');
  String? orderHistoryTotal = "0";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHistoryApi("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: Colors.white30,

          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        shadowColor: Colors.white30,
        title: Text(
          "Order History",
          style: TextStyle(
            color: blackColor,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: blackColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            ListTile(
              onTap: () {
                print("tap---------------------->138");
                _datePicker(context);
              },
              leading: Icon(
                Icons.calendar_month,
                color: blackColor,
                size: 32,
              ),
              title: Container(
                alignment: Alignment.center,

                height: 40,
                // margin: EdgeInsets.all(10),
                color: whiteColor.withOpacity(0.6),
                child: Text(
                  dateController.text.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              trailing: SizedBox(
                height: 40,
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellowColor,
                  ),
                  onPressed: () {
                    getHistoryApi(dateController.text.toString());
                  },
                  child: Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              color: whiteColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹ ${orderHistoryTotal}",
                    style: TextStyle(
                        fontSize: 24,
                        color: blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    orderHistory.isEmpty
                        ? Container(
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height / 3),
                            alignment: Alignment.center,
                            child: Text(
                              "There is no Order history",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: bordertextcolor,
                                  fontSize: headerSize),
                            ),
                          )
                        : SizedBox(
                            child: SafeArea(
                              bottom: true,
                              child: ListView.builder(
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: orderHistory.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 24),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  15)) /*border: Border.all(color: Colors.black26)*/),
                                      child: Table(
                                        children: [
                                          TableRow(children: [
                                            TableCell(
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    child: Text(
                                                      'Bill id',
                                                      style: TextStyle(
                                                          color: blackColor),
                                                    ))),
                                            TableCell(
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    child: Text(
                                                      "ORD000" +
                                                          orderHistory[index]
                                                                  ['bill_id']
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: blackColor),
                                                    ))),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    child: Text(
                                                      'Date & Time',
                                                      style: TextStyle(
                                                          color: blackColor),
                                                    ))),
                                            TableCell(
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    child: Text(
                                                      orderHistory[index]
                                                              ['created_on']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: blackColor),
                                                    ))),
                                          ]),
                                          TableRow(children: [
                                            TableCell(
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    child: Text(
                                                      'Total Price',
                                                      style: TextStyle(
                                                          color: blackColor),
                                                    ))),
                                            TableCell(
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    child: Text(
                                                      "₹ ${orderHistory[index]['total_price'].toString()}",
                                                      style: TextStyle(
                                                          color: blackColor),
                                                    ))),
                                          ]),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _datePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate: DateTime(
            2022), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2100));
    print(pickedDate);
    if (pickedDate != null) {
      print(
          pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
      String formattedDate = DateFormat('dd-MM-yyyy').format(
          pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
      print(
          formattedDate); //formatted date output using intl package =>  2022-07-04(yyyy-MM-dd)
      //You can format date as per your need
      setState(() {
        dateController.text =
            formattedDate; //set foratted date to TextField value.
      });
    } else {
      print("Date is not selected");
    }
  }

  getHistoryApi(date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var body = jsonEncode({
      "created_by": prefs.getString('userID').toString(),
      "from_date": date
    });
    print(body);
    ApiService.post("app-orders-history", body).then((success) {
      setState(() {
        var data = jsonDecode(success.body); //store response as string
        orderHistory = data['Orders'];
        setState(() {
          orderHistoryTotal = data['grand_total'].toString();
        });

        print('data-------------------->>$data');
        print('orderHistory-------------------->>$orderHistory');
      });
    });
  }
}
