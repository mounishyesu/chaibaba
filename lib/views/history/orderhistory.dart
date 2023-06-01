import 'dart:convert';

import 'package:chai/widgets/constraints.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHistoryApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      appBar: AppBar(
        backgroundColor: yellowColor,
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
      body:  orderHistory.isEmpty
          ? Container(
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
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: orderHistory.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                decoration:
                    BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.all(Radius.circular(15))
                        /*border: Border.all(color: Colors.black26)*/),
                child: Table(
                  children: [
                    TableRow(children: [
                      TableCell(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                'Bill id',
                                style: TextStyle(color: blackColor),
                              ))),
                      TableCell(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(orderHistory[index]['bill_id'].toString(),
                                style: TextStyle(color: blackColor),
                              ))),
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                'Date & Time',
                                style: TextStyle(color: blackColor),
                              ))),
                      TableCell(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                orderHistory[index]['bill_id'].toString(),
                                style: TextStyle(color: blackColor),
                              ))),
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                'Total Price',
                                style: TextStyle(color: blackColor),
                              ))),
                      TableCell(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                orderHistory[index]['total_price'].toString(),
                                style: TextStyle(color: blackColor),
                              ))),
                    ]),
                  ],
                ),
              );
            }),
      ),
    );
  }

  getHistoryApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var body = jsonEncode({
      "created_by":prefs.getString('userID').toString()
    });
    print(body);
    ApiService.post("app-orders-history", body).then((success) {
      setState(() {
        var data = jsonDecode(success.body); //store response as string
        orderHistory = data['Orders'];
        print('data-------------------->>$data');
        print('orderHistory-------------------->>$orderHistory');
      });
    });
  }

}
