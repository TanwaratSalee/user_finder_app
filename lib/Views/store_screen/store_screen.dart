import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_finalproject/Views/collection_screen/loading_indicator.dart';
import 'package:flutter_finalproject/Views/store_screen/match_detail_screen.dart';
import 'package:flutter_finalproject/Views/store_screen/reviews_screen.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:get/get.dart';

class StoreScreen extends StatelessWidget {
  final String vendorId;
  const StoreScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchSellerName(vendorId), // ดึงชื่อผู้ขาย
      builder: (context, snapshot) {
        // สร้าง AppBar ตามสถานะของ Future
        String title = snapshot.hasData ? snapshot.data! : 'Loading...';
        return Scaffold(
          backgroundColor: whiteColor,
          appBar: AppBar(
            title: Text(title),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Get.back(),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              // แก้ไขในส่วนนี้
              children: [
                _buildLogoAndRatingSection(context),
                // _buildReviewHighlights(),
                _buildProductMatchTabs(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoAndRatingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: <Widget>[
          _buildRatingSection(context),
        ],
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: FutureBuilder<String>(
                    future: fetchSellerImgs(
                        vendorId), // อย่าลืมเปลี่ยนให้ตรงกับการเรียกใช้ของคุณ
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // หรือ widget โหลดแบบอื่นๆ ที่คุณต้องการ
                      } else if (snapshot.hasError) {
                        return Image.asset(
                          imProfile, // รูปภาพหากเกิดข้อผิดพลาด
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        );
                      } else if (snapshot.hasData) {
                        return Image.network(
                          snapshot.data!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Image.asset(
                          imProfile, // รูปภาพเริ่มต้นหรือหากไม่มีข้อมูล
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      '4.9/5.0',
                      style: TextStyle(fontSize: 14, fontFamily: regular),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReviewScreen()),
                        );
                      },
                      child: const Text('All Reviews >>>'),
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

  // Widget _buildReviewHighlights() {
  //   return Container(
  //     height: 120,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: 3,
  //       itemBuilder: (context, index) {
  //         return _buildReviewCard();
  //       },
  //     ),
  //   );
  // }

  Widget _buildReviewCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          const BoxShadow(
            color: fontGrey,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reviewer Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < 4 ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
          const Text(
            'The review text goes here...',
            style: TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProductMatchTabs(BuildContext context) {
    return DefaultTabController(
      length: 2, // มีแท็บทั้งหมด 2 แท็บ
      child: Column(
        children: <Widget>[
          TabBar(
            labelStyle: const TextStyle(
                fontSize: 15, fontFamily: regular, color: fontGreyDark),
            unselectedLabelStyle: const TextStyle(
                fontSize: 14, fontFamily: regular, color: fontGrey),
            tabs: [
              const Tab(text: 'Product'),
              const Tab(text: 'Match'),
            ],
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: TabBarView(
              children: [
                _buildProductTab(context),
                _buildMatchTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTab(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5),
          child: _buildCategoryTabs(context),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }

  Widget _buildMatchTab(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5),
          child: _buildCategoryMath(context),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: <Widget>[
          const TabBar(
            isScrollable: true,
            indicatorColor: primaryApp,
            labelStyle: TextStyle(
                fontSize: 13, fontFamily: regular, color: fontGreyDark),
            unselectedLabelStyle:
                TextStyle(fontSize: 12, fontFamily: regular, color: fontGrey),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Outer'),
              Tab(text: 'Dress'),
              Tab(text: 'Bottoms'),
              Tab(text: 'T-shirts'),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: TabBarView(
              children: [
                _buildProductGrid('All'),
                _buildProductGrid('Outer'),
                _buildProductGrid('Dress'),
                _buildProductGrid('Bottoms'),
                _buildProductGrid('T-shirts'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(String category) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .where('vendor_id', isEqualTo: vendorId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: loadingIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No data available');
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1 / 1.2),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var product = snapshot.data!.docs[index];
            String productName = product.get('p_name');
            String price = product.get('p_price');
            String productImage = product.get('p_imgs')[0];
            String subcollection = product.get('p_subcollection');

            if (category == 'All' || subcollection == category) {
              print('Subcollection: $subcollection');
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MatchDetailScreen(),
                    ),
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.network(
                        productImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            3.heightBox,
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
                              '$price',
                              style: const TextStyle(
                                  color: greyColor, fontFamily: regular),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).box.color(whiteColor).make(),
                ),
              );
            } else {
              // return Text('Data not found');
            }
          },
        );
      },
    );
  }

  Widget _buildCategoryMath(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: <Widget>[
          const TabBar(
            isScrollable: true,
            indicatorColor: primaryApp,
            tabs: [
              Tab(text: 'All'),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: TabBarView(
              children: [
                _buildProductMathGrids('All'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductMathGrids(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: loadingIndicator(),
          );
        }

        List<String> mixMatchList = [];
        snapshot.data!.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('p_mixmatch')) {
            String currentMixMatch = data['p_mixmatch'];
            if (!mixMatchList.contains(currentMixMatch)) {
              mixMatchList.add(currentMixMatch);
            }
          }
        });

        // แสดงข้อมูลที่ได้จากการตรวจสอบ p_mixmatch ใน console
        print('MixMatch List: $mixMatchList');

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1 / 1.3,
          ),
          itemBuilder: (BuildContext context, int index) {
            int actualIndex = index * 2;

            String price1 = snapshot.data!.docs[actualIndex].get('p_price');
            String price2 = snapshot.data!.docs[actualIndex + 1].get('p_price');

            String totalPrice =
                (int.parse(price1) + int.parse(price2)).toString();

            String productName1 =
                snapshot.data!.docs[actualIndex].get('p_name');
            String productName2 =
                snapshot.data!.docs[actualIndex + 1].get('p_name');

            String productImage1 =
                snapshot.data!.docs[actualIndex].get('p_imgs')[0];
            String productImage2 =
                snapshot.data!.docs[actualIndex + 1].get('p_imgs')[0];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchDetailScreen(
                      price1: price1,
                      price2: price2,
                      productName1: productName1,
                      productName2: productName2,
                      productImage1: productImage1,
                      productImage2: productImage2,
                      totalPrice: totalPrice,
                    ),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Column(
                          children: [
                            Image.network(
                              productImage1,
                              width: 80,
                              height: 80,
                            ),
                            Image.network(
                              productImage2,
                              width: 80,
                              height: 80,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 2),
                                Text(
                                  productName1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Price: \$${price1.toString()}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  productName2,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Price: \$${price2.toString()}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Total Price: \$${totalPrice.toString()}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: (mixMatchList.length).ceil(),
        );
      },
    );
  }

  Future<String> fetchSellerName(String vendorId) async {
    // ค้นหาเอกสารใน collection 'products' ที่มี 'vendor_id' ตรงกับ vendorId ที่ให้มา
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('vendor_id', isEqualTo: vendorId)
        .limit(1) // จำกัดผลลัพธ์เพื่อประหยัดทรัพยากร
        .get();

    // ตรวจสอบว่าพบเอกสารหรือไม่
    if (querySnapshot.docs.isNotEmpty) {
      // ดึงข้อมูล 'p_seller' จากเอกสารแรกที่พบ
      Map<String, dynamic> data =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      return data['p_seller'] ??
          'Unknown Seller'; // คืนค่า 'p_seller' หรือ 'Unknown Seller' หากไม่พบข้อมูล
    } else {
      return 'Unknown Seller'; // คืนค่า 'Unknown Seller' หากไม่พบเอกสารใดๆ
    }
  }

  Future<String> fetchSellerImgs(String vendorId) async {
    try {
      // ค้นหาเอกสารใน collection 'vendors' ที่มี 'vendor_id' ตรงกับ vendorId ที่ให้มา
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .where('vendor_id', isEqualTo: vendorId)
          .limit(1) // จำกัดผลลัพธ์เพื่อประหยัดทรัพยากร
          .get();

      // ตรวจสอบว่าพบเอกสารหรือไม่
      if (querySnapshot.docs.isNotEmpty) {
        // ดึงข้อมูล 'imageUrl' จากเอกสารแรกที่พบ
        Map<String, dynamic> data =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        return data['imageUrl'] ?? 'URL รูปภาพเริ่มต้น/คำแนะนำหากไม่พบ';
      } else {
        return 'URL รูปภาพเริ่มต้น/คำแนะนำหากไม่พบ'; // คืนค่า URL เริ่มต้นหากไม่พบเอกสารใดๆ
      }
    } catch (e) {
      // จัดการกับข้อผิดพลาดที่อาจเกิดขึ้น
      print('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
      return 'URL รูปภาพเริ่มต้น/คำแนะนำหากเกิดข้อผิดพลาด'; // คืนค่า URL เริ่มต้นหรือคำแนะนำในกรณีเกิดข้อผิดพลาด
    }
  }
}
