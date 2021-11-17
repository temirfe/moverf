import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mover/helpers/api_req.dart';
import '/controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import '/helpers/misc.dart';
import '/widgets/my_widgets.dart';
import '/models/profile_model.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final ZakazController zctr = Get.find<ZakazController>();

  final _formKey = GlobalKey<FormState>();

  final tcName = TextEditingController();
  final tcPlate = TextEditingController();
  final tcMark = TextEditingController();
  final tcColor = TextEditingController();
  Profile? prof;

  @override
  void initState() {
    super.initState();
    prof = zctr.prof;
    if (prof != null) {
      if (prof!.ctgParentId != null) {
        zctr.formCtgParId.value = prof!.ctgParentId!;
        zctr.formCtgChilId.value = prof!.ctgId;
      } else {
        zctr.formCtgParId.value = prof!.ctgId;
      }
      if (prof!.user['name'] != null) {
        tcName.text = prof!.user['name'];
      }
      if (prof!.vehicle != null) {
        tcPlate.text = prof!.vehicle!['plate'];
        tcMark.text = prof!.vehicle!['mark'];
        tcColor.text = prof!.vehicle!['color'];
      }
    }
  }

  @override
  void dispose() {
    tcName.dispose();
    tcPlate.dispose();
    tcMark.dispose();
    tcColor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль'), centerTitle: true),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(horizpad),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                name(),
                const SizedBox(height: 20),
                txt2('Категория'),
                ctgParDrop(),
                const SizedBox(height: 5),
                ctgChilDrop(),
                vehicle(),
                const SizedBox(height: 20),
                submitBtn()
              ],
            )),
      ),
    );
  }

  Widget name() {
    return TextFormField(
      //maxLength: 13,
      //autofocus: true,
      controller: tcName,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.sentences,
      //textInputAction: TextInputAction.done,
      decoration:
          const InputDecoration(hintText: 'Имя', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Напишите имя';
        }
        return null;
      },
      onChanged: (text) {
        zctr.profileFormIsDirty(true);
      },
    );
  }

  Widget vehicle() {
    return Obx(() {
      if (zctr.formCtgChilId.value == 0) {
        return const SizedBox();
      }
      return Column(children: [
        const SizedBox(height: 10),
        plate(),
        const SizedBox(height: 10),
        markmodel(),
        const SizedBox(height: 10),
        color()
      ]);
    });
  }

  Widget plate() {
    return TextFormField(
      //maxLength: 13,
      //autofocus: true,
      controller: tcPlate,
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
          labelText: 'Госномер', border: OutlineInputBorder()),
      validator: (value) {
        if (zctr.formCtgParId.value != 5 && (value == null || value.isEmpty)) {
          return 'Поле не должно быть пустым';
        }
        return null;
      },
      onChanged: (text) {
        zctr.profileFormIsDirty(true);
      },
    );
  }

  Widget markmodel() {
    return TextFormField(
      //maxLength: 13,
      //autofocus: true,
      controller: tcMark,
      //focusNode: myFocusNode,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
          hintText: 'Марка и модель', border: OutlineInputBorder()),
      validator: (value) {
        if (zctr.formCtgParId.value != 5 && (value == null || value.isEmpty)) {
          return 'Поле не должно быть пустым';
        }
        return null;
      },
      onChanged: (text) {
        zctr.profileFormIsDirty(true);
      },
    );
  }

  Widget color() {
    return TextFormField(
      //maxLength: 13,
      //autofocus: true,
      controller: tcColor,
      //focusNode: myFocusNode,
      keyboardType: TextInputType.text,
      //textInputAction: TextInputAction.done,
      decoration:
          const InputDecoration(hintText: 'Цвет', border: OutlineInputBorder()),
      validator: (value) {
        if (zctr.formCtgParId.value != 5 && (value == null || value.isEmpty)) {
          return 'Поле не должно быть пустым';
        }
        return null;
      },
      onChanged: (text) {
        zctr.profileFormIsDirty(true);
      },
    );
  }

  Widget ctgParDrop() {
    //cprint('build ctgParDrop');
    var items = <DropdownMenuItem<int>>[];
    return Obx(() {
      //cprint('build ctgParDrop obx');
      var ddVal = zctr.formCtgParId.value;
      if (items.isEmpty) {
        for (Map c in zctr.categories) {
          if (c['parent_id'] == null) {
            if (ddVal == 0) {
              ddVal = c['id']; //make first ctg selected
            }
            items.add(DropdownMenuItem<int>(
              value: c['id'],
              child: Text(c['title']),
            ));
          }
        }
      }
      return DropdownButton<int>(
        isExpanded: true,
        underline: const SizedBox(),
        value: ddVal,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 6,
        onChanged: (int? v) {
          zctr.formCtgParId.value = v!;
        },
        items: items,
      );
    });
  }

  Widget ctgChilDrop() {
    //cprint('build ctgChilDrop');
    return Obx(() {
      var items = <DropdownMenuItem<int>>[];
      var ddVal = zctr.formCtgChilId.value;
      var pid = zctr.formCtgParId.value;
      //cprint('build ctgChilDrop obx $items');
      for (Map c in zctr.categories) {
        if (pid == 0) {
          if (c['parent_id'] == null) {
            pid = c['id'];
          }
        }
        if (c['parent_id'] == pid) {
          //make first ctg selected if ddVal is 0 or is not child of current parent
          if (ddVal == 0 || !zctr.parentChild[pid]!.contains(ddVal)) {
            ddVal = c['id'];
            Future.delayed(const Duration(milliseconds: 300), () {
              zctr.formCtgChilId.value = c['id'];
            });
          }
          Widget itm = Text(c['title']);
          if (c['description'] != null && c['description'] != '') {
            itm =
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['title']),
              txt2(c['description']),
            ]);
          }
          items.add(DropdownMenuItem<int>(
            value: c['id'],
            child: itm,
          ));
        }
      }
      if (items.isEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          zctr.formCtgChilId.value = 0;
        });
        return Container();
      }
      return DropdownButton<int>(
        isExpanded: true,
        underline: const SizedBox(),
        elevation: 6,
        value: ddVal,
        icon: const Icon(Icons.arrow_drop_down),
        onChanged: (int? v) {
          zctr.formCtgChilId.value = v!;
        },
        items: items,
      );
    });
  }

  Widget submitBtn() {
    return Obx(() {
      if (!zctr.profileFormIsDirty.value) {
        return const SizedBox();
      }
      if (zctr.isSubmittingProfile.value) {
        return MyWid.txtBtn(
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
            () {});
      }
      void onpressed() async {
        if (_formKey.currentState!.validate()) {
          var ctgId = zctr.formCtgChilId.value;
          if (ctgId == 0) {
            ctgId = zctr.formCtgParId.value;
          }
          var param = {
            'name': tcName.text,
            'Serviceman[category_id]': ctgId.toString(),
            'Serviceman[vehicle_color]': tcColor.text,
            'Serviceman[vehicle_mark]': tcMark.text,
            'Serviceman[plate]': tcPlate.text,
          };
          zctr.isSubmittingProfile(true);
          var res = await postServiceman(param);
          cprint('res $res');
          zctr.isSubmittingProfile(false);
          if (res) {
            zctr.profileFormIsDirty(false);
            Get.snackbar('Сохранено', '');
          }
        }
      }

      return MyWid.txtBtn('Сохранить', onpressed);
    });
  }
}
