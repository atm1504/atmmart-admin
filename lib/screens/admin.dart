import 'package:atmmartadmin/db/brand.dart';
import 'package:atmmartadmin/db/category.dart';
import 'package:atmmartadmin/screens/add_product.dart';
import 'package:atmmartadmin/utils/utils.dart';
import 'package:flutter/material.dart';

enum Page { dashboard, manage }

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.red;
  MaterialColor selected = Colors.blue;
  var notSelected = Colors.white;
  MaterialColor notActive = Colors.grey;
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  BrandService _brandService = BrandService();
  CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                  child: FlatButton.icon(
                      color: _selectedPage == Page.dashboard
                          ? selected
                          : notSelected,
                      onPressed: () {
                        setState(() => _selectedPage = Page.dashboard);
                      },
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedPage == Page.dashboard
                            ? active
                            : notActive,
                      ),
                      label: Text('Dashboard'))),
              Expanded(
                  child: FlatButton.icon(
                      color:
                          _selectedPage == Page.manage ? selected : notSelected,
                      onPressed: () {
                        setState(() => _selectedPage = Page.manage);
                      },
                      icon: Icon(
                        Icons.sort,
                        color:
                            _selectedPage == Page.manage ? active : notActive,
                      ),
                      label: Text('Manage'))),
            ],
          ),
          elevation: 0.0,
          backgroundColor: Colors.orange[900],
        ),
        body: _loadScreen());
  }

  Widget _loadScreen() {
    switch (_selectedPage) {
      case Page.dashboard:
        return Container(
          color: Colors.orange[100],
          child: Column(
            children: <Widget>[
              ListTile(
                subtitle: FlatButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Icons.attach_money,
                    size: 30.0,
                    color: Colors.green,
                  ),
                  label: Text('12,000',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30.0, color: Colors.green)),
                ),
                title: Text(
                  'Revenue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0, color: Colors.black87),
                ),
              ),
              Expanded(
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Card(
                        child: ListTile(
                            title: FlatButton.icon(
                                onPressed: null,
                                icon: Icon(Icons.people_outline),
                                label: Text("Users")),
                            subtitle: Text(
                              '7',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: active, fontSize: 60.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Card(
                        child: ListTile(
                            title: FlatButton.icon(
                                onPressed: null,
                                icon: Icon(
                                  Icons.category,
                                  size: 15,
                                ),
                                label: Text("Categories")),
                            subtitle: Text(
                              '23',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: active, fontSize: 60.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Card(
                        child: ListTile(
                            title: FlatButton.icon(
                                onPressed: null,
                                icon: Icon(Icons.track_changes),
                                label: Text("Producs")),
                            subtitle: Text(
                              '120',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: active, fontSize: 60.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Card(
                        child: ListTile(
                            title: FlatButton.icon(
                                onPressed: null,
                                icon: Icon(Icons.tag_faces),
                                label: Text("Sold")),
                            subtitle: Text(
                              '13',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: active, fontSize: 60.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Card(
                        child: ListTile(
                            title: FlatButton.icon(
                                onPressed: null,
                                icon: Icon(Icons.shopping_cart),
                                label: Text("Orders")),
                            subtitle: Text(
                              '5',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: active, fontSize: 60.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Card(
                        child: ListTile(
                            title: FlatButton.icon(
                                onPressed: null,
                                icon: Icon(Icons.close),
                                label: Text("Return")),
                            subtitle: Text(
                              '0',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: active, fontSize: 60.0),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case Page.manage:
        return Container(
          color: Colors.yellow[100],
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.add),
                title: Text(
                  "Add Product",
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AddProduct()));
                },
              ),
              Divider(
                color: Colors.red,
              ),
              ListTile(
                leading: Icon(Icons.change_history),
                title: Text("Products List"),
                onTap: () {},
              ),
              Divider(
                color: Colors.red,
              ),
              ListTile(
                leading: Icon(Icons.add_circle),
                title: Text("Add Category"),
                onTap: () {
                  _categoryAlert();
                },
              ),
              Divider(
                color: Colors.red,
              ),
              ListTile(
                leading: Icon(Icons.category),
                title: Text("Category List"),
                onTap: () {},
              ),
              Divider(
                color: Colors.red,
              ),
              ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text("Add Brand"),
                onTap: () {
                  _brandAlert();
                },
              ),
              Divider(
                color: Colors.red,
              ),
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text("Brand list"),
                onTap: () {},
              ),
              Divider(),
            ],
          ),
        );
        break;
      default:
        return Container();
    }
  }

  void _categoryAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _categoryFormKey,
        child: TextFormField(
          controller: categoryController,
          validator: (value) {
            // ignore: missing_return, missing_return
            if (value.length <= 0) {
              return 'Category cannot be empty';
            }
            return null;
          },
          decoration: InputDecoration(hintText: "Add category"),
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              if (categoryController.text.length != 0) {
                _categoryService.createCategory(categoryController.text);
                showLongSuccessToast("Category created successfully");
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                showLongWarningToast("Category field cannot be empty");
              }
            },
            child: Text('ADD')),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  void _brandAlert() {
    var alert = new AlertDialog(
      content: Form(
        key: _brandFormKey,
        child: TextFormField(
          controller: brandController,
          validator: (value) {
            if (value.isEmpty) {
              return 'category cannot be empty';
            }
            return null;
          },
          decoration: InputDecoration(hintText: "add brand"),
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              if (brandController.text.length > 0) {
                _brandService.createBrand(brandController.text);
                Navigator.pop(context);
                showLongSuccessToast("Brand added successfully");
              } else {
                Navigator.pop(context);
                showLongWarningToast("Brand field cannot be empty");
              }
            },
            child: Text('ADD')),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL')),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }
}
