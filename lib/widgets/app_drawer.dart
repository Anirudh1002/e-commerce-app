import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/helpers/custom_route.dart';
import 'package:shops_app/providers/auth.dart';
import 'package:shops_app/screens/orders_screen.dart';
import 'package:shops_app/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello Firend!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.shop),
              title: Text('Shop'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              }),
          Divider(),
          ListTile(
              leading: Icon(Icons.payment),
              title: Text('Orders'),
              onTap: () {
                // Navigator.of(context)
                //     .pushReplacementNamed(OrderScreen.routeName);
                Navigator.of(context).pushReplacement(
                    CustomRoute(builder: (ctx) => OrderScreen()));
              }),
          Divider(),
          ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserProductsScreen.routeName);
              }),
          Divider(),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context, listen: false).logout();
              })
        ],
      ),
    );
  }
}
