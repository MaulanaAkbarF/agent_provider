import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
// import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_webservice2/places.dart' as places;
import 'package:http/http.dart' as http;

import '../../../constant_values/_constant_text_values.dart';
import '../../../constant_values/_setting_value/log_app_values.dart';
import '../../../constant_values/enum_values.dart';
import '../../../models/_global_widget_model/search_maps.dart';
import '../../../utilities/functions/logger_func.dart';
import '../../../utilities/functions/system_func.dart';
import '../../../utilities/local_storage/sqflite/services/_setting_services/log_app_services.dart';
import '../auth/user_provider.dart';

class GoogleMapsProvider extends ChangeNotifier with WidgetsBindingObserver {
  final BuildContext context;
  final TextEditingController _tecSearch = TextEditingController();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  final LatLng _startLocation = LatLng(-10.0, 118.5); // Biar awalnya nampilin map Indonesia
  bool _isInitialFinished = false;
  bool _isExpanded = true;
  List<SearchMapsData> _options = <SearchMapsData>[];
  GoogleMapsState _mapState = GoogleMapsState.initial;
  MapSearchTechnology _mapSearchTechnology = MapSearchTechnology.openStreet;
  MapType _mapType = MapType.normal;
  bool _isMapsPaused = false;
  CameraPosition? _savedCameraPosition;

  String baseUri = 'https://nominatim.openstreetmap.org';

  GoogleMapsProvider(this.context);

