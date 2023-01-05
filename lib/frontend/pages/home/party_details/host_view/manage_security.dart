import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';

class ManageSecurity extends StatefulWidget {
  final List guestNames;
  final List security;
  final SharedPrefData sharedPrefData;

  const ManageSecurity({Key key, this.guestNames, this.sharedPrefData, this.security}) : super(key: key);
  @override
  _ManageSecurityState createState() => _ManageSecurityState();
}

class _ManageSecurityState extends State<ManageSecurity> {
  List securityListBuilder;
  final successSnackbar = SnackBar(content: Text('success', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);
  bool editMode = false;
  List<bool> _isChecked;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    securityListBuilder = widget.security;
    _isChecked = List<bool>.filled(widget.security.length, false);
  }



  updateListBuilder(newList) => setState(() {
    securityListBuilder = newList;
    _isChecked = List<bool>.filled(newList.length, false);
  });




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("manage security"),),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  List tempList = [];
                  widget.guestNames.forEach((element) {
                    if(securityListBuilder == null ? widget.security.contains(element) : securityListBuilder.contains(element) ){
                    }else {
                      tempList.add(element);
                    }
                  });
                  showSearch(
                      context: context,
                      delegate: SearchGuestsForSecurity(
                        currSecurity: widget.security,
                          guestNames: tempList, plotCode: widget.sharedPrefData.plotCode,
                      updateListBuilder: updateListBuilder,
                  )
                  );
                },
                child: Ink(
                  height: 100,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.black),
                      borderRadius:
                      BorderRadius.all(Radius.circular(15))),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                      Align(
                        child: Icon(Icons.add, color: Colors.white,),
                        alignment: Alignment.centerLeft,
                      ),
                      SizedBox(width: 10,),
                      Align(
                        child: Text(
                          "add security",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Text(widget.security.length == 0 ? "no security yet" : "current security", style: TextStyle(
                fontSize: 32,color: Colors.white, fontWeight: FontWeight.bold
              ),),
              Text("security has the power to view each guest's background info and scan guests into the party.", textAlign: TextAlign.center, style: TextStyle(
                fontSize: 12, color: Colors.white
              ),),
              Container(child: Divider(thickness: 2,),
              padding: EdgeInsets.only(left: 10, right: 10),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: securityListBuilder == null ? widget.security.length : securityListBuilder.length,
                  itemBuilder: (BuildContext context, int index) {
                    if(index == 0){
                     return Row(children: [
                    editMode ? Checkbox(
                      side: BorderSide(
                        width: 3,
                        color: Colors.white
                      ),
                    value: _isChecked[index],
                    checkColor: Colors.white,
                    onChanged: (val) {
                    setState(
                    () {
                    _isChecked[index] = val;
                     },
                     );
                     },
                    ) : Container(),
                      Container(
                      padding: EdgeInsets.all(16),
                    child: Text("${securityListBuilder == null ? widget.security[index] : securityListBuilder[index]}", style: TextStyle(
                    fontSize: 20
                    ),)
                    ),
                        Expanded(child: Container(),),
                       editMode? IconButton(icon: Icon(Icons.delete, color: Colors.red,), color: Colors.red, onPressed: (){
                         bool atLeastOneChecked = false;
                         _isChecked.forEach((element) {
                           if (element){
                             atLeastOneChecked = true;
                           }
                         });
                         if (editMode == true && atLeastOneChecked) {
                           FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                           for(var i = 0; i < _isChecked.length; i++){
                             if (_isChecked[i]){
                               firestoreFunctions.removeSecurity(widget.sharedPrefData.plotCode, widget.security[i]);
                               setState(() {
                                 widget.security.removeAt(i);
                               });
                             }
                           }
                           ScaffoldMessenger.of(context).showSnackBar(
                               successSnackbar);
                         }
                         setState(() {
                           editMode = !editMode;
                         });
                       },) : Container(),
                       IconButton(icon: Icon(Icons.edit, color: Colors.white,),color: Color(0xff1e1e1e),
                       onPressed: (){
                         setState(() {
                           editMode = !editMode;
                         });
                       },
                       )
                      ],);
                    } else {
                      return Row(
                        children: [
                          editMode ? Checkbox(
                            side: BorderSide(
                                width: 3,
                                color: Colors.white
                            ),
                            value: _isChecked[index],
                            checkColor: Colors.white,
                            onChanged: (val) {
                              setState(
                                    () {
                                  _isChecked[index] = val;
                                },
                              );
                            },
                          ) : Container(),
                          Container(
                              padding: EdgeInsets.all(16),
                              child: Text("${securityListBuilder == null ? widget
                                  .security[index] : securityListBuilder[index]}",
                                style: TextStyle(
                                    fontSize: 20
                                ),)
                          ),
                        ],
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}


class SearchGuestsForSecurity extends SearchDelegate<String> {
  final successSnackbar = SnackBar(content: Text('success', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);
  final List guestNames;
  final List currSecurity;
  final Function updateListBuilder;
  final String plotCode;

  List<dynamic> recentSearches = [];

  SearchGuestsForSecurity({this.guestNames, this.plotCode,this.currSecurity, this.updateListBuilder});

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for Appbar
    return [
//      IconButton(
//        icon: Icon(Icons.clear),
//        onPressed: () {
//          query = "";
//        },
//      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSearches
        : guestNames.where((p) => p.startsWith(query)).toList();
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSearches
        : guestNames
        .where((p) => p.toUpperCase().startsWith(query.toUpperCase()))
        .toList();

    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) =>  ListTile(
          onTap: () {
                      query = '${suggestionList[index]}';
                      FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                      firestoreFunctions.addSecurity(plotCode, query);
                      ScaffoldMessenger.of(context).showSnackBar(
                          successSnackbar);
                      List tempList = []..addAll(currSecurity);
                      tempList.add(query);
                      Navigator.pop(context);
                      updateListBuilder(tempList);

          },
          title: RichText(
            text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: TextStyle(
                    color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 20),
                children: [
                  TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 20 ),
                    text: suggestionList[index].substring(query.length,suggestionList[index].length),
                  )
                ]),
          ),
        ));
  }
}

