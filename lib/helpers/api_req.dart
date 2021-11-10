import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/helpers/misc.dart';
import 'package:get/get.dart';
import '/controllers/zakaz_controller.dart';

//const url = 'http://192.168.0.107:8085/';
//const ip = '230';
const ip = '254';
//const url = 'http://192.168.88.' + ip + ':8085/';
const url = 'http://perevozchik.ml/';
const urlBase = url + 'api/';
//const wsUrl = 'ws://192.168.88.' + ip + '/ws';
const wsUrl = 'ws://perevozchik.ml/ws';
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
  try {
    //cprint('postZakaz $param');
    var response = await http.post(Uri.parse(url), body: param, headers: {
      HttpHeaders.authorizationHeader: 'Bearer EPu4KGqTzDbezKepOuy8BVsxESNQy6y7'
    });

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

Future<int> postUser(Map param) async {
  //await checkConnection();
  // bool internet = await DataConnectionChecker().hasConnection;
  // if (!internet) {
  //   return null;
  // }
  // session.setBool('internet', internet);
  const url = urlBase + 'sensor/device';
  try {
    //cprint('postUser $param');
    var response = await http.post(Uri.parse(url), body: param);

    if (response.statusCode == 2001) {
      // cprint('json getCharts decode response is: ${json.decode(response.body)}');
      var resp = json.decode(response.body);
      if (resp != null && resp is int && resp != 0) {
        return resp;
      } else {
        //session.remove('sensorId');
      }

      //cprint('json postUser: $resp');
    } else {
      cprint('getCharts -get');
    }
  } catch (error) {
    cprint('postUser $error');
  }
  return 0;
}

Future<List> getUserAddresses() async {
  const url = urlBase + 'zakaz/address';
  try {
    //cprint('request getCharts');
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer EPu4KGqTzDbezKepOuy8BVsxESNQy6y7'
    });
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
  try {
    //cprint('request getCurrentOrders');
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer EPu4KGqTzDbezKepOuy8BVsxESNQy6y7'
    });
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

Future<List> getOrders() async {
  //var url = urlBase + 'zakazs?ZakazSearch[status]=1';
  var url = urlBase + 'zakazs?page=${zctr.currentPage}';
  cprint('request getOrders');
  try {
    var response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader: 'Bearer EPu4KGqTzDbezKepOuy8BVsxESNQy6y7'
    });
    if (response.statusCode == 200) {
      //cprint('json getCurrentOrders decode response is: ${json.decode(response.body)}');
      cprint('getOrders length: ${json.decode(response.body).length}');
      response.headers.forEach((name, values) {
        if (name == 'x-pagination-page-count') {
          zctr.xPageCount['zakaz'] = int.parse(values[0]);
        } else if (name == 'x-pagination-current-page') {
          zctr.xCurrentPage['zakaz'] = int.parse(values[0]);
        } else if (name == 'x-pagination-total-count') {
          zctr.xTotalCount['zakaz'] = int.parse(values[0]);
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

Future<int> postAccept(Map param) async {
  const url = urlBase + 'zakaz/accept';
  try {
    //cprint('postZakaz $param');
    var response = await http.post(Uri.parse(url), body: param, headers: {
      HttpHeaders.authorizationHeader: 'Bearer P0or3-vSc_Z_xzLeyQ_0mpiIBtxMQw5x'
    });

    var resp = json.decode(response.body);
    if (response.statusCode == 200) {
      cprint('json postAccept decode response is: $resp');

      return resp;

      //cprint('json postUser: $resp');
    } else {
      cprint('postAccept -error status: ${response.statusCode}, body: $resp');
    }
  } catch (error) {
    cprint('postAccept error: $error');
  }
  return 1;
}
