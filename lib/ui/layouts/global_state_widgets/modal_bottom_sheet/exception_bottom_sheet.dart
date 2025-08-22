import 'package:agent/core/constant_values/assets_values.dart';
import 'package:agent/core/services/http_services/exceptions.dart';
import 'package:agent/ui/layouts/global_state_widgets/modal_bottom_sheet/regular_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';

void showExceptionModalBottomSheet(BuildContext context, Exception? e) async {
  String? title;
  String? description;
  String? imagePath;

  if (e is NetworkException) {
    title = 'Yaah, Koneksi kamu putus';
    description = 'Kita nggak bisa nyambung ke internet. Cek dulu sinyal atau WiFi kamu ya, habis itu coba lagi.';
    imagePath = exceptionNoInternet;
  } else if (e is ComingsoonException) {
    title = 'Maaf, Lagi ada pembaruan';
    description = 'Sistem baru diupdate biar makin lancar jaya. Tungguin bentar ya, aplikasinya bakal makin gercep.';
    imagePath = exceptionComingsoon;
  } else if (e is TimeoutException) {
    title = 'Prosesnya butuh waktu lama';
    description = 'Kayaknya proses ini butuh lebih banyak waktu. Coba refresh atau tunggu sebentar, ya. ';
    imagePath = exceptionTimeOut;
  } else if (e is ServerErrorException) {
    title = 'Ups… Sistemnya Nge-freeze!';
    description = 'Aplikasi tiba-tiba berhenti. Data kamu aman, kok. Coba buka lagi, ya.';
    imagePath = exceptionServerError;
  } else if (e is UnprocessableEntityException) {
    title = 'Hmm, Data kamu gak ketemu';
    description = 'Sepertinya data yang kamu cari belum ada. Coba cek lagi atau coba pencarian lainnya.';
    imagePath = exceptionNoData;
  } else {
    title = 'Maaf, sepertinya terjadi masalah :(';
    description = 'Maaf atas ketidaknyamannya ya! Kami akan mencoba memperbaiki';
    imagePath = exceptionNoData;
  }

  await showRegularBottomSheet<void>(
      context: context,
      title: title,
      description: description,
      imagePath: imagePath,
      onTap: () async => Navigator.canPop(context)
  );
}