import 'package:energya_ind/frontend/home/widgets/text_feilds.dart';
import 'package:flutter/material.dart';

Widget step2SearchWidget({
  required TextEditingController controller,
  void Function(String)? onChanged,
  void Function()? onClose,
}) {
  return TextFeild(
    hintText: 'Search on Marks....',
    prefixIcon: Icons.note_add,
    controller: controller,
    alpha: .1,
    suffix: IconButton(
      onPressed: onClose,
      icon: const Icon(
        Icons.close,
        color: Colors.redAccent,
      ),
    ),
    onChanged: onChanged,
  );
}
