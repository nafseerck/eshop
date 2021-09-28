import 'dart:async';
import 'dart:convert';
import 'Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/Constant.dart';
import 'Helper/SimBtn.dart';
import 'Helper/String.dart';
import 'Model/Model.dart';

class CustomerSupport extends StatefulWidget {
  @override
  _CustomerSupportState createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport> {
  bool _isLoading = true, _isProgress = false;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  List<Model> typeList = [];
  String type, email, title, desc;
  FocusNode nameFocus, emailFocus, descFocus;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final descController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getType();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    descController.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, 'CUSTOMER_SUPPORT'), context),
      body: _isLoading
          ? shimmer()
          : SingleChildScrollView(
              child: Form(
                  key: _formkey,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Card(
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    setType(),
                                    setEmail(),
                                    setTitle(),
                                    setDesc(),
                                    send()
                                  ],
                                ),
                              )),
                        ],
                      ),
                      showCircularProgress(_isProgress, colors.primary),
                    ],
                  ))),
    );
  }

  Widget setType() {
    return DropdownButtonFormField(
      iconEnabledColor: colors.fontColor,
      isDense: true,
      hint: new Text(
        getTranslated(context, 'SELECT_TYPE'),
        style: Theme.of(this.context)
            .textTheme
            .subtitle2
            .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
      ),
      decoration: InputDecoration(
        filled: true,
        isDense: true,
        fillColor: colors.lightWhite,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.fontColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.lightWhite),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      value: type,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      onChanged: (String newValue) {
        if (mounted)
          setState(() {
            type = newValue;
          });
      },
      items: typeList.map((Model user) {
        return DropdownMenuItem<String>(
          value: user.id,
          child: Text(
            user.title,
          ),
        );
      }).toList(),
    );
  }

  void validateAndSubmit() async {
    if (type == null)
      setSnackbar('Please Select Type');
    else if (validateAndSave()) {
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      sendRequest();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
        await buttonController.reverse();
      });
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  bool validateAndSave() {
    final form = _formkey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setEmail() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style:
            TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
        validator: (val) => validateEmail(
            val,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String value) {
          email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus, nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: colors.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setTitle() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        controller: nameController,
        style:
            TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
        validator: (val) =>
            validateField(val, getTranslated(context, 'FIELD_REQUIRED')),
        onSaved: (String value) {
          title = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus, nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'TITLE'),
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: colors.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setDesc() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        focusNode: descFocus,
        controller: descController,
        maxLines: null,
        style:
            TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
        validator: (val) =>
            validateField(val, getTranslated(context, 'FIELD_REQUIRED')),
        onSaved: (String value) {
          desc = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus, nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'DESCRIPTION'),
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: colors.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> getType() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Response response = await post(getTicketApi, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {

          var data = getdata["data"];

          typeList = (data as List)
              .map((data) => new Model.fromSupport(data))
              .toList();
        } else {
          setSnackbar(msg);
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.black),
      ),
      backgroundColor: colors.white,
      elevation: 1.0,
    ));
  }

  send() {
    return SimBtn(
        size: 0.4,
        title: getTranslated(context, 'SEND'),
        onBtnSelected: () {
          validateAndSubmit();
        });
  }

  Future<void> sendRequest() async {
    if (mounted)
      setState(() {
        _isProgress = true;
      });

    try {
      var data = {
        USER_ID: CUR_USERID,
        SUB: title,
        DESC: desc,
        TICKET_TYPE: type,
        EMAIL: email,
      };
      //  if (widget.update) data[ID] = addressList[widget.index].id;

      Response response = await post(addTicketApi,
              //  widget.update ? updateAddressApi : getAddAddressApi,
              body: data,
              headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];

      

        if (mounted)
          setState(() {
            _isProgress = false;
            type = null;
            email = null;
            title = null;
            desc = null;
            emailController.text = "";
            nameController.text = "";
            descController.text = "";
          });

        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
  }
}
