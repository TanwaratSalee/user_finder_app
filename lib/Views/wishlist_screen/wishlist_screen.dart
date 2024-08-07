import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_finalproject/Views/store_screen/item_details.dart';
import 'package:flutter_finalproject/services/firestore_services.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:intl/intl.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          "Favourite",
          
        ).text
            .size(26)
            .fontFamily(semiBold)
            .color(blackColor)
            .make(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreServices.getFavorite(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.docs;
          if (data.isEmpty) {
            return const Center(
                child:
                    Text("No orders yet!", style: TextStyle(color: greyDark)));
          }
          return ListView.separated(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetails(
                        title: data[index]['p_name'],
                        data: data[index],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data[index]['p_imgs'][0],
                            height: 75,
                            width: 65,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                data[index]['p_name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: regular,
                                ),
                              ),
                              Text(
                                "${NumberFormat('#,##0').format(double.parse(data[index]['price']).toInt())} Bath",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: regular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: redColor),
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
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: greyColor,
                thickness: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
