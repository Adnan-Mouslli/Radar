import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

void dialogueConfirm(String title , void Function()? onPressed)
{

  Get.dialog(Container(
    width: 200,
    height: 200 ,
    child: CupertinoAlertDialog(
      title: Text(title) , //Text("Are you sure to delete the account ?"),
      actions: [
        TextButton(onPressed: onPressed , child: Text('OK')),
        TextButton(
            onPressed: () {
              Get.back() ;
            },
            child: Text('Cancel')),
      ],
    ),

  )) ;



}