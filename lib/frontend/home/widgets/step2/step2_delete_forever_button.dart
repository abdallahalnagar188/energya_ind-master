import 'package:energya_ind/core/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

InkWell deleteForeverWidget(BuildContext context,
    {void Function()? permDelete}) {
  return InkWell(
    onTap: () {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure?? \n\nWhen you delete it, you will not be able to recover all the changes previously made to it',
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: permDelete,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_forever_outlined,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Deleted Material List',
                            style: TextStyle(color: Colors.redAccent),
                          )
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppStaticColor.primary),
                      ))
                ],
              ),
            );
          });
    },
    child: Container(
      height: 65,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red, width: 3),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_forever_outlined,
            color: Colors.red,
          ),
          SizedBox(width: 10),
          Text(
            'Deleted Material List',
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    ),
  );
}