  bool get isInitialFinished => _isInitialFinished;
  bool get isExpanded => _isExpanded;
  TextEditingController get tecSearch => _tecSearch;
  Completer<GoogleMapController> get controllerGoogleMap => _controllerGoogleMap;
  GoogleMapController? get mapController => _mapController;
  GoogleMapsState get mapState => _mapState;
  MapSearchTechnology get mapSearchTechnology => _mapSearchTechnology;
  CameraPosition? get cameraPosition => _cameraPosition;
  LatLng get startLocation => _startLocation;
  MapType get mapType => _mapType;
  List<SearchMapsData> get option => _options;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tecSearch.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused: pauseMaps(); break;
      case AppLifecycleState.resumed: resumeMaps(); break;
      case AppLifecycleState.inactive: break;
      case AppLifecycleState.detached: break;
      case AppLifecycleState.hidden: break;
    }
  }

  Future<void> pauseMaps() async {
    if (_isMapsPaused) return;

    try {
      clog('Pausing Google Maps operations...');
      if (_mapController != null && _cameraPosition != null) {
        _savedCameraPosition = _cameraPosition;
        clog('Camera position saved: ${_savedCameraPosition?.target}');
      }

      _isMapsPaused = true;
      if (_options.length > 50) _options = _options.take(10).toList();
    } catch (e, s) {
      clog('Error pausing maps: $e');
      await addLogApp(level: ListLogAppLevel.critical.level, title: 'Maps Pause Error', logs: '$e\n$s');
    }
  }

  Future<void> resumeMaps() async {
    if (!_isMapsPaused) return;
    try {
      clog('Resuming Google Maps operations...');
      _isMapsPaused = false;
      if (_mapController != null && _savedCameraPosition != null) {
        await Future.delayed(Duration(milliseconds: 100)); // Beri waktu controller siap
        await _mapController!.animateCamera(CameraUpdate.newCameraPosition(_savedCameraPosition!));
        clog('Camera position restored: ${_savedCameraPosition?.target}');
      }
      notifyListeners();
    } catch (e, s) {
      clog('Error resuming maps: $e');
      await addLogApp(level: ListLogAppLevel.critical.level, title: 'Maps Resume Error', logs: '$e\n$s');
    }
  }

  /// Fungsi untuk menetapkan implementasi maps pada platform spesifik
  /// Kode ini opsional, namun katanya dapat meningkatkan performa dengan mengimplementasikan konfigurasi yang sesuai dengan jenis platform
  /// Tapi saat saya implementasikan, jadi ngelag njir, tapi positifnya peringatan-peringatan di log jadi hilang
  void initialize() {
    // final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
    // if (mapsImplementation is GoogleMapsFlutterAndroid) {
    //   mapsImplementation.useAndroidViewSurface = true;
    // }
  }

  /// Fungsi untuk menetapkan Colpleter MapController saat halaman dimuat atau Consumer diperbarui
  void setMapsCompleterController(GoogleMapController controller){
    _controllerGoogleMap.complete(controller);
  }

  /// Fungsi untuk menetapkan MapController saat halaman dimuat atau Consumer diperbarui
  void setMapsController(GoogleMapController controller){
    _mapController = controller;
  }

  /// Fungsi untuk menetapkan posisi kamera saat pointer map digerakkan/berubah lokasi dengan digerakkan
  void setCameraPosition(CameraPosition position){
    _cameraPosition = position;
  }

  /// Fungsi untuk mengatur kondisi/state pada maps
  void setMapsState(GoogleMapsState state){
    if (!_isInitialFinished){
      _isInitialFinished = true;
      return;
    }
    _mapState = state;
    notifyListeners();
  }

  /// Fungsi untuk menampilkan dan menymbunyikan list lokasi yang telah dicari
  void setExpandedList(){
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  /// Fungsi untuk mengganti medan/tampilan dari maps
  void changeMapTerrain(){
    if (_mapType == MapType.normal) {
      _mapType = MapType.satellite;
    } else if (_mapType == MapType.satellite) {
      _mapType = MapType.terrain;
    } else {
      _mapType = MapType.normal;
    }
    notifyListeners();
  }

  /// Fungsi untuk mengganti server untuk pencarian alamat
  void changeSearchMapTechnology(){
    if (_mapSearchTechnology == MapSearchTechnology.openStreet){
      _mapSearchTechnology = MapSearchTechnology.googleMaps;
    } else {
      _mapSearchTechnology = MapSearchTechnology.openStreet;
    }
    notifyListeners();
  }

  /// Fungsi untuk mencari lokasi/alamat dari hasil pencarian alamat oleh pengguna
  Future<List<SearchMapsData>> searchLocation() async {
    if (_tecSearch.text.trim().isEmpty) return [];
    bool conn = await checkInternetConnectivity();
    if (!conn) return [];
    if (_mapSearchTechnology == MapSearchTechnology.openStreet){
      /// Kode berikut akan dijalankan saat pengguna menggunakan pencarion Open Street Map (OSM)
      var client = http.Client();
      try {
        var response = await client.get(Uri.parse('$baseUri/search?q=${_tecSearch.text.trim()}&format=json&polygon_geojson=1&addressdetails=1',), headers: {
          'User-Agent': '$appNameText/1.0 (${UserProvider.read(context).user?.email ?? 'guest@gmail.com'})',
        });
        if (response.statusCode == 200) {
          var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
          _options = decodedResponse.map((e) => SearchMapsData(displayname: e['display_name'] ?? '', lat: double.parse(e['lat'] ?? '0'), lon: double.parse(e['lon'] ?? '0'))).toList();
          return _options;
        } else {
          clog('Gagal mendapatkan daftar lokasi dari OpenStreet.\n${response.body}');
          await addLogApp(level: ListLogAppLevel.severe.level, statusCode: response.statusCode, title: 'Gagal mendapatkan daftar lokasi dari OpenStreet', logs: response.body);
        }
        return [];
      } catch (e, s) {
        clog('Terjadi masalah saat GoogleMapsProvider searchLocationOSM: $e\n$s');
        await addLogApp(level: ListLogAppLevel.severe.level, title: e.toString(), logs: s.toString());
        return [];
      } finally {
        client.close();
        notifyListeners();
      }
    } else {
      /// Kode berikut akan dijalankan saat pengguna menggunakan pencarion Google Maps (G-Maps)
      try {
        final place = places.GoogleMapsPlaces(apiKey: 'AIzaSyBeSIA0J_be66pU5jbsj8Tp-3M1tWnEZTs', apiHeaders: await const GoogleApiHeaders().getHeaders());
        final result = await place.autocomplete(_tecSearch.text.trim(), language: 'id');
        if (result.status == "OK") {
          List<SearchMapsData> googleMapsResults = [];
          /// Batasi maksimal ambil 3 data saja untuk menghemat billing dan gunakan UUID untuk membuat sesi pencarian saat ini
          for (var prediction in result.predictions.take(3)) {
            final detail = await place.getDetailsByPlaceId(prediction.placeId!);
            googleMapsResults.add(SearchMapsData(
              displayname: prediction.description ?? '',
              lat: detail.result.geometry!.location.lat,
              lon: detail.result.geometry!.location.lng,
            ));
          }
          _options = googleMapsResults;
          return _options;
        } else {
          clog('Gagal Mencari Alamat!\nStatus: ${result.status}\nPenyebab: ${result.errorMessage ?? "Unknown error"}');
          await addLogApp(level: ListLogAppLevel.severe.level, statusCode: 500, title: 'Gagal mendapatkan daftar lokasi dari Google Maps API', logs: result.errorMessage ?? '');
          return [];
        }
      } catch (e, s) {
        clog('Terjadi masalah saat GoogleMapsProvider searchLocationGMaps: $e\n$s');
        await addLogApp(level: ListLogAppLevel.severe.level, title: e.toString(), logs: s.toString());
        return [];
      } finally {
        notifyListeners();
      }
    }
  }
}

/*
CATATAN:
Kamu bisa menambahkan fungsi caching untuk request permintaan maps yang sama
Dengan menyimpannya ke dalam local storage atau API
Agar saat user melakukan request yang sama, data diambil dari local storage atau API dan tidak menggunakan google maps
 */