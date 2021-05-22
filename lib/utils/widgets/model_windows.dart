import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget modelMain(BuildContext context, List<Widget> widgets) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      )),
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return DraggableScrollableActuator(
          child: DraggableScrollableSheet(
              minChildSize: 0.2,
              initialChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, controller) {
                return SingleChildScrollView(
                  controller: controller,
                  child: Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widgets,
                      )),
                );
              }),
        );
      });
}

Widget modelBlock(context, List<Widget> widgets) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return Material(
          child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: MediaQuery.of(context).size.width * 0.85),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets,
              )),
        );
      });
}
