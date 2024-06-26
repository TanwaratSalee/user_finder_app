import 'package:get/get.dart';
import 'package:flutter_finalproject/Views/widgets_common/tapButton.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:flutter_finalproject/controllers/product_controller.dart';

class MatchPostProduct extends StatefulWidget {
  final Map<String, dynamic> topProduct;
  final Map<String, dynamic> lowerProduct;

  MatchPostProduct({
    required this.topProduct,
    required this.lowerProduct,
  });

  @override
  _MatchPostProductState createState() => _MatchPostProductState();
}

class _MatchPostProductState extends State<MatchPostProduct> {
  final ProductController controller = Get.find<ProductController>();
  final TextEditingController explanationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isSelectedAll = controller.selectedGender.value == 'all';
    bool isSelectedMen = controller.selectedGender.value == 'men';
    bool isSelectedWomen = controller.selectedGender.value == 'women';
    bool isSelectedSummer = controller.selectedCollections.contains('summer');
    bool isSelectedWinter = controller.selectedCollections.contains('winter');
    bool isSelectedAutumn = controller.selectedCollections.contains('autumn');
    bool isSelectedDinner = controller.selectedCollections.contains('dinner');
    bool isSelectedEveryday =
        controller.selectedCollections.contains('everydaylook');

    return WillPopScope(
      onWillPop: () async {
        resetSelections();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Match Your Outfit'),
        ),
        bottomNavigationBar: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 35),
            child: tapButton(
              color: primaryApp,
              title: 'Post',
              textColor: whiteColor,
              onPress: () {
                if (validateInputs()) {
                  controller.addPostByUserMatch(
                    widget.topProduct['name'],
                    widget.lowerProduct['name'],
                    context,
                    controller.selectedGender.value,
                    List.from(controller.selectedCollections),
                    explanationController.text,
                    widget.topProduct['product_id'],
                    widget.lowerProduct['product_id'],
                  );
                  resetSelections();
                }
              },
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildProductImage(widget.topProduct['imgs'], 'Top'),
                        SizedBox(width: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryApp,
                              ),
                            ),
                            Icon(
                              Icons.add,
                              size: 24,
                              color: whiteColor,
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                        buildProductImage(widget.lowerProduct['imgs'], 'Lower'),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: buildGenderSelector(
                      isSelectedAll: isSelectedAll,
                      isSelectedMen: isSelectedMen,
                      isSelectedWomen: isSelectedWomen,
                      onAllSelected: (isSelected) {
                        setState(() {
                          isSelectedAll = isSelected;
                          if (isSelected) {
                            isSelectedMen = false;
                            isSelectedWomen = false;
                            controller.selectedGender.value = 'all';
                          } else if (!isSelectedMen && !isSelectedWomen) {
                            controller.selectedGender.value = '';
                          }
                        });
                      },
                      onMenSelected: (isSelected) {
                        setState(() {
                          isSelectedMen = isSelected;
                          if (isSelected) {
                            isSelectedAll = false;
                            isSelectedWomen = false;
                            controller.selectedGender.value = 'men';
                          } else if (!isSelectedAll && !isSelectedWomen) {
                            controller.selectedGender.value = '';
                          }
                        });
                      },
                      onWomenSelected: (isSelected) {
                        setState(() {
                          isSelectedWomen = isSelected;
                          if (isSelected) {
                            isSelectedAll = false;
                            isSelectedMen = false;
                            controller.selectedGender.value = 'women';
                          } else if (!isSelectedAll && !isSelectedMen) {
                            controller.selectedGender.value = '';
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: buildCollectionSelector(
                      isSelectedSummer: isSelectedSummer,
                      isSelectedWinter: isSelectedWinter,
                      isSelectedAutumn: isSelectedAutumn,
                      isSelectedDinner: isSelectedDinner,
                      isSelectedEveryday: isSelectedEveryday,
                      onSummerSelected: (isSelected) {
                        setState(() {
                          isSelectedSummer = isSelected;
                          updateCollection('summer', isSelected);
                        });
                      },
                      onWinterSelected: (isSelected) {
                        setState(() {
                          isSelectedWinter = isSelected;
                          updateCollection('winter', isSelected);
                        });
                      },
                      onAutumnSelected: (isSelected) {
                        setState(() {
                          isSelectedAutumn = isSelected;
                          updateCollection('autumn', isSelected);
                        });
                      },
                      onDinnerSelected: (isSelected) {
                        setState(() {
                          isSelectedDinner = isSelected;
                          updateCollection('dinner', isSelected);
                        });
                      },
                      onEverydaySelected: (isSelected) {
                        setState(() {
                          isSelectedEveryday = isSelected;
                          updateCollection('everydaylook', isSelected);
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Explain clothing matching",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: medium,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: explanationController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter your explanation here',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Color.fromRGBO(240, 240, 240, 1),
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: regular,
                            color: blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProductImage(dynamic imageUrl, String label) {
    if (imageUrl is List && imageUrl.isNotEmpty && imageUrl[0] is String) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Container(
              width: 140,
              height: 150,
              color: whiteColor,
              child: Center(
                child:
                    Image.network(imageUrl[0]), // ใช้เฉพาะ URL ตัวแรกจาก List
              ).box.border(color: greyLine).rounded.make(),
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontFamily: regular,
            ),
          ),
        ],
      );
    } else {
      print('Error: Expected a String but got ${imageUrl.runtimeType}');
      return Column(
        children: [
          Text('Invalid image URL'),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontFamily: regular,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: Container(
            width: 140,
            height: 150,
            color: whiteColor,
            child: Center(
              child: Image.network(imageUrl),
            ).box.border(color: greyLine).rounded.make(),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontFamily: regular,
          ),
        ),
      ],
    );
  }

  void resetSelections() {
    setState(() {
      controller.selectedGender.value = '';
      controller.selectedCollections.clear();
      explanationController.clear();
    });
  }

  void updateCollection(String collection, bool isSelected) {
    setState(() {
      if (isSelected) {
        controller.selectedCollections.add(collection);
      } else {
        controller.selectedCollections.remove(collection);
      }
    });
  }

  bool validateInputs() {
    if (controller.selectedGender.value.isEmpty) {
      showSnackbar('Please select a suitable gender.');
      return false;
    }
    if (controller.selectedCollections.isEmpty) {
      showSnackbar('Please select a collection suitable for the outfit.');
      return false;
    }
    return true;
  }

  void showSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget buildGenderSelector({
    required bool isSelectedAll,
    required bool isSelectedMen,
    required bool isSelectedWomen,
    required Function(bool) onAllSelected,
    required Function(bool) onMenSelected,
    required Function(bool) onWomenSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          "Suitable for gender",
          style: TextStyle(
            fontSize: 16,
            fontFamily: medium,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildFilterChip("All", isSelectedAll, onAllSelected),
            SizedBox(width: 5),
            buildFilterChip("Men", isSelectedMen, onMenSelected),
            SizedBox(width: 5),
            buildFilterChip("Women", isSelectedWomen, onWomenSelected),
          ],
        ),
      ],
    );
  }

  Widget buildCollectionSelector({
    required bool isSelectedSummer,
    required bool isSelectedWinter,
    required bool isSelectedAutumn,
    required bool isSelectedDinner,
    required bool isSelectedEveryday,
    required Function(bool) onSummerSelected,
    required Function(bool) onWinterSelected,
    required Function(bool) onAutumnSelected,
    required Function(bool) onDinnerSelected,
    required Function(bool) onEverydaySelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          "Collection",
          style: TextStyle(fontSize: 16, fontFamily: medium),
        ),
        SizedBox(height: 8),
        Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 1,
            children: [
              buildFilterChip("Summer", isSelectedSummer, onSummerSelected),
              buildFilterChip("Winter", isSelectedWinter, onWinterSelected),
              buildFilterChip("Autumn", isSelectedAutumn, onAutumnSelected),
              buildFilterChip("Dinner", isSelectedDinner, onDinnerSelected),
              buildFilterChip(
                  "Everydaylook", isSelectedEveryday, onEverydaySelected),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFilterChip(
      String label, bool isSelected, Function(bool) onSelected) {
    final BorderSide borderSide = BorderSide(
      color: isSelected ? primaryApp : greyLine,
      width: 2.0,
    );

    return TextButton(
      onPressed: () => onSelected(!isSelected),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? thinPrimaryApp : whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderSide,
        ),
        minimumSize: Size(105, 40),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        splashFactory: NoSplash.splashFactory,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: isSelected ? medium : regular,
          color: greyColor,
        ),
      ),
    );
  }
}
