import 'package:dazz/src/blocs/login/login_bloc.dart';
import 'package:dazz/src/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants.dart';

class SignOutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LogOutSuccessState) {
          showLogin(context);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        if (state is DoLogOutState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return RaisedButton(
              onPressed: () {
                BlocProvider.of<LoginBloc>(context).add(LogOutEvent());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                child: Text(
                  'Salir',
                  textAlign: TextAlign.center,
                ),
                width: size.width * .2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: BorderSide(
                    width: 2, style: BorderStyle.solid, color: dPrimaryColor),
              ),
              elevation: 0.0,
              color: dScaffoldColor);
        }
      }),
    );
  }
}
