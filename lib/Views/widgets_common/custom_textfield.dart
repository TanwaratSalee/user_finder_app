import 'package:flutter_finalproject/consts/consts.dart';

// Widget customPasswordField({
//   required TextEditingController controller,
//   String? label,
// }) {
//   return StatefulBuilder(
//     builder: (context, setState) {
//       bool _isObscured = true;

//       return TextField(
//         controller: controller,
//         obscureText: _isObscured,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(
//             color: Colors.grey,
//             fontSize: 16,
//           ),
//           filled: true,
//           fillColor: whiteColor,
//           contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: Colors.grey,
//               width: 1,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: Colors.grey,
//               width: 1,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: Colors.grey,
//               width: 1,
//             ),
//           ),
//           suffixIcon: IconButton(
//             icon: Icon(
//               _isObscured ? Icons.visibility_off : Icons.visibility,
//               color: Colors.grey,
//             ),
//             onPressed: () {
//               setState(() {
//                 _isObscured = !_isObscured;
//               });
//             },
//           ),
//         ),
//         style: TextStyle(
//           fontSize: 16,
//           color: blackColor,
//         ),
//       );
//     },
//   );
// }

Widget customTextField({
  String? title,
  String? label,
  TextEditingController? controller,
  bool isPass = false,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        obscureText: isPass,
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: const TextStyle(
              color: greyDark, fontFamily: regular, fontSize: 14),
          hintStyle: const TextStyle(
              color: greyDark, fontFamily: regular, fontSize: 12),
          filled: true,
          fillColor: whiteColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: greyLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: greyColor),
          ),
        ),
        style: TextStyle(
          color: blackColor,
          fontSize: 14,
          fontFamily: regular,
        ),
      ),
    ],
  );
}

class CustomTextField2 extends StatefulWidget {
  final String? title;
  final String? label;
  final TextEditingController? controller;
  final bool isPass;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField2({
    Key? key,
    this.title,
    this.label,
    this.controller,
    this.isPass = false,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  _CustomTextField2State createState() => _CustomTextField2State();
}

class _CustomTextField2State extends State<CustomTextField2> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          obscureText: widget.isPass ? _obscureText : false,
          controller: widget.controller,
          readOnly: widget.readOnly,
          obscuringCharacter: '●',
          decoration: InputDecoration(
            isDense: true,
            labelText: widget.label,
            labelStyle: const TextStyle(
                color: greyDark, fontFamily: regular, fontSize: 14),
            hintStyle: const TextStyle(
                color: greyDark, fontFamily: regular, fontSize: 12),
            filled: true,
            fillColor: whiteColor,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: greyLine),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: greyColor),
            ),
            suffixIcon: widget.isPass
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          style: TextStyle(
            color: blackColor,
            fontSize: _obscureText ? 14 : 14,
            fontFamily: regular,
            letterSpacing: _obscureText ? 2 : 1,
          ),
        ),
      ],
    );
  }
}
