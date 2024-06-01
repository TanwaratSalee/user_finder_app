import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_finalproject/Views/collection_screen/loading_indicator.dart';
import 'package:flutter_finalproject/Views/orders_screen/orders_details.dart';
import 'package:flutter_finalproject/Views/orders_screen/writeReview_screen.dart';
import 'package:flutter_finalproject/Views/widgets_common/tapButton.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text("My Orders")
            .text
            .size(26)
            .fontFamily(semiBold)
            .color(blackColor)
            .make(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Delivery'),
            Tab(text: 'Review'),
            Tab(text: 'History'),
          ],
          indicatorColor: primaryApp,
          labelColor: blackColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildOrders(context),
          buildDelivery(context),
          buildReview(context),
          buildHistory(context),
        ],
      ),
    );
  }

Widget buildOrders(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: getOrders(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: loadingIndicator());
      } else if (snapshot.data!.docs.isEmpty) {
        return const Center(
            child: Text("No orders yet!", style: TextStyle(color: greyDark)));
      } else {
        var data = snapshot.data!.docs;

        // Sort data by order_date in descending order
        data.sort((a, b) {
          var dateA = (a.data() as Map<String, dynamic>)['order_date'].toDate();
          var dateB = (b.data() as Map<String, dynamic>)['order_date'].toDate();
          return dateB.compareTo(dateA);
        });

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var orderData = data[index].data() as Map<String, dynamic>;
            var products = orderData['orders'] as List<dynamic>;

            return InkWell(
              onTap: () {
                Get.to(() => OrdersDetails(data: orderData));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order code ${orderData['order_code']}",
                      ).text.fontFamily(medium).color(blackColor).size(18).make(),
                      Text(intl.DateFormat()
                          .add_yMd()
                          .format((orderData['order_date'].toDate()))),
                      Text(
                        orderData['order_confirmed'] ? "Confirm" : "Pending",
                        style: TextStyle(
                            color: orderData['order_confirmed']
                                ? Colors.green
                                : Colors.orange,
                            fontFamily: regular,
                            fontSize: 16),
                      ),
                    ],
                  ).box.padding(EdgeInsets.symmetric(horizontal: 12)).make(),
                  5.heightBox,
                  ...products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('x${product['qty']}',).text.fontFamily(regular).color(greyColor).size(12).make(),
                          const SizedBox(width: 5),
                          Image.network(product['img'],
                              width: 70, height: 60, fit: BoxFit.cover),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['title'],
                                  style: const TextStyle(
                                    fontFamily: medium,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                    '${NumberFormat('#,##0').format(product['price'])} Bath',
                                    ).text.fontFamily(regular).color(greyColor).size(14).make(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              )
                  .box
                  .color(whiteColor)
                  .roundedSM
                  .border(color: greyLine)
                  .margin(const EdgeInsets.symmetric(vertical: 8, horizontal: 18))
                  .p12
                  .make(),
            );
          },
        );
      }
    },
  );
}


  Widget buildDelivery(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getDeliveryOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: loadingIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No orders yet!", style: TextStyle(color: greyDark)));
        } else {
          var data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var orderData = data[index].data() as Map<String, dynamic>;
              var products = orderData['orders'] as List<dynamic>;

              return InkWell(
                onTap: () {
                  Get.to(() => OrdersDetails(data: orderData));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order code ${orderData['order_code']}",
                        ).text.fontFamily(medium).color(blackColor).size(18).make(),
                        Text(
                          orderData['order_confirmed'] ? "Confirm" : "Pending",
                          style: TextStyle(
                              color: orderData['order_confirmed']
                                  ? Colors.green
                                  : Colors.orange,
                              fontFamily: regular,
                              fontSize: 16),
                        ),
                      ],
                    ).box.padding(EdgeInsets.symmetric(horizontal: 12)).make(),
                    5.heightBox,
                    ...products.map((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('x${product['qty']}',).text.fontFamily(regular).color(greyColor).size(12).make(),
                            const SizedBox(width: 5),
                            Image.network(product['img'],
                                width: 70, height: 60, fit: BoxFit.cover),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'],
                                    style: const TextStyle(
                                      fontFamily: medium,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                      '${NumberFormat('#,##0').format(product['price'])} Bath',
                                      ).text.fontFamily(regular).color(greyColor).size(14).make(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                )
                    .box
                    .color(whiteColor)
                    .roundedSM
                    .border(color: greyLine)
                    .margin(const EdgeInsets.symmetric(vertical: 8, horizontal: 18))
                    .p12
                    .make(),
              );
            },
          );
        }
      },
    );
  }

  Widget buildReview(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrderHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: loadingIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No orders yet!", style: TextStyle(color: greyDark)));
        } else {
          var data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var orderData = data[index].data() as Map<String, dynamic>;
              var products = orderData['orders'] as List<dynamic>;

              return InkWell(
                onTap: () {
                  Get.to(() => OrdersDetails(data: orderData));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order code ${orderData['order_code']}",
                        ).text.fontFamily(medium).color(blackColor).size(18).make(),
                        Text(
                          orderData['order_confirmed'] ? "Confirm" : "Pending",
                          style: TextStyle(
                              color: orderData['order_confirmed']
                                  ? Colors.green
                                  : Colors.orange,
                              fontFamily: regular,
                              fontSize: 16),
                        ),
                      ],
                    ).box.padding(EdgeInsets.symmetric(horizontal: 12)).make(),
                    5.heightBox,
                    ...products.map((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('x${product['qty']}',).text.fontFamily(regular).color(greyColor).size(12).make(),
                            const SizedBox(width: 5),
                            Image.network(product['img'],
                                width: 70, height: 60, fit: BoxFit.cover),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'],
                                    style: const TextStyle(
                                      fontFamily: medium,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).text.fontFamily(medium).color(blackColor).size(14).make(),
                                  Text(
                                      '${NumberFormat('#,##0').format(product['price'])} Bath',
                                      ).text.fontFamily(regular).color(greyColor).size(14).make(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: tapButton(
                        title: 'Write product review',
                        color: primaryApp,
                        textColor: whiteColor,
                        onPress: () {
                          Get.to(() => WriteReviewScreen(product: products[index],));
                        },
                      ),
                    ),
                  ],
                )
                    .box
                    .color(whiteColor)
                    .roundedSM
                    .border(color: greyLine)
                    .margin(const EdgeInsets.symmetric(vertical: 8, horizontal: 18))
                    .p12
                    .make(),
              );
            },
          );
        }
      },
    );
  }

  Widget buildHistory(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getHistoryOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: loadingIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No history yet!", style: TextStyle(color: greyDark)));
        } else {
          var data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var orderData = data[index].data() as Map<String, dynamic>;
              var products = orderData['orders'] as List<dynamic>;

              return InkWell(
                onTap: () {
                  Get.to(() => OrdersDetails(data: orderData));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order code ${orderData['order_code']}",
                        ).text.fontFamily(medium).color(blackColor).size(18).make(),
                        Text(
                          orderData['order_confirmed'] ? "Confirm" : "Pending",
                          style: TextStyle(
                              color: orderData['order_confirmed']
                                  ? Colors.green
                                  : Colors.orange,
                              fontFamily: regular,
                              fontSize: 16),
                        ),
                      ],
                    ).box.padding(EdgeInsets.symmetric(horizontal: 12)).make(),
                    5.heightBox,
                    ...products.map((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('x${product['qty']}',).text.fontFamily(regular).color(greyColor).size(12).make(),
                            const SizedBox(width: 5),
                            Image.network(product['img'],
                                width: 70, height: 60, fit: BoxFit.cover),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'],
                                    style: const TextStyle(
                                      fontFamily: medium,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).text.fontFamily(medium).color(blackColor).size(14).make(),
                                  Text(
                                      '${NumberFormat('#,##0').format(product['price'])} Bath',
                                      ).text.fontFamily(regular).color(greyColor).size(14).make(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                )
                    .box
                    .color(whiteColor)
                    .roundedSM
                    .border(color: greyLine)
                    .margin(const EdgeInsets.symmetric(vertical: 8, horizontal: 18))
                    .p12
                    .make(),
              );
            },
          );
        }
      },
    );
  }

  static Stream<QuerySnapshot> getOrders() {
    return firestore
        .collection(ordersCollection)
        .where('order_on_delivery', isEqualTo: false)
        .where('order_delivered', isEqualTo: false)
        .where('order_by', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getDeliveryOrders() {
    return firestore
        .collection(ordersCollection)
        .where('order_on_delivery', isEqualTo: true)
        .where('order_delivered', isEqualTo: false)
        .where('order_by', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getOrderHistory() {
    return firestore
        .collection(ordersCollection)
        .where('order_delivered', isEqualTo: true)
        .where('order_by', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getHistoryOrders() {
    return firestore
        .collection(ordersCollection)
        .where('order_delivered', isEqualTo: true)
        .where('order_by', isEqualTo: currentUser!.uid)
        .snapshots();
  }
}
