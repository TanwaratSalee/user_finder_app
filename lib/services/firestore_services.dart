import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreServices {
  //get users data
  static getUser(uid) {
    return firestore
        .collection(usersCollection)
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  //get products according to collection
  static getProducts(collection) {
    return firestore
        .collection(productsCollection)
        .where('collection', isEqualTo: collection)
        .snapshots();
  }

  static void updateDocumentCart(String docId, Map<String, dynamic> data) {
    FirebaseFirestore.instance.collection('cart').doc(docId).update(data);
  }

  static void deleteDocumentCart(String docId) {
    FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }

  static getSubCollectionProducts(title) {
    return firestore
        .collection(productsCollection)
        .where('subcollection', isEqualTo: title)
        .snapshots();
  }

  //get cart

  static Stream<QuerySnapshot> getCart(String userId) {
    return FirebaseFirestore.instance
        .collection('cart')
        .where('added_by', isEqualTo: userId)
        .snapshots();
  }

  //get address
  static getAddress(uid) {
    return firestore
        .collection(usersCollection)
        .where('address', isEqualTo: uid)
        .snapshots();
  }

  // delete document
  static deleteDocument(docId) {
    return firestore.collection(cartCollection).doc(docId).delete();
  }

  static getChatMessages(docId) {
    return firestore
        .collection(chatsCollection)
        .doc(docId)
        .collection(messagesCollection)
        .orderBy('created_on', descending: false)
        .snapshots();
  }

  static Stream<QuerySnapshot> getAllChatMessages(String docId) {
    return FirebaseFirestore.instance
        .collection(chatsCollection)
        .doc(docId)
        .collection(messagesCollection)
        .orderBy('created_on', descending: false)
        .snapshots();
  }

  static getAllOrders() {
    return firestore
        .collection(ordersCollection)
        .where('order_by', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  static getFavorite() {
    return firestore
        .collection(productsCollection)
        .where('favorite_uid', arrayContains: currentUser!.uid)
        .snapshots();
  }

  static getUserMatchFavorite() {
    return firestore
        .collection('usermatchfavorite')
        .where('favorite_uid', arrayContains: currentUser!.uid)
        .snapshots();
  }

  static Stream<List<QuerySnapshot>> getFavoriteusermixmatchs() {
    return CombineLatestStream.list([
      FirebaseFirestore.instance
          .collection('usermixandmatch')
          .where('favorite_userid',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      FirebaseFirestore.instance
          .collection('storemixandmatchs')
          .where('favorite_userid',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
    ]);
  }

  static getAllMessages() {
    return firestore
        .collection(chatsCollection)
        .where('user_id', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  static getCounts() async {
    var res = await Future.wait([
      firestore
          .collection(cartCollection)
          .where('added_by', isEqualTo: currentUser!.uid)
          .get()
          .then((value) {
        return value.docs.length;
      }),
      firestore
          .collection(productsCollection)
          .where('favorite_uid', arrayContains: currentUser!.uid)
          .get()
          .then((value) {
        return value.docs.length;
      }),
      firestore
          .collection(ordersCollection)
          .where('order_by', isEqualTo: currentUser!.uid)
          .get()
          .then((value) {
        return value.docs.length;
      }),
    ]);
    return res;
  }

  static allproducts() {
    return firestore.collection(productsCollection).snapshots();
  }

  static allmatchbystore() {
    return firestore.collection(vendorsCollection).snapshots();
  }

  static getFeaturedProducts() {
    return firestore
        .collection(productsCollection)
        .where('is_featured', isEqualTo: true)
        .get();
  }

  static searchProducts(title) {
    return firestore.collection(productsCollection).get();
  }

  //get vendors
  static getVendor(uid) {
    return firestore
        .collection(vendorsCollection)
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  static getReviews(String productId) {
    return FirebaseFirestore.instance
        .collection(reviewsCollection)
        .where('productId', isEqualTo: productId)
        .snapshots();
  }
}
