import 'dart:io';
import 'package:atmmartadmin/db/brand.dart';
import 'package:atmmartadmin/db/category.dart';
import 'package:atmmartadmin/db/product.dart';
import 'package:atmmartadmin/screens/admin.dart';
import 'package:atmmartadmin/utils/colors.dart';
import 'package:atmmartadmin/utils/constants.dart';
import 'package:atmmartadmin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  // Forms and controllers
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _categorySuggestionController = TextEditingController();
  TextEditingController _brandSuggestionController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  // Class initialization
  BrandService _brandService = BrandService();
  CategoryService _categoryService = CategoryService();
  ProductService _productService = ProductService();
  ImagePicker _picker = ImagePicker();

  // Custom input validators
  bool isProductNameOk = true;
  bool isLoading = false;

  // List of brands and categories
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  List<String> selectedSizes = <String>[];
  String _currentCategory = "";
  String _currentBrand = "";
  PickedFile _image1;
  PickedFile _image2;
  PickedFile _image3;

  @override
  void initState() {
    super.initState();
    _getBrands();
    _getCategories();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(categories[i].data[CATEGORY]),
                value: categories[i].data[CATEGORY]));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].data[BRAND]),
                value: brands[i].data[BRAND]));
      });
    }
    return items;
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data[CATEGORY];
      _categorySuggestionController.text = _currentCategory;
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].data[BRAND];
      _brandSuggestionController.text = _currentBrand;
    });
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() {
      _currentCategory = selectedCategory;
      _categorySuggestionController.text = selectedCategory;
    });
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() {
      _currentBrand = selectedBrand;
      _brandSuggestionController.text = selectedBrand;
    });
  }

  // Product name validation
  productNameChangedController(String name) {
    if (name.length > 20 || name.length == 0) {
      setState(() {
        isProductNameOk = false;
      });
    } else {
      setState(() {
        isProductNameOk = true;
      });
    }
  }

  // For selecting the sizes of the product
  void changeSelectedSize(String size) {
    if (selectedSizes.contains(size)) {
      setState(() {
        selectedSizes.remove(size);
      });
    } else {
      setState(() {
        selectedSizes.insert(0, size);
      });
    }
  }

  // Allows the user to choose the source of image
  void _selectImageSource(int imageNumber) {
    Alert(
      context: context,
      title: "Image Source",
      desc: "Select Image from Gallery or Capture using Camera",
      buttons: [
        DialogButton(
          child: Text(
            "GALLERY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            _selectImage(imageNumber, "gallery");
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "CAMERA",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            _selectImage(imageNumber, "camera");
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  // Select image from file or camera
  void _selectImage(int imageNumber, String sourceFrom) async {
    PickedFile tempImg;
    if (sourceFrom == "gallery") {
      tempImg = await _picker.getImage(source: ImageSource.gallery);
    } else {
      tempImg = await _picker.getImage(source: ImageSource.camera);
    }

    switch (imageNumber) {
      case 1:
        setState(() => _image1 = tempImg);
        break;
      case 2:
        setState(() => _image2 = tempImg);
        break;
      case 3:
        setState(() => _image3 = tempImg);
        break;
    }
  }

// Display image once selected
  Widget _displayChild(PickedFile image) {
    if (image == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 80),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        File(image.path),
        fit: BoxFit.fill,
        width: double.infinity,
        scale: 0.5,
        height: double.infinity,
      );
    }
  }

  Future<void> validateAndUpload() async {
    print("Validate form");
    if (_formKey.currentState.validate()) {
      if (_image1 != null && _image2 != null && _image3 != null) {
        if (selectedSizes.isNotEmpty) {
          print("Inside");
          // Downloadable image link
          String imageUrl1;
          String imageUrl2;
          String imageUrl3;

          // File name
          final String pictureName1 =
              "atm1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          final String pictureName2 =
              "atm2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          final String pictureName3 =
              "atm3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

          final FirebaseStorage storage = FirebaseStorage.instance;
          StorageUploadTask task1 =
              storage.ref().child(pictureName1).putFile(File(_image1.path));
          StorageUploadTask task2 =
              storage.ref().child(pictureName2).putFile(File(_image2.path));
          StorageUploadTask task3 =
              storage.ref().child(pictureName3).putFile(File(_image3.path));

          StorageTaskSnapshot snapshot1 =
              await task1.onComplete.then((value) => value);
          StorageTaskSnapshot snapshot2 =
              await task2.onComplete.then((value) => value);
          task3.onComplete.then((snapshot3) async {
            imageUrl1 = await snapshot1.ref.getDownloadURL();
            imageUrl2 = await snapshot2.ref.getDownloadURL();
            imageUrl3 = await snapshot3.ref.getDownloadURL();
            List<String> imageList = [imageUrl1, imageUrl2, imageUrl3];

            _productService.uploadProduct({
              "name": _productNameController.text,
              "price": double.parse(_priceController.text),
              "sizes": selectedSizes,
              "images": imageList,
              "quantity": int.parse(_quantityController.text),
              "brand": _currentBrand,
              "category": _currentCategory
            });
          }).catchError((err) {
            print(err);
          });
        } else {
          showLongWarningToast("Select at least one size!");
        }
      } else {
        showLongWarningToast("Add all the three images!");
      }
    }
  }

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
        leading: InkWell(
          child: Icon(
            Icons.close,
            color: white,
          ),
          onTap: () {
            Navigator.pop(
                context, MaterialPageRoute(builder: (_) => (Admin())));
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: OutlineButton(
                        borderSide:
                            BorderSide(color: grey.withOpacity(0.8), width: 1),
                        onPressed: () {
//                          _selectImage(1, "gallery");
                          _selectImageSource(1);
                        },
                        child: _displayChild(_image1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(
                              color: grey.withOpacity(0.8), width: 1),
                          onPressed: () {
                            _selectImageSource(2);
                          },
                          child: _displayChild(_image2)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                          borderSide: BorderSide(
                              color: grey.withOpacity(0.8), width: 1),
                          onPressed: () {
                            _selectImageSource(3);
                          },
                          child: _displayChild(_image3)),
                    ),
                  ),
                ],
              ),
            ),
            // TextField to take product name
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Product Name",
                        textAlign: TextAlign.start,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 10),
                        child: Text(
                          "Should be less than 20 characters",
                          style: TextStyle(
                              color: orange900,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  Visibility(
                    visible: !isProductNameOk,
                    child: Text(
                      "Please Enter valid product name",
                      style: TextStyle(color: red, fontSize: 18),
                    ),
                  ),
                  TextFormField(
                    controller: _productNameController,
                    decoration: InputDecoration(
                      hintText: "Product Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: red),
                      ),
                    ),
                    validator: (value) {
                      print(value);
                      if (value.isEmpty) {
                        return "You must enter the product name";
                      } else if (value.length > 20) {
                        return "Product name must be less than 20 characters";
                      }
                    },
                    onChanged: productNameChangedController,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 50,
                color: Colors.amberAccent[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Category: ',
                              style: TextStyle(color: red),
                            ),
                          ),
                          DropdownButton(
                            value: _currentCategory,
                            items: categoriesDropDown,
                            onChanged: changeSelectedCategory,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _categorySuggestionController,
                          autofocus: false,
                          cursorColor: orange900,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                              labelText: "Category Selected",
                              hintText: _currentCategory),
                        ),
                        suggestionsCallback: (pattern) async {
                          return await _categoryService
                              .getCategorySuggestions(pattern);
                        },
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                            elevation: 0.2,
                            borderRadius: BorderRadius.circular(3),
                            color: grey200),
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: Icon(Icons.category),
                            title: Text(suggestion[CATEGORY]),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          setState(() {
                            print(suggestion);
                            _currentCategory = suggestion[CATEGORY];
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 50,
                color: Colors.amberAccent[100],
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Brand: ',
                              style: TextStyle(color: red),
                            ),
                          ),
                          DropdownButton(
                            value: _currentBrand,
                            items: brandsDropDown,
                            onChanged: changeSelectedBrand,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _brandSuggestionController,
                          autofocus: false,
                          cursorColor: orange900,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                              labelText: "Brand Selected",
                              hintText: _currentBrand),
                        ),
                        suggestionsCallback: (pattern) async {
                          return await _brandService
                              .getBrandSuggestions(pattern);
                        },
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                            elevation: 0.2,
                            borderRadius: BorderRadius.circular(3),
                            color: grey200),
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: Icon(Icons.category),
                            title: Text(suggestion[BRAND]),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          setState(() {
                            print(suggestion);
                            _currentBrand = suggestion[BRAND];
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 65,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: '5', labelText: "Quantity"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You must enter the quantity';
                    }
                  },
                ),
              ),
            ),
            Container(
              height: 65,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Rs: ",
                        style: TextStyle(
                            color: red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 12,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: '200', labelText: "Price in Rupees"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter the price';
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
              child: Text(
                'Available Sizes',
                style: TextStyle(
                    color: blue, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),

            Row(
              children: <Widget>[
                Checkbox(
                    value: selectedSizes.contains('XS'),
                    onChanged: (value) => changeSelectedSize('XS')),
                Text('XS'),
                Checkbox(
                    value: selectedSizes.contains('S'),
                    onChanged: (value) => changeSelectedSize('S')),
                Text('S'),
                Checkbox(
                    value: selectedSizes.contains('M'),
                    onChanged: (value) => changeSelectedSize('M')),
                Text('M'),
                Checkbox(
                    value: selectedSizes.contains('L'),
                    onChanged: (value) => changeSelectedSize('L')),
                Text('L'),
                Checkbox(
                    value: selectedSizes.contains('XL'),
                    onChanged: (value) => changeSelectedSize('XL')),
                Text('XL'),
                Checkbox(
                    value: selectedSizes.contains('XXL'),
                    onChanged: (value) => changeSelectedSize('XXL')),
                Text('XXL'),
              ],
            ),

            Row(
              children: <Widget>[
                Checkbox(
                    value: selectedSizes.contains('28'),
                    onChanged: (value) => changeSelectedSize('28')),
                Text('28'),
                Checkbox(
                    value: selectedSizes.contains('30'),
                    onChanged: (value) => changeSelectedSize('30')),
                Text('30'),
                Checkbox(
                    value: selectedSizes.contains('32'),
                    onChanged: (value) => changeSelectedSize('32')),
                Text('32'),
                Checkbox(
                    value: selectedSizes.contains('34'),
                    onChanged: (value) => changeSelectedSize('34')),
                Text('34'),
                Checkbox(
                    value: selectedSizes.contains('36'),
                    onChanged: (value) => changeSelectedSize('36')),
                Text('36'),
                Checkbox(
                    value: selectedSizes.contains('38'),
                    onChanged: (value) => changeSelectedSize('38')),
                Text('38'),
              ],
            ),

            Row(
              children: <Widget>[
                Checkbox(
                    value: selectedSizes.contains('40'),
                    onChanged: (value) => changeSelectedSize('40')),
                Text('40'),
                Checkbox(
                    value: selectedSizes.contains('42'),
                    onChanged: (value) => changeSelectedSize('42')),
                Text('42'),
                Checkbox(
                    value: selectedSizes.contains('44'),
                    onChanged: (value) => changeSelectedSize('44')),
                Text('44'),
                Checkbox(
                    value: selectedSizes.contains('46'),
                    onChanged: (value) => changeSelectedSize('46')),
                Text('46'),
                Checkbox(
                    value: selectedSizes.contains('48'),
                    onChanged: (value) => changeSelectedSize('48')),
                Text('48'),
                Checkbox(
                    value: selectedSizes.contains('50'),
                    onChanged: (value) => changeSelectedSize('50')),
                Text('50'),
              ],
            ),
            Center(
              child: RaisedButton(
                color: red,
                textColor: white,
                child: Text("Add Product"),
                elevation: 1,
                onPressed: () {
                  validateAndUpload();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
