// SingleChildScrollView(
// child: SizedBox(
// height: MediaQuery.of(context).size.height * 0.8,
// child: Row(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// SizedBox(
// width: MediaQuery.of(context).size.width / 3.5,
// child: ListView.builder(
// physics: const ScrollPhysics(),
// shrinkWrap: true,
// itemCount: itemsList.length,
// itemBuilder: (context, index) {
// return Container(
// margin: EdgeInsets.all(5),
// height: 80,
// width: 100,
// child: ElevatedButton(
// style: ElevatedButton.styleFrom(
// backgroundColor: yellowColor,
// shape: RoundedRectangleBorder(
// side:
// BorderSide(color: bordertextcolor),
// ),
// ),
// onPressed: () {
// print(
// '------------------>>>${itemsList[index]['category_id']}');
// subCategoryApiCall(
// itemsList[index]['category_id']);
// },
// child: Text(
// itemsList[index]['title'].toString(),
// textAlign: TextAlign.center,
// style: TextStyle(
// color: bordertextcolor,
// fontSize: headerSize),
// ),
// ),
// );
// }),
// ),
// subitemsList.isEmpty
// ? Container(
// margin: EdgeInsets.only(
// left: MediaQuery.of(context).size.width / 5,
// ),
// alignment: Alignment.center,
// child: Text(
// "No Items Found",
// style: TextStyle(
// fontWeight: FontWeight.bold,
// color: bordertextcolor,
// fontSize: headerSize),
// ),
// )
// : Padding(
// padding: const EdgeInsets.all(5.0),
// child: SizedBox(
// width:
// MediaQuery.of(context).size.width / 1.5,
// height: MediaQuery.of(context).size.height,
// child: GridView.builder(
// physics: ScrollPhysics(),
// itemCount: subitemsList.length,
// gridDelegate:
// SliverGridDelegateWithFixedCrossAxisCount(
// crossAxisCount: 2,
// crossAxisSpacing: 4.0,
// mainAxisSpacing: 10.0),
// itemBuilder:
// (BuildContext context, int index) {
// return GestureDetector(
// onTap: () {
// dialogWithStateManagement(
// context,
// subitemsList[index]['title'],
// int.parse(
// subitemsList[index]['unit_price'],
// ),
// subitemsList[index]['product_id'],
// subitemsList[index]['category_id'],
// );
// },
// child: Container(
// padding: EdgeInsets.all(5),
// decoration: BoxDecoration(
// border: Border.all(
// color: bordertextcolor)),
// child: Column(
// children: [
// // subitemsList[index]['image']
// Image.asset(
// 'assets/images/default.jpg',
// height: 85,
// width: 85,
// ),
// SizedBox(
// height: 5,
// ),
// Text(
// subitemsList[index]['title']
//     .toString(),
// style: TextStyle(
// fontWeight: FontWeight.bold,
// color: bordertextcolor,
// fontSize: 10),
// ),
// ],
// ),
// ),
// );
// },
// ),
// ),
// ),
// ],
// ),
// ),
// ),
