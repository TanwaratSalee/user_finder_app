import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_finalproject/Views/collection_screen/loading_indicator.dart';
import 'package:flutter_finalproject/Views/orders_screen/orders_details.dart';
import 'package:flutter_finalproject/Views/widgets_common/tapButton.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

  Future<Map<String, String>> getProductDetails(String productId) async {
    if (productId.isEmpty) {
      debugPrint('Error: productId is empty.');
      return {'name': 'Unknown Product', 'id': productId, 'imageUrl': ''};
    }

    try {
      var productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productSnapshot.exists) {
        debugPrint('Document ID: ${productSnapshot.id}'); // Use debugPrint
        var productData = productSnapshot.data() as Map<String, dynamic>?;
        return {
          'name': productData?['name'] ?? 'Unknown Product',
          'id': productId,
          'imageUrl':
              (productData?['imgs'] != null && productData!['imgs'].isNotEmpty)
                  ? productData['imgs'][0]
                  : ''
        };
      } else {
        return {'name': 'Unknown Product', 'id': productId, 'imageUrl': ''};
      }
    } catch (e) {
      debugPrint('Error getting product name: $e');
      return {'name': 'Unknown Product', 'id': productId, 'imageUrl': ''};
    }
  }

  Future<Map<String, String>> getVendorDetails(String vendorId) async {
    if (vendorId.isEmpty) {
      debugPrint('Error: vendorId is empty.');
      return {'name': 'Unknown Vendor'};
    }

    try {
      var vendorSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();
      if (vendorSnapshot.exists) {
        var vendorData = vendorSnapshot.data() as Map<String, dynamic>?;
        return {'name': vendorData?['name'] ?? 'Unknown Vendor'};
      } else {
        return {'name': 'Unknown Vendor'};
      }
    } catch (e) {
      debugPrint('Error getting vendor name: $e');
      return {'name': 'Unknown Vendor'};
    }
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

          // Sort data by created_at in descending order
          data.sort((a, b) {
            var dateA =
                (a.data() as Map<String, dynamic>)['created_at'].toDate();
            var dateB =
                (b.data() as Map<String, dynamic>)['created_at'].toDate();
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order : ${orderData['order_id']?.length > 16 ? orderData['order_id']?.substring(0, 16) + '...' : orderData['order_id']}",
                        )
                            .text
                            .fontFamily(medium)
                            .color(blackColor)
                            .size(18)
                            .make(),
                        // Text(intl.DateFormat()
                        //     .add_yMd()
                        //     .format((orderData['created_at'].toDate()))),

                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: orderData['order_confirmed']
                                ? greenColor
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            orderData['order_confirmed']
                                ? "Confirm"
                                : "Pending",
                            style: TextStyle(
                              color: whiteColor,
                              fontFamily: medium,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ).box.padding(EdgeInsets.symmetric(horizontal: 12)).make(),
                    10.heightBox,
                    ...products.map((product) {
                      return FutureBuilder<Map<String, String>>(
                        future: getProductDetails(product['product_id'] ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!['name']!.isEmpty) {
                            return Text('Unknown Product');
                          }

                          var productName = snapshot.data!['name'] ?? 'Unknown';
                          var productImage = snapshot.data!['imageUrl'] ?? '';
                          var productPrice = product['total_price'] != null
                              ? NumberFormat('#,##0')
                                  .format(product['total_price'])
                              : '0';

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('x${product['qty']}')
                                    .text
                                    .fontFamily(regular)
                                    .color(blackColor)
                                    .size(16)
                                    .make(),
                                const SizedBox(width: 10),
                                productImage.isNotEmpty
                                    ? Image.network(productImage,
                                        width: 60,
                                        height: 70,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: 60,
                                        height: 70,
                                        color: greyColor),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(productName,
                                          style: const TextStyle(
                                              fontFamily: medium, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text('${productPrice} Bath')
                                          .text
                                          .fontFamily(regular)
                                          .color(greyColor)
                                          .size(14)
                                          .make(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                )
                    .box
                    .color(whiteColor)
                    .roundedSM
                    .border(color: greyLine)
                    .margin(
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 18))
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
              var products = orderData['orders'] as List<dynamic>? ?? [];

              return InkWell(
                onTap: () {
                  Get.to(() => OrdersDetails(data: orderData));
                },
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order : ${orderData['order_id']?.length > 16 ? orderData['order_id']?.substring(0, 16) + '...' : orderData['order_id']}",
                        )
                            .text
                            .fontFamily(medium)
                            .color(blackColor)
                            .size(18)
                            .make(),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: orderData['order_confirmed']
                                ? greenColor
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            orderData['order_confirmed']
                                ? "Confirm"
                                : "Pending",
                            style: TextStyle(
                              color: whiteColor,
                              fontFamily: medium,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ).box.padding(EdgeInsets.symmetric(horizontal: 12)).make(),
                    5.heightBox,
                    ...products.map((product) {
                      return FutureBuilder<Map<String, String>>(
                        future: getProductDetails(product['product_id'] ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!['name']!.isEmpty) {
                            return Text('Unknown Product');
                          }
                          var productDetails = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'x${product['qty'] ?? 0}',
                                )
                                    .text
                                    .fontFamily(regular)
                                    .color(blackColor)
                                    .size(16)
                                    .make(),
                                const SizedBox(width: 10),
                                Image.network(productDetails['imageUrl']!,
                                    width: 60, height: 70, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image, size: 70);
                                }),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productDetails['name'] ??
                                            'Unknown Product',
                                        style: const TextStyle(
                                          fontFamily: medium,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${NumberFormat('#,##0').format(product['total_price'] ?? 0)} Bath',
                                      )
                                          .text
                                          .fontFamily(regular)
                                          .color(greyColor)
                                          .size(14)
                                          .make(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                )
                    .box
                    .color(whiteColor)
                    .roundedSM
                    .border(color: greyLine)
                    .margin(
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 18))
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
      stream: getReviewOrders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child:
                  Text("No orders yet!", style: TextStyle(color: greyColor)));
        } else {
          var data = snapshot.data!.docs;

          // Filter orders that have at least one product with 'reviews' set to false
          var ordersWithProductsToReview = data.where((orderDoc) {
            var orderData = orderDoc.data() as Map<String, dynamic>;
            var products = orderData['orders'] as List<dynamic>;
            return products.any((product) => product['reviews'] == false);
          }).toList();

          if (ordersWithProductsToReview.isEmpty) {
            return const Center(
                child:
                    Text("No orders yet!", style: TextStyle(color: greyColor)));
          }

          return ListView.builder(
            itemCount: ordersWithProductsToReview.length,
            itemBuilder: (context, index) {
              var orderDoc = ordersWithProductsToReview[index];
              var orderData = orderDoc.data() as Map<String, dynamic>;
              var products = orderData['orders'] as List<dynamic>;

              // Filter products that have 'reviews' set to false
              var productsToReview = products
                  .where((product) => product['reviews'] == false)
                  .toList();

              return FutureBuilder<Map<String, String>>(
                future: getVendorDetails(orderData['vendor_id']),
                builder: (context, vendorSnapshot) {
                  if (vendorSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (vendorSnapshot.hasError ||
                      !vendorSnapshot.hasData) {
                    return Center(child: Text('Error loading vendor details.'));
                  } else {
                    var vendorDetails = vendorSnapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (productsToReview.isNotEmpty)
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(iconsStore, width: 20),
                                          15.widthBox,
                                          Text(
                                            vendorDetails['name'] ??
                                                'Unknown Vendor',
                                            style: TextStyle(
                                              fontFamily: medium,
                                              color: blackColor,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(intl.DateFormat().add_yMd().format(
                                          (orderData['created_at'].toDate()))),
                                    ],
                                  ).paddingOnly(top: 10),
                                  5.heightBox,
                                  Divider(
                                    color: greyLine,
                                  ),
                                  Text(
                                    "Order : ${orderData['order_id']?.length > 16 ? orderData['order_id']?.substring(0, 16) + '...' : orderData['order_id']}",
                                    style: TextStyle(
                                      fontFamily: medium,
                                      color: greyDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                        ...productsToReview.asMap().entries.map((entry) {
                          int productIndex = entry.key;
                          var product = entry.value;
                          var reviewController = TextEditingController();
                          var rating = 0.0;

                          return FutureBuilder<Map<String, String>>(
                            future: getProductDetails(product['product_id']),
                            builder: (context, productSnapshot) {
                              if (productSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (productSnapshot.hasError ||
                                  !productSnapshot.hasData) {
                                return Center(
                                    child:
                                        Text('Error loading product details.'));
                              } else {
                                var productDetails = productSnapshot.data!;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.network(
                                                    productDetails[
                                                            'imageUrl'] ??
                                                        'default_image_url',
                                                    width: 85,
                                                    height: 85,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          productDetails[
                                                                  'name'] ??
                                                              'Unknown',
                                                          style: TextStyle(
                                                            fontFamily: medium,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${NumberFormat('#,##0').format(product['total_price'] ?? 0)} Bath',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                regular,
                                                            color: greyColor,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        RatingBar.builder(
                                                          initialRating: 0,
                                                          minRating: 1,
                                                          direction:
                                                              Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemSize:
                                                              20.0, // Smaller stars
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  Icon(
                                                            Icons.star,
                                                            color: golden,
                                                          ),
                                                          onRatingUpdate:
                                                              (ratingValue) {
                                                            setState(() {
                                                              rating =
                                                                  ratingValue;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              TextField(
                                                controller: reviewController,
                                                maxLines: 2,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Write your review here',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    borderSide: BorderSide(color: greyColor),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular( 8.0),
                                                    borderSide: BorderSide(
                                                      color: greyColor,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular( 8.0),
                                                    borderSide: BorderSide(
                                                      color: greyColor,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              tapButton(
                                                color: primaryApp,
                                                title: 'Submit',
                                                textColor: whiteColor,
                                                onPress: rating > 0 ? () async {
                                                  var currentUser = FirebaseAuth.instance.currentUser;
                                                  if (currentUser != null) {
                                                    var userName = currentUser.displayName ?? 'Anonymous';
                                                    var userImg = currentUser.photoURL ?? 'default_user_image_url';
                                                    var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
                                                    if (userDoc.exists) {
                                                      var userData = userDoc.data() as Map<String, dynamic>?;
                                                      userName = userData?['name'] ?? userName;
                                                      userImg = userData?['imageUrl'] ?? userImg;
                                                    }

                                                    var vendorId = orderData['vendor_id'] ?? 'Unknown Vendor'; 

                                                    var reviewData = {
                                                      'vendor_id': vendorId,
                                                      'product_id': product['product_id'] ?? 'N/A',
                                                      'rating': rating,
                                                      'review_text': reviewController.text,
                                                      'created_at': DateTime.now(),
                                                      'user_id': currentUser.uid,
                                                      'user_img': userImg,
                                                    };

                                                    await FirebaseFirestore.instance.collection('reviews').add(reviewData);

                                                    var updatedProducts = products.map((p) {
                                                      if (p['product_id'] == product['product_id']) {
                                                        p['reviews'] = true;
                                                      }
                                                      return p;
                                                    }).toList();

                                                    await orderDoc.reference.update({
                                                      'orders': updatedProducts
                                                    });

                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Review Submitted: Thank you for your feedback!'),
                                                        duration: Duration(seconds: 2),
                                                      ),
                                                    );

                                                    setState(() {
                                                      productsToReview.removeAt(productIndex);
                                                      if (productsToReview.isEmpty) {
                                                        ordersWithProductsToReview.removeAt(index);
                                                      }
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Error: You need to be logged in to submit a review'),
                                                        duration: Duration(seconds: 2),
                                                      ),
                                                    );
                                                  }
                                                } : null,
                                              ),
                                              ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          );
                        }).toList(),
                      ],
                    )
                        .box
                        .border(color: greyLine)
                        .rounded
                        .margin(
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8))
                        .make();
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Widget buildHistory(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrderHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: loadingIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
              child:
                  Text("No history yet!", style: TextStyle(color: greyDark)));
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
                          "Order : ${orderData['order_id']?.length > 16 ? orderData['order_id']?.substring(0, 16) + '...' : orderData['order_id']}",
                        )
                            .text
                            .fontFamily(medium)
                            .color(blackColor)
                            .size(18)
                            .make(),
                        Text(
                          orderData['created_at'] != null
                              ? intl.DateFormat()
                                  .add_yMd()
                                  .format((orderData['created_at'].toDate()))
                              : 'Unknown Date',
                        ),
                      ],
                    ).box.padding(EdgeInsets.symmetric(horizontal: 12)).make(),
                    Divider(
                      color: greyLine,
                    ),
                    5.heightBox,
                    ...products.map((product) {
                      return FutureBuilder<Map<String, String>>(
                        future: getProductDetails(product['product_id'] ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!['name']!.isEmpty) {
                            return Text('Unknown Product');
                          }
                          var productDetails = snapshot.data!;
                          var productName =
                              productDetails['name'] ?? 'Unknown Product';
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'x${product['qty']}',
                                )
                                    .text
                                    .fontFamily(medium)
                                    .color(blackColor)
                                    .size(16)
                                    .make(),
                                const SizedBox(width: 5),
                                Image.network(productDetails['imageUrl']!,
                                    width: 60, height: 70, fit: BoxFit.cover),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productName,
                                        style: const TextStyle(
                                          fontFamily: medium,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${NumberFormat('#,##0').format(product['total_price'])} Bath',
                                      )
                                          .text
                                          .fontFamily(regular)
                                          .color(greyColor)
                                          .size(14)
                                          .make(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                )
                    .box
                    .color(whiteColor)
                    .roundedSM
                    .border(color: greyLine)
                    .margin(
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 18))
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
    return FirebaseFirestore.instance
        .collection(ordersCollection)
        .where('order_on_delivery', isEqualTo: false)
        .where('order_delivered', isEqualTo: false)
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getDeliveryOrders() {
    return FirebaseFirestore.instance
        .collection(ordersCollection)
        .where('order_on_delivery', isEqualTo: true)
        .where('order_delivered', isEqualTo: false)
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getOrderHistory() {
    return FirebaseFirestore.instance
        .collection(ordersCollection)
        .where('order_delivered', isEqualTo: true)
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getReviewOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('order_delivered', isEqualTo: true)
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }
}
