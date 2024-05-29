// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  late TextEditingController searchController;
  var isFav = false.obs;
  var selectedGender = ''.obs;
  var maxPrice = 999999.0.obs;
  var selectedColors = <int>[].obs;
  var selectedTypes = <String>[].obs;
  var selectedCollections = <String>[].obs;
  var selectedVendorId = ''.obs;

  // get searchController => null;

  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void updateFilters({
    String? gender,
    double? price,
    List<int>? colors,
    List<String>? types,
    List<String>? collections,
    String? vendorId,
  }) {
    if (gender != null) selectedGender.value = gender;
    if (price != null) maxPrice.value = price;
    if (colors != null) selectedColors.value = colors;
    if (types != null) selectedTypes.value = types;
    if (collections != null) selectedCollections.value = collections;
    if (vendorId != null) selectedVendorId.value = vendorId;
  }

  void resetFilters() {
    selectedGender.value = '';
    maxPrice.value = 999999.0;
    selectedColors.clear();
    selectedTypes.clear();
    selectedCollections.clear();
  }


  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  void addToWishlist(Map<String, dynamic> product) {
    FirebaseFirestore.instance
        .collection(productsCollection)
        .where('p_name', isEqualTo: product['p_name'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        List<dynamic> wishlist = doc['p_wishlist'];
        if (!wishlist.contains(currentUser!.uid)) {
          doc.reference.update({
            'p_wishlist': FieldValue.arrayUnion([currentUser!.uid])
          }).then((value) {
            // Update UI or show message
          }).catchError((error) {
            print('Error adding ${product['p_name']} to Favorite: $error');
          });
        }
      }
    });
  }
}
