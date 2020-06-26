import 'dart:io';
import 'package:atmmartadmin/db/brand.dart';
import 'package:atmmartadmin/db/category.dart';
import 'package:atmmartadmin/screens/admin.dart';
import 'package:atmmartadmin/utils/colors.dart';
import 'package:atmmartadmin/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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

  // Class initialization
  BrandService _brandService = BrandService();
  CategoryService _categoryService = CategoryService();
  ImagePicker _picker = ImagePicker();

  // Custom input validators
  bool isProductNameOk = true;

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

  void _selectImage(int imageNumber) async {
    PickedFile tempImg = await _picker.getImage(source: ImageSource.gallery);
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

  // First Image box
  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 80),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        File(_image1.path),
        fit: BoxFit.fill,
        width: double.infinity,
      );
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
              height: 210,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide:
                            BorderSide(color: grey.withOpacity(0.8), width: 5),
                        onPressed: () {
                          _selectImage(1);
                        },
                        child: _displayChild1(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide:
                            BorderSide(color: grey.withOpacity(0.8), width: 5),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 80, 20, 80),
                          child: Icon(
                            Icons.add,
                            color: grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide:
                            BorderSide(color: grey.withOpacity(0.8), width: 5),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 80, 20, 80),
                          child: Icon(
                            Icons.add,
                            color: grey,
                          ),
                        ),
                      ),
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'You must enter the product name';
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text('Available Sizes'),
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
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
