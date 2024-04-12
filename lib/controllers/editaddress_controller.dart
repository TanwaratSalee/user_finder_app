import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_finalproject/Views/widgets_common/custom_textfield.dart';
import 'package:flutter_finalproject/Views/widgets_common/our_button.dart';
import 'package:flutter_finalproject/consts/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class editaddress_controller extends StatefulWidget {
  final String documentId;
  final String firstname;
  final String surname;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String phone;

  editaddress_controller({
    Key? key,
    required this.documentId,
    required this.firstname,
    required this.surname,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.phone,
  }) : super(key: key);

  @override
  _editaddressFormState createState() => _editaddressFormState();
}

class _editaddressFormState extends State<editaddress_controller> {
  late TextEditingController _firstnameController;
  late TextEditingController _surnameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: widget.firstname);
    _surnameController = TextEditingController(text: widget.surname);
    _addressController = TextEditingController(text: widget.address);
    _cityController = TextEditingController(text: widget.city);
    _stateController = TextEditingController(text: widget.state);
    _postalCodeController = TextEditingController(text: widget.postalCode);
    _phoneController = TextEditingController(text: widget.phone);
  }

Future<void> updateAddressForCurrentUser() async {
  try {
    // Get the current user's document reference
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Get the current user's address data
      final userData = await userRef.get();
      final List<dynamic>? addressesList = userData.data()?['address'];

      if (addressesList is List) {
        // Find the index of the address to be updated
        final index = addressesList.indexWhere((address) {
          return address['firstname'] == widget.firstname &&
              address['surname'] == widget.surname &&
              address['address'] == widget.address &&
              address['city'] == widget.city &&
              address['state'] == widget.state &&
              address['postalCode'] == widget.postalCode &&
              address['phone'] == widget.phone;
        });

        if (index != -1) {
          // Update the address at the found index
          addressesList[index] = {
            'firstname': _firstnameController.text,
            'surname': _surnameController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'postalCode': _postalCodeController.text,
            'phone': _phoneController.text,
          };

          // Update the user document with the modified addresses list
          await userRef.update({'address': addressesList});

          // Show a message or perform any other action after update if necessary
          VxToast.show(context, msg: "Suscessful save Address");
          Navigator.pop(context);
        } else {
          print('Address not found');
          // Handle case where address to be updated is not found
        }
      } else {
        print('No address data found');
        // Handle case where no address data is found for the user
      }
    } else {
      print('User not logged in');
      // Handle case where no user is logged in
    }
  } catch (error) {
    print('Failed to update address: $error');
    // Handle error as needed
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title:
            "Edit Address".text.fontFamily(regular).color(greyDark2).make(),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: ourButton(
          onPress: () {
          updateAddressForCurrentUser();
            },
            color: primaryApp,
            textColor: whiteColor,
            title: "Save"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            customTextField(
                label: "Firstname",
                isPass: false,
                readOnly: false,
                controller: _firstnameController),
            customTextField(
                label: "Surname",
                isPass: false,
                readOnly: false,
                controller: _surnameController),
            customTextField(
                label: "Address",
                isPass: false,
                readOnly: false,
                controller: _addressController),
            customTextField(
                label: "City",
                isPass: false,
                readOnly: false,
                controller: _cityController),
            customTextField(
                label: "State",
                isPass: false,
                readOnly: false,
                controller: _stateController),
            customTextField(
                label: "Postal Code",
                isPass: false,
                readOnly: false,
                controller: _postalCodeController),
            customTextField(
                label: "Phone",
                isPass: false,
                readOnly: false,
                controller: _phoneController),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}