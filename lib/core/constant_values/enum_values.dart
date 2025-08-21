enum GoogleMapsState {
  initial("Mengisiasi..."),
  loading("Mencari Alamat..."),
  success("Alamat Ditemukan!"),
  failed("Alamat Tidak Ditemukan!"),
  onSearch("Mencari Alamat");

  final String text;
  const GoogleMapsState(this.text);
}

enum MapSearchTechnology {
  openStreet("Cari Lokasi (OSM)"),
  googleMaps("Cari Lokasi (G-Maps)");

  final String text;
  const MapSearchTechnology(this.text);
}