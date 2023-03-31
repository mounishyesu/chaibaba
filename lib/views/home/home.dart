import 'dart:convert';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import '../../widgets/constraints.dart';
import '../../widgets/responsive.dart';
import '../apicalls/restapi.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Utilities.draftList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: HomePageBody(),
      desktop: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: HomePageBody(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomePageBody extends StatefulWidget {
  const HomePageBody({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  List itemsList = [];
  List subitemsList = [];
  bool ispage1visible = true,
      ispage2visible = false,
      ispage3visible = false,
      ispage4visible = false;
  int finalPrice = 0;
  var itemDetails;
  List orderDetails = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makeCategoryApiCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellowColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3.5,
              child: Text(
                finalPrice.toString(),
                style: TextStyle(
                    color: bordertextcolor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
                decoration:
                    BoxDecoration(border: Border.all(color: bordertextcolor)),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      orderDetails = [];
                      itemDetails = [];
                      finalPrice = 0;
                    });
                  },
                  child: Image.asset('assets/icons/delete_icon.png'),
                )),
            SizedBox(
              width: 7,
            ),
            Container(
                decoration:
                    BoxDecoration(border: Border.all(color: bordertextcolor)),
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset('assets/icons/printer_icon.png'),
                )),
            SizedBox(
              width: 7,
            ),
            Container(
                decoration:
                    BoxDecoration(border: Border.all(color: bordertextcolor)),
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset('assets/icons/history_icon.png'),
                )),
            SizedBox(
              width: 7.8,
            ),
            Container(
                width: 50,
                height: 50,
                // padding: EdgeInsets.only(bottom: 20),
                decoration:
                    BoxDecoration(border: Border.all(color: bordertextcolor)),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'c',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: bordertextcolor,
                        fontSize: 38,
                        fontWeight: FontWeight.w300),
                  ),
                )),
          ],
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: yellowColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3.5,
                child: ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: itemsList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(5),
                        height: 80,
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellowColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: bordertextcolor),
                            ),
                          ),
                          onPressed: () {
                            print(
                                '------------------>>>${itemsList[index]['category_id']}');
                            subCategoryApiCall(itemsList[index]['category_id']);
                          },
                          child: Text(
                            itemsList[index]['title'].toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: bordertextcolor, fontSize: headerSize),
                          ),
                        ),
                      );
                    }),
              ),
              subitemsList.isEmpty
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 80),
                      alignment: Alignment.center,
                      child: Text(
                        "No Items Found",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: bordertextcolor,
                            fontSize: headerSize),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        height: MediaQuery.of(context).size.height,
                        child: GridView.builder(
                          itemCount: subitemsList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 10.0),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                dialogWithStateManagement(
                                  context,
                                  subitemsList[index]['title'],
                                  int.parse(
                                    subitemsList[index]['unit_price'],
                                  ),
                                  subitemsList[index]['product_id'],
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: bordertextcolor)),
                                child: Column(
                                  children: [
                                    // subitemsList[index]['image']
                                    Image.asset(
                                      'assets/images/default.jpg',
                                      height: 100,
                                      width: 100,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      subitemsList[index]['title'].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: bordertextcolor,
                                          fontSize: textSize),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ],
          )),
    );
  }

  void dialogWithStateManagement(BuildContext parentContext, String itemName,
      int itemCost, String itemId) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        int item_Cost = 1;
        int finalitem_Cost = itemCost;
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return Dialog(
            // The background color
            backgroundColor: bordertextcolor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            itemName.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: textSize),
                          ),
                        ),
                        Container(
                          child: Text(
                            "${itemCost.toString()}/-",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: textSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: yellowColor, fontSize: textSize),
                      decoration: InputDecoration(
                        hintText: "${item_Cost}",
                        hintStyle:
                            TextStyle(color: yellowColor, fontSize: textSize),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: yellowColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: yellowColor)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: yellowColor)),
                        prefixIcon: IconButton(
                          enableFeedback: false,
                          onPressed: item_Cost == 1
                              ? null
                              : () {
                                  stfSetState(() {
                                    if (item_Cost > 1) {
                                      item_Cost--;
                                    }
                                    finalitem_Cost = itemCost * item_Cost;
                                  });
                                },
                          icon: Icon(
                            Icons.remove,
                            color: item_Cost == 1 ? lightgrey : yellowColor,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            stfSetState(() {
                              item_Cost++;
                              finalitem_Cost = itemCost * item_Cost;
                            });
                          },
                          icon: Icon(
                            Icons.add,
                            color: yellowColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            "Total",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: textSize),
                          ),
                        ),
                        Container(
                          child: Text(
                            "${finalitem_Cost.toString()}/-",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: textSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellowColor,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(15),
                            // ),
                          ),
                          onPressed: () {
                            setState(() {
                              itemDetails = [];
                              itemDetails = jsonEncode({
                                "item_ID": itemId,
                                "item_Name": itemName,
                                "item_Qty": item_Cost,
                                "item_Price": itemCost,
                                "total_cost": finalitem_Cost,
                              });

                              if (orderDetails.length > 0) {
                                for (int i = 0; i < orderDetails.length; i++) {
                                  var singleObj = jsonDecode(orderDetails[i]);
                                  if (singleObj['item_ID'] == itemId) {
                                    orderDetails.remove(orderDetails[i]);
                                  }
                                }
                                orderDetails.add(itemDetails);
                              } else {
                                orderDetails.add(itemDetails);
                              }
                            });
                            // print(itemDetails);
                            print(orderDetails);
                            method();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Ok",
                            style: TextStyle(color: whiteColor),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellowColor,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(15),
                            // ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Close",
                            style: TextStyle(color: whiteColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  method() {
    if (orderDetails.length > 0) {
      finalPrice = 0;
      for (int i = 0; i < orderDetails.length; i++) {
        var singleObj = jsonDecode(orderDetails[i]);
        finalPrice = finalPrice + int.parse(singleObj['total_cost'].toString());
      }
    } else {
      finalPrice = 0;
    }
  }

  makeCategoryApiCall() async {
    ApiService.get("app-categorys").then((success) {
      setState(() {
        var data = jsonDecode(success.body); //store response as string
        itemsList = data['categorys'];
        print('data-------------------->>$itemsList');
      });
    });
  }

  subCategoryApiCall(id) async {
    Map<String, dynamic> formMap = {
      "category_id": id,
    };
    ApiService.post("app-categorybyproducts", formMap).then((success) {
      setState(() {
        var data = jsonDecode(success.body); //store response as string
        subitemsList = data['products'];
        print('data-------------------->>$subitemsList');
      });
    });
  }
}
