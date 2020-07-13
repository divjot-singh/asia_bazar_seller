
import 'package:asia_bazar_seller/blocs/item_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/utils/deboucer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchItems extends StatefulWidget {
  @override
  _SearchItemsState createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> {
  ThemeData theme;
  ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();
  var scrollHeight = 0;
  bool showScrollUp = false;
  bool isFetching = false;
  Debouncer _debouncer = Debouncer();
  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    searchItems('');
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _debouncer = null;
    super.dispose();
  }

  scrollListener() {
    setState(() {
      showScrollUp = _scrollController.position.pixels >
          MediaQuery.of(context).size.height;
    });

    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        isFetching != true) {
      _fetchMoreItems();
    }
  }

  _fetchMoreItems() {
    var state =
        BlocProvider.of<ItemDatabaseBloc>(context).state['searchListing'];
    if (state is SearchListingFetched) {
      var listing = state.searchItems;
      DocumentSnapshot lastItem = listing[listing.length - 1];
      BlocProvider.of<ItemDatabaseBloc>(context).add(SearchAllItems(
          query: _textController.text,
          callback: (listing) {
            setState(() {
              isFetching = false;
            });
            if (listing is List && listing.length == 0) {
              _scrollController.removeListener(scrollListener);
            }
          },
          startAt: lastItem));
      setState(() {
        isFetching = true;
      });
    }
  }

  void searchItems(query) {
    setState(() {
      showScrollUp = false;
    });
    query = query.toLowerCase();
    _debouncer.run(() {
      BlocProvider.of<ItemDatabaseBloc>(context)
          .add(SearchAllItems(query: query));
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {
        
        return Container();
      }),
    );
  }
}
