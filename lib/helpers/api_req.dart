import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/helpers/misc.dart';
import 'package:get/get.dart';
import '/controllers/zakaz_controller.dart';

//const url = 'http://192.168.0.102:8085/';
//const wsUrl = 'ws://192.168.0.102:8085/ws';

const url = 'http://192.168.88.230:8085/';
const wsUrl = 'ws://192.168.88.230/ws';

//const url = 'http://perevozchik.ml/';
//const wsUrl = 'ws://perevozchik.ml/ws';

const urlBase = url + 'api/';
final ZakazController zctr = Get.find<ZakazController>();

Future<List> getCategories() async {
  const url = urlBase + 'zakaz/category';
  try {
    //cprint('request getCharts');
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      //cprint('json getCategories decode response is: ${json.decode(response.body)}');
      cprint('json getCategories length: ${json.decode(response.body).length}');

      return json.decode(response.body);
    } else {
      cprint('getCategories -error status: ${response.statusCode}');
    }
  } catch (error) {
    cprint('getCategories error: $error');
  }
  return [];
}

Future<Map> postZakaz(Map param) async {
  const url = urlBase + 'zakazs';
  var authkey = prefBox.get('authKey');
  try {
    //cprint('postZakaz $param');
    var response = await http.post(Uri.parse(url),
        body: param,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $authkey'});

    var resp = json.decode(response.body);
    if (response.statusCode == 201) {
      cprint('json postZakaz decode response is: $resp');
      if (resp != null && resp is Map && resp.isNotEmpty) {
        return resp;
      } else {
        //session.remove('sensorId');
      }

      //cprint('json postUser: $resp');
    } else {
      cprint('postZakaz -error status: ${response.statusCode}, body: $resp');
    }
  } catch (error) {
    cprint('postZakaz error: $error');
  }
  return {};
}

Future postUser(Map param) async {
  //await checkConnection();
  // bool internet = await DataConnectionChecker().hasConnection;
  // if (!internet) {
  //   return null;
  // }
  // session.setBool('internet', internet);
  const url = urlBase + 'zakaz/auth';
  try {
    cprint('postUser params: $param');
    var response = await http.post(Uri.parse(url), body: param);

    cprint('json postUser statusCode: ${response.statusCode}');
    if (response.statusCode == 200) {
      cprint('json postUser: ${json.decode(response.body)}');
      var resp = json.decode(response.body);
      if (resp != null) {
        return resp;
      }
      //cprint('json postUser: $resp');
    }
  } catch (error) {
    cprint('postUser $error');
  }
  return null;
}

Future<List> getUserAddresses() async {
  const url = urlBase + 'zakaz/address';
  var authkey = prefBox.get('authKey');
  try {
    //cprint('request getCharts');
    var response = await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $authkey'});
    if (response.statusCode == 200) {
      //cprint('json getCategories decode response is: ${json.decode(response.body)}');
      cprint('json getUserAddresses: ${json.decode(response.body)}');

      return json.decode(response.body);
    } else {
      cprint('getUserAddresses -error status: ${response.statusCode}');
    }
  } catch (error) {
    cprint('getUserAddresses error: $error');
  }
  return [];
}

Future<List> getCurrentOrders() async {
  const url = urlBase + 'zakaz/inprogress';
  var authkey = prefBox.get('authKey');
  try {
    //cprint('request getCurrentOrders');
    var response = await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $authkey'});
    if (response.statusCode == 200) {
      //cprint('json getCurrentOrders decode response is: ${json.decode(response.body)}');
      cprint(
          'json getCurrentOrders length: ${json.decode(response.body).length}');

      return json.decode(response.body);
    } else {
      cprint('getCurrentOrders -error status: ${response.statusCode}');
    }
  } catch (error) {
    cprint('getCurrentOrders error: $error');
  }
  return [];
}

Future<List> getOrders({String params = '', String forwho = 'zakaz'}) async {
  var curPg = zctr.currentPage;
  if (forwho == 'myOrders') {
    curPg = zctr.currentPageMy;
  }
  var url = urlBase + 'zakaz/list?page=$curPg';
  if (params != '') {
    url += '&$params';
  }
  var authkey = prefBox.get('authKey');
  //cprint('request getOrders $url, $authkey');
  try {
    var response = await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $authkey'});
    if (response.statusCode == 200) {
      //cprint('json getCurrentOrders decode response is: ${json.decode(response.body)}');
      cprint('getOrders $params length: ${json.decode(response.body).length}');
      response.headers.forEach((name, values) {
        if (name == 'x-pagination-page-count') {
          zctr.xPageCount[forwho] = int.parse(values[0]);
        } else if (name == 'x-pagination-current-page') {
          zctr.xCurrentPage[forwho] = int.parse(values[0]);
        } else if (name == 'x-pagination-total-count') {
          zctr.xTotalCount[forwho] = int.parse(values[0]);
        }
      });

      return json.decode(response.body);
    } else {
      cprint('getOrders -error status: ${response.statusCode}');
    }
  } catch (error) {
    cprint('getOrders error: $error');
  }
  return [];
}

Future<bool> postServiceman(Map param) async {
  var authkey = prefBox.get('authKey');
  const url = urlBase + 'zakaz/serviceman';
  try {
    //cprint('postUser $param');
    var response = await http.post(Uri.parse(url),
        body: param,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $authkey'});

    cprint('json postServiceman statusCode: ${response.statusCode}');
    if (response.statusCode == 200) {
      cprint('json postServiceman: ${json.decode(response.body)}');
      var resp = json.decode(response.body);
      if (resp != null) {
        return resp;
      }
      //cprint('json postUser: $resp');
    }
  } catch (error) {
    cprint('postUser $error');
  }
  return false;
}

Future getProfile() async {
  const url = urlBase + 'zakaz/serviceman';
  var authkey = prefBox.get('authKey');
  try {
    //cprint('request getProfile');
    var response = await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $authkey'});
    if (response.statusCode == 200) {
      //cprint('json getCategories decode response is: ${json.decode(response.body)}');
      return json.decode(response.body);
    } else {
      cprint('getProfile -error status: ${response.statusCode}');
    }
  } catch (error) {
    cprint('getProfile error: $error');
  }
  return null;
}

Future<int> postAction(String action, Map param) async {
  var url = urlBase + 'zakaz/$action';
  var authkey = prefBox.get('authKey');
  try {
    //cprint('postAction $param');
    var response = await http.post(Uri.parse(url),
        body: param,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $authkey'});

    var resp = json.decode(response.body);
    if (response.statusCode == 200) {
      cprint('json postAction $action resp: $resp');

      return resp;

      //cprint('json postUser: $resp');
    } else {
      cprint('postAction -error status: ${response.statusCode}, body: $resp');
    }
  } catch (error) {
    cprint('postAction error: $error');
  }
  return 1;
}

Future<int> getStatus(int id) async {
  var url = urlBase + 'zakaz/status?id=$id';
  try {
    //cprint('request getCharts');
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      //cprint('json getCategories decode response is: ${json.decode(response.body)}');
      return json.decode(response.body);
    } else {
      cprint('getStatus -error statusCode: ${response.statusCode}');
    }
  } catch (error) {
    cprint('getStatus error: $error');
  }
  return 0;
}

void postTest(Map params) async {
  var url = urlBase + 'zakaz/test';
  //var authkey = prefBox.get('authKey');
  try {
    //cprint('postAction $param');
    var response = await http.post(Uri.parse(url), body: params);

    var resp = json.decode(response.body);
    if (response.statusCode == 200) {
      cprint('json postTest resp: $resp');

      //cprint('json postUser: $resp');
    } else {
      cprint('postTest -error status: ${response.statusCode}, body: $resp');
    }
  } catch (error) {
    cprint('postTest error: $error');
  }
}

void postLocation(Map params) async {
  var url = urlBase + 'zakaz/locstream';
  //var authkey = prefBox.get('authKey');
  try {
    cprint('postLocation $params');
    var response = await http.post(Uri.parse(url), body: params);

    var resp = json.decode(response.body);
    if (response.statusCode == 200) {
      cprint('json postLocation resp: $resp');

      //cprint('json postUser: $resp');
    } else {
      cprint('postLocation -error status: ${response.statusCode}, body: $resp');
    }
  } catch (error) {
    cprint('postLocation error: $error');
  }
}
