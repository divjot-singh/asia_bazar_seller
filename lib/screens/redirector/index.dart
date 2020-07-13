import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/state.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Redirector extends StatefulWidget {
  @override
  _RedirectorState createState() => _RedirectorState();
}

class _RedirectorState extends State<Redirector> {
  @override
  void initState() {
    BlocProvider.of<UserDatabaseBloc>(context).add(CheckIfAdmin());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<UserDatabaseBloc, Map>(
        listener: (context, currentState) {
          var state = currentState['userstate'];
          if (state is UserIsNotAdmin) {
            Navigator.pushReplacementNamed(context, Constants.USER_NOT_ADMIN);
          } else if (state is UserIsAdmin) {
            Navigator.pushReplacementNamed(context, Constants.HOME);
          }
        },
        child: BlocBuilder<UserDatabaseBloc, Map>(
          builder: (context, currentState) {
            var state = currentState['userstate'];
            if (state is GlobalErrorState) {
              return PageErrorView();
            }
            return Container(
              color: ColorShades.white,
              //decoration: BoxDecoration(gradient: Gradients.greenGradient),
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: PageFetchingViewWithLightBg(),
              ),
            );
          },
        ),
      ),
    );
  }
}
