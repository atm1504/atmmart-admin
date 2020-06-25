import 'package:atmmartadmin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange900,
        elevation: 0.2,
        title: Text(
          "Add Product",
          style: TextStyle(color: white),
        ),
        leading: Icon(
          Icons.close,
          color: white,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlineButton(
                    borderSide:
                        BorderSide(color: grey.withOpacity(0.8), width: 5),
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(17, 35, 17, 35),
                      child: Icon(
                        Icons.add,
                        color: grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlineButton(
                    borderSide:
                        BorderSide(color: grey.withOpacity(0.8), width: 5),
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(17, 35, 17, 35),
                      child: Icon(
                        Icons.add,
                        color: grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlineButton(
                    borderSide:
                        BorderSide(color: grey.withOpacity(0.8), width: 5),
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(17, 35, 17, 35),
                      child: Icon(
                        Icons.add,
                        color: grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // TextField to take product name
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 5, 8, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Product Name",
                    textAlign: TextAlign.start,
                  ),
                  TextFormField(
                    controller: productNameController,
                    decoration: InputDecoration(
                      hintText: "Product Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: red),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "You must enter the product name";
                      } else if (value.length > 20) {
                        return "Product name must be less than 20 characters";
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
