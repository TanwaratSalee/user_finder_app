import 'package:flutter/material.dart';
import 'package:flutter_finalproject/Views/collection_screen/loading_indicator.dart';
import 'package:flutter_finalproject/Views/match_screen/matchpost_details.dart';
import 'package:flutter_finalproject/Views/match_screen/matchpost_screen.dart';
import 'package:flutter_finalproject/Views/profile_screen/menu_setting_screen.dart';
import 'package:flutter_finalproject/Views/store_screen/matchstore_detail.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../consts/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_finalproject/Views/store_screen/item_details.dart';
import 'package:flutter_finalproject/services/firestore_services.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  TabController? _mainTabController;
  TabController? _favoriteTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _favoriteTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController?.dispose();
    _favoriteTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 26,
            fontFamily: medium,
          ),
        ),
        shadowColor: greyColor.withOpacity(0.5),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: blackColor,
            ),
            onPressed: () {
              Get.to(() => const MenuSettingScreen());
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          buildUserProfile(),
          AnimatedBuilder(
            animation: _mainTabController!,
            builder: (context, child) {
              return TabBar(
                controller: _mainTabController,
                labelStyle: const TextStyle(
                    fontSize: 15, fontFamily: regular, color: greyDark),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 14, fontFamily: regular, color: greyDark),
                tabs: [
                  Tab(
                    icon: Image.asset(
                      icTapPostProfile,
                      color: _mainTabController?.index == 0
                          ? primaryApp
                          : greyLine,
                      width: 22,
                      height: 22,
                    ),
                  ),
                  Tab(
                    icon: Image.asset(
                      icTapProfileFav,
                      color: _mainTabController?.index == 1
                          ? primaryApp
                          : greyLine,
                      width: 22,
                      height: 22,
                    ),
                  ),
                ],
                unselectedLabelColor: greyColor,
                labelColor: primaryApp,
                indicatorColor: Theme.of(context).primaryColor,
                onTap: (index) {
                  setState(() {});
                },
              );
            },
          ),
          Divider(
            color: greyLine,
            thickness: 1,
            height: 2,
          ),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                buildPostTab(),
                Column(
                  children: [
                    TabBar(
                      controller: _favoriteTabController,
                      labelStyle: const TextStyle(
                          fontSize: 16, fontFamily: medium, color: greyColor),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 14, fontFamily: medium, color: greyColor),
                      tabs: [
                        const Tab(text: 'Product'),
                        const Tab(text: 'My Matchs'),
                        const Tab(text: 'Online Matchs'),
                      ],
                      unselectedLabelColor: greyColor,
                      labelColor: primaryApp,
                      indicatorColor: Theme.of(context).primaryColor,
                    ),
                    Divider(
                      color: greyLine,
                      thickness: 1,
                      height: 2,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TabBarView(
                        controller: _favoriteTabController,
                        children: [
                          buildProductsTab(),
                          buildMyMatchTab(),
                          buildOnlineMatchTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserProfile() {
    return StreamBuilder(
      stream: FirestoreServices.getUser(currentUser!.uid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryApp),
            ),
          );
        } else {
          var data = snapshot.data!.docs[0];

          return SafeArea(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          data['imageUrl'] == ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child:
                                      loadingIndicator() /*  Image.asset(
                                    imgProfile,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ), */
                                  )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    data['imageUrl'],
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          const SizedBox(height: 10),
                          Text(
                            data['name'][0].toUpperCase() +
                                data['name'].substring(1),
                            style: const TextStyle(
                              fontSize: 20,
                              color: blackColor,
                              fontFamily: medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildPostTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usermixandmatch')
          .orderBy('favorite_count', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!.docs;

        String currentUserUID = FirebaseAuth.instance.currentUser?.uid ?? '';

        var filteredData = data.where((doc) {
          var docData = doc.data() as Map<String, dynamic>;
          print(
              'Document data: $docData'); // เพิ่มการพิมพ์ข้อมูลเอกสารเพื่อตรวจสอบ
          return docData['user_id'] == currentUserUID;
        }).toList();

        if (filteredData.isEmpty) {
          return Center(
            child:
                Text("No posts available!", style: TextStyle(color: greyDark)),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 7,
            mainAxisSpacing: 8,
            childAspectRatio: 9 / 11,
          ),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            var doc = filteredData[index];
            var docData = doc.data() as Map<String, dynamic>;

            var productIdTop = docData['product_id_top'] ?? '';
            var productIdLower = docData['product_id_lower'] ?? '';

            return FutureBuilder<List<DocumentSnapshot>>(
              future: Future.wait([
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productIdTop)
                    .get(),
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productIdLower)
                    .get()
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var snapshotTop = snapshot.data![0];
                var snapshotLower = snapshot.data![1];

                if (!snapshotTop.exists || !snapshotLower.exists) {
                  return Center(child: Text("One or more products not found"));
                }

                var productDataTop = snapshotTop.data() as Map<String, dynamic>;
                var productDataLower =
                    snapshotLower.data() as Map<String, dynamic>;

                var topImage =
                    (productDataTop['imgs'] as List<dynamic>?)?.first ?? '';
                var lowerImage =
                    (productDataLower['imgs'] as List<dynamic>?)?.first ?? '';
                var productNameTop = productDataTop['name'] ?? '';
                var productNameLower = productDataLower['name'] ?? '';
                var priceTop = productDataTop['price']?.toString() ?? '0';
                var priceLower = productDataLower['price']?.toString() ?? '0';
                var collections = docData['collection'] != null
                    ? List<String>.from(docData['collection'])
                    : [];
                var situations = docData['situations'] != null
                    ? List<String>.from(docData['situations'])
                    : [];
                var description = docData['description'] ?? '';
                var favoriteCount = (docData['favorite_count'] ?? 0) as int;
                var gender = docData['gender'] ?? '';
                var postedBy = docData['user_id'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Get.to(() => MatchPostsDetails(
                          docId: doc.id,
                          productName1: productNameTop,
                          productName2: productNameLower,
                          price1: priceTop,
                          price2: priceLower,
                          productImage1: topImage,
                          productImage2: lowerImage,
                          totalPrice:
                              (int.parse(priceTop) + int.parse(priceLower))
                                  .toString(),
                          vendorName1: 'Vendor Name 1',
                          vendorName2: 'Vendor Name 2',
                          vendor_id: doc.id,
                          collection: collections,
                          description: description,
                          gender: gender,
                          user_id: postedBy,
                          situations: situations, // ตรวจสอบ situations
                        ));
                  },
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('usermixandmatch')
                            .doc(doc.id)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var docData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          var favoriteUserIds =
                              List<String>.from(docData['favorite_userid']);
                          bool isFavorited =
                              favoriteUserIds.contains(currentUserUID);

                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 75,
                                      height: 80,
                                      child: Image.network(
                                        topImage,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            productNameTop,
                                            style: const TextStyle(
                                              fontFamily: medium,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            "${NumberFormat('#,##0').format(double.parse(priceTop).toInt())} Bath",
                                            style: const TextStyle(
                                                color: greyColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 75,
                                      height: 80,
                                      child: Image.network(
                                        lowerImage,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            productNameLower,
                                            style: const TextStyle(
                                              fontFamily: medium,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            "${NumberFormat('#,##0').format(double.parse(priceLower).toInt())} Bath",
                                            style: const TextStyle(
                                                color: greyColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                10.heightBox,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(icTapFavoriteButton, width: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      favoriteCount.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: regular,
                                        color: greyColor,
                                      ),
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 8),
                              ],
                            )
                                .box
                                .border(color: greyLine)
                                .rounded
                                .padding(EdgeInsets.all(8))
                                .make(),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildProductsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreServices.getFavorite(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final data = snapshot.data!.docs;
        if (data.isEmpty) {
          return const Center(
            child: Text("No products you liked!",
                style: TextStyle(color: greyDark)),
          );
        }
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetails(
                      title: data[index]['name'],
                      data: data[index].data() as Map<String, dynamic>,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.network(
                        data[index]['imgs'][0],
                        height: 70,
                        width: 65,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  data[index]['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: medium,
                                  ),
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ).box.width(180).make(),
                                Text(
                                  "${NumberFormat('#,##0').format(double.parse(data[index]['price']).toInt())} Bath",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: regular,
                                      color: greyDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(icTapFavoriteButton, width: 20),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection(productsCollection)
                            .doc(data[index].id)
                            .update({
                          'favorite_uid': FieldValue.arrayRemove(
                              [FirebaseAuth.instance.currentUser!.uid])
                        });
                      },
                    ),
                  ],
                )
                    .box
                    .border(color: greyLine)
                    .roundedSM
                    .margin(EdgeInsets.symmetric(horizontal: 12, vertical: 4))
                    .make(),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildMyMatchTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreServices.getUserMatchFavorite(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final data = snapshot.data!.docs;
        if (data.isEmpty) {
          return const Center(
            child: Text("No products you liked!",
                style: TextStyle(color: greyDark)),
          );
        }
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var docData = data[index].data() as Map<String, dynamic>;
            var productIdTop =
                docData['product_id_top'] ?? 'Unknown Product ID';
            var productIdLower =
                docData['product_id_lower'] ?? 'Unknown Product ID';

            return FutureBuilder<List<DocumentSnapshot>>(
              future: Future.wait([
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productIdTop)
                    .get(),
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productIdLower)
                    .get()
              ]),
              builder: (context, futureSnapshot) {
                if (!futureSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var productTopSnapshot = futureSnapshot.data![0];
                var productLowerSnapshot = futureSnapshot.data![1];

                if (!productTopSnapshot.exists &&
                    !productLowerSnapshot.exists) {
                  return Center(child: Text("Both products not found"));
                } else if (!productTopSnapshot.exists) {
                  return Center(child: Text("Top product not found"));
                } else if (!productLowerSnapshot.exists) {
                  return Center(child: Text("Lower product not found"));
                }

                var productTopData =
                    productTopSnapshot.data() as Map<String, dynamic>?;
                var productLowerData =
                    productLowerSnapshot.data() as Map<String, dynamic>?;

                var nameTop = productTopData?['name']?.toString() ?? '0';
                var nameLower = productLowerData?['name']?.toString() ?? '0';
                var topImage =
                    (productTopData?['imgs'] as List<dynamic>?)?.first ?? '';
                var lowerImage =
                    (productLowerData?['imgs'] as List<dynamic>?)?.first ?? '';
                var priceTop = productTopData?['price']?.toString() ?? '0';
                var priceLower = productLowerData?['price']?.toString() ?? '0';

                totalPrice:
                (int.parse(priceTop) + int.parse(priceLower)).toString();

                return Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetails(
                                      title: nameTop,
                                      data: productTopData!,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Image.network(
                                          topImage,
                                          height: 60,
                                          width: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nameTop,
                                            style: const TextStyle(
                                              fontFamily: medium,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ).box.width(180).make(),
                                          Text(
                                            "${NumberFormat('#,##0').format(double.parse(priceTop).toInt())} Bath",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: regular,
                                                color: greyDark),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  IconButton(
                        icon: Image.asset(icTapFavoriteButton, width: 20),
                        onPressed: () async {
                          String documentId = data[index].id;
                          DocumentSnapshot docSnapshot = await FirebaseFirestore
                              .instance
                              .collection(userfavmatchCollection)
                              .doc(documentId)
                              .get();

                          if (docSnapshot.exists) {
                            await FirebaseFirestore.instance
                                .collection(userfavmatchCollection)
                                .doc(documentId)
                                .update({
                              'favorite_uid': FieldValue.arrayRemove(
                                  [FirebaseAuth.instance.currentUser!.uid])
                            });
                            VxToast.show(context,
                                msg: "Removed favorited match successfully");
                            print(
                                "Document updated successfully for ID: $documentId");
                          } else {
                            print("Document not found for ID: $documentId");
                            VxToast.show(context, msg: "Product not found");
                          }
                        },
                      ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetails(
                                      title: nameLower,
                                      data: productLowerData!,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.network(
                                      lowerImage,
                                      height: 60,
                                      width: 55,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nameLower,
                                        style: const TextStyle(
                                          fontFamily: medium,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ).box.width(180).make(),
                                      Text(
                                        "${NumberFormat('#,##0').format(double.parse(priceLower).toInt())} Bath",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: regular,
                                            color: greyDark),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total ${NumberFormat('#,##0').format(int.parse(priceTop) + int.parse(priceLower))} Bath",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: medium,
                                    color: blackColor,
                                  ),
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {
                                    if (productTopData != null &&
                                        productLowerData != null) {
                                      Get.to(() => MatchPostProduct(
                                            topProduct: productTopData,
                                            lowerProduct: productLowerData,
                                          ));
                                    } else {
                                      print('Product data is null');
                                    }
                                  },
                                  child: SizedBox(
                                          child: Text("Post").text.white.make())
                                      .box
                                      .color(primaryApp)
                                      .roundedSM
                                      .padding(EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8))
                                      .make(),
                                )
                              ],
                            ).marginOnly(left: 20)
                          ],
                        ),
                      ),
                    ],
                  )
                      .box
                      .border(color: greyLine)
                      .roundedSM
                      .margin(EdgeInsets.symmetric(horizontal: 12, vertical: 4))
                      .make(),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildOnlineMatchTab() {
    return FutureBuilder<List<QuerySnapshot>>(
      future: FirestoreServices.getFavoriteusermixmatchs().first,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data!
            .expand((querySnapshot) => querySnapshot.docs)
            .toList();

        if (data.isEmpty) {
          return const Center(
            child: Text("No products you liked!",
                style: TextStyle(color: greyDark)),
          );
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var doc = data[index];
            var docData = doc.data() as Map<String, dynamic>;
            var productIdTop = docData['product_id_top'] ?? '';
            var productIdLower = docData['product_id_lower'] ?? '';
            bool isStoreMatch = doc.reference.parent.id == 'storemixandmatchs';

            return FutureBuilder<List<DocumentSnapshot>>(
              future: Future.wait([
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productIdTop)
                    .get(),
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productIdLower)
                    .get()
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var productSnapshotTop = snapshot.data![0];
                var productSnapshotLower = snapshot.data![1];

                if (!productSnapshotTop.exists ||
                    !productSnapshotLower.exists) {
                  return const Center(
                    child: Text("Some products not found!"),
                  );
                }

                var productDataTop =
                    productSnapshotTop.data() as Map<String, dynamic>;
                var productDataLower =
                    productSnapshotLower.data() as Map<String, dynamic>;

                var topImage =
                    (productDataTop['imgs'] as List<dynamic>?)?.first ?? '';
                var lowerImage =
                    (productDataLower['imgs'] as List<dynamic>?)?.first ?? '';
                var productNameTop = productDataTop['name'] ?? '';
                var productNameLower = productDataLower['name'] ?? '';
                var priceTop = productDataTop['price']?.toString() ?? '0';
                var priceLower = productDataLower['price']?.toString() ?? '0';
                var collections = docData['collection'] != null
                    ? List<String>.from(docData['collection'])
                    : [];
                var situations = docData['situations'] != null
                    ? List<String>.from(docData['situations'])
                    : [];
                var description = docData['description'] ?? '';
                var views = docData['views'] ?? 0;
                var gender = docData['gender'] ?? '';
                var postedBy = docData['user_id'] ?? '';

                return GestureDetector(
                  onTap: () {
                    if (isStoreMatch) {
                      Get.to(() => MatchStoreDetailScreen(
                            documentId: doc.id,
                          ));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchPostsDetails(
                            docId: doc.id,
                            productName1: productNameTop,
                            productName2: productNameLower,
                            price1: priceTop,
                            price2: priceLower,
                            productImage1: topImage,
                            productImage2: lowerImage,
                            totalPrice:
                                (int.parse(priceTop) + int.parse(priceLower))
                                    .toString(),
                            vendorName1: 'Vendor Name 1',
                            vendorName2: 'Vendor Name 2',
                            vendor_id: doc.id,
                            collection: collections,
                            situations: situations,
                            description: description,
                            gender: gender,
                            user_id: postedBy,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.network(
                                    topImage,
                                    height: 60,
                                    width: 55,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        productNameTop,
                                        style: const TextStyle(
                                          fontFamily: medium,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ).box.width(180).make(),
                                      Text(
                                        "${NumberFormat('#,##0').format(double.parse(priceTop).toInt())} Bath",
                                        style:
                                            const TextStyle(color: greyColor),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Image.network(
                                    lowerImage,
                                    height: 60,
                                    width: 55,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productNameLower,
                                        style: const TextStyle(
                                          fontFamily: medium,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "${NumberFormat('#,##0').format(double.parse(priceLower).toInt())} Bath",
                                        style:
                                            const TextStyle(color: greyColor),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.only(right: 200),
                                child: Text(
                                  "Total ${NumberFormat('#,##0').format(int.parse(priceTop) + int.parse(priceLower))} Bath",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: medium,
                                    color: blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Image.asset(icTapFavoriteButton, width: 20),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('usermixandmatch')
                                  .doc(data[index].id)
                                  .update({
                                'favorite_userid': FieldValue.arrayRemove(
                                    [FirebaseAuth.instance.currentUser!.uid])
                              });
                            },
                          ),
                        ),
                      ],
                    )
                        .box
                        .border(color: greyLine)
                        .roundedSM
                        .margin(
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4))
                        .make(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productName,
      String docIdTop, String docIdLower) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: AnimatedPadding(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: whiteColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: greyDark,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Confirm Deletion",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontFamily: bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Are you sure you want to delete ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: greyDark),
                        ),
                      ),
                      SizedBox(width: 20.0),
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('usermixandmatch')
                              .doc(docIdTop)
                              .delete();
                          await FirebaseFirestore.instance
                              .collection('usermixandmatch')
                              .doc(docIdLower)
                              .delete();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(color: redColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateToItemDetails(BuildContext context, String productName) {
    FirebaseFirestore.instance
        .collection(productsCollection)
        .where('name', isEqualTo: productName)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var productData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetails(
              title: productData['name'],
              data: productData,
            ),
          ),
        );
      } else {
        VxToast.show(
          context,
          msg: 'No details available for $productName',
        );
      }
    });
  }
}

Widget buildPostButton(Map<String, dynamic>? productTopData,
    Map<String, dynamic>? productLowerData) {
  return TextButton(
    onPressed: () {
      if (productTopData != null && productLowerData != null) {
        Get.to(() => MatchPostProduct(
              topProduct: productTopData,
              lowerProduct: productLowerData,
            ));
      } else {
        print('Product data is null');
      }
    },
    child: SizedBox(child: Text("Post").text.white.make())
        .box
        .color(primaryApp)
        .roundedSM
        .padding(EdgeInsets.symmetric(horizontal: 20, vertical: 8))
        .make(),
  );
}
