import 'dart:convert';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:chai/helpers/utilities.dart';
import 'package:chai/views/history/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as RB;
import 'package:shared_preferences/shared_preferences.dart';

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
  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  final flutterReactiveBle = RB.FlutterReactiveBle();
  RB.DiscoveredDevice? deviceChipseaBle;
  String mButtonText = "Connect Chipsea-BLE";
  String mWeighingReading = "---";
  String mUnit = "no";
  List itemsList = [];
  List subitemsList = [];
  var productDetails;
  bool ispage1visible = true,
      ispage2visible = false,
      ispage3visible = false,
      ispage4visible = false;
  int finalPrice = 0;
  var itemDetails;
  List orderDetails = [];
  static const methodChannel = const MethodChannel("print");

  TextEditingController productIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    makeCategoryApiCall();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    methodChannel.setMethodCallHandler((call) async {
      print(call.method);
      switch (call.method) {
        case 'error':
          return print("Error from method call");
        case 'home':
          {
            createOrderApi(Utilities.billNumber);
          }
          break;
        default:
          throw PlatformException(code: '1', message: 'Not Implemented');
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: Colors.white30,

          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        shadowColor: Colors.white30,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount : ',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              '₹ ${finalPrice.toString()}',
              style: TextStyle(
                  color: bordertextcolor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      orderDetails = [];
                      itemDetails = [];
                      finalPrice = 0;
                    });
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5)),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    printDialogue(context, "", 0, "", "");
                  },
                  child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Color(0xff42f5da),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        Icons.print,
                        color: Colors.white,
                        size: 32,
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderHistory()));
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Color(0xff42c8f5),
                        borderRadius: BorderRadius.circular(5)),
                    child: Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 24,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: productIdController,
                      autofocus: false,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor, fontSize: headerSize),
                      decoration: InputDecoration(
                        fillColor: whiteColor.withOpacity(0.6),
                        filled: true,
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        hintText: "Type product id....",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: blackColor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: blackColor)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: blackColor)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 45,
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellowColor,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(15),
                        // ),
                      ),
                      onPressed: () {
                        print(productIdController.text);

                        getProductDetails();
                      },
                      child: Text(
                        "Search",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.network(
                      Utilities.companyLogo.toString(),
                      height: 300,
                      width: 300,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void dialogWithStateManagement(BuildContext parentContext, String itemName,
      int itemCost, String itemId, String categoryId) {
    showDialog(
      barrierDismissible: false,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Flexible(
                          child: Text(
                            itemName.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: textSize),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: yellowColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            "Cost",
                            style: TextStyle(
                                color: yellowColor, fontSize: textSize),
                          ),
                        ),
                        Container(
                          child: Text(
                            "${itemCost.toString()}/-",
                            style: TextStyle(
                                color: yellowColor, fontSize: textSize),
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
                        hintStyle: TextStyle(color: yellowColor, fontSize: 24),
                        border: InputBorder.none,
                        // enabledBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(color: yellowColor)),
                        // focusedBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(color: yellowColor)),
                        // border: OutlineInputBorder(
                        //     borderSide: BorderSide(color: yellowColor)),
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
                            Icons.remove_circle_outline,
                            size: 40,
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
                            Icons.add_box_outlined,
                            size: 40,
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
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            "Total",
                            style: TextStyle(
                                color: yellowColor, fontSize: textSize),
                          ),
                        ),
                        Container(
                          child: Text(
                            "${finalitem_Cost.toString()}/-",
                            style: TextStyle(
                                color: yellowColor, fontSize: textSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
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
                                  "category_Id": categoryId,
                                  "item_Name": itemName,
                                  "item_Qty": item_Cost,
                                  "item_Price": itemCost,
                                  "total_cost": finalitem_Cost,
                                  "bill_id": Utilities.billNumber
                                });

                                if (orderDetails.length > 0) {
                                  for (int i = 0;
                                      i < orderDetails.length;
                                      i++) {
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
                              print("orderDetails--------->$orderDetails");
                              method();
                              productIdController.clear();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Ok",
                              style: TextStyle(color: whiteColor),
                            ),
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

  void printDialogue(BuildContext parentContext, String itemName, int itemCost,
      String itemId, String categoryId) {
    showDialog(
      barrierDismissible: false,
      context: parentContext,
      builder: (dialogContext) {
        int item_Cost = 1;
        int finalitem_Cost = itemCost;
        var printOrderDetailsList = jsonDecode(orderDetails.toString());
        print("printOrderDetailsList");

        print("printOrderDetailsList");
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return Dialog(
            // The background color
            backgroundColor: bordertextcolor,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            "Order Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: headerSize),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: yellowColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SafeArea(
                      bottom: true,
                      child: ListView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: printOrderDetailsList.length,
                          itemBuilder: (context, index) {
                            var item_Qty =
                                printOrderDetailsList[index]['item_Qty'];
                            return Container(
                              margin: EdgeInsets.all(2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                    child: Text(
                                      printOrderDetailsList[index]['item_Name']
                                          .toString(),
                                      style: TextStyle(
                                        color: whiteColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: TextFormField(
                                      readOnly: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: yellowColor,
                                          fontSize: textSize),
                                      decoration: InputDecoration(
                                        hintText: item_Qty.toString(),
                                        hintStyle: TextStyle(
                                            color: yellowColor, fontSize: 18),
                                        border: InputBorder.none,
                                        // enabledBorder: OutlineInputBorder(
                                        //     borderSide: BorderSide(color: yellowColor)),
                                        // focusedBorder: OutlineInputBorder(
                                        //     borderSide: BorderSide(color: yellowColor)),
                                        // border: OutlineInputBorder(
                                        //     borderSide: BorderSide(color: yellowColor)),
                                        prefixIcon: IconButton(
                                          iconSize: 35,
                                          // enableFeedback: false,
                                          onPressed: printOrderDetailsList[
                                                      index]['item_Qty'] ==
                                                  1
                                              ? () {
                                                  stfSetState(() {
                                                    for (int i = 0;
                                                        i < orderDetails.length;
                                                        i++) {
                                                      var singleObj =
                                                          jsonDecode(
                                                              orderDetails[i]);
                                                      if (singleObj[
                                                              'item_ID'] ==
                                                          printOrderDetailsList[
                                                                  index]
                                                              ['item_ID']) {
                                                        orderDetails.remove(
                                                            orderDetails[i]);
                                                      }
                                                    }
                                                    method();

                                                    printOrderDetailsList
                                                        .removeAt(index);
                                                  });
                                                }
                                              : () {
                                                  stfSetState(() {
                                                    printOrderDetailsList[index]
                                                        ['item_Qty']--;

                                                    itemDetails = [];

                                                    itemDetails = jsonEncode({
                                                      "item_ID":
                                                          printOrderDetailsList[
                                                              index]['item_ID'],
                                                      "category_Id":
                                                          printOrderDetailsList[
                                                                  index]
                                                              ['category_Id'],
                                                      "item_Name":
                                                          printOrderDetailsList[
                                                                  index]
                                                              ['item_Name'],
                                                      "item_Qty":
                                                          printOrderDetailsList[
                                                                  index]
                                                              ['item_Qty'],
                                                      "bill_id":
                                                          Utilities.billNumber,
                                                      "item_Price":
                                                          printOrderDetailsList[
                                                                  index]
                                                              ['item_Price'],
                                                      "total_cost":
                                                          printOrderDetailsList[
                                                                      index][
                                                                  'item_Price'] *
                                                              printOrderDetailsList[
                                                                      index]
                                                                  ['item_Qty'],
                                                    });

                                                    if (orderDetails.length >
                                                        0) {
                                                      finalPrice = 0;
                                                      for (int i = 0;
                                                          i <
                                                              orderDetails
                                                                  .length;
                                                          i++) {
                                                        var singleObj =
                                                            jsonDecode(
                                                                orderDetails[
                                                                    i]);
                                                        if (singleObj[
                                                                'item_ID'] ==
                                                            printOrderDetailsList[
                                                                    index]
                                                                ['item_ID']) {
                                                          orderDetails.remove(
                                                              orderDetails[i]);
                                                        }
                                                      }
                                                      orderDetails
                                                          .add(itemDetails);
                                                    } else {
                                                      orderDetails
                                                          .add(itemDetails);
                                                    }
                                                  });
                                                  method();
                                                },
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            // size: 40,
                                            color: item_Qty == null
                                                ? lightgrey
                                                : yellowColor,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          iconSize: 35,
                                          onPressed: () {
                                            stfSetState(() {
                                              printOrderDetailsList[index]
                                                  ['item_Qty']++;
                                              // finalitem_Cost = itemCost * item_Cost;

                                              itemDetails = [];
                                              itemDetails = jsonEncode({
                                                "item_ID":
                                                    printOrderDetailsList[index]
                                                        ['item_ID'],
                                                "category_Id":
                                                    printOrderDetailsList[index]
                                                        ['category_Id'],
                                                "item_Name":
                                                    printOrderDetailsList[index]
                                                        ['item_Name'],
                                                "item_Qty":
                                                    printOrderDetailsList[index]
                                                        ['item_Qty'],
                                                "item_Price":
                                                    printOrderDetailsList[index]
                                                        ['item_Price'],
                                                "bill_id": Utilities.billNumber,
                                                "total_cost":
                                                    printOrderDetailsList[index]
                                                            ['item_Price'] *
                                                        printOrderDetailsList[
                                                            index]['item_Qty'],
                                              });

                                              if (orderDetails.length > 0) {
                                                finalPrice = 0;
                                                for (int i = 0;
                                                    i < orderDetails.length;
                                                    i++) {
                                                  var singleObj = jsonDecode(
                                                      orderDetails[i]);
                                                  if (singleObj['item_ID'] ==
                                                      printOrderDetailsList[
                                                          index]['item_ID']) {
                                                    orderDetails.remove(
                                                        orderDetails[i]);
                                                  }
                                                }
                                                orderDetails.add(itemDetails);
                                              } else {
                                                orderDetails.add(itemDetails);
                                              }
                                            });
                                            method();
                                          },
                                          icon: Icon(
                                            Icons.add_box_outlined,
                                            // size: 40,
                                            color: yellowColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    printOrderDetailsList.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: yellowColor,
                                      // shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(15),
                                      // ),
                                    ),
                                    onPressed: () async {
                                      ///*********** Below code is to print the order ***************//
                                      productIdController.clear();
                                      await getHistoryApi();

                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Print",
                                      style: TextStyle(color: blackColor),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      // shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(15),
                                      // ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            child: Text(
                              "Cart is Empty",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: headerSize),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  method() {
    setState(() {
      if (orderDetails.length > 0) {
        finalPrice = 0;
        for (int i = 0; i < orderDetails.length; i++) {
          var singleObj = jsonDecode(orderDetails[i]);
          finalPrice =
              finalPrice + int.parse(singleObj['total_cost'].toString());
          Utilities.finalPrice = finalPrice;
          print("final Price---------->$finalPrice");
        }
      } else {
        finalPrice = 0;
      }
    });
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

  getProductDetails() {
    print(productIdController.text);
    Map<String, dynamic> formMap = {
      "product_id": productIdController.text.toString(),
    };
    // var formMap = jsonEncode({"product_id": productIdController.text.toString()});
    ApiService.post("app-getidbasedproduct", formMap).then((success) {
      setState(() {
        var data = jsonDecode(success.body); //store response as string
        productDetails = data['product'];
        print("productDetails");
        print(productDetails);
        if (productDetails != null) {
          dialogWithStateManagement(
            context,
            productDetails['title'],
            int.parse(
              productDetails['unit_price'],
            ),
            productDetails['product_id'],
            productDetails['category_id'],
          );
        } else {
          Utilities.showAlert(context, "No Product Found");
        }
      });
    });
  }

  getHistoryApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var body = jsonEncode({"created_by": prefs.getString('userID').toString()});
    print(body);
    ApiService.post("app-orders-history", body).then((success) async {
      var data = jsonDecode(success.body); //store response as string
      var orderHistory = data['Orders'];
      print('data-------------------->>$data');
      print('orderHistory-------------------->>$orderHistory');
      int billNo = 1;
      if (orderHistory.length > 0) {
        billNo = int.parse(orderHistory[0]['order_id']) + 1;
      } else {
        billNo = 100;
      }

      Utilities.orderDataList = [];
      Utilities.billNumber = billNo;
      Utilities.orderDataList = orderDetails;
      Utilities.finalPrice = finalPrice;

      print('Data->>>>$orderDetails');
      print('Data->>>>${Utilities.orderDataList}');
      print('Data->>>>${Utilities.bthAddress}');
      await methodChannel
          .invokeMethod("print", [json.encode(orderDetails), billNo]);
    });
  }

  createOrderApi(billId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("========================>>674========$billId");
    print(orderDetails);
    List itemDetails = [];
    var orderItems = jsonDecode(orderDetails.toString());
    if (orderItems.length > 0) {
      for (var i = 0; i < orderItems.length; i++) {
        var item = {
          "category_id": orderItems[i]['category_Id'].toString(),
          "product_id": orderItems[i]['item_ID'].toString(),
          "quantity": orderItems[i]['item_Qty'].toString(),
          "price": orderItems[i]['item_Price'].toString(),
          "totalprice": orderItems[i]['total_cost'].toString(),
        };
        itemDetails.add(item);
      }
    }

    print(Utilities.orderDataList);
    var body = jsonEncode({
      "created_by": prefs.getString('userID').toString(),
      "bill_id": billId,
      "total_price": finalPrice,
      "items": itemDetails
    });

    print("itemDetails------");
    print(body);

    ApiService.post("app-create-order", body).then((success) {
      setState(() {
        var data = jsonDecode(success.body);
        setState(() {
          orderDetails = [];
          itemDetails = [];
          finalPrice = 0;
        }); //store response as string
        // print('data-------------------->>$data');
      });
    });
  }
}
